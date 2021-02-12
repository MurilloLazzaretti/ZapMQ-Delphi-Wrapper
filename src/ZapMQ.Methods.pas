// 
// Created by the DataSnap proxy generator.
// 12/02/2021 18:19:44
// 

unit ZapMQ.Methods;

interface

uses System.JSON, Datasnap.DSProxyRest, Datasnap.DSClientRest, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TZapMethodsClient = class(TDSAdminRestClient)
  private
    FGetMessageCommand: TDSRestCommand;
    FUpdateMessageCommand: TDSRestCommand;
    FUpdateRPCResponseCommand: TDSRestCommand;
    FGetRPCResponseCommand: TDSRestCommand;
  public
    constructor Create(ARestConnection: TDSRestConnection); overload;
    constructor Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function GetMessage(pQueueName: string; const ARequestFilter: string = ''): string;
    function UpdateMessage(pQueueName: string; pMessage: string; const ARequestFilter: string = ''): string;
    function UpdateRPCResponse(pQueueName: string; pIdMessage: string; pResponse: string; const ARequestFilter: string = ''): string;
    function GetRPCResponse(pQueueName: string; pIdMessage: string; const ARequestFilter: string = ''): string;
  end;

const
  TZapMethods_GetMessage: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'pQueueName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'string')
  );

  TZapMethods_UpdateMessage: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'pQueueName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pMessage'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'string')
  );

  TZapMethods_UpdateRPCResponse: array [0..3] of TDSRestParameterMetaData =
  (
    (Name: 'pQueueName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pIdMessage'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pResponse'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'string')
  );

  TZapMethods_GetRPCResponse: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'pQueueName'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'pIdMessage'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'string')
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

function TZapMethodsClient.UpdateMessage(pQueueName: string; pMessage: string; const ARequestFilter: string): string;
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
  FUpdateMessageCommand.Execute(ARequestFilter);
  Result := FUpdateMessageCommand.Parameters[2].Value.GetWideString;
end;

function TZapMethodsClient.UpdateRPCResponse(pQueueName: string; pIdMessage: string; pResponse: string; const ARequestFilter: string): string;
begin
  if FUpdateRPCResponseCommand = nil then
  begin
    FUpdateRPCResponseCommand := FConnection.CreateCommand;
    FUpdateRPCResponseCommand.RequestType := 'GET';
    FUpdateRPCResponseCommand.Text := 'TZapMethods.UpdateRPCResponse';
    FUpdateRPCResponseCommand.Prepare(TZapMethods_UpdateRPCResponse);
  end;
  FUpdateRPCResponseCommand.Parameters[0].Value.SetWideString(pQueueName);
  FUpdateRPCResponseCommand.Parameters[1].Value.SetWideString(pIdMessage);
  FUpdateRPCResponseCommand.Parameters[2].Value.SetWideString(pResponse);
  FUpdateRPCResponseCommand.Execute(ARequestFilter);
  Result := FUpdateRPCResponseCommand.Parameters[3].Value.GetWideString;
end;

function TZapMethodsClient.GetRPCResponse(pQueueName: string; pIdMessage: string; const ARequestFilter: string): string;
begin
  if FGetRPCResponseCommand = nil then
  begin
    FGetRPCResponseCommand := FConnection.CreateCommand;
    FGetRPCResponseCommand.RequestType := 'GET';
    FGetRPCResponseCommand.Text := 'TZapMethods.GetRPCResponse';
    FGetRPCResponseCommand.Prepare(TZapMethods_GetRPCResponse);
  end;
  FGetRPCResponseCommand.Parameters[0].Value.SetWideString(pQueueName);
  FGetRPCResponseCommand.Parameters[1].Value.SetWideString(pIdMessage);
  FGetRPCResponseCommand.Execute(ARequestFilter);
  Result := FGetRPCResponseCommand.Parameters[2].Value.GetWideString;
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
  FUpdateRPCResponseCommand.DisposeOf;
  FGetRPCResponseCommand.DisposeOf;
  inherited;
end;

end.
