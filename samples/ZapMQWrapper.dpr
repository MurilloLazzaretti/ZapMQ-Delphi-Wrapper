program ZapMQWrapper;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {FrmMain},
  ZapMQ.Core in '..\src\ZapMQ.Core.pas',
  ZApMQ.Handler in '..\src\ZApMQ.Handler.pas',
  ZapMQ.Message.JSON in '..\src\ZapMQ.Message.JSON.pas',
  ZapMQ.Methods in '..\src\ZapMQ.Methods.pas',
  ZapMQ.Queue in '..\src\ZapMQ.Queue.pas',
  ZapMQ.Thread in '..\src\ZapMQ.Thread.pas',
  ZapMQ.Wrapper in '..\src\ZapMQ.Wrapper.pas',
  ZapMQ.Message.RPC in '..\src\ZapMQ.Message.RPC.pas',
  BenchMark in 'BenchMark.pas',
  BenchMarkResults in 'BenchMarkResults.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
