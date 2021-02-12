unit ZapMQ.Wrapper;

interface

uses
  ZapMQ.Core, ZapMQ.Thread, ZapMQ.Handler, JSON;

type
  TZapMQWrapper = class
  private
    FCore : TZapMQ;
    FThread : TZapMQThread;
  public
    function SendMessage(const pQueueName : string; const pMessage : TJSONObject;
      const pTTL : Word = 0) : boolean;
    procedure Bind(const pQueueName : string; const pHandler : TZapMQHanlder);
    procedure UnBind(const pQueueName : string);
    constructor Create(const pHost : string; const pPort : integer); overload;
    destructor Destroy; override;
  end;

implementation

uses
  ZapMQ.Queue;

{ TZapMQWrapper }

procedure TZapMQWrapper.Bind(const pQueueName: string;
  const pHandler: TZapMQHanlder);
var
  Queue : TZapMQQueue;
begin
  Queue := TZapMQQueue.Create;
  Queue.Name := pQueueName;
  Queue.Handler := pHandler;
  FCore.Queues.Add(Queue);
end;

constructor TZapMQWrapper.Create(const pHost: string; const pPort: integer);
begin
  FCore := TZapMQ.Create(pHost, pPort);
  FThread := TZapMQThread.Create(FCore);
  FThread.Start;
end;

destructor TZapMQWrapper.Destroy;
begin
  FThread.Terminate;
  FCore.Free;
  inherited;
end;

function TZapMQWrapper.SendMessage(const pQueueName: string;
  const pMessage: TJSONObject; const pTTL: Word): boolean;
begin
  Result := FCore.SendMessage(pQueueName, pMessage, pTTL);
end;

procedure TZapMQWrapper.UnBind(const pQueueName: string);
var
  Queue : TZapMQQueue;
begin
  Queue := FCore.FindQueue(pQueueName);
  if Assigned(Queue) then
    FCore.Queues.Remove(Queue);
end;

end.
