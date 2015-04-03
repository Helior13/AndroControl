unit unMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  IPPeerServer, System.Tether.Manager, System.Tether.AppProfile, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FMX.TabControl,
  FMX.ListView.Types, FMX.ListView, FMX.Ani, unMedia, unPower;

type
  TfmMain = class(TForm)
    tthManager: TTetheringManager;
    tthProfile: TTetheringAppProfile;
    lbServers: TListBox;
    falbHeight: TFloatAnimation;
    btnKeyboard: TButton;
    btnMedia: TButton;
    btnPower: TButton;
    falbOpacity: TFloatAnimation;
    procedure tthManagerEndManagersDiscovery(const Sender: TObject;
      const ARemoteManagers: TTetheringManagerInfoList);
    procedure Discover;
    procedure FormCreate(Sender: TObject);
    procedure tthManagerEndProfilesDiscovery(const Sender: TObject;
      const ARemoteProfiles: TTetheringProfileInfoList);
    procedure ServerClick(Sender: TObject);
    procedure btnControlClick(Sender: TObject);
    procedure tthProfileResourceUpdated(const Sender: TObject;
      const AResource: TRemoteResource);
    procedure falbOpacityFinish(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation


{$R *.fmx}

procedure TfmMain.btnControlClick(Sender: TObject);
begin
 case TButton(Sender).Tag of
    1: fmMedia.Show;
    3: fmPower.Show;
 end;

end;

procedure TfmMain.Discover;   // Запуск обнаружения серверов
var i: integer;
begin
for i := tthManager.PairedManagers.Count-1 downto 0 do
    tthManager.UnPairManager(tthManager.PairedManagers[i]);

tthManager.DiscoverManagers;
end;


procedure TfmMain.falbOpacityFinish(Sender: TObject);
begin
Sleep(1000);
falbHeight.Start;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Discover;
end;

procedure TfmMain.ServerClick(Sender: TObject); // Выбор компьютера для управления
begin
  tthManager.PairManager(tthManager.RemoteManagers[TListBoxItem(Sender).Tag]);
 // falbHeight.Start; // закрываем окно выбора компьютера
end;

procedure TfmMain.tthManagerEndManagersDiscovery(const Sender: TObject;
  const ARemoteManagers: TTetheringManagerInfoList);
var
  i: integer;
  ObjServer:  TListBoxItem;
begin
if ARemoteManagers.Count > 1 then
    begin
      for i := 0 to ARemoteManagers.Count -1 do                           // Добавляем в список только сервера
              if ARemoteManagers[i].ManagerText <> 'tthManagerClient' then
                  begin
                  ObjServer := TListBoxItem.Create(Self);
                  ObjServer.StyledSettings := ObjServer.StyledSettings - [TStyledSetting.ssOther];
                  ObjServer.Text := ARemoteManagers[i].ManagerText;
                  ObjServer.Tag := i;
                  ObjServer.OnClick := ServerClick;
                  ObjServer.Margins.Top := 10;
                  ObjServer.TextAlign := TTextAlign.Center;
                  lbServers.AddObject(ObjServer);
                  end;
      lbServers.Height := (lbServers.ItemHeight +12) * lbServers.Count;
      lbServers.Opacity := 1;
    end
    else
      tthManager.PairManager(tthManager.RemoteManagers[0]);
end;

procedure TfmMain.tthManagerEndProfilesDiscovery(const Sender: TObject;
  const ARemoteProfiles: TTetheringProfileInfoList);
Var i: integer;
    Item: TListBoxItem;
begin
tthProfile.Connect(tthManager.RemoteProfiles[0]);
tthProfile.SubscribeToRemoteItem(tthManager.RemoteProfiles[0],'Volume');
fmMedia.tbVolume.Value := tthProfile.GetRemoteResourceValue(tthManager.RemoteProfiles[0],'Volume').Value.AsSingle;

lbServers.Clear;
lbServers.Items.Add('Connected to '+ tthManager.PairedManagers[0].ManagerText);
Item := lbServers.ItemByIndex(0);
Item.StyledSettings := Item.StyledSettings - [TStyledSetting.ssOther];
Item.TextAlign := TTextAlign.Center;
falbOpacity.Start;
end;

procedure TfmMain.tthProfileResourceUpdated(const Sender: TObject;
  const AResource: TRemoteResource);
begin
    if (AResource.Name = 'Volume')  then
      with fmMedia do
        begin
        tbVolume.OnChange := nil;
        tbVolume.Value := AResource.Value.AsSingle;
        tbVolume.OnChange := tbVolumeChange;
        end;

end;

end.
