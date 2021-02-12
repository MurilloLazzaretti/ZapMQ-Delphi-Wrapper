unit ZapMQ.Wrapper;

interface

uses
  ZapMQ.Core, ZapMQ.Thread, ZapMQ.Handler, JSON;

type
  TZapMQWrapper = class
  private
    FCore : TZapMQ;
    FThread : TZapMQThread;
  public
    function SendMessage(const pQueueName : string; const pMessage : TJSONObject;
      const pTTL : Word = 0) : boolean;
    function SendRPCMessage(const pQueueName : string; const pMessage : TJSONObject;
      const pHandler : TZapMQHandlerRPC; const pTTL : Word = 0;
      const pTimeout : Word = 0) : boolean;
    procedure Bind(const pQueueName : string; const pHandler : TZapMQHanlder);
    procedure UnBind(const pQueueName : string);
    constructor Create(const pHost : string; const pPort : integer); overload;
    destructor Destroy; override;
  end;

implementation

uses
  ZapMQ.Queue, ZapMQ.Message.JSON, System.SysUtils;

{ TZapMQWrapper }

procedure TZapMQWrapper.Bind(const pQueueName: string;
  const pHandler: TZapMQHanlder);
var
  Queue : TZapMQQueue;
begin
  Queue := TZapMQQueue.Create;
  Queue.Name := pQueueName;
  Queue.Handler := pHandler;
  FCore.Queues.Add(Queue);
end;

constructor TZapMQWrapper.Create(const pHost: string; const pPort: integer);
begin
  FCore := TZapMQ.Create(pHost, pPort);
  FThread := TZapMQThread.Create(FCore);
  FThread.Start;
end;

destructor TZapMQWrapper.Destroy;
begin
  FThread.Terminate;
  while not FThread.Finished do;
  FCore.Free;
  inherited;
end;

function TZapMQWrapper.SendMessage(const pQueueName: string;
  const pMessage: TJSONObject; const pTTL: Word): boolean;
var
  JSONMessage : TZapJSONMessage;
begin
  try
    JSONMessage := TZapJSONMessage.Create;
    JSONMessage.Body := TJSONObject.ParseJSONValue(
      TEncoding.ASCII.GetBytes(pMessage.ToString), 0) as TJSONObject;
    JSONMessage.RPC := False;
    JSONMessage.TTL := pTTL;
    FCore.SendMessage(pQueueName, JSONMessage);
    Result := True;
  except
    Result := False;
  end;
end;

function TZapMQWrapper.SendRPCMessage(const pQueueName : string; const pMessage : TJSONObject;
  const pHandler : TZapMQHandlerRPC; const pTTL : Word = 0;
  const pTimeout : Word = 0) : boolean;
var
  JSONMessage : TZapJSONMessage;
  MessageId : string;
  ResponseThread : TZapMQRPCThread;
begin
  try
    JSONMessage := TZapJSONMessage.Create;
    JSONMessage.Body := TJSONObject.ParseJSONValue(
      TEncoding.ASCII.GetBytes(pMessage.ToString), 0) as TJSONObject;
    JSONMessage.RPC := True;
    JSONMessage.TTL := pTTL;
    JSONMessage.Timeout := pTimeout;
    MessageId := FCore.SendMessage(pQueueName, JSONMessage);
    ResponseThread := TZapMQRPCThread.Create(FCore, pHandler, MessageId, pQueueName);
    ResponseThread.Start;
    Result := True;
  except
    Result := False;
  end;
end;

procedure TZapMQWrapper.UnBind(const pQueueName: string);
var
  Queue : TZapMQQueue;
begin
  Queue := FCore.FindQueue(pQueueName);
  if Assigned(Queue) then
    FCore.Queues.Remove(Queue);
end;

end.
