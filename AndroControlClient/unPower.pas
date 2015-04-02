unit unPower;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls;

type
  TfmPower = class(TForm)
    btnPowerOff: TButton;
    btnReboot: TButton;
    btnLogOff: TButton;
    btnLock: TButton;
    btnHybernate: TButton;
    btnSuspend: TButton;
    procedure btnPowerClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPower: TfmPower;

implementation

uses unMain;

{$R *.fmx}


procedure TfmPower.btnPowerClick(Sender: TObject);
begin
fmMain.tthProfile.Resources.FindByName('Power').Value := Tbutton(Sender).Tag;
end;

end.
