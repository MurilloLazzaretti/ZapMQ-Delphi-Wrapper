unit ZapMQ.Wrapper;

interface

uses
  ZapMQ.Core, ZapMQ.Thread, ZapMQ.Handler, JSON, Generics.Collections,
  System.Classes, ZapMQ.Message.RPC;

type
  TZapMQWrapper = class
  private
    FCore : TZapMQ;
    FThread : TZapMQThread;
    FRPCThread : TZapMQRPCThread;
    FRPCMessages : TObjectList<TZapRPCMessage>;
    FOnRPCExpired: TEventRPCExpired;
    procedure SetOnRPCExpired(const Value: TEventRPCExpired);
  public
    property OnRPCExpired : TEventRPCExpired read FOnRPCExpired write SetOnRPCExpired;
    function SendMessage(const pQueueName : string; const pMessage : TJSONObject;
      const pTTL : Word = 0) : boolean;
    function SendRPCMessage(const pQueueName : string; const pMessage : TJSONObject;
      const pHandler : TZapMQHandlerRPC; const pTTL : Word = 0) : boolean;
    procedure Bind(const pQueueName : string; const pHandler : TZapMQHanlder);
    procedure UnBind(const pQueueName : string);
    function IsBinded(const pQueueName : string) : boolean;
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
  if pQueueName <> string.Empty then
  begin
    Queue := TZapMQQueue.Create;
    Queue.Name := pQueueName;
    Queue.Handler := pHandler;
    FCore.Queues.Add(Queue);
  end
  else
    raise Exception.Create('You cannot bind an unnamed Queue');
end;

constructor TZapMQWrapper.Create(const pHost: string; const pPort: integer);
begin
  FCore := TZapMQ.Create(pHost, pPort);
  FRPCMessages := TObjectList<TZapRPCMessage>.Create(True);
  FThread := TZapMQThread.Create(FCore);
  FThread.Start;
  FRPCThread := TZapMQRPCThread.Create(pHost, pPort, FRPCMessages);
  FRPCThread.Start;
end;

destructor TZapMQWrapper.Destroy;
begin
  FRPCThread.Stop;
  FThread.Stop;
  FRPCMessages.Free;
  FCore.Free;
  inherited;
end;

function TZapMQWrapper.IsBinded(const pQueueName: string): boolean;
var
  Queue : TZapMQQueue;
begin
  Result := False;
  for Queue in FCore.Queues do
  begin
    if Queue.Name = pQueueName then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TZapMQWrapper.SendMessage(const pQueueName: string;
  const pMessage: TJSONObject; const pTTL: Word): boolean;
var
  ZapMessage : TZapJSONMessage;
begin
  if pQueueName = string.Empty then
    raise Exception.Create('Inform the Queue name');
  if not IsBinded(pQueueName) then
  begin
    ZapMessage := TZapJSONMessage.Create;
    try
      ZapMessage.Body := TJSONObject.ParseJSONValue(
        TEncoding.ASCII.GetBytes(pMessage.ToString), 0) as TJSONObject;
      ZapMessage.RPC := False;
      ZapMessage.TTL := pTTL;
      try
        FCore.SendMessage(pQueueName, ZapMessage);
        Result := True;
      except
        Result := False;
      end;
    finally
      ZapMessage.Free;
    end;
  end
  else
    raise Exception.Create('You cannot send message to a Queue self binded');
end;

function TZapMQWrapper.SendRPCMessage(const pQueueName : string; const pMessage : TJSONObject;
  const pHandler : TZapMQHandlerRPC; const pTTL : Word = 0) : boolean;
var
  JSONMessage : TZapJSONMessage;
  ZapRPCMessage : TZapRPCMessage;
begin
  if pQueueName = string.Empty then
    raise Exception.Create('Inform the Queue name');
  if not IsBinded(pQueueName) then
  begin
    JSONMessage := TZapJSONMessage.Create;
    JSONMessage.Body := TJSONObject.ParseJSONValue(
      TEncoding.ASCII.GetBytes(pMessage.ToString), 0) as TJSONObject;
    JSONMessage.RPC := True;
    JSONMessage.TTL := pTTL;
    try
      JSONMessage.Id := FCore.SendMessage(pQueueName, JSONMessage);
      if JSONMessage.Id <> string.Empty then
      begin
        FRPCThread.EventRPCExpired := FOnRPCExpired;
        ZapRPCMessage := TZapRPCMessage.Create(JSONMessage, pHandler, pQueueName);
        FRPCMessages.Add(ZapRPCMessage);
        Result := True;
      end
      else
      begin
        JSONMessage.Free;
        Result := False;
      end;
    except
      JSONMessage.Free;
      Result := False;
    end;
  end
  else
    raise Exception.Create('You cannot send message to a Queue self binded');
end;

procedure TZapMQWrapper.SetOnRPCExpired(const Value: TEventRPCExpired);
begin
  FOnRPCExpired := Value;
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
