unit ZapMQ.Core;

interface

uses
  Datasnap.DSClientRest, JSON, ZapMQ.Queue, Generics.Collections,ZapMQ.Message.JSON,
  ZapMQ.Handler;

type
  TZapMQ = class
  private
    FQueues : TObjectList<TZapMQQueue>;
    FPort: Word;
    FHost: string;
    procedure SetQueues(const Value: TObjectList<TZapMQQueue>);
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: Word);
    function CreateRestConnection : TDSRestConnection;
  public
    property Queues : TObjectList<TZapMQQueue> read FQueues write SetQueues;
    property Host : string read FHost write SetHost;
    property Port : Word read FPort write SetPort;
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
  FHost := pHost;
  FPort := pPort;
end;

function TZapMQ.CreateRestConnection: TDSRestConnection;
begin
  Result := TDSRestConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.Host := FHost;
  Result.Port := FPort;
end;

destructor TZapMQ.Destroy;
begin
  FQueues.Free;
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
  Connection : TDSRestConnection;
  Methods : TZapMethodsClient;
  Content : string;
begin
  Connection := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Connection);
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
        Result := nil;
      end;
    finally
      Methods.Free;
    end;
  finally
    Connection.Free;
  end;
end;

function TZapMQ.GetRPCResponse(const pQueueName, pIdMessage: string): string;
var
  Connection : TDSRestConnection;
  Methods : TZapMethodsClient;
begin
  Connection := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Connection);
    try
      try
        Result := Methods.GetRPCResponse(pQueueName, pIdMessage);
      except
        raise Exception.Create('Error getting RPC message from ZapMQ Server');
      end;
    finally
      Methods.Free;
    end;
  finally
    Connection.Free;
  end;
end;

function TZapMQ.SendMessage(const pQueueName : string;
  const pMessage : TZapJSONMessage) : string;
var
  Connection : TDSRestConnection;
  Methods : TZapMethodsClient;
  JSON : TJSONObject;
begin
  Connection := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Connection);
    JSON := pMessage.ToJSON;
    try
      try
        Result := Methods.UpdateMessage(pQueueName, JSON.ToString);
      except
        raise Exception.Create('Error sending message to ZapMQ Server');
      end;
    finally
      JSON.Free;
      Methods.Free;
    end;
  finally
    Connection.Free;
  end;
end;

procedure TZapMQ.SendRPCResponse(const pQueueName, pIdMessage, pResponse: string);
var
  Connection : TDSRestConnection;
  Methods : TZapMethodsClient;
begin
  Connection := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Connection);
    try
      try
        Methods.UpdateRPCResponse(pQueueName, pIdMessage, pResponse);
      except
        raise Exception.Create('Error sending RPC response to ZapMQ Server');
      end;
    finally
      Methods.Free;
    end;
  finally
    Connection.Free;
  end;
end;

procedure TZapMQ.SetHost(const Value: string);
begin
  FHost := Value;
end;

procedure TZapMQ.SetPort(const Value: Word);
begin
  FPort := Value;
end;

procedure TZapMQ.SetQueues(const Value: TObjectList<TZapMQQueue>);
begin
  FQueues := Value;
end;

end.
