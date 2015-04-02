unit unMedia;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls;

type
  TfmMedia = class(TForm)
    btnFWD: TButton;
    btnLaunch: TButton;
    btnMute: TButton;
    btnPlay: TButton;
    btnRWD: TButton;
    btnVolDown: TButton;
    btnVolUp: TButton;
    tbVolume: TTrackBar;
    procedure btnMediaClick(Sender: TObject);
    procedure tbVolumeChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMedia: TfmMedia;

implementation

uses unMain;

{$R *.fmx}

procedure TfmMedia.btnMediaClick(Sender: TObject);
begin
// Отправляем код нажатой клавиши
  fmMain.tthProfile.Resources.FindByName('Key').Value :=  TButton(Sender).Tag;
end;



procedure TfmMedia.tbVolumeChange(Sender: TObject);
begin
// Отправляем значение громкости
  fmMain.tthProfile.Resources.FindByName('Volume').Value := tbVolume.Value;
end;

procedure TfmMedia.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
Case Key of
   vkVolumeUp:     begin tbVolume.Value := tbVolume.Value + 0.1; Key := 0; end;
   vkVolumeDown:   begin tbVolume.Value := tbVolume.Value - 0.1; Key := 0; end;
  End;
end;

procedure TfmMedia.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  Case Key of
   vkVolumeUp:     Key := 0;
   vkVolumeDown:   Key := 0;
  End;
end;

end.
