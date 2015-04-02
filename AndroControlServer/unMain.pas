unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IPPeerClient, IPPeerServer, ActiveX,
  System.Tether.Manager, System.Tether.AppProfile, Vcl.StdCtrls, MMDeviceAPI,  Vcl.ComCtrls, System.Generics.Collections;

type
  TfmMain = class(TForm)
    tthManager: TTetheringManager;
    tthProfile: TTetheringAppProfile;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure tthManagerPairedFromLocal(const Sender: TObject;
      const AManagerInfo: TTetheringManagerInfo);
    procedure tthManagerEndProfilesDiscovery(const Sender: TObject;
      const ARemoteProfiles: TTetheringProfileInfoList);
    procedure tthProfileResourceUpdated(const Sender: TObject;
      const AResource: TRemoteResource);
    procedure tthManagerRemoteManagerShutdown(const Sender: TObject;
      const AManagerIdentifier: string);

  private
    FMMDev: IMMDevice;
    FMMDevEnum: IMMDeviceEnumerator;
    FEndpoint: IAudioEndpointVolume;
    FVolumeUpdating: Boolean;
    procedure InitMasterVolume;
    procedure UpdateMasterVolume;
  public
    property VolumeUpdating: Boolean read FVolumeUpdating write FVolumeUpdating;
  end;

TMyEndpointVolumeCallback = class(TInterfacedObject, IAudioEndpointVolumeCallback)
  public
    function OnNotify(pNotify: PAUDIO_VOLUME_NOTIFICATION_DATA): HRESULT; stdcall;
  end;

  function SetSuspendState(hibernate, forcecritical, disablewakeevent: boolean): boolean;
        stdcall; external 'powrprof.dll' name 'SetSuspendState';


var
  fmMain: TfmMain;
  VolDeny: boolean;
implementation

{$R *.dfm}



procedure TfmMain.FormCreate(Sender: TObject);
function GetComputerNetName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;
begin
  tthManager.Text := GetComputerNetName;
    // Только для висты и выше. Для изменения громкости
  if (Win32Platform <> VER_PLATFORM_WIN32_NT) or (Win32MajorVersion < 6) then
  begin
    ShowMessage('For Vista and above only.');
 //   Application.Terminate;
  end;

  InitMasterVolume;
end;

procedure TfmMain.tthManagerEndProfilesDiscovery(const Sender: TObject;
  const ARemoteProfiles: TTetheringProfileInfoList);
  Var ActiveProfile, i : integer;
      RRLIst : TList<TRemoteResource>;
begin
//показываем что получили профайлы, коннектимся к профайлу и подписываемся на все события
ActiveProfile := tthManager.RemoteProfiles.Count - 1;
ListBox1.Items.Add(tthManager.RemoteProfiles[ActiveProfile].ProfileText);
tthProfile.Connect(tthManager.RemoteProfiles[ActiveProfile]);
RRList:=tthProfile.GetRemoteProfileResources(tthManager.RemoteProfiles[ActiveProfile]);

for i := 0 to RRList.Count-1 do    //Подписываемся на все ресурсы
    tthProfile.SubscribeToRemoteItem(tthManager.RemoteProfiles[ActiveProfile],RRLIst[i]);
end;

procedure TfmMain.tthManagerPairedFromLocal(const Sender: TObject;
  const AManagerInfo: TTetheringManagerInfo);
begin   //Удалить
ListBox1.Items.Add(AManagerInfo.ManagerText);
end;

procedure TfmMain.tthManagerRemoteManagerShutdown(const Sender: TObject;
  const AManagerIdentifier: string);
begin
//tthManager.DiscoverManagers;
end;

procedure TfmMain.tthProfileResourceUpdated(const Sender: TObject;
  const AResource: TRemoteResource);
function MyExitWindows(RebootParam: Longword): Boolean;
var
  TTokenHd: THandle;
  TTokenPvg: TTokenPrivileges;
  cbtpPrevious: DWORD;
  rTTokenPvg: TTokenPrivileges;
  pcbtpPreviousRequired: DWORD;
  tpResult: Boolean;
const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    tpResult := OpenProcessToken(GetCurrentProcess(),
      TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
      TTokenHd);
    if tpResult then
    begin
      tpResult := LookupPrivilegeValue(nil,
                                       SE_SHUTDOWN_NAME,
                                       TTokenPvg.Privileges[0].Luid);
      TTokenPvg.PrivilegeCount := 1;
      TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      cbtpPrevious := SizeOf(rTTokenPvg);
      pcbtpPreviousRequired := 0;
      if tpResult then
        AdjustTokenPrivileges(TTokenHd,
                                      False,
                                      TTokenPvg,
                                      cbtpPrevious,
                                      rTTokenPvg,
                                      pcbtpPreviousRequired);
    end;
  end;
  Result := ExitWindowsEx(RebootParam, 0);
end;
begin
case AResource.Name[1] of
{Key}   'K': begin     // Нажатие клавиши клавиатуры
               ListBox1.Items.Add(AResource.Value.AsInteger.ToString());
               keybd_event(AResource.Value.AsInteger,0,0,0);
               keybd_event(AResource.Value.AsInteger,0,KEYEVENTF_KEYUP,0);
             end;
{Volume}'V': begin     // Изменение громкости
             VolDeny := True;
              if not FVolumeUpdating then
               FEndPoint.SetMasterVolumeLevelScalar(AResource.Value.AsSingle, nil);
             end;
{Power} 'P': begin      // Управление питанием и сеансом
             case AResource.Value.AsInteger of
               10: LockWorkStation;
               20: SetSuspendState(True,False,False);
               21: SetSuspendState(False,False,False);
                  else
                    MyExitWindows(AResource.Value.AsInteger or EWX_FORCE);
                 end;
             end;
  end;
end;

 // Обработка изменения громкости
procedure TfmMain.InitMasterVolume;
var
  PropVar: ^tag_inner_PROPVARIANT;
  MyEndpointVolumeCallback: IAudioEndpointVolumeCallback;
begin
  PropVar := nil;
  CoCreateInstance(CLASS_MMDeviceEnumerator, nil, CLSCTX_ALL, IID_IMMDeviceEnumerator,
    FMMDevEnum);

  FMMDevEnum.GetDefaultAudioEndpoint(eRender, eMultimedia, FMMDev);
  FMMDev.Activate(IID_IAudioEndpointVolume, CLSCTX_ALL, PropVar^, Pointer(FEndPoint));

  // Volume changes handler.
  MyEndpointVolumeCallback := TMyEndpointVolumeCallback.Create;
  FEndPoint.RegisterControlChangeNotify(MyEndpointVolumeCallback);

  UpdateMasterVolume;
end;

procedure TfmMain.UpdateMasterVolume;
var
  VolLevel: Single;
begin
  FEndPoint.GetMasterVolumeLevelScalar(VolLevel);
  tthProfile.Resources.FindByName('Volume').Value := VolLevel;
end;

{ TMyEndpointVolumeCallback }

function TMyEndpointVolumeCallback.OnNotify(
  pNotify: PAUDIO_VOLUME_NOTIFICATION_DATA): HRESULT;
begin
  Result := S_OK;

  fmMain.VolumeUpdating := True;
  try
  if not VolDeny then
     fmMain.tthProfile.Resources.FindByName('Volume').Value := pNotify.fMasterVolume;
  finally
    fmMain.VolumeUpdating := False;
    VolDeny := False;
  end;
end;
 // Обработка изменения громкости

end.
