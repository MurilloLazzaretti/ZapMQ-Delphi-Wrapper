object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'ZapMQ - Wrapper'
  ClientHeight = 560
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
    Height = 126
    Align = alTop
    Caption = 'Queues'
    TabOrder = 0
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
      Height = 103
      Align = alRight
      Enabled = False
      ItemHeight = 13
      TabOrder = 4
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
    Top = 135
    Width = 514
    Height = 137
    Align = alTop
    Caption = 'Messages'
    TabOrder = 1
    object Label3: TLabel
      Left = 181
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
    object Label2: TLabel
      Left = 288
      Top = 47
      Width = 38
      Height = 13
      Caption = 'Cycles :'
    end
    object Label4: TLabel
      Left = 288
      Top = 88
      Width = 44
      Height = 13
      Caption = 'Queues :'
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
      Width = 170
      Height = 21
      TabOrder = 2
    end
    object Edit4: TEdit
      Left = 181
      Top = 37
      Width = 60
      Height = 21
      TabOrder = 3
      Text = '0'
    end
    object Button9: TButton
      Left = 389
      Top = 62
      Width = 122
      Height = 25
      Caption = 'Start Send BenchMark'
      TabOrder = 4
      OnClick = Button9Click
    end
    object ActivityIndicator1: TActivityIndicator
      Left = 433
      Top = 93
    end
    object Button8: TButton
      Left = 288
      Top = 16
      Width = 93
      Height = 25
      Caption = 'BenchMark Bind'
      TabOrder = 6
      OnClick = Button8Click
    end
    object Edit5: TEdit
      Left = 288
      Top = 105
      Width = 54
      Height = 21
      TabOrder = 7
      Text = '3'
    end
    object Edit6: TEdit
      Left = 288
      Top = 65
      Width = 54
      Height = 21
      TabOrder = 8
      Text = '5'
    end
    object Button10: TButton
      Left = 389
      Top = 16
      Width = 122
      Height = 25
      Caption = 'BenchMark UnBind'
      TabOrder = 9
      OnClick = Button10Click
    end
  end
  object GroupBox3: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 278
    Width = 514
    Height = 279
    Align = alBottom
    Caption = 'Process'
    TabOrder = 2
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
end
