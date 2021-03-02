unit ZapMQ.Queue;

interface

uses
  ZapMQ.Handler, Generics.Collections;

type
  TZapMQQueuePriority = (mqpHigh, mqpMediumHigh ,mqpMedium, mqpMediumLow, mqpLow);

  TZapMQQueue = class
  private
    FName: string;
    FHandler: TZapMQHanlder;
    FPriority: TZapMQQueuePriority;
    procedure SetHandler(const Value: TZapMQHanlder);
    procedure SetName(const Value: string);
    procedure SetPriority(const Value: TZapMQQueuePriority);
  public
    property Name : string read FName write SetName;
    property Handler : TZapMQHanlder read FHandler write SetHandler;
    property Priority : TZapMQQueuePriority read FPriority write SetPriority;
  end;

implementation

{ TZapMQQueue }

procedure TZapMQQueue.SetHandler(const Value: TZapMQHanlder);
begin
  FHandler := Value;
end;

procedure TZapMQQueue.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TZapMQQueue.SetPriority(const Value: TZapMQQueuePriority);
begin
  FPriority := Value;
end;

end.
