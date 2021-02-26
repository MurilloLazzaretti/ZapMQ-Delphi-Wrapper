unit BenchMark;

interface

uses
  System.Classes, SyncObjs, ZapMQ.Wrapper, ZapMQ.Message.JSON, BenchMarkResults,
  JSON;

type
  TBenchMark = class(TThread)
  private
    FEvent : TEvent;
    FZapMQWrapper : TZapMQWrapper;
    FBenchMark : TBenchMarkResults;
    FCycles: integer;
    FStartedTime : TDateTime;
    FFinishedTime : TDateTime;
    FQueues: integer;
    procedure BenchMarkExpired(const pMessage : TZapJSONMessage);
    procedure BenchMarkHandlerRPC(pMessage: TJSONObject);
    procedure Print;
    function GetTotalMessagesExpired : integer;
    function GetTotalMessagesRecived : integer;
    function GetLatency : integer;
    function GetConnectLatency : integer;
    procedure SetCycles(const Value: integer);
    procedure SetQueues(const Value: integer);
  public
    property Cycles : integer read FCycles write SetCycles;
    property Queues : integer read FQueues write SetQueues;
    procedure Execute; override;
    procedure Stop;
    constructor Create(const pHost : string; const pPort : integer); overload;
    destructor Destroy; override;
  end;

implementation

uses
 System.SysUtils, System.DateUtils, uMain;

{ TBenchMark }

procedure TBenchMark.BenchMarkHandlerRPC(pMessage: TJSONObject);
var
  Cycle, Queue : integer;
  Resultb : TBenchMarkResult;
  Body : TJSONObject;
begin
  Body := pMessage.GetValue<TJSONObject>('Body');
  Cycle := Body.GetValue<integer>('Cycle');
  Queue := Body.GetValue<integer>('Queue');
  Resultb := FBenchMark.FindResult(Cycle, Queue);
  if Assigned(Resultb) then
  begin
    Resultb.Expired := False;
    Resultb.Arrived := Now;
    Resultb.Latency := MilliSecondsBetween(Resultb.Arrived, Resultb.Sended);
  end;
end;

constructor TBenchMark.Create(const pHost : string; const pPort : integer);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FEvent := TEvent.Create(nil, True, False, '');
  FZapMQWrapper := TZapMQWrapper.Create(pHost, pPort);
  FZapMQWrapper.OnRPCExpired := BenchMarkExpired;
  FBenchMark := TBenchMarkResults.Create;
end;

destructor TBenchMark.Destroy;
begin
  FZapMQWrapper.Free;
  FBenchMark.Free;
  FEvent.Free;
  inherited;
end;

procedure TBenchMark.Execute;
var
  I, J : integer;
  JSON : TJSONObject;
  Resultb : TBenchMarkResult;
begin
  inherited;
  FStartedTime := Now;
  while not Terminated do
  begin
    for J := 1 to Cycles do
    begin
      for I := 1 to Queues do
      begin
        JSON := TJSONObject.Create;
        JSON.AddPair('Cycle', J.ToString);
        JSON.AddPair('Queue', I.ToString);
        try
          Resultb := TBenchMarkResult.Create;
          Resultb.Created := Now;
          if FZapMQWrapper.SendRPCMessage('BenchMark' + I.ToString, JSON, BenchMarkHandlerRPC, 5000) then
          begin
            Resultb.Latency := 0;
            Resultb.Expired := False;
            Resultb.Cycle := J;
            Resultb.Queue := I;
            Resultb.Sended := Now;
            Resultb.ConnectLatency := MilliSecondsBetween(Now, Resultb.Created);
            FBenchMark.Results.Add(Resultb);
          end;
        finally
          JSON.Free;
        end;
        if (FEvent.WaitFor(10) = wrSignaled) then
        begin
          Terminate;
        end;
      end;
    end;
    Terminate;
  end;
  while GetTotalMessagesRecived < (Cycles * Queues) do ;
  FFinishedTime := Now;
  Synchronize(TThread.Current, procedure
  begin
    Print;
  end);
end;

function TBenchMark.GetConnectLatency: integer;
var
  TotalLatency : Cardinal;
  ResultB : TBenchMarkResult;
begin
  TotalLatency := 0;
  Result := 0;
  for ResultB in FBenchMark.Results do
  begin
    if not ResultB.Expired then
      TotalLatency := TotalLatency + Resultb.ConnectLatency;
  end;
  if FBenchMark.Results.Count > 0 then
  begin
    Result := Trunc(TotalLatency / GetTotalMessagesRecived);
  end;
end;

function TBenchMark.GetLatency: integer;
var
  TotalLatency : Cardinal;
  ResultB : TBenchMarkResult;
begin
  TotalLatency := 0;
  Result := 0;
  for ResultB in FBenchMark.Results do
  begin
    if not ResultB.Expired then
      TotalLatency := TotalLatency + Resultb.Latency;
  end;
  if FBenchMark.Results.Count > 0 then
  begin
    Result := Trunc(TotalLatency / GetTotalMessagesRecived);
  end;
end;

function TBenchMark.GetTotalMessagesExpired: integer;
var
  ResultB : TBenchMarkResult;
begin
  Result := 0;
  for ResultB in FBenchMark.Results do
  begin
    if ResultB.Expired then
      Inc(Result);
  end;
end;

function TBenchMark.GetTotalMessagesRecived: integer;
var
  ResultB : TBenchMarkResult;
begin
  Result := 0;
  for ResultB in FBenchMark.Results do
  begin
    if ResultB.Latency > 0 then
      Inc(Result);
  end;
end;

procedure TBenchMark.Print;
begin
  FrmMain.Memo1.Lines.Add('***** BenchMark Result *****');
  FrmMain.Memo1.Lines.Add('Time Elapsed (miliseconds) : ' + MilliSecondsBetween(FStartedTime, FFinishedTime).ToString);
  FrmMain.Memo1.Lines.Add('Cycles : ' + Cycles.ToString);
  FrmMain.Memo1.Lines.Add('Total Messages Sended :' + IntToStr(Queues * Cycles));
  FrmMain.Memo1.Lines.Add('Total Messages Recived :' + GetTotalMessagesRecived.ToString);
  FrmMain.Memo1.Lines.Add('Total Messages Expired :' + GetTotalMessagesExpired.ToString);
  FrmMain.Memo1.Lines.Add('Average Latency (miliseconds) :' + GetLatency.ToString);
  FrmMain.Memo1.Lines.Add('Average Connect Latency (miliseconds) :' + GetConnectLatency.ToString);
  FrmMain.Memo1.Lines.Add('***** ---------------- *****');
  FrmMain.ActivityIndicator1.Animate := False;
  FrmMain.Button9.Enabled := True;
end;

procedure TBenchMark.BenchMarkExpired(const pMessage: TZapJSONMessage);
var
  Cycle, Queue : integer;
  Resultb : TBenchMarkResult;
begin
  Cycle := pMessage.Body.GetValue<integer>('Cycle');
  Queue := pMessage.Body.GetValue<integer>('Queue');
  Resultb := FBenchMark.FindResult(Cycle, Queue);
  if Assigned(Resultb) then
  begin
    ResultB.Latency := 1;
    ResultB.Expired := True;
    Resultb.Arrived := Now;
  end;
end;

procedure TBenchMark.SetCycles(const Value: integer);
begin
  FCycles := Value;
end;

procedure TBenchMark.SetQueues(const Value: integer);
begin
  FQueues := Value;
end;

procedure TBenchMark.Stop;
begin
  if Assigned(FEvent) then
    FEvent.SetEvent;
  while not Terminated do;
end;

end.
