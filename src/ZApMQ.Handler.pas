unit ZapMQ.Handler;

interface

uses
  ZapMQ.Message.JSON, System.JSON;

type
  TZapMQHandler = reference to function(pMessage: TZapJSONMessage; var pProcessing: Boolean): TJSONObject;
  TZapMQHandlerRPC = reference to procedure(pMessage: TJSONObject; var pProcessing: Boolean);

implementation

end.

