object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'ZapMQ - Wrapper'
  ClientHeight = 742
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 514
    Height = 163
    Align = alTop
    Caption = 'Queues'
    TabOrder = 0
    ExplicitWidth = 676
    object Label5: TLabel
      Left = 5
      Top = 17
      Width = 34
      Height = 13
      Caption = 'Name :'
    end
    object Button1: TButton
      Left = 5
      Top = 63
      Width = 108
      Height = 25
      Caption = 'Bind Handler Publish'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 3
      Top = 36
      Width = 308
      Height = 21
      TabOrder = 1
    end
    object Button4: TButton
      Left = 218
      Top = 94
      Width = 93
      Height = 25
      Caption = 'UnBind'
      TabOrder = 2
      OnClick = Button4Click
    end
    object Button6: TButton
      Left = 119
      Top = 63
      Width = 93
      Height = 25
      Caption = 'Bind Handler RPC'
      TabOrder = 3
      OnClick = Button6Click
    end
    object ListBox1: TListBox
      AlignWithMargins = True
      Left = 352
      Top = 18
      Width = 157
      Height = 140
      Align = alRight
      Enabled = False
      ItemHeight = 13
      TabOrder = 4
      ExplicitLeft = 514
    end
    object Button7: TButton
      Left = 5
      Top = 94
      Width = 128
      Height = 25
      Caption = 'Bind Handler New Publish'
      TabOrder = 5
      OnClick = Button7Click
    end
  end
  object GroupBox2: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 172
    Width = 514
    Height = 109
    Align = alTop
    Caption = 'Messages'
    TabOrder = 1
    object Label3: TLabel
      Left = 167
      Top = 18
      Width = 24
      Height = 13
      Caption = 'TTL :'
    end
    object Label6: TLabel
      Left = 5
      Top = 18
      Width = 69
      Height = 13
      Caption = 'Queue Name :'
    end
    object Button2: TButton
      Left = 5
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Publish'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button5: TButton
      Left = 86
      Top = 64
      Width = 75
      Height = 25
      Caption = 'RPC'
      TabOrder = 1
      OnClick = Button5Click
    end
    object Edit2: TEdit
      Left = 5
      Top = 37
      Width = 156
      Height = 21
      TabOrder = 2
    end
    object Edit4: TEdit
      Left = 167
      Top = 37
      Width = 75
      Height = 21
      TabOrder = 3
      Text = '0'
    end
    object Button11: TButton
      Left = 167
      Top = 64
      Width = 75
      Height = 25
      Caption = 'LOG'
      TabOrder = 4
      OnClick = Button11Click
    end
  end
  object GroupBox3: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 460
    Width = 514
    Height = 279
    Align = alBottom
    Caption = 'Process'
    TabOrder = 2
    ExplicitLeft = -2
    ExplicitTop = 546
    ExplicitWidth = 669
    object Label1: TLabel
      Left = 354
      Top = 28
      Width = 73
      Height = 13
      Caption = 'Sleep Process :'
    end
    object Button3: TButton
      Left = 5
      Top = 21
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 0
      OnClick = Button3Click
    end
    object Memo1: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 53
      Width = 504
      Height = 221
      Align = alBottom
      TabOrder = 1
      ExplicitWidth = 666
    end
    object Edit3: TEdit
      Left = 433
      Top = 25
      Width = 76
      Height = 21
      TabOrder = 2
      Text = '1000'
    end
  end
  object GroupBox4: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 287
    Width = 514
    Height = 173
    Align = alTop
    Caption = 'BenchMark'
    TabOrder = 3
    ExplicitTop = 372
    ExplicitWidth = 676
    object Label2: TLabel
      Left = 131
      Top = 64
      Width = 38
      Height = 13
      Caption = 'Cycles :'
    end
    object Label4: TLabel
      Left = 117
      Top = 16
      Width = 44
      Height = 13
      Caption = 'Queues :'
    end
    object Label7: TLabel
      Left = 194
      Top = 63
      Width = 24
      Height = 13
      Caption = 'TTL :'
    end
    object Button8: TButton
      Left = 5
      Top = 31
      Width = 93
      Height = 25
      Caption = 'BenchMark Bind'
      TabOrder = 0
      OnClick = Button8Click
    end
    object Edit6: TEdit
      Left = 131
      Top = 82
      Width = 54
      Height = 21
      TabOrder = 1
      Text = '5'
    end
    object Edit5: TEdit
      Left = 117
      Top = 33
      Width = 54
      Height = 21
      TabOrder = 2
      Text = '3'
    end
    object ActivityIndicator1: TActivityIndicator
      Left = 42
      Top = 110
    end
    object Button9: TButton
      Left = 3
      Top = 79
      Width = 122
      Height = 25
      Caption = 'Start Send BenchMark'
      TabOrder = 4
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 181
      Top = 31
      Width = 122
      Height = 25
      Caption = 'BenchMark UnBind'
      TabOrder = 5
      OnClick = Button10Click
    end
    object RadioGroup1: TRadioGroup
      AlignWithMargins = True
      Left = 379
      Top = 18
      Width = 130
      Height = 150
      Align = alRight
      Caption = 'Priority'
      ItemIndex = 2
      Items.Strings = (
        'Low'
        'Medium Low'
        'Medium'
        'Medium High'
        'High')
      TabOrder = 6
      ExplicitLeft = 541
    end
    object Edit7: TEdit
      Left = 194
      Top = 82
      Width = 60
      Height = 21
      TabOrder = 7
      Text = '5000'
    end
  end
end
