program AndroControlClient;

uses
  System.StartUpCopy,
  FMX.Forms,
  unMain in 'unMain.pas' {fmMain},
  unMedia in 'unMedia.pas' {fmMedia},
  unPower in 'unPower.pas' {fmPower};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmMedia, fmMedia);
  Application.CreateForm(TfmPower, fmPower);
  Application.Run;
end.
