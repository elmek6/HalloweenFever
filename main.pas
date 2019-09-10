unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ImgList, StdCtrls, Buttons, jpeg, CheckLst;

const
  limX = 8;
  limY = 8;

type
  matris = array[1..limy,1..limx] of integer;

type
  TfrmMain = class(TForm)
    imgMain: TImage;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Image1: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    chlBolum: TCheckListBox;
    procedure imgMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure chlBolumClick(Sender: TObject);
  private
    { Private declarations }
    function MatrisGir:matris;
    procedure MatrisCik(var p: matris);
    procedure TasiSil(var m:matris ; x, y, z: integer);
    procedure BagSayYig(var m:matris; x, y, z:integer);
    procedure hepsinipozitifyap;
    procedure BosluklariSil(var m:matris);
    function ArtanTasSay(var m:matris): integer;
    procedure KutuKoy(x, y, z: integer);
    procedure KalanIhtimal;
    procedure UnDo;
    procedure ReDo;
  public
    { Public declarations }
  end;

var
  frmMain     :TfrmMain;
  globalsay   :integer;
  m           :matris;
  tsUnRedo    :TStrings;
  tsStages    :TStringList;

implementation

{$R *.dfm}

function TfrmMain.MatrisGir:matris;
  var x, y  :Integer;
begin
  for x := 1 to limX do
    for y := 1 to limY do
     showmessage('');// result[x, y] := strtoint(sagMain.Cells[x, y]);
end;

procedure TfrmMain.MatrisCik(var p: matris);
  var x, y  :Integer;
begin
  for y := 1 to limY do
    for x := 1 to limX do
      KutuKoy(x, y, m[y,x]);
end;


{ verilen pozisyondaki tasi siler }
procedure TfrmMain.TasiSil(var m:matris ; x, y, z: integer);
begin
  m[x,y] := 0; { tasin okunan parcalarini siler }

  if (x<limx)and(m[x+1,y] = z) then TasiSil(m, x+1, y, z); { saga baglanti }
  if (y<limy)and(m[x,y+1] = z) then TasiSil(m, x, y+1, z); { asagi baglanti }
  if (x>1)and(m[x-1,y] = z) then TasiSil(m, x-1, y, z); { sola baglanti }
  if (y>1)and(m[x,y-1] = z) then TasiSil(m, x, y-1, z); { yukari baglanti }
end;

procedure TfrmMain.BagSayYig(var m:matris; x, y, z:integer);
begin

  if m[x,y] = abs(z) then begin
    inc(globalsay);
    m[x,y] := -z; { sayilan grup elamanlarini negatif yapiyor }

    if (x<limx)and(m[x+1,y] = z) then BagSayYig(m, x+1, y, z); { saga baglanti }
    if (y<limy)and(m[x,y+1] = z) then BagSayYig(m, x, y+1, z); { asagi baglanti }
    if (x>1)and(m[x-1,y] = z) then BagSayYig(m, x-1, y, z); { sola baglanti }
    if (y>1)and(m[x,y-1] = z) then BagSayYig(m, x, y-1, z); { yukari baglanti }

  end;
end;


procedure TfrmMain.hepsinipozitifyap;
  var x, y:integer;
begin
  for y := 1 to limY do
    for x :=1  to limY do
        m[x,y] := abs(m[x,y]);
end;


procedure TfrmMain.imgMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    _x, _y, _z  :integer;
begin
  _x := x div 32 + 1;
  _y := y div 32 + 1;
  _z := m[_y,_x];

  if _z=0 then exit; {bosluga basildiginda hatayi onlemek icin}

  globalsay:=0;
  BagSayYig(m, _y, _x, _z);

  hepsinipozitifyap;
  if globalsay >=3 then begin
    ReDo;
    TasiSil(m, _y, _x, _z);
    BosluklariSil(m);
    matriscik(m);
  end;

  kalanihtimal;
end;


{ bos sutun olustugunda rakamlari bos sutuna kaydirir }
procedure TfrmMain.BosluklariSil(var m:matris);
  var
    x, y, z:integer;
    i      :integer;
    brk    :boolean;
