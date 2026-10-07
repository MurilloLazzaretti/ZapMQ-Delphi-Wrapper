unit ZapMQ.Message.RPC;

interface

uses
  ZapMQ.Message.JSON, ZapMQ.Handler, Windows;

type
  TZapRPCMessage = class
  private
    FHandler: TZapMQHandlerRPC;
    FQueueName: string;
    FJSONMessage: TZapJSONMessage;
    FBirthTime: Cardinal;
    procedure SetHandler(const Value: TZapMQHandlerRPC);
    procedure SetQueueName(const Value: string);
    procedure SetJSONMessage(const Value: TZapJSONMessage);
  public
    constructor Create(const pZapMessage: TZapJSONMessage;
      const pHandler: TZapMQHandlerRPC; const pQueueName: string);
    destructor Destroy; override;

    function IsExpired: Boolean;

    property QueueName: string read FQueueName write SetQueueName;
    property Handler: TZapMQHandlerRPC read FHandler write SetHandler;
    property JSONMessage: TZapJSONMessage read FJSONMessage write SetJSONMessage;
  end;

implementation

{ TZapRPCMessage }

constructor TZapRPCMessage.Create(const pZapMessage: TZapJSONMessage;
  const pHandler: TZapMQHandlerRPC; const pQueueName: string);
begin
  inherited Create;
  FHandler := pHandler;
  FQueueName := pQueueName;
  FJSONMessage := pZapMessage;
  FBirthTime := GetTickCount;
end;

destructor TZapRPCMessage.Destroy;
begin
  FJSONMessage.Free;
  inherited;
end;

function TZapRPCMessage.IsExpired: Boolean;
begin
  Result := (FJSONMessage.TTL > 0) and
            (GetTickCount - FBirthTime > FJSONMessage.TTL);
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

