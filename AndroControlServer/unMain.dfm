object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Server'
  ClientHeight = 559
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 580
    Height = 193
    Align = alTop
    ItemHeight = 13
    TabOrder = 0
  end
  object tthManager: TTetheringManager
    OnEndProfilesDiscovery = tthManagerEndProfilesDiscovery
    OnPairedFromLocal = tthManagerPairedFromLocal
    OnRemoteManagerShutdown = tthManagerRemoteManagerShutdown
    Text = 'tthManagerServer'
    AllowedAdapters = 'Network'
    Left = 48
    Top = 16
  end
  object tthProfile: TTetheringAppProfile
    Manager = tthManager
    Text = 'tthProfileServer'
    Actions = <>
    Resources = <
      item
        Name = 'Volume'
        IsPublic = True
      end>
    OnResourceUpdated = tthProfileResourceUpdated
    Left = 48
    Top = 64
  end
end
