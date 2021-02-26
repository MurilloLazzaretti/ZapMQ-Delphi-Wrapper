unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Datasnap.DSClientRest, Vcl.StdCtrls, ZapMQ.Wrapper,
  ZapMQ.Message.JSON, JSON, Vcl.WinXCtrls;

type
  TFrmMain = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Edit1: TEdit;
    Button4: TButton;
    Button6: TButton;
    Label5: TLabel;
    ListBox1: TListBox;
    GroupBox2: TGroupBox;
    Button2: TButton;
    Button5: TButton;
    Edit2: TEdit;
    Edit4: TEdit;
    Label3: TLabel;
    Label6: TLabel;
    GroupBox3: TGroupBox;
    Button3: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Edit3: TEdit;
    Button7: TButton;
    Button9: TButton;
    ActivityIndicator1: TActivityIndicator;
    Button8: TButton;
    Edit5: TEdit;
    Edit6: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    Button10: TButton;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
  private
    function ZapMQHandler(pMessage : TZapJSONMessage;
      var pProcessing : boolean) : TJSONObject;
    function ZapMQHandlerRPCMessage(pMessage : TZapJSONMessage;
      var pProcessing : boolean) : TJSONObject;
    function ZapMQHandlerBenchMark(pMessage : TZapJSONMessage;
      var pProcessing : boolean) : TJSONObject;
    function ZapMQHandlerNewPublish(pMessage : TZapJSONMessage;
      var pProcessing : boolean) : TJSONObject;
    procedure ZapMQHandlerRPC(pMessage : TJSONObject);
    procedure RPCExpired(const pMessage : TZapJSONMessage);
  public
    ZapMQWrapper : TZapMQWrapper;
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  BenchMark;

{$R *.dfm}

procedure TFrmMain.Button10Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to StrToInt(Edit5.Text) do
  begin
    ZapMQWrapper.UnBind('BenchMark' + I.ToString);
    Memo1.Lines.Add('*** UnBinded in '+ 'BenchMark' + I.ToString +' ***');
  end;
end;

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  ZapMQWrapper.Bind(Edit1.Text, ZapMQHandler);
  ListBox1.AddItem(Edit1.Text, nil);
  Memo1.Lines.Add('*** Binded in '+ Edit1.Text +' ***');
end;

procedure TFrmMain.Button2Click(Sender: TObject);
var
  JSON : TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('message', 'Message to Send');
    if ZapMQWrapper.SendMessage(Edit2.Text, JSON, StrToInt(Edit4.Text)) then
      Memo1.Lines.Add('*** Message Sended ***')
    else
      Memo1.Lines.Add('*** Error to Send Message ***');
  finally
    JSON.Free;
  end;
end;

procedure TFrmMain.Button3Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TFrmMain.Button4Click(Sender: TObject);
begin
  ZapMQWrapper.UnBind(Edit1.Text);
  ListBox1.Items.Delete(ListBox1.Items.IndexOf(Edit1.Text));
  Memo1.Lines.Add('*** UnBinded in '+ Edit1.Text +' ***');
end;

procedure TFrmMain.Button5Click(Sender: TObject);
var
  JSON : TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('RPC', 'RPC message recived');
    if ZapMQWrapper.SendRPCMessage(Edit2.Text, JSON, ZapMQHandlerRPC, StrToInt(Edit4.Text)) then
      Memo1.Lines.Add('*** RPC Message Sended '+ FormatDateTime('hh:mm:ss.zzz', now)+' ***')
    else
      Memo1.Lines.Add('*** Error to Send RPC Message ***');
  finally
    JSON.Free;
  end;
end;

procedure TFrmMain.Button6Click(Sender: TObject);
begin
  ZapMQWrapper.Bind(Edit1.Text, ZapMQHandlerRPCMessage);
  ListBox1.AddItem(Edit1.Text, nil);
  Memo1.Lines.Add('*** Binded in '+ Edit1.Text +' ***');
end;

