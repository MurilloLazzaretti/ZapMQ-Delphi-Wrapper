unit ZapMQ.Thread;

interface

uses
  System.Classes, ZapMQ.Core, ZapMQ.handler;

type
  TZapMQThread = class(TThread)
  private
    FCore : TZapMQ;
  public
    procedure Execute; override;
    constructor Create(const pCore : TZapMQ); overload;
  end;

  TZapMQRPCThread = class(TThread)
  private
    FCore : TZapMQ;
    FHandler : TZapMQHandlerRPC;
    FIDMessage : string;
    FQueueName : string;
    //FTimeout : Word;
  public
    procedure Execute; override;
    constructor Create(const pCore : TZapMQ; const pHandler : TZapMQHandlerRPC;
      const pIdMessage : string; const pQueueName : string); overload;
  end;

implementation

uses
  ZapMQ.Queue, ZapMQ.Message.JSON, JSON, System.SysUtils;

{ TZapMQThread }

constructor TZapMQThread.Create(const pCore: TZapMQ);
begin
  inherited Create(True);
  FCore := pCore;
end;

procedure TZapMQThread.Execute;
var
  Queue : TZapMQQueue;
  JSONMessage : TZapJSONMessage;
  ProcessingMessage : boolean;
  RPCAnswer : TJSONObject;
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
            RPCAnswer := Queue.Handler(JSONMessage, ProcessingMessage);
            if Assigned(RPCAnswer) and (JSONMessage.RPC) then
            begin
              FCore.SendRPCResponse(Queue.Name, JSONMessage.Id, RPCAnswer.ToString);
            end;
          end);
        end;
      end;
    end;
    Sleep(100);
  end;
end;

{ TZapMQRPCThread }

constructor TZapMQRPCThread.Create(const pCore: TZapMQ;
  const pHandler: TZapMQHandlerRPC; const pIdMessage: string;
  const pQueueName : string);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FCore := pCore;
  FHandler := pHandler;
  FIDMessage := pIdMessage;
  FQueueName := pQueueName;
end;

procedure TZapMQRPCThread.Execute;
var
  Response : string;
  RPCAnswer : TJSONObject;
begin
  inherited;
  while Response = String.Empty do
  begin
    Response := FCore.GetRPCResponse(FQueueName, FIDMessage);
    if Response <> string.Empty then
    begin
      RPCAnswer := TJSONObject.ParseJSONValue(
        TEncoding.ASCII.GetBytes(Response), 0) as TJSONObject;
      FHandler(RPCAnswer);
    end;
  end;
end;

end.
