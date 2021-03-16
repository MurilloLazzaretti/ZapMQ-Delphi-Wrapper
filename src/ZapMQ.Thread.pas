unit ZapMQ.Thread;

interface

uses
  System.Classes, ZapMQ.Core, ZapMQ.handler, ZapMQ.Message.JSON, SyncObjs,
  Generics.Collections, ZapMQ.Message.RPC, ZapMQ.Queue;

type
  TEventRPCExpired = procedure(const pMessage : TZapJSONMessage) of object;

  TZapMQThread = class(TThread)
  private
    FEvent : TEvent;
    FCore : TZapMQ;
    FPriority : TZapMQQueuePriority;
    FWaitTime : Cardinal;
    FIsProcessing: Boolean;
    FSafeStop: Boolean;
    procedure SetIsProcessing(const Value: Boolean);
    procedure SetSafeStop(const Value: Boolean);
  public
    property IsProcessing : Boolean read FIsProcessing write SetIsProcessing;
    property SafeStop : Boolean read FSafeStop write SetSafeStop;
    property QueuePriority : TZapMQQueuePriority read FPriority;
    procedure Execute; override;
    procedure Stop;
    constructor Create(const pCore : TZapMQ; const pPriority : TZapMQQueuePriority); overload;
    destructor Destroy; override;
  end;

  TZapMQRPCThread = class(TThread)
  private
    FEvent : TEvent;
    FCore : TZapMQ;
    FEventRPCExpired : TEventRPCExpired;
    FRPCMessages : TObjectList<TZapRPCMessage>;
    FIsProcessing: boolean;
    FSafeStop: boolean;
    procedure SetEventRPCExpired(const Value: TEventRPCExpired);
    procedure SetIsProcessing(const Value: boolean);
    procedure SetSafeStop(const Value: boolean);
  public
    property IsProcessing : boolean read FIsProcessing write SetIsProcessing;
    property SafeStop : boolean read FSafeStop write SetSafeStop;
    property SyncEvent : TEvent read FEvent write FEvent;
    property EventRPCExpired : TEventRPCExpired read FEventRPCExpired write SetEventRPCExpired;
    procedure Execute; override;
    procedure Stop;
    constructor Create(const pHost: string; const pPort : Word;
      const pRPCMessages : TObjectList<TZapRPCMessage>); overload;
    destructor Destroy; override;
  end;

  const
    LOW_PRIORITY = 1000;
    MEDIUM_LOW_PRIORITY = 750;
    MEDIUM_PRIORITY = 500;
    MEDIUM_HIGH_PRIORITY = 250;
    HIGH_PRIORITY = 100;

implementation

uses
  JSON, System.SysUtils, System.Threading;

{ TZapMQThread }

constructor TZapMQThread.Create(const pCore : TZapMQ; const pPriority : TZapMQQueuePriority);
begin
  inherited Create(True);
  FCore := pCore;
  FPriority := pPriority;
  FSafeStop := False;
  case FPriority of
    mqpHigh: FWaitTime := HIGH_PRIORITY;
    mqpMediumHigh: FWaitTime := MEDIUM_HIGH_PRIORITY;
    mqpMedium: FWaitTime := MEDIUM_PRIORITY;
    mqpMediumLow: FWaitTime := MEDIUM_LOW_PRIORITY;
    mqpLow: FWaitTime := LOW_PRIORITY;
  end;
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
  RPCAnswer : TJSONObject;
begin
  inherited;
  while not Terminated do
  begin
    for Queue in FCore.Queues do
    begin
      if not FIsProcessing and not FSafeStop then
      begin
        if Queue.Priority = FPriority then
        begin
          JSONMessage := FCore.GetMessage(Queue.Name);
          if Assigned(JSONMessage) then
          begin
            try
              FIsProcessing := True;
              RPCAnswer := Queue.Handler(JSONMessage, FIsProcessing);
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
        end
      end;
    end;
    FEvent.ResetEvent;
    FEvent.WaitFor(FWaitTime);
  end;
end;

procedure TZapMQThread.SetIsProcessing(const Value: Boolean);
begin
  FIsProcessing := Value;
end;

procedure TZapMQThread.SetSafeStop(const Value: Boolean);
begin
  FSafeStop := Value;
end;

procedure TZapMQThread.Stop;
begin
  Terminate;
  FEvent.SetEvent;
  while not Terminated do ;
end;

{ TZapMQRPCThread }

constructor TZapMQRPCThread.Create(const pHost: string; const pPort : Word;
  const pRPCMessages : TObjectList<TZapRPCMessage>);
begin
  inherited Create(True);
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
      if not FIsProcessing and not FSafeStop then
      begin
        ZapMessage := FRPCMessages[i];
        Response := FCore.GetRPCResponse(ZapMessage.QueueName, ZapMessage.JSONMessage.Id);
        if Response <> string.Empty then
        begin
          RPCAnswer := TJSONObject.ParseJSONValue(
            TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
          try
            ZapMessage.Handler(RPCAnswer, FIsProcessing);
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
              FRPCMessages.Remove(ZapMessage);
            end;
          end;
        end;
      end;
    end;
    if FRPCMessages.Count = 0 then FEvent.ResetEvent else Sleep(50);
    FEvent.WaitFor(INFINITE);
  end;
end;

procedure TZapMQRPCThread.SetEventRPCExpired(const Value: TEventRPCExpired);
begin
  FEventRPCExpired := Value;
end;

procedure TZapMQRPCThread.SetIsProcessing(const Value: boolean);
begin
  FIsProcessing := Value;
end;

procedure TZapMQRPCThread.SetSafeStop(const Value: boolean);
begin
  FSafeStop := Value;
end;

procedure TZapMQRPCThread.Stop;
begin
  Terminate;
  FEvent.SetEvent;
  while not Terminated do ;
end;

end.
