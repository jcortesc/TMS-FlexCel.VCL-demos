unit UMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  VCL.FlexCel.Core, FlexCel.XlsAdapter, FlexCel.Report, FlexCel.Render,
  {$if CompilerVersion >= 23.0} System.UITypes, {$IFEND}
  ShellApi,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls, DB, ADODB;

type
  TMainForm = class(TForm)
    btnCancel: TButton;
    btnGo: TButton;
    SaveDialog: TSaveDialog;
    Label1: TLabel;
    ADOConnection: TADOConnection;
    Customers: TADODataSet;
    Employees: TADODataSet;
    DsEmployees: TDataSource;
    Orders: TADODataSet;
    procedure btnCancelClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure RunReport;
    function GetDataPath: string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation
uses IOUtils;

{$R *.dfm}

function DBFile: string;
begin
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), '..\..\..\SharedData\Northwind.mdb');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ADOConnection.ConnectionString := StringReplace(ADOConnection.ConnectionString, 'Northwind.mdb', DbFile, []);
end;

procedure TMainForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.btnGoClick(Sender: TObject);
begin
  RunReport;

end;

function TMainForm.GetDataPath: string;
begin
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), '..\..');
end;


procedure TMainForm.RunReport;
var
  Report: TFlexCelReport;
begin
  if not SaveDialog.Execute then exit;

  Report := TFlexCelReport.Create(true);
  try
    Report.AddTable('Employees', Employees);
    Report.AddTable('Orders', Orders);
    Report.AddTable('Customers', Customers);
    Report.Run(
      TPath.Combine(GetDataPath, 'Split Datasets.template.xls'),
      SaveDialog.FileName);
  finally
    Report.Free;
  end;

  if MessageDlg('Do you want to open the generated file?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ShellExecute(0, 'open', PCHAR(SaveDialog.FileName), nil, nil, SW_SHOWNORMAL);
  end;


end;

end.
