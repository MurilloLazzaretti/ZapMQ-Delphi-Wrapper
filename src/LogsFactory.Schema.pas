unit LogsFactory.Schema;

interface

type
  TOccurrenceType = (otInformation, otException, otError);

  TLogsFactorySchema = class
  private
    FOccurrenceDate: TDateTime;
    FTitle: string;
    FText: string;
    FApplicationName: string;
    FOccurrenceType: TOccurrenceType;
    FOccurrenceOrigin: string;
    procedure SetApplicationName(const Value: string);
    procedure SetOccurrenceDate(const Value: TDateTime);
    procedure SetOccurrenceType(const Value: TOccurrenceType);
    procedure SetText(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetOccurrenceOrigin(const Value: string);
  public
    property OccurrenceType : TOccurrenceType read FOccurrenceType write SetOccurrenceType;
    property OccurrenceDate : TDateTime read FOccurrenceDate write SetOccurrenceDate;
    property OccurrenceOrigin : string read FOccurrenceOrigin write SetOccurrenceOrigin;
    property ApplicationName : string read FApplicationName write SetApplicationName;
    property Title : string read FTitle write SetTitle;
    property Text : string read FText write SetText;
  end;

implementation

{ TLogsFactorySchema }

procedure TLogsFactorySchema.SetApplicationName(const Value: string);
begin
  FApplicationName := Value;
end;

procedure TLogsFactorySchema.SetOccurrenceDate(const Value: TDateTime);
begin
  FOccurrenceDate := Value;
end;

procedure TLogsFactorySchema.SetOccurrenceOrigin(const Value: string);
begin
  FOccurrenceOrigin := Value;
end;

procedure TLogsFactorySchema.SetOccurrenceType(const Value: TOccurrenceType);
begin
  FOccurrenceType := Value;
end;

procedure TLogsFactorySchema.SetText(const Value: string);
begin
  FText := Value;
end;

procedure TLogsFactorySchema.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

end.
