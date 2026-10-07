unit ZapMQ.Core;

interface

uses
  Datasnap.DSClientRest, JSON, Generics.Collections,
  ZapMQ.Queue, ZapMQ.Message.JSON, ZapMQ.Handler;

type
  TZapMQ = class
  private
    FQueues: TObjectList<TZapMQQueue>;
    FPort: Word;
    FHost: string;
    function CreateRestConnection: TDSRestConnection;
  public
    property Queues: TObjectList<TZapMQQueue> read FQueues;
    property Host: string read FHost write FHost;
    property Port: Word read FPort write FPort;
    constructor Create(const AHost: string; const APort: Word);
    destructor Destroy; override;

    function GetMessage(const AQueueName: string): TZapJSONMessage;
    function GetRPCResponse(const AQueueName, AMessageId: string): string;
    function SendMessage(const AQueueName: string; const AMessage: TZapJSONMessage): string;
    procedure SendRPCResponse(const AQueueName, AMessageId, AResponse: string);
    function FindQueue(const AQueueName: string): TZapMQQueue;
  end;

implementation

uses
  System.SysUtils, ZapMQ.Methods;

{ TZapMQ }

constructor TZapMQ.Create(const AHost: string; const APort: Word);
begin
  FQueues := TObjectList<TZapMQQueue>.Create(True);
  FHost := AHost;
  FPort := APort;
end;

destructor TZapMQ.Destroy;
begin
  FQueues.Free;
  inherited;
end;

function TZapMQ.CreateRestConnection: TDSRestConnection;
begin
  Result := TDSRestConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.Host := FHost;
  Result.Port := FPort;
end;

function TZapMQ.FindQueue(const AQueueName: string): TZapMQQueue;
var
  Queue: TZapMQQueue;
begin
  for Queue in FQueues do
    if Queue.Name = AQueueName then
      Exit(Queue);
  Result := nil;
end;

function TZapMQ.GetMessage(const AQueueName: string): TZapJSONMessage;
var
  Conn: TDSRestConnection;
  Methods: TZapMethodsClient;
  Content: string;
begin
  Conn := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Conn);
    try
      Content := Methods.GetMessage(AQueueName);
      if Content <> '' then
        Result := TZapJSONMessage.FromJSON(Content)
      else
        Result := nil;
    finally
      Methods.Free;
    end;
  finally
    Conn.Free;
  end;
end;

function TZapMQ.GetRPCResponse(const AQueueName, AMessageId: string): string;
var
  Conn: TDSRestConnection;
  Methods: TZapMethodsClient;
begin
  Conn := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Conn);
    try
      Result := Methods.GetRPCResponse(AQueueName, AMessageId);
    finally
      Methods.Free;
    end;
  finally
    Conn.Free;
  end;
end;

function TZapMQ.SendMessage(const AQueueName: string; const AMessage: TZapJSONMessage): string;
var
  Conn: TDSRestConnection;
  Methods: TZapMethodsClient;
  JSON: TJSONObject;
begin
  Conn := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Conn);
    JSON := AMessage.ToJSON;
    try
      Result := Methods.UpdateMessage(AQueueName, JSON.ToString);
    finally
      JSON.Free;
      Methods.Free;
    end;
  finally
    Conn.Free;
  end;
end;

procedure TZapMQ.SendRPCResponse(const AQueueName, AMessageId, AResponse: string);
var
  Conn: TDSRestConnection;
  Methods: TZapMethodsClient;
begin
  Conn := CreateRestConnection;
  try
    Methods := TZapMethodsClient.Create(Conn);
    try
      Methods.UpdateRPCResponse(AQueueName, AMessageId, AResponse);
    finally
      Methods.Free;
    end;
  finally
    Conn.Free;
  end;
end;

end.

