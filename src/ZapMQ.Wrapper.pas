unit ZapMQ.Wrapper;

interface

uses
  ZapMQ.Core,
  ZapMQ.Thread,
  ZapMQ.Handler,
  JSON,
  Generics.Collections,
  System.Classes,
  ZapMQ.Message.RPC,
  ZapMQ.Queue;

type
  TZapMQOccurrenceType = (otInformation, otException, otError);

  TZapMQWrapper = class
  private
    FCore: TZapMQ;
    FListThreads: TObjectList<TZapMQThread>;
    FRPCThread: TZapMQRPCThread;
    FRPCMessages: TObjectList<TZapRPCMessage>;
    FOnRPCExpired: TEventRPCExpired;
    procedure SetOnRPCExpired(const Value: TEventRPCExpired);
    procedure CheckPriorityThreadAndCreate(const Priority: TZapMQQueuePriority);
    procedure CheckPriorityThreadAndFree(const Priority: TZapMQQueuePriority);
    function GetIsProcessing: Boolean;
  public
    constructor Create(const Host: string; const Port: Integer);
    destructor Destroy; override;

    property IsProcessing: Boolean read GetIsProcessing;
    property OnRPCExpired: TEventRPCExpired read FOnRPCExpired write SetOnRPCExpired;

    procedure SafeStop;
    procedure Bind(const QueueName: string; const Handler: TZapMQHandler;
      const Priority: TZapMQQueuePriority = mqpMedium);
    procedure UnBind(const QueueName: string);
    function IsBinded(const QueueName: string): Boolean;
    function SendMessage(const QueueName: string; const Message: TJSONObject;
      const TTL: Word = 0): Boolean;
    function SendRPCMessage(const QueueName: string; const Message: TJSONObject;
      const Handler: TZapMQHandlerRPC; const TTL: Word = 0): Boolean;
    procedure Log(const OccurrenceType: TZapMQOccurrenceType;
      const OccurrenceOrigin, Title, Text: string);
  end;

implementation

uses
  ZapMQ.Message.JSON,
  System.SysUtils,
  Vcl.Forms,
  TypInfo;

{ TZapMQWrapper }

constructor TZapMQWrapper.Create(const Host: string; const Port: Integer);
begin
  FCore := TZapMQ.Create(Host, Port);
  FRPCMessages := TObjectList<TZapRPCMessage>.Create(True);
  FListThreads := TObjectList<TZapMQThread>.Create(True);
  FRPCThread := TZapMQRPCThread.Create(Host, Port, FRPCMessages);
  FRPCThread.Start;
end;

destructor TZapMQWrapper.Destroy;
var
  Thread: TZapMQThread;
begin
  FRPCThread.Stop;
  FRPCThread.Free;

  for Thread in FListThreads do
    Thread.Stop;

  FListThreads.Clear;
  FListThreads.Free;
  FRPCMessages.Free;
  FCore.Free;

  inherited;
end;

procedure TZapMQWrapper.Bind(const QueueName: string; const Handler: TZapMQHandler;
  const Priority: TZapMQQueuePriority);
var
  Queue: TZapMQQueue;
begin
  if QueueName.IsEmpty then
    raise Exception.Create('You cannot bind an unnamed Queue');

  if not IsBinded(QueueName) then
  begin
    Queue := TZapMQQueue.Create;
    Queue.Name := QueueName;
    Queue.Handler := Handler;
    Queue.Priority := Priority;
    FCore.Queues.Add(Queue);
    CheckPriorityThreadAndCreate(Priority);
  end;
end;

procedure TZapMQWrapper.CheckPriorityThreadAndCreate(const Priority: TZapMQQueuePriority);
var
  Thread: TZapMQThread;
begin
  for Thread in FListThreads do
    if Thread.QueuePriority = Priority then
      Exit;

  Thread := TZapMQThread.Create(FCore, Priority);
  FListThreads.Add(Thread);
  Thread.Start;
end;

procedure TZapMQWrapper.CheckPriorityThreadAndFree(const Priority: TZapMQQueuePriority);
var
  Queue: TZapMQQueue;
  Thread: TZapMQThread;
begin
  for Queue in FCore.Queues do
    if Queue.Priority = Priority then
      Exit;

  for Thread in FListThreads do
    if Thread.QueuePriority = Priority then
    begin
      Thread.Stop;
      FListThreads.Remove(Thread);
      Break;
    end;
end;

function TZapMQWrapper.GetIsProcessing: Boolean;
var
  Thread: TZapMQThread;
begin
  for Thread in FListThreads do
    if Thread.IsProcessing then
      Exit(True);

  Result := FRPCThread.IsProcessing;
end;