begin

  (*Dikey bosluklari sil*)
  { Bosluklari kaydirma islemi yukardan asagiya dogru yapiliyor
    boylece birden fazla bosluk olmasi problem cikartmiyor son kalan
    satir 0 ile kapatiliyor }

  for x := 1 to limX do begin
    for y := 1 to limY-1 do begin


       if m[y+1][x]=0 then begin { satir icindeki }

         { bosluk varsa tum ust satirlari bir asagi cekiyor }
         for z := y downto 1 do
           m[z+1][x] := m[z][x];

         { kaydirma sonrasi olusan bos alan sifirlaniyor }
         m[1][x] := 0;
      end;


    end;
  end;



  (*Yatay bosluklari sil*)

  for x := limX downto 1 do begin

    brk := False;

    for y := 1 to limY do begin

      { Sutun arasi tamamen bos mu ? }
      if m[y][x]<>0 then
        brk := True;

    end;


    if not brk then begin
      for z := x to limX-1 do begin

        for i := 1 to 8 do begin
          m[i][z] := m[i][z+1];
          { kaydirma sonrasi olusan bos alan sifirlaniyor }
          m[i][z+1] := 0;
        end;
      end;

    end;
  end;
end;


function TfrmMain.ArtanTasSay(var m:matris): integer;
  var
    x, y  :Integer;
begin
  result := 0;

  for y := 1 to limY do
    for x := 1 to limX do
      if m[x, y]<>0 then
        result := 1;

end;

procedure TfrmMain.BitBtn2Click(Sender: TObject);
  var
    x,y :integer;
begin
  for y := 1 to limY do
    for x := 1 to limX do
      m[y,x] := strtoint(tsStages.Strings[chlBolum.itemindex][(y-1)*8+x]);

  matriscik(m);
end;

procedure TfrmMain.KutuKoy(x, y, z: integer);
  var
    t  :TBitMap;
    s,
    d  :TRect;
begin
  s.Left := z*32;
  s.Top := 0;
  s.Right := s.Left+32;
  s.Bottom := 32;

  d.Left := x*32-32;
  d.Top := Y*32-32;
  d.Right := d.Left+32;
  d.Bottom := d.Top+32;

  //imgMain.Picture.Bitmap.Assign(t);
//  imgmain.Canvas.CopyMode := cmWhiteness;
  imgMain.Canvas.CopyRect(d, image1.Canvas, s);
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin

  m[2][1] := 0;
  m[2][2] := 1;
  m[2][3] := 2;
  m[2][4] := 3;
  m[2][5] := 4;
  m[2][6] := 5;
  m[2][7] := 6;
  m[2][8] := 7;

  matriscik(m);
end;

procedure TfrmMain.KalanIhtimal;
  var
    x, y, c  :integer;
begin
  c := 0;

  for y := 1 to limY do
   for x := 1 to limX do
    if m[y][x] <> 0 then begin
      globalsay := 0;
      BagSayYig(m, y, x, m[y,x]);

      if globalsay>=3 then
        inc(c);
    end;
  hepsinipozitifyap;

  label1.Caption := format('Gecerli hamle %d', [c]);

end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin
  if tsUnRedo.Count>0 then
    UnDo;
end;

procedure TfrmMain.UnDo;
  var
    x, y  :integer;
begin

  for y := 1 to limY do
   for x := 1 to limX do
    m[y][x] := strtoint(tsUnRedo.Strings[tsUnRedo.Count-1][(y-1)*8+x]);

  tsUnRedo.Delete(tsUnRedo.Count-1);
  MatrisCik(m);

end;

procedure TfrmMain.ReDo;
  var
    x, y  :integer;
    s     :string;
begin
  s := '';
  for y := 1 to limY do
   for x := 1 to limX do
    s := s + inttostr(m[y][x]);

  tsUnRedo.Add(s);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  tsUnRedo := TStringList.Create;

  tsStages := TStringList.Create;
  tsStages.LoadFromFile(getcurrentDir+'\stages.txt');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  tsUnRedo.Free;
  tsStages.Free;
end;

procedure TfrmMain.SpeedButton2Click(Sender: TObject);
begin
  chlBolumClick(sender);
end;

procedure TfrmMain.chlBolumClick(Sender: TObject);
begin
  tsUnRedo.Clear;
  BitBtn2.Click;
end;

end.
