unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.Grids,
  Data.DB, Data.SqlExpr, CPort;

type
  TMainForm = class(TForm)
    pnlBackground: TPanel;
    lblTitle: TLabel;
    lblTeamName: TLabel;
    lblDate: TLabel;
    gridWeatherData: TStringGrid;
    SQLConnection1: TSQLConnection;
    SQLQuery1: TSQLQuery;
    ComPort1: TComPort;
    procedure FormCreate(Sender: TObject);
  private
    procedure UpdateWeatherDataFromDB;
    procedure ConfigureGridAppearance;
    procedure UpdateDate;
    procedure SendDataToDisplay;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Width := 480;
  Height := 320;

  lblTeamName.Caption := 'MetereoTech';
  lblTeamName.Font.Size := 16;
  lblTeamName.Font.Color := clBlue;
  lblTeamName.Font.Style := [fsBold];
  lblTeamName.Left := 10;
  lblTeamName.Top := 10;

  UpdateDate;
  ConfigureGridAppearance;
  UpdateWeatherDataFromDB; // Load and display data from MySQL database
  
  ComPort1.Port := 'COM3'; // Set this to your USB port
  ComPort1.BaudRate := br9600;
  ComPort1.DataBits := dbEight;
  ComPort1.StopBits := sbOneStopBit;
  ComPort1.Parity.Bits := prNone;
  ComPort1.Open;
end;

procedure TMainForm.UpdateDate;
begin
  lblDate.Caption := 'Date: ' + FormatDateTime('dd/mm/yyyy', Now);
  lblDate.Font.Size := 10;
  lblDate.Left := 350;
  lblDate.Top := 10;
end;

procedure TMainForm.UpdateWeatherDataFromDB;
begin
  SQLConnection1.ConnectionString := 'DriverName=MySQL;HostName=localhost;Database=seu_banco_de_dados;User_Name=seu_usuario;Password=sua_senha;';
  SQLConnection1.LoginPrompt := False;
  SQLConnection1.Connected := True;

  SQLQuery1.SQL.Text := 'SELECT variavel, atual, media, minimo, maximo FROM tabela_dados ORDER BY variavel';
  SQLQuery1.Open;

  gridWeatherData.RowCount := SQLQuery1.RecordCount + 1;
  gridWeatherData.ColCount := 5; // Variable, Current, Average, Min, Max

  gridWeatherData.Cells[0, 0] := 'Variable';
  gridWeatherData.Cells[1, 0] := 'Current';
  gridWeatherData.Cells[2, 0] := 'Average';
  gridWeatherData.Cells[3, 0] := 'Min';
  gridWeatherData.Cells[4, 0] := 'Max';

  var RowIndex: Integer := 1;
  while not SQLQuery1.Eof do
  begin
    gridWeatherData.Cells[0, RowIndex] := SQLQuery1.Fields[0].AsString;
    gridWeatherData.Cells[1, RowIndex] := SQLQuery1.Fields[1].AsString;
    gridWeatherData.Cells[2, RowIndex] := SQLQuery1.Fields[2].AsString;
    gridWeatherData.Cells[3, RowIndex] := SQLQuery1.Fields[3].AsString;
    gridWeatherData.Cells[4, RowIndex] := SQLQuery1.Fields[4].AsString;
    Inc(RowIndex);
    SQLQuery1.Next;
  end;

  SQLQuery1.Close;
  SQLConnection1.Connected := False;
end;

procedure TMainForm.ConfigureGridAppearance;
begin
  gridWeatherData.Font.Name := 'Arial';
  gridWeatherData.Font.Size := 10;
  gridWeatherData.DefaultRowHeight := 24;
  gridWeatherData.FixedRows := 1;
  gridWeatherData.Options := gridWeatherData.Options + [goRowSelect];
  gridWeatherData.GridLineColor := clSilver;
  gridWeatherData.FixedColor := clBtnFace;
  gridWeatherData.Color := clWindow;
end;

end.