function TZapMQWrapper.IsBinded(const QueueName: string): Boolean;
var
  Queue: TZapMQQueue;
begin
  for Queue in FCore.Queues do
    if Queue.Name = QueueName then
      Exit(True);

  Result := False;
end;

procedure TZapMQWrapper.Log(const OccurrenceType: TZapMQOccurrenceType;
  const OccurrenceOrigin, Title, Text: string);
var
  JsonObject: TJSONObject;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('OccurrenceDate', TJSONString.Create(DateTimeToStr(Now)));
    JsonObject.AddPair('OccurrenceOrigin', TJSONString.Create(OccurrenceOrigin));
    JsonObject.AddPair('ApplicationName', TJSONString.Create(ExtractFileName(Application.ExeName)));
    JsonObject.AddPair('Title', TJSONString.Create(Title));
    JsonObject.AddPair('Text', TJSONString.Create(Text));
    JsonObject.AddPair('OccurrenceType', TJSONString.Create(
      GetEnumName(TypeInfo(TZapMQOccurrenceType), Ord(OccurrenceType))));
    SendMessage('LogsFactory', JsonObject);
  finally
    JsonObject.Free;
  end;
end;

procedure TZapMQWrapper.SafeStop;
var
  Thread: TZapMQThread;
  TimeoutCount: Integer;
begin
  for Thread in FListThreads do
    Thread.SafeStop := True;

  FRPCThread.SafeStop := True;

  TimeoutCount := 0;
  while IsProcessing do
  begin
    Application.ProcessMessages;
    Sleep(10);
    Inc(TimeoutCount);
    if TimeoutCount > 300 then
      Break;
  end;

  for Thread in FListThreads do
  begin
    if not Thread.Finished then
    begin
      Thread.Terminate;
      Thread.WaitFor;
    end;
  end;

  if Assigned(FRPCThread) then
  begin
    if not FRPCThread.Finished then
    begin
      FRPCThread.Terminate;
      FRPCThread.WaitFor;
    end;
  end;
end;

function TZapMQWrapper.SendMessage(const QueueName: string; const Message: TJSONObject;
  const TTL: Word): Boolean;
var
  ZapMessage: TZapJSONMessage;
begin
  if QueueName.IsEmpty then
    raise Exception.Create('Inform the Queue name');

  if IsBinded(QueueName) then
    raise Exception.Create('You cannot send message to a Queue self binded');

  ZapMessage := TZapJSONMessage.Create;
  try
    ZapMessage.Body := TJSONObject.ParseJSONValue(
      TEncoding.ASCII.GetBytes(Message.ToString), 0) as TJSONObject;
    ZapMessage.RPC := False;
    ZapMessage.TTL := TTL;

    try
      FCore.SendMessage(QueueName, ZapMessage);
      Result := True;
    except
      Result := False;
    end;
  finally
    ZapMessage.Free;
  end;
end;

function TZapMQWrapper.SendRPCMessage(const QueueName: string; const Message: TJSONObject;
  const Handler: TZapMQHandlerRPC; const TTL: Word): Boolean;
var
  JSONMessage: TZapJSONMessage;
  ZapRPCMessage: TZapRPCMessage;
begin
  if QueueName.IsEmpty then
    raise Exception.Create('Inform the Queue name');

  if IsBinded(QueueName) then
    raise Exception.Create('You cannot send message to a Queue self binded');

  JSONMessage := TZapJSONMessage.Create;
  JSONMessage.Body := TJSONObject.ParseJSONValue(
    TEncoding.ASCII.GetBytes(Message.ToString), 0) as TJSONObject;
  JSONMessage.RPC := True;
  JSONMessage.TTL := TTL;

  try
    JSONMessage.Id := FCore.SendMessage(QueueName, JSONMessage);
    if JSONMessage.Id.IsEmpty then
    begin
      JSONMessage.Free;
      Exit(False);
    end;

    FRPCThread.EventRPCExpired := FOnRPCExpired;
    ZapRPCMessage := TZapRPCMessage.Create(JSONMessage, Handler, QueueName);
    FRPCMessages.Add(ZapRPCMessage);
    FRPCThread.SyncEvent.SetEvent;
    Result := True;
  except
    JSONMessage.Free;
    Result := False;
  end;
end;

procedure TZapMQWrapper.SetOnRPCExpired(const Value: TEventRPCExpired);
begin
  FOnRPCExpired := Value;
end;

procedure TZapMQWrapper.UnBind(const QueueName: string);
var
  Queue: TZapMQQueue;
begin
  Queue := FCore.FindQueue(QueueName);
  if Assigned(Queue) then
  begin
    FCore.Queues.Remove(Queue);
    CheckPriorityThreadAndFree(Queue.Priority);
  end;
end;

end.

