unit ZapMQ.Core;

interface

uses
  Datasnap.DSClientRest, JSON, ZapMQ.Queue, Generics.Collections,ZapMQ.Message.JSON,
  ZapMQ.Handler;

type
  TZapMQ = class
  private
    FConnection : TDSRestConnection;
    FQueues : TObjectList<TZapMQQueue>;
    procedure SetQueues(const Value: TObjectList<TZapMQQueue>);
    procedure SetConnection(const Value: TDSRestConnection);
  public
    property Connection : TDSRestConnection read FConnection write SetConnection;
    property Queues : TObjectList<TZapMQQueue> read FQueues write SetQueues;
    function GetMessage(const pQueueName : string) : TZapJSONMessage;
    function GetRPCResponse(const pQueueName, pIdMessage : string) : string;
    function SendMessage(const pQueueName : string; const pMessage : TZapJSONMessage) : string;
    procedure SendRPCResponse(const pQueueName, pIdMessage, pResponse: string);
    function FindQueue(const pQueueName : string) : TZapMQQueue;
    constructor Create(const pHost : string; const pPort : integer); overload;
    destructor Destroy; override;
  end;

implementation

uses
  ZapMQ.Methods, System.SysUtils;

{ TZapMQ }

constructor TZapMQ.Create(const pHost: string; const pPort: integer);
begin
  FQueues := TObjectList<TZapMQQueue>.Create(True);
  FConnection := TDSRestConnection.Create(nil);
  FConnection.Host := pHost;
  FConnection.Port := pPort;
  FConnection.LoginPrompt := False;
end;

destructor TZapMQ.Destroy;
begin
  FQueues.Free;
  FConnection.Free;
  inherited;
end;

function TZapMQ.FindQueue(const pQueueName: string): TZapMQQueue;
var
  Queue : TZapMQQueue;
begin
  Result := nil;
  for Queue in FQueues do
  begin
    if Queue.Name = pQueueName then
    begin
      Result := Queue;
      Break;
    end;
  end;
end;

function TZapMQ.GetMessage(const pQueueName: string): TZapJSONMessage;
var
  Methods : TZapMethodsClient;
  Content : string;
begin
  Methods := TZapMethodsClient.Create(FConnection);
  try
    try
      Content := Methods.GetMessage(pQueueName);
      if Content <> string.Empty then
      begin
        Result := TZapJSONMessage.FromJSON(Content);
      end
      else
        Result := nil;
    except
      raise Exception.Create('Error getting message from ZapMQ Server');
    end;
  finally
    Methods.Free;
  end;
end;

function TZapMQ.GetRPCResponse(const pQueueName, pIdMessage: string): string;
var
  Methods : TZapMethodsClient;
begin
  Methods := TZapMethodsClient.Create(FConnection);
  try
    try
      rESULT := Methods.GetRPCResponse(pQueueName, pIdMessage);
    except
      raise Exception.Create('Error getting RPC message from ZapMQ Server');
    end;
  finally
    Methods.Free;
  end;
end;

function TZapMQ.SendMessage(const pQueueName : string;
  const pMessage : TZapJSONMessage) : string;
var
  Methods : TZapMethodsClient;
begin
  Methods := TZapMethodsClient.Create(FConnection);
  try
    try
      Result := Methods.UpdateMessage(pQueueName, pMessage.ToJSON.ToString);
    except
      raise Exception.Create('Error sending message to ZapMQ Server');
    end;
  finally
    Methods.Free;
  end;
end;

procedure TZapMQ.SendRPCResponse(const pQueueName, pIdMessage, pResponse: string);
var
  Methods : TZapMethodsClient;
begin
  Methods := TZapMethodsClient.Create(FConnection);
  try
    try
      Methods.UpdateRPCResponse(pQueueName, pIdMessage, pResponse);
    except
      raise Exception.Create('Error sending RPC response to ZapMQ Server');
    end;
  finally
    Methods.Free;
  end;
end;

procedure TZapMQ.SetConnection(const Value: TDSRestConnection);
begin
  FConnection := Value;
end;

procedure TZapMQ.SetQueues(const Value: TObjectList<TZapMQQueue>);
begin
  FQueues := Value;
end;

end.
