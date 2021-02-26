unit BenchMarkResults;

interface

uses
  Generics.Collections;

type
  TBenchMarkResult = class
  private
    FExpired: Boolean;
    FLatency: Cardinal;
    FArrived: TDateTime;
    FSended: TDateTime;
    FQueue: integer;
    FCycle: integer;
    FConnectLatency: Cardinal;
    FCreated: TDateTime;
    procedure SetExpired(const Value: Boolean);
    procedure SetLatency(const Value: Cardinal);
    procedure SetArrived(const Value: TDateTime);
    procedure SetCycle(const Value: integer);
    procedure SetQueue(const Value: integer);
    procedure SetSended(const Value: TDateTime);
    procedure SetConnectLatency(const Value: Cardinal);
    procedure SetCreated(const Value: TDateTime);
  public
    property ConnectLatency : Cardinal read FConnectLatency write SetConnectLatency;
    property Latency : Cardinal read FLatency write SetLatency;
    property Expired : Boolean read FExpired write SetExpired;
    property Cycle : integer read FCycle write SetCycle;
    property Queue : integer read FQueue write SetQueue;
    property Created : TDateTime read FCreated write SetCreated;
    property Sended : TDateTime read FSended write SetSended;
    property Arrived : TDateTime read FArrived write SetArrived;
  end;

  TBenchMarkResults = class
  private
    FResults: TObjectList<TBenchMarkResult>;
    procedure SetResults(const Value: TObjectList<TBenchMarkResult>);
  public
    function FindResult(const pCycle : integer; const pQueue : integer) : TBenchMarkResult;
    property Results : TObjectList<TBenchMarkResult> read FResults write SetResults;
    constructor Create; overload;
    destructor Destroy; override;
  end;

implementation

{ TBenchMarkResults }

constructor TBenchMarkResults.Create;
begin
  FResults := TObjectList<TBenchMarkResult>.Create(True);
end;

destructor TBenchMarkResults.Destroy;
begin
  FResults.Free;
  inherited;
end;

function TBenchMarkResults.FindResult(const pCycle,
  pQueue: integer): TBenchMarkResult;
var
  ResultB: TBenchMarkResult;
begin
  Result := nil;
  for ResultB in FResults do
  begin
    if (ResultB.FCycle = pCycle) and (ResultB.FQueue = pQueue) then
    begin
      Result := Resultb;
      break;
    end;
  end;
end;

procedure TBenchMarkResults.SetResults(
  const Value: TObjectList<TBenchMarkResult>);
begin
  FResults := Value;
end;

{ TBenchMarkResult }

procedure TBenchMarkResult.SetArrived(const Value: TDateTime);
begin
  FArrived := Value;
end;

procedure TBenchMarkResult.SetConnectLatency(const Value: Cardinal);
begin
  FConnectLatency := Value;
end;

procedure TBenchMarkResult.SetCreated(const Value: TDateTime);
begin
  FCreated := Value;
end;

procedure TBenchMarkResult.SetCycle(const Value: integer);
begin
  FCycle := Value;
end;

procedure TBenchMarkResult.SetExpired(const Value: Boolean);
begin
  FExpired := Value;
end;

procedure TBenchMarkResult.SetLatency(const Value: Cardinal);
begin
  FLatency := Value;
end;

procedure TBenchMarkResult.SetQueue(const Value: integer);
begin
  FQueue := Value;
end;

procedure TBenchMarkResult.SetSended(const Value: TDateTime);
begin
  FSended := Value;
end;

end.
