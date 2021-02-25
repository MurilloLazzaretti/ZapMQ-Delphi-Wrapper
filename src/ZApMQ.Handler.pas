unit ZApMQ.Handler;

interface

uses
  ZapMQ.Message.JSON, JSON;

type
  TZapMQHanlder = reference to function(pMessage : TZapJSONMessage;
    var pProcessing : boolean) : TJSONObject;
  TZapMQHandlerRPC = reference to procedure(pMessage : TJSONObject);

implementation

end.
