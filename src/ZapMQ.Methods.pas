// 
// Created by the DataSnap proxy generator.
// 12/02/2021 10:38:27
// 

unit ZapMQ.Methods;

interface

uses System.JSON, Datasnap.DSProxyRest, Datasnap.DSClientRest, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TZapMethodsClient = class(TDSAdminRestClient)
  private
    FGetMessageCommand: TDSRestCommand;
    FUpdateMessageCommand: TDSRestCommand;
    FUpdateMessageCommand_Cache: TDSRestCommand;
  public
    constructor Create(ARestConnection: TDSRestConnection); overload;
    constructor Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function GetMessage(pQueueName: string; const ARequestFilter: string = ''): string;
    function UpdateMessage(pQueueName: string; pMessage: string; pTTL: Word; const ARequestFilter: string = ''): TJSONValue;
    function UpdateMessage_Cache(pQueueName: string; pMessage: string; pTTL: Word; const ARequestFilter: string = ''): IDSRestCachedJSONValue;
  end;

const
  TZapMethods_GetMessage: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'pQueueName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'string')
  );

  TZapMethods_UpdateMessage: array [0..3] of TDSRestParameterMetaData =
  (
    (Name: 'pQueueName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pMessage'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pTTL'; Direction: 1; DBXType: 12; TypeName: 'Word'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TJSONValue')
  );

  TZapMethods_UpdateMessage_Cache: array [0..3] of TDSRestParameterMetaData =
  (
    (Name: 'pQueueName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pMessage'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pTTL'; Direction: 1; DBXType: 12; TypeName: 'Word'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

implementation

function TZapMethodsClient.GetMessage(pQueueName: string; const ARequestFilter: string): string;
begin
  if FGetMessageCommand = nil then
  begin
    FGetMessageCommand := FConnection.CreateCommand;
    FGetMessageCommand.RequestType := 'GET';
    FGetMessageCommand.Text := 'TZapMethods.GetMessage';
    FGetMessageCommand.Prepare(TZapMethods_GetMessage);
  end;
  FGetMessageCommand.Parameters[0].Value.SetWideString(pQueueName);
  FGetMessageCommand.Execute(ARequestFilter);
  Result := FGetMessageCommand.Parameters[1].Value.GetWideString;
end;

function TZapMethodsClient.UpdateMessage(pQueueName: string; pMessage: string; pTTL: Word; const ARequestFilter: string): TJSONValue;
begin
  if FUpdateMessageCommand = nil then
  begin
    FUpdateMessageCommand := FConnection.CreateCommand;
    FUpdateMessageCommand.RequestType := 'GET';
    FUpdateMessageCommand.Text := 'TZapMethods.UpdateMessage';
    FUpdateMessageCommand.Prepare(TZapMethods_UpdateMessage);
  end;
  FUpdateMessageCommand.Parameters[0].Value.SetWideString(pQueueName);
  FUpdateMessageCommand.Parameters[1].Value.SetWideString(pMessage);
  FUpdateMessageCommand.Parameters[2].Value.SetUInt16(pTTL);
  FUpdateMessageCommand.Execute(ARequestFilter);
  Result := TJSONValue(FUpdateMessageCommand.Parameters[3].Value.GetJSONValue(FInstanceOwner));
end;

function TZapMethodsClient.UpdateMessage_Cache(pQueueName: string; pMessage: string; pTTL: Word; const ARequestFilter: string): IDSRestCachedJSONValue;
begin
  if FUpdateMessageCommand_Cache = nil then
  begin
    FUpdateMessageCommand_Cache := FConnection.CreateCommand;
    FUpdateMessageCommand_Cache.RequestType := 'GET';
    FUpdateMessageCommand_Cache.Text := 'TZapMethods.UpdateMessage';
    FUpdateMessageCommand_Cache.Prepare(TZapMethods_UpdateMessage_Cache);
  end;
  FUpdateMessageCommand_Cache.Parameters[0].Value.SetWideString(pQueueName);
  FUpdateMessageCommand_Cache.Parameters[1].Value.SetWideString(pMessage);
  FUpdateMessageCommand_Cache.Parameters[2].Value.SetUInt16(pTTL);
  FUpdateMessageCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedJSONValue.Create(FUpdateMessageCommand_Cache.Parameters[3].Value.GetString);
end;

constructor TZapMethodsClient.Create(ARestConnection: TDSRestConnection);
begin
  inherited Create(ARestConnection);
end;

constructor TZapMethodsClient.Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ARestConnection, AInstanceOwner);
end;

destructor TZapMethodsClient.Destroy;
begin
  FGetMessageCommand.DisposeOf;
  FUpdateMessageCommand.DisposeOf;
  FUpdateMessageCommand_Cache.DisposeOf;
  inherited;
end;

end.
