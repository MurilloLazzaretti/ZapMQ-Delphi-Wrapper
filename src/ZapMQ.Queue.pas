unit ZapMQ.Queue;

interface

uses
  ZapMQ.Handler, Generics.Collections;

type
  TZapMQQueue = class
  private
    FName: string;
    FHandler: TZapMQHanlder;
    procedure SetHandler(const Value: TZapMQHanlder);
    procedure SetName(const Value: string);
  public
    property Name : string read FName write SetName;
    property Handler : TZapMQHanlder read FHandler write SetHandler;
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

end.
