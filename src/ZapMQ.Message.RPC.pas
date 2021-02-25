unit ZapMQ.Message.RPC;

interface

uses
  ZapMQ.Message.JSON, ZapMQ.Handler;

type
  TZapRPCMessage = class
  private
    FHandler: TZapMQHandlerRPC;
    FQueueName: string;
    FJSONMessage: TZapJSONMessage;
    FBirthTime : Cardinal;
    procedure SetHandler(const Value: TZapMQHandlerRPC);
    procedure SetQueueName(const Value: string);
    procedure SetJSONMessage(const Value: TZapJSONMessage);
  public
    function IsExpired : Boolean;
    property QueueName : string read FQueueName write SetQueueName;
    property Handler : TZapMQHandlerRPC read FHandler write SetHandler;
    property JSONMessage : TZapJSONMessage read FJSONMessage write SetJSONMessage;
    constructor Create(const pZapMessage : TZapJSONMessage;
      const pHandler : TZapMQHandlerRPC; const pQueueName : string); overload;
    destructor Destroy; override;
  end;

implementation

uses
  Windows;

{ TZapRPCMessage }

constructor TZapRPCMessage.Create(const pZapMessage: TZapJSONMessage;
  const pHandler: TZapMQHandlerRPC; const pQueueName : string);
begin
  FHandler := pHandler;
  JSONMessage := pZapMessage;
  QueueName := pQueueName;
  FBirthTime := GetTickCount;
end;

destructor TZapRPCMessage.Destroy;
begin
  JSONMessage.Free;
  inherited;
end;

function TZapRPCMessage.IsExpired: Boolean;
begin
  Result := (FJSONMessage.TTL > 0) and ((FBirthTime + FJSONMessage.TTL) < GetTickCount);
end;

procedure TZapRPCMessage.SetHandler(const Value: TZapMQHandlerRPC);
begin
  FHandler := Value;
end;

procedure TZapRPCMessage.SetJSONMessage(const Value: TZapJSONMessage);
begin
  FJSONMessage := Value;
end;

procedure TZapRPCMessage.SetQueueName(const Value: string);
begin
  FQueueName := Value;
end;

end.
