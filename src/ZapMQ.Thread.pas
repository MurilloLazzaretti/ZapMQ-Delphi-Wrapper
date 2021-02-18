unit ZapMQ.Thread;

interface

uses
  System.Classes, ZapMQ.Core, ZapMQ.handler, ZapMQ.Message.JSON;

type
  TEventRPCExpired = procedure(const pMessage : TZapJSONMessage) of object;

  TZapMQThread = class(TThread)
  private
    FCore : TZapMQ;
  public
    procedure Execute; override;
    constructor Create(const pCore : TZapMQ); overload;
  end;

  TZapMQRPCThread = class(TThread)
  private
    FCore : TZapMQ;
    FHandler : TZapMQHandlerRPC;
    FMessage : TZapJSONMessage;
    FQueueName : string;
    FTTL : Word;
    FBirthTime : Cardinal;
    FEventRPCExpired : TEventRPCExpired;
    function IsExpired : boolean;
  public
    procedure Execute; override;
    constructor Create(const pHost: string; const pPort : Word; const pHandler : TZapMQHandlerRPC;
      const pMessage : TZapJSONMessage; const pQueueName : string; const pEventRPCExpired : TEventRPCExpired;
      const pTTL : Word = 0); overload;
    destructor Destroy; override;
  end;

implementation

uses
  ZapMQ.Queue, JSON, System.SysUtils;

{ TZapMQThread }

constructor TZapMQThread.Create(const pCore : TZapMQ);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FCore := pCore;
end;

procedure TZapMQThread.Execute;
var
  Queue : TZapMQQueue;
  JSONMessage : TZapJSONMessage;
  ProcessingMessage : boolean;
  RPCAnswer : TJSONObject;
begin
  inherited;
  ProcessingMessage := False;
  while not Terminated do
  begin
    if not ProcessingMessage then
    begin
      for Queue in FCore.Queues do
      begin
        JSONMessage := FCore.GetMessage(Queue.Name);
        if Assigned(JSONMessage) then
        begin
          ProcessingMessage := True;
          try
            RPCAnswer := Queue.Handler(JSONMessage, ProcessingMessage);
            if Assigned(RPCAnswer) and (JSONMessage.RPC) then
            begin
              try
                FCore.SendRPCResponse(Queue.Name, JSONMessage.Id, RPCAnswer.ToString);
              finally
                RPCAnswer.Free;
              end;
            end;
          finally
            JSONMessage.Free;
          end;
        end;
      end;
    end;
    Sleep(100);
  end;
end;

{ TZapMQRPCThread }

constructor TZapMQRPCThread.Create(const pHost: string; const pPort : Word;
  const pHandler : TZapMQHandlerRPC; const pMessage : TZapJSONMessage;
  const pQueueName : string; const pEventRPCExpired : TEventRPCExpired;
  const pTTL : Word = 0);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FCore := TZapMQ.Create(pHost, pPort);
  FHandler := pHandler;
  FMessage := pMessage;
  FQueueName := pQueueName;
  FTTL := pTTL;
  FBirthTime := GetTickCount;
  FEventRPCExpired := pEventRPCExpired;
end;

destructor TZapMQRPCThread.Destroy;
begin
  FCore.Free;
  inherited;
end;

procedure TZapMQRPCThread.Execute;
var
  Response : string;
  RPCAnswer : TJSONObject;
begin
  inherited;
  while (Response = String.Empty) and (not IsExpired) and (not Terminated) do
  begin
    Response := FCore.GetRPCResponse(FQueueName, FMessage.Id);
    if Response <> string.Empty then
    begin
      RPCAnswer := TJSONObject.ParseJSONValue(
        TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
      try
        FHandler(RPCAnswer);
      finally
        RPCAnswer.Free;
      end;
    end;
    Sleep(100);
  end;
  if (Response = String.Empty) and (IsExpired) then
  begin
    if Assigned(FEventRPCExpired) then
      FEventRPCExpired(FMessage);
  end;
end;

function TZapMQRPCThread.IsExpired: boolean;
begin
  Result := (FTTL > 0) and ((FBirthTime + FTTL) < GetTickCount);
end;

end.
