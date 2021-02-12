unit ZApMQ.Handler;

interface

uses
  JSON;

type
  TZapMQHanlder = reference to procedure(pMessage : TJSONObject;
    var pProcessing : boolean);

implementation

end.
