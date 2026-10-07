unit ZapMQ.Message.JSON;

interface

uses
  JSON, System.SysUtils;

type
  TZapJSONMessage = class
  private
    FBody: TJSONObject;
    FId: string;
    FRPC: Boolean;
    FTTL: Word;
    procedure SetBody(const Value: TJSONObject);
    procedure SetId(const Value: string);
    procedure SetRPC(const Value: Boolean);
    procedure SetTTL(const Value: Word);
  public
    constructor Create;
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(const pJSONString: string): TZapJSONMessage;

    property Id: string read FId write SetId;
    property Body: TJSONObject read FBody write SetBody;
    property RPC: Boolean read FRPC write SetRPC;
    property TTL: Word read FTTL write SetTTL;
  end;

implementation

{ TZapJSONMessage }

constructor TZapJSONMessage.Create;
begin
  inherited;
  FBody := nil;
  FId := '';
  FRPC := False;
  FTTL := 0;
end;

destructor TZapJSONMessage.Destroy;
begin
  FBody.Free;
  inherited;
end;

class function TZapJSONMessage.FromJSON(const pJSONString: string): TZapJSONMessage;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(pJSONString), 0) as TJSONObject;
  try
    Result := TZapJSONMessage.Create;
    Result.FId := JSON.GetValue<string>('Id');
    Result.FBody := TJSONObject.ParseJSONValue(
      TEncoding.ASCII.GetBytes(JSON.GetValue<TJSONObject>('Body').ToString), 0) as TJSONObject;
    Result.FRPC := JSON.GetValue<Boolean>('RPC');
    Result.FTTL := JSON.GetValue<Word>('TTL');
  finally
    JSON.Free;
  end;
end;

procedure TZapJSONMessage.SetBody(const Value: TJSONObject);
begin
  FBody := Value;
end;

procedure TZapJSONMessage.SetId(const Value: string);
begin
  FId := Value;
end;

procedure TZapJSONMessage.SetRPC(const Value: Boolean);
begin
  FRPC := Value;
end;

procedure TZapJSONMessage.SetTTL(const Value: Word);
begin
  FTTL := Value;
end;

function TZapJSONMessage.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Id', TJSONString.Create(FId));
  Result.AddPair('Body', TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(FBody.ToString), 0));
  Result.AddPair('RPC', TJSONBool.Create(FRPC));
  Result.AddPair('TTL', TJSONNumber.Create(FTTL));
end;

end.

