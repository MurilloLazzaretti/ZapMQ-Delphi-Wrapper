unit ZapMQ.Thread;

interface

uses
  System.Classes, ZapMQ.Core;

type
  TZapMQThread = class(TThread)
  private
    FCore : TZapMQ;
  public
    procedure Execute; override;
    constructor Create(const pCore : TZapMQ); overload;
  end;

implementation

uses
  ZapMQ.Queue, JSON;

{ TZapMQThread }

constructor TZapMQThread.Create(const pCore: TZapMQ);
begin
  inherited Create(True);
  FCore := pCore;
end;

procedure TZapMQThread.Execute;
var
  Queue : TZapMQQueue;
  JSONMessage : TJSONObject;
  ProcessingMessage : boolean;
begin
  inherited;
  ProcessingMessage := False;
  while not Terminated do
  begin
    if not ProcessingMessage then
    begin
      for Queue in FCore.Queues do
      begin
        JSONMessage := FCore.GetMessage(Queue.Name);
        if Assigned(JSONMessage) then
        begin
          ProcessingMessage := True;
          Synchronize(Current, procedure
          begin
            Queue.Handler(JSONMessage, ProcessingMessage);
          end);
        end;
      end;
    end;
    Sleep(100);
  end;
end;

end.
