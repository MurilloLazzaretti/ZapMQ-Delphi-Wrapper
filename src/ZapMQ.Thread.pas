unit ZapMQ.Thread;

interface

uses
  System.Classes, ZapMQ.Core, ZapMQ.handler, ZapMQ.Message.JSON, SyncObjs,
  Generics.Collections, ZapMQ.Message.RPC;

type
  TEventRPCExpired = procedure(const pMessage : TZapJSONMessage) of object;

  TZapMQThread = class(TThread)
  private
    FEvent : TEvent;
    FCore : TZapMQ;
  public
    procedure Execute; override;
    procedure Stop;
    constructor Create(const pCore : TZapMQ); overload;
    destructor Destroy; override;
  end;

  TZapMQRPCThread = class(TThread)
  private
    FEvent : TEvent;
    FCore : TZapMQ;
    FEventRPCExpired : TEventRPCExpired;
    FRPCMessages : TObjectList<TZapRPCMessage>;
    procedure SetEventRPCExpired(const Value: TEventRPCExpired);
  public
    property EventRPCExpired : TEventRPCExpired read FEventRPCExpired write SetEventRPCExpired;
    procedure Execute; override;
    procedure Stop;
    constructor Create(const pHost: string; const pPort : Word;
      const pRPCMessages : TObjectList<TZapRPCMessage>); overload;
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
  FEvent := TEvent.Create(nil, True, False, '');
end;

destructor TZapMQThread.Destroy;
begin
  FEvent.Free;
  inherited;
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
    if not (FEvent.WaitFor(100) = wrTimeout) then
    begin
      Terminate;
    end;
  end;
end;

procedure TZapMQThread.Stop;
begin
  FEvent.SetEvent;
  while not Terminated do ;
end;

{ TZapMQRPCThread }

constructor TZapMQRPCThread.Create(const pHost: string; const pPort : Word;
  const pRPCMessages : TObjectList<TZapRPCMessage>);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FCore := TZapMQ.Create(pHost, pPort);
  FEvent := TEvent.Create(nil, True, False, '');
  FRPCMessages := pRPCMessages;
end;

destructor TZapMQRPCThread.Destroy;
begin
  FCore.Free;
  FEvent.Free;
  inherited;
end;

procedure TZapMQRPCThread.Execute;
var
  Response : string;
  RPCAnswer : TJSONObject;
  ZapMessage : TZapRPCMessage;
  i : integer;
begin
  inherited;
  while not Terminated do
  begin
    for i := Pred(FRPCMessages.Count) downto 0 do
    begin
      ZapMessage := FRPCMessages[i];
      Response := FCore.GetRPCResponse(ZapMessage.QueueName, ZapMessage.JSONMessage.Id);
      if Response <> string.Empty then
      begin
        RPCAnswer := TJSONObject.ParseJSONValue(
          TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
        try
          ZapMessage.Handler(RPCAnswer);
          FRPCMessages.Remove(ZapMessage);
        finally
          RPCAnswer.Free;
        end;
      end
      else
      begin
        if ZapMessage.IsExpired then
        begin
          if Assigned(FEventRPCExpired) then
          begin
            FEventRPCExpired(ZapMessage.JSONMessage);
          end;
          FRPCMessages.Remove(ZapMessage);
        end;
      end;
    end;
    if not (FEvent.WaitFor(100) = wrTimeout) then
    begin
      Terminate;
    end;
  end;
end;

procedure TZapMQRPCThread.SetEventRPCExpired(const Value: TEventRPCExpired);
begin
  FEventRPCExpired := Value;
end;

procedure TZapMQRPCThread.Stop;
begin
  if Assigned(FEvent) then
    FEvent.SetEvent;
  while not Terminated do ;
end;

end.
