## 🇧🇷 ZapMQ-Delphi-Wrapper 🇧🇷

Wrapper for Delphi to connect to [`ZapMQ server.`](https://github.com/MurilloLazzaretti/ZapMQ) With this wrapper you can connect easily and with a low code you can send/recive messages to/from others ZapMQ clients.

## ⚙️ Installation

Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:
``` sh
$ boss install https://github.com/MurilloLazzaretti/ZapMQ-Delphi-Wrapper.git
```
## ⚡️ First step

You need to create the Wrapper and provide the IP and Port of the ZapMQ service.

```delphi
uses ZapMQ.Wrapper;

var
  ZapMQWrapper : TZapMQWrapper;  
begin  
  ZapMQWrapper := TZapMQWrapper.Create('localhost', 5679);   
end;
```
Probably ZapMQWrapper will gona be a Field of a Form in your application or Property in a class, the code above is just for example.

Dont forget to free ZapMQWrapper when your application will terminate, this will stop all threads and kill others objects. (Please, no memory leak)

```delphi
begin  
  ZapMQWrapper.Free;
end;  
```

## 🧬 Resources

👂 _Publisher and Subscriber_

Send a message to a dermined queue with <b>no answer.</b> "One" of the "N" subscribers registered in this queue will process your message.

_Publisher_

In this type of message, you gonna send an JSON object to a determined queue and you gonna have <b>no answer.</b> See the code below :

```delphi
var
  JSON : TJSONObject;
  QueueName : string;
  TTL : Word;  
begin
  JSON := TJSONObject.Create;
  QueueName := 'MyQueue';
  TTL := 5000; 
  try
    JSON.AddPair('message', 'message to send');
    if ZapMQWrapper.SendMessage(QueueName, JSON, TTL) then
      // Success to send the message 
    else
      // Error to send the message
  finally
    JSON.Free;
  end;
end;
```
The code above, send a JSON Object, with no answer to 'MyQueue' and this message has a TTL of 5 seconds, so if this message was not processed for any subscriber of this queue in 5 seconds, this message will gonna die in the server. If you dont want a TTL to your message, send 0.

_Subscriber_

To subscribe your application in a Queue, just bind it with his name and associate a handler :

```delphi
begin
  ZapMQWrapper.Bind('MyQueue', MyHandler);
end;
```
Processing the message :

```delphi
function ZapMQHandler(pMessage : TZapJSONMessage; var pProcessing : boolean) : TJSONObject;
begin
  try
    // Do what you need with the message, for example :
    Log(pMessage.Body.ToString)
  finally
    pProcessing := False; // Telling the thread that you are done with this message and you can process another one.
  end;
  Result := nil; // This is a message with no response
end;
```
⚠️ _Warning_

If you dont tell the tread that you finish to process the message (pProcessing := False), you never recive another one.

🔌 _RPC_ 

Send a JSON object to a dermined queue with <b> answer.</b> "One" of the "N" subscribers registered in this queue will process your message and send an answer to the publisher.

_Publisher_

In this type of message, you gonna send an JSON object to a determined queue and you gonna have <b>an answer.</b> See the code below :

```delphi
var
  JSON : TJSONObject;
  QueueName : string;
  TTL : Word;  
begin
  JSON := TJSONObject.Create;
  QueueName := 'MyQueue';
  TTL := 5000; 
  try
    JSON.AddPair('message', 'message RPC to send');
    if ZapMQWrapper.SendRPCMessage(QueueName, JSON, ZapMQHandlerRPC, TTL) then
      // Success to send the message 
    else
      // Error to send the message
  finally
    JSON.Free;
  end;
end;
```

The code above, send a JSON Object to 'MyQueue' and 'wait' for response asynchronously. This message has a TTL of 5 seconds, so if this message was not processed/answered for any subscriber of this queue in 5 seconds, this message will gonna die in the server and the thread on the publisher too. If you dont want a TTL to your message, send 0, but take care of it, if this this message never process for any subscriber you gonna have a started thread for ever.

_OnRPCExpired_

There is an event on the wrapper that raise when one of your RPC message was expired, this could be useful !

```delphi
begin
  ZapMQWrapper.OnRPCExpired := RPCExpired;    
end;

procedure RPCExpired(const pMessage: TZapJSONMessage);
begin
  // Do what you need with the message, for example :
  Log('Message expired:' pMessage.Id);
end;

```

_Processing the answer_

```delphi
procedure ZapMQHandlerRPC(pMessage: TJSONObject);
begin
  // Do what you need with the message, for example :
  Log(pMessage.ToString)
end;
```

_Subscriber_

To subscribe your application in a Queue, just bind it with his name and associate a handler :

```delphi
begin
  ZapMQWrapper.Bind('MyQueue', MyRPCHandler);
end;
```

Processing the message :

```delphi
function MyRPCHandler(pMessage: TZapJSONMessage; var pProcessing: boolean): TJSONObject;
begin
  try
    // Do what you need with the message, for example :
    Log(pMessage.Body.ToString);
  finally
    pProcessing := False; // Telling the thread that you are done with this message and you can process another one.
  end;        
  // This is a message with response, so answer it
  Result := TJSONObject.Create;
  Result.AddPair('message', 'RPC answer');
end;
```
✏ _Tips_

The class TZapJSONMessage have a boolean property named RPC, if you want you can have only one handler for the same queue bind and if the publisher needs an answer you do, other wise, result nil :

```delphi
function MyRPCHandler(pMessage: TZapJSONMessage; var pProcessing: boolean): TJSONObject;
begin
  try
    // Do what you need with the message, for example :
    Log(pMessage.Body.ToString);
  finally
    pProcessing := False; // Telling the thread that you are done with this message and you can process another one.
  end;
  if pMessage.RPC then
  begin
    Result := TJSONObject.Create;
    Result.AddPair('message', 'RPC answer');
  end
  else
    Result := nil;
end;    
```
⚠️ _Warning_

If you dont tell the tread that you finish to process the message (pProcessing := False), you never recive another one.

🌐 _Exchange_ (Coming soon)

Send a message to a dermined queue with <b>no answer.</b> "All" of the subscribers registered in this queue will process your message. 