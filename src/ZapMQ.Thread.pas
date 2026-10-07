unit ZapMQ.Thread;

interface

uses
  System.Classes, ZapMQ.Core, ZapMQ.Handler, ZapMQ.Message.JSON, SyncObjs,
  Generics.Collections, ZapMQ.Message.RPC, ZapMQ.Queue, System.SysUtils;

type
  TEventRPCExpired = procedure(const pMessage: TZapJSONMessage) of object;

  TZapMQThread = class(TThread)
  private
    FEvent: TEvent;
    FCore: TZapMQ;
    FPriority: TZapMQQueuePriority;
    FWaitTime: Cardinal;
    FIsProcessing: Boolean;
    FSafeStop: Boolean;
    procedure SetIsProcessing(const Value: Boolean);
    procedure SetSafeStop(const Value: Boolean);
  public
    constructor Create(const pCore: TZapMQ; const pPriority: TZapMQQueuePriority);
    destructor Destroy; override;
    procedure Execute; override;
    procedure Stop;

    property IsProcessing: Boolean read FIsProcessing write SetIsProcessing;
    property SafeStop: Boolean read FSafeStop write SetSafeStop;
    property QueuePriority: TZapMQQueuePriority read FPriority;
  end;

  TZapMQRPCThread = class(TThread)
  private
    FEvent: TEvent;
    FCore: TZapMQ;
    FEventRPCExpired: TEventRPCExpired;
    FRPCMessages: TObjectList<TZapRPCMessage>;
    FIsProcessing: Boolean;
    FSafeStop: Boolean;
    procedure SetEventRPCExpired(const Value: TEventRPCExpired);
    procedure SetIsProcessing(const Value: Boolean);
    procedure SetSafeStop(const Value: Boolean);
  public
    constructor Create(const pHost: string; const pPort: Word; const pRPCMessages: TObjectList<TZapRPCMessage>);
    destructor Destroy; override;
    procedure Execute; override;
    procedure Stop;

    property IsProcessing: Boolean read FIsProcessing write SetIsProcessing;
    property SafeStop: Boolean read FSafeStop write SetSafeStop;
    property SyncEvent: TEvent read FEvent write FEvent;
    property EventRPCExpired: TEventRPCExpired read FEventRPCExpired write SetEventRPCExpired;
  end;

const
  PRIORITY_WAIT_TIMES: array [TZapMQQueuePriority] of Cardinal = (
    100, 250, 500, 750, 1000
  );

implementation

uses
  JSON;

{ TZapMQThread }

constructor TZapMQThread.Create(const pCore: TZapMQ; const pPriority: TZapMQQueuePriority);
begin
  inherited Create(True);
  FCore := pCore;
  FPriority := pPriority;
  FWaitTime := PRIORITY_WAIT_TIMES[FPriority];
  FEvent := TEvent.Create(nil, True, False, '');
end;

destructor TZapMQThread.Destroy;
begin
  FEvent.Free;
  inherited;
end;

procedure TZapMQThread.Execute;
var
  Queue: TZapMQQueue;
  JSONMessage: TZapJSONMessage;
  RPCAnswer: TJSONObject;
begin
  while not Terminated do
  begin
    for Queue in FCore.Queues do
    begin
      if not FIsProcessing and not FSafeStop and (Queue.Priority = FPriority) then
      begin
        JSONMessage := FCore.GetMessage(Queue.Name);
        if Assigned(JSONMessage) then
        begin
          try
            FIsProcessing := True;
            RPCAnswer := Queue.Handler(JSONMessage, FIsProcessing);
            if Assigned(RPCAnswer) and JSONMessage.RPC then
            begin
              try
                FCore.SendRPCResponse(Queue.Name, JSONMessage.Id, RPCAnswer.ToString);
              finally
                RPCAnswer.Free;
              end;
            end;
          finally
            JSONMessage.Free;
            FIsProcessing := False;
          end;
        end;
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

constructor TZapMQRPCThread.Create(const pHost: string; const pPort: Word; const pRPCMessages: TObjectList<TZapRPCMessage>);
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
  i: Integer;
  ZapMessage: TZapRPCMessage;
  Response: string;
  RPCAnswer: TJSONObject;
begin
  while not Terminated do
  begin
    for i := FRPCMessages.Count - 1 downto 0 do
    begin
      if not FIsProcessing and not FSafeStop then
      begin
        ZapMessage := FRPCMessages[i];
        Response := FCore.GetRPCResponse(ZapMessage.QueueName, ZapMessage.JSONMessage.Id);

        if not Response.IsEmpty then
        begin
          RPCAnswer := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
          try
            ZapMessage.Handler(RPCAnswer, FIsProcessing);
            FRPCMessages.Remove(ZapMessage);
          finally
            RPCAnswer.Free;
          end;
        end
        else if ZapMessage.IsExpired then
        begin
          if Assigned(FEventRPCExpired) then
            FEventRPCExpired(ZapMessage.JSONMessage);
          FRPCMessages.Remove(ZapMessage);
        end;
      end;
    end;

    if FRPCMessages.Count = 0 then
      FEvent.ResetEvent
    else
      Sleep(50);

    FEvent.WaitFor(INFINITE);
  end;
end;

procedure TZapMQRPCThread.SetEventRPCExpired(const Value: TEventRPCExpired);
begin
  FEventRPCExpired := Value;
end;

procedure TZapMQRPCThread.SetIsProcessing(const Value: Boolean);
begin
  FIsProcessing := Value;
end;

procedure TZapMQRPCThread.SetSafeStop(const Value: Boolean);
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