procedure TFrmMain.Button7Click(Sender: TObject);
begin
  ZapMQWrapper.Bind(Edit1.Text, ZapMQHandlerNewPublish);
  ListBox1.AddItem(Edit1.Text, nil);
  Memo1.Lines.Add('*** Binded in '+ Edit1.Text +' ***');
end;

procedure TFrmMain.Button8Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to StrToInt(Edit5.Text) do
  begin
    ZapMQWrapper.Bind('BenchMark' + I.ToString, ZapMQHandlerBenchMark);
    Memo1.Lines.Add('*** Binded in '+ 'BenchMark' + I.ToString +' ***');
  end;
end;

procedure TFrmMain.Button9Click(Sender: TObject);
var
  BenchMark : TBenchMark;
begin
  Button9.Enabled := False;
  ActivityIndicator1.Animate := True;
  BenchMark := TBenchMark.Create('localhost', 5679);
  BenchMark.Cycles := StrToInt(Edit6.Text);
  BenchMark.Queues := StrToInt(Edit5.Text);
  BenchMark.Start;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ZapMQWrapper.Free;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ZapMQWrapper := TZapMQWrapper.Create('localhost', 5679);
  ZapMQWrapper.OnRPCExpired := RPCExpired;
  Memo1.Lines.Add('*** ZapMQ Wrapper Started ***');
end;

procedure TFrmMain.RPCExpired(const pMessage: TZapJSONMessage);
begin
  Memo1.Lines.Add('*** RPC Message Expired ***');
  Memo1.Lines.Add('Id:' + pMessage.Id);
end;

function TFrmMain.ZapMQHandler(pMessage : TZapJSONMessage;
  var pProcessing : boolean) : TJSONObject;
begin
  Memo1.Lines.Add('*** Processing Message '+FormatDateTime('hh:mm:ss.zzz', now)+' ***');
  Sleep(StrToInt(Edit3.Text));
  Memo1.Lines.Add(pMessage.Body.ToString);
  pProcessing := False;
  Memo1.Lines.Add('*** Message Processed ***');
  Result := nil;
end;

function TFrmMain.ZapMQHandlerBenchMark(pMessage: TZapJSONMessage;
  var pProcessing: boolean): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('RPC message', 'Answer');
  //Sleep(StrToInt(Edit3.Text));
  pProcessing := False;
end;

function TFrmMain.ZapMQHandlerNewPublish(pMessage: TZapJSONMessage;
  var pProcessing: boolean): TJSONObject;
var
  JSON : TJSONObject;
begin
  Memo1.Lines.Add('*** Processing Message '+FormatDateTime('hh:mm:ss.zzz', now)+' ***');
  Sleep(StrToInt(Edit3.Text));
  Memo1.Lines.Add(pMessage.Body.ToString);
  pProcessing := False;
  Memo1.Lines.Add('*** Message Processed ***');
  TThread.Queue(TThread.Current, procedure
  begin
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('TESTE', 'TESTESSSSS');
      ZapMQWrapper.SendMessage('Teste', JSON);
    finally
      JSON.Free;
    end;
  end);
  Result := nil;
end;

function TFrmMain.ZapMQHandlerRPCMessage(pMessage: TZapJSONMessage;
  var pProcessing: boolean): TJSONObject;
begin
  if pMessage.RPC then
  begin
    Memo1.Lines.Add('*** Processing Message '+FormatDateTime('hh:mm:ss.zzz', now)+' ***');
    Sleep(StrToInt(Edit3.Text));
    Memo1.Lines.Add(pMessage.Body.ToString);
    Memo1.Lines.Add('*** Message Processed ***');
    pProcessing := False;
    Result := TJSONObject.Create;
    Result.AddPair('RPC message', 'Answer');
  end
  else
    Result := nil;
end;

procedure TFrmMain.ZapMQHandlerRPC(pMessage: TJSONObject);
begin
  Memo1.Lines.Add('*** RPC Answer '+FormatDateTime('hh:mm:ss.zzz', now)+' ***');
  Memo1.Lines.Add(pMessage.ToString);
end;

end.
