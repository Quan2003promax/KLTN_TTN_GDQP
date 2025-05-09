unit Website1;

interface

uses System.SysUtils, System.Classes, Web.HTTPApp, Data.DBXDataSnap,
  Data.DBXCommon, IPPeerClient, Data.FMTBcd, Data.SqlExpr, Data.DB,
  Datasnap.DBClient, Datasnap.DSConnect, Data.DBXMSSQL,System.StrUtils,Generics.Collections;

type
  TWebModule1 = class(TWebModule)
    SQLConnection1: TSQLConnection;
    DSProviderConnection1: TDSProviderConnection;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebModule1KetQuaActionAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebModule1ChungChiActionAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebQRAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebDownloadAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1ChungChiSinhVienAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
procedure TWebModule1.WebModule1ChungChiSinhVienAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  maSV, hoTen, gioiTinh, ngaySinh, nganhHoc, truong, xepLoai, soHieu, soCap: string;
  ngay, thang, nam: string;
  TotalTinChi, tc,i:Integer;
  diem, TongDiemSo, DiemTB: Double;
  CoMonRot: Boolean;
 randomChar: Char;begin
  Handled := True;
                  Randomize;
  maSV := Trim(Request.QueryFields.Values['masv']);
  if maSV = '' then
  begin
    Response.Content := '<script>alert("❗ Vui lòng nhập mã sinh viên."); window.history.back();</script>';
    Exit;
  end;

  // Lấy thông tin cơ bản
  ClientDataSet1.Close;
 ClientDataSet1.CommandText :=
  'SELECT H.HoLot + '' '' + H.Ten AS HoTen, H.Phai, ' +
  'CONVERT(VARCHAR, H.NgaySinh, 103) AS NgaySinh, L.TenLop AS NganhHoc, ' +
  '''Trường Đại học Tây Nguyên'' AS Truong, H.GDQP ' +
  'FROM HSSV H JOIN LopHoc L ON H.MaLop = L.MaLop ' +
  'WHERE H.MaSV = :masv';
  ClientDataSet1.Params.ParamByName('masv').AsString := maSV;
  ClientDataSet1.Open;

  if ClientDataSet1.IsEmpty then
  begin
    Response.Content := '<script>alert("❌ Không tìm thấy sinh viên."); window.history.back();</script>';
    Exit;
  end;

  if not ClientDataSet1.FieldByName('GDQP').AsBoolean then
  begin
    Response.Content := '<script>alert("⚠️ Chưa đạt GDQP, không thể cấp chứng chỉ."); window.history.back();</script>';
    Exit;
  end;

  hoTen := ClientDataSet1.FieldByName('HoTen').AsString;
gioiTinh := ClientDataSet1.FieldByName('Phai').AsString;
ngaySinh := ClientDataSet1.FieldByName('NgaySinh').AsString;
nganhHoc := ClientDataSet1.FieldByName('NganhHoc').AsString;
truong := ClientDataSet1.FieldByName('Truong').AsString;
  randomChar := Chr(Ord('A') + Random(26));   soHieu := '';
  for i := 1 to 7 do
    soHieu := soHieu + IntToStr(Random(10));
  soHieu := randomChar+''+ soHieu;
  soCap := FormatDateTime('yyyy', Now) + '/';
  for i := 1 to 5 do
    soCap := soCap + IntToStr(Random(10));

  ClientDataSet1.Close;
  ClientDataSet1.CommandText :=
    'SELECT B.DiemMax, HP.TinChi FROM BangDiem B JOIN HocPhan HP ON B.MaHP = HP.MaHP ' +
    'WHERE B.MaSV = :masv AND HP.MaHP LIKE ''QP%'' ' +
    'AND B.DiemMax = (SELECT MAX(D2.DiemMax) FROM BangDiem D2 WHERE D2.MaSV = B.MaSV AND D2.MaHP = B.MaHP)';
  ClientDataSet1.Params.ParamByName('masv').AsString := maSV;
  ClientDataSet1.Open;

  TotalTinChi := 0;
  TongDiemSo := 0;
  CoMonRot := False;

  while not ClientDataSet1.Eof do
  begin
    tc := ClientDataSet1.FieldByName('TinChi').AsInteger;
    diem := ClientDataSet1.FieldByName('DiemMax').AsFloat;
    TotalTinChi := TotalTinChi + tc;
    TongDiemSo := TongDiemSo + (diem * tc);
    if diem < 5 then CoMonRot := True;
    ClientDataSet1.Next;
  end;

  if TotalTinChi > 0 then
    DiemTB := TongDiemSo / TotalTinChi
  else
    DiemTB := 0;

  if CoMonRot then
    xepLoai := 'Không đạt'
  else if DiemTB >= 9 then
    xepLoai := 'Xuất sắc'
  else if DiemTB >= 8 then
    xepLoai := 'Giỏi'
  else if DiemTB >= 7 then
    xepLoai := 'Khá'
  else if DiemTB >= 5 then
    xepLoai := 'Trung bình'
  else
    xepLoai := 'Không đạt';

  ngay := FormatDateTime('dd', Now);
  thang := FormatDateTime('MM', Now);
  nam := FormatDateTime('yyyy', Now);
Response.Content :=
  '<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8">' +
  '<title>Chứng chỉ GDQP</title>' +
  '<style>' +
  'body{font-family:''Times New Roman'',serif;background: linear-gradient(to right, #f0fdff, #fff3f6);padding:20px;}' +
  '.certificate{width:900px;height:600px;background-image:url(''/chungchi2.jpg'');' +
  'background-size:cover;background-position:center;margin:auto;position:relative;}' +
  '.field{position:absolute;font-size:18px;font-weight:bold;}' +
  '</style></head><body>' +
  '<div class="certificate">' +
  '<div class="field" style="top:230px; left:180px;">' + hoTen + '</div>' +
  '<div class="field" style="top:270px; left:180px;">' + ngaySinh + '</div>' +
  '<div class="field" style="top:380px; left:180px;">' + xepLoai + '</div>' +
  '<div class="field" style="top:520px; left:160px;">' + soHieu + '</div>' +
  '<div class="field" style="top:555px; left:310px;">' + soCap + '</div>' +
  '<div class="field" style="top:270px; left:550px;">Trường Đại học Tây Nguyên</div>' +
  '</div>' +
 '<div style="text-align: center; margin-top: 20px;">' +
  '<button id="saveBtn" style="font-size:16px;background:#6a1b9a;color:#fff;' +
  'padding:10px 20px;border:none;border-radius:6px;cursor:pointer;margin:0 auto;">' +
  '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" style="vertical-align:middle;margin-right:5px;" viewBox="0 0 16 16">' +
  '<path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z"/>' +
  '<path d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z"/>' +
  '</svg> Lưu Ảnh</button>' +
  '</div>' +
  '<script>' +
  'document.getElementById("saveBtn").addEventListener("click", function() {' +
  '  const certificateDiv = document.querySelector(".certificate");' +
  '  html2canvas(certificateDiv).then(canvas => {' +
  '    const link = document.createElement("a");' +
  '    link.download = "ChungChi_GDQP.png";' +
  '    link.href = canvas.toDataURL("image/png");' +
  '    link.click();' +
  '  });' +
  '});' +
  '</script>' +
  '<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>' +
  '</body></html>';
Response.ContentType := 'text/html; charset=utf-8';


end;


procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  HTML: string;
begin
  HTML :=
    '<!DOCTYPE html>' +
    '<html lang="vi">' +
    '<head>' +
    '  <meta charset="UTF-8">' +
    '  <title>TTN - Tra cứu GDQP</title>' +
    '  <style>' +
    '    body { margin: 0; padding: 0; font-family: Segoe UI, sans-serif;' +
    '           background: linear-gradient(to right, #e0f7ff, #ffe0f7); }' +
    '    .container { display: flex; justify-content: center; align-items: center;' +
    '                 height: 100vh; }' +
    '    .box { background: white; padding: 40px; border-radius: 20px; width: 500px;' +
    '           box-shadow: 0 0 20px rgba(0,0,0,0.1); text-align: center; }' +
    '    img.logo { width: 180px; margin-bottom: 20px; }' +
    '    .btn { display: inline-block; margin: 10px; padding: 10px 20px; font-weight: bold;' +
    '           background: #f0f0f0; text-decoration: none; color: black; border-radius: 8px;' +
    '           transition: 0.3s; box-shadow: 1px 1px 4px rgba(0,0,0,0.1); }' +
    '    .btn:hover { background: #cce5ff; transform: translateY(-2px); }' +
    '    footer { margin-top: 20px; font-size: 12px; color: gray; }' +
    '  </style>' +
    '</head>' +
    '<body>' +
    '  <div class="container">' +
    '    <div class="box">' +
    '      <img class="logo" src="/logotruong.png" alt="logo">' +
    '      <h1>Hi, Welcome back!</h1>' +
    '      <p>Website tra cứu điểm GDQP dành cho sinh viên trường Đại học Tây Nguyên</p>' +
    '      <div>' +
    '        <a class="btn" href="/ketqua">🎓 Kết quả</a>' +
    '        <a class="btn" href="/chungchi">📅 Chứng chỉ GDQP</a>' +
    '        <a class="btn" href="https://www.ttn.edu.vn/index.php/ttgdqp">ℹ Thông tin</a>' +
    '        <a class="btn" href="/download">💾 Tải phần mềm</a>' +
     '        <a class="btn" href="/donate">🎁 Tài trợ</a>' +
    '      </div>' +
    '      <footer>Delphi WebBroker version • Design by AnhQuan</footer>' +
    '    </div>' +
    '  </div>' +
    '</body>' +
    '</html>';

  Response.Content := HTML;
  Handled := True;
end;

procedure TWebModule1.WebModule1WebDownloadAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  FilePath: string;
  HTML: string;
begin
  FilePath := ExtractFilePath(ParamStr(0)) + 'public\download\ttn_ttgdqp\Output\ttn_ttgdqp_setup.exe';

  if (Request.QueryFields.Values['download'] = '1') then
  begin
    if FileExists(FilePath) then
    begin
      Response.ContentType := 'application/octet-stream';
      Response.ContentStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
      Response.CustomHeaders.Values['Content-Disposition'] := 'attachment; filename="ttn_ttgdqp_setup.exe"';
      Response.SendResponse;
      Handled := True;
    end
    else
    begin
      Response.Content := 'Không tìm thấy file!';
      Response.StatusCode := 404;
      Handled := True;
    end;
  end
  else
  begin
    HTML :=
      '<!DOCTYPE html>' +
      '<html lang="vi">' +
      '<head>' +
      '<meta charset="UTF-8">' +
      '<title>Tải phần mềm TTN_GDQP</title>' +
      '<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>' +
      '</head>' +
      '<body onload="showConfirm()">' +
      '<script>' +
      'function showConfirm() {' +
      '  Swal.fire({' +
      '    title: "Tải phần mềm TTN_GDQP?",' +
      '    html: "📦 Dung lượng: ~52MB<br><br>" +' +
      '          "⚠️ <b>Lưu ý trước khi tải: </b>Hãy bật <b>Telnet Client</b><br>" +' +
      '          "<i>Control Panel → Programs → Turn Windows features on or off → Tick Telnet Client → OK</i>",' +
      '    icon: "question",' +
      '    showCancelButton: true,' +
      '    confirmButtonColor: "#3085d6",' +
      '    cancelButtonColor: "#d33",' +
      '    confirmButtonText: "Có, tải ngay!",' +
      '    cancelButtonText: "Không"' +
      '  }).then((result) => {' +
      '    if (result.isConfirmed) {' +
      '      window.location.href = "/download?download=1";' +
      '    } else {' +
      '      window.location.href = "/";' +
      '    }' +
      '  });' +
      '}' +
      '</script>' +
      '</body>' +
      '</html>';

    Response.ContentType := 'text/html; charset=UTF-8';
    Response.Content := HTML;
    Handled := True;
  end;
end;

 
procedure TWebModule1.WebModule1WebModule1ChungChiActionAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
const
  KhoaCount = 8;
  KhoaTen: array[1..KhoaCount] of string = (
    'Khoa Y Dược',
    'Khoa Nông lâm Nghiệp',
    'Khoa Kinh Tế',
    'Khoa Sư Phạm',
    'Khoa Lý luận Chính trị',
    'Khoa Ngoại Ngữ',
    'Khoa Chăn nuôi Thú Y',
    'Khoa KHTN&CN'
  );
var
  i, TotalTinChi, tc: Integer;
  HTML, MaKhoa, MaLop, MaSV, HoTen, xl, gdqp,linkChungChi:string;
  lop, tenlop: string;
  TongDiemSo, diem, DiemTB: Double;
  CoMonRot: Boolean;
begin
  MaKhoa := Request.QueryFields.Values['khoa'];
  MaLop := Request.QueryFields.Values['lop'];

  HTML := '<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><title>Chứng chỉ GDQP</title>' +
          '<style>' +
          'body {  margin:0; padding:0; font-family: Segoe UI, sans-serif; background: #e8f4ff; text-align: center  }' +
          'select { padding: 6px; font-size: 14px; margin: 5px; }' +
          'table { margin: 30px auto; border-collapse: collapse; background: white; }' +
          'th, td { padding: 8px 12px; border: 1px solid #ccc; }' +
          'thead { background: #dff6ff; font-weight: bold; }' +
         '</style></head><body>' +
  '<div style="background:linear-gradient(to right, #f0fdff, #fff3f6); padding:12px 30px; border-radius:12px; margin:20px auto; max-width:1200px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 4px 12px rgba(0,0,0,0.05);">' +
  '  <div style="display:flex;align-items:center;gap:10px;">' +
  '    <img src="/logotruong.png" alt="logo" style="height:40px;">' +
  '    <span style="font-weight:bold;font-size:20px;color:#b30059;">GDQP</span>' +
  '  </div>' +
  '  <div style="display:flex;align-items:center;gap:30px;font-weight:bold;font-size:16px;margin-top:0;padding-top:0;">' +
  '    <a href="/" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🏠</span> Trang chủ</a>' +
  '    <a href="/ketqua" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🖋️</span> Học tập</a>' +
  '    <a href="/chungchi" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">📅️</span> Chứng chỉ GDQP</a>' +
  '    <a href="https://www.ttn.edu.vn/index.php/ttgdqp" target="_blank" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">ℹ️</span> Thông tin</a>' +
  '    <a href="/download" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">💾</span> Tải phần mềm</a>' +
  '    <a href="/donate" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🎁</span> Tài trợ</a>' +
  '  </div>' +
  '</div>' +
  '<div style="max-width:1100px;margin:30px auto;background:white;padding:40px;border-radius:20px;box-shadow:0 8px 30px rgba(0,0,0,0.05);"> '+
          '<h2>Tra cứu chứng chỉ GDQP</h2>' +
          '<form method="get" action="/chungchi">' +
          '<div style="display:inline-block; padding: 20px; background: white; border-radius: 12px;">' +
          '<label><b>Chọn Khoa:</b></label> ' +
          '<select name="khoa" onchange="this.form.submit()" style="margin-right:20px;">' +
          '<option value="">--Chọn khoa--</option>'+
' </div> '  ;
  for i := 1 to KhoaCount do
    HTML := HTML + '<option value="' + IntToStr(i) + '"' +
                   IfThen(MaKhoa = IntToStr(i), ' selected', '') + '>' + KhoaTen[i] + '</option>';
  HTML := HTML + '</select>';

  // Chọn lớp
  if MaKhoa <> '' then
  begin
    HTML := HTML +
      '<label><b>Chọn Lớp:</b></label> ' +
      '<select name="lop" onchange="this.form.submit()">' +
      '<option value="">--Chọn lớp--</option>';

    ClientDataSet1.Close;
    ClientDataSet1.CommandText :=
      'SELECT DISTINCT H.MaLop, L.TenLop2 FROM HSSV H ' +
      'JOIN LopHoc L ON H.MaLop = L.MaLop ' +
      'WHERE L.MaKhoa = :mk ORDER BY L.TenLop2';
    ClientDataSet1.Params.ParamByName('mk').AsInteger := StrToIntDef(MaKhoa, 0);
    ClientDataSet1.Open;

    while not ClientDataSet1.Eof do
    begin
      lop := ClientDataSet1.FieldByName('MaLop').AsString;
      tenlop := ClientDataSet1.FieldByName('TenLop2').AsString;
      HTML := HTML + '<option value="' + lop + '"' +
                     IfThen(MaLop = lop, ' selected', '') + '>' + tenlop + '</option>';
      ClientDataSet1.Next;
    end;

    HTML := HTML + '</select>';
  end;

  HTML := HTML + '</div></form>';

  // Hiển thị bảng chứng chỉ
   if MaLop <> '' then
  begin
    HTML := HTML + '<table>' +
            '<thead><tr><th>STT</th><th>Họ tên</th><th>GDQP</th><th>Xếp loại</th><th>Chứng chỉ</th></tr></thead><tbody>';

    ClientDataSet1.Close;
    ClientDataSet1.CommandText :=
      'SELECT MaSV, HoLot + '' '' + Ten AS HoTen, GDQP FROM HSSV WHERE MaLop = :ml ORDER BY Ten';
    ClientDataSet1.Params.ParamByName('ml').AsString := MaLop;
    ClientDataSet1.Open;

    i := 1;
    while not ClientDataSet1.Eof do
    begin
      MaSV := ClientDataSet1.FieldByName('MaSV').AsString;
      HoTen := ClientDataSet1.FieldByName('HoTen').AsString;
      gdqp := IfThen(ClientDataSet1.FieldByName('GDQP').AsBoolean, '✅', '❌');

      if not ClientDataSet1.FieldByName('GDQP').AsBoolean then
    xl := '⚠️ Không đạt'
    else
    begin
  // Kiểm tra nếu không có học phần GDQP nhưng GDQP = 1
    ClientDataSet1.Close;
    ClientDataSet1.CommandText :=
      'SELECT COUNT(*) AS SoMon FROM BangDiem WHERE MaSV = :masv AND MaHP LIKE ''QP%''';
    ClientDataSet1.Params.ParamByName('masv').AsString := MaSV;
    ClientDataSet1.Open;

    if ClientDataSet1.FieldByName('SoMon').AsInteger = 0 then
    begin
      xl := '🎓	Đã có GDQP trước đó';
    end
    else
    begin
    ClientDataSet1.Close;
    ClientDataSet1.CommandText :=
      'SELECT B.DiemMax, HP.TinChi FROM BangDiem B JOIN HocPhan HP ON B.MaHP = HP.MaHP ' +
      'WHERE B.MaSV = :masv AND HP.MaHP LIKE ''QP%'' AND ' +
      'B.DiemMax = (SELECT MAX(D2.DiemMax) FROM BangDiem D2 WHERE D2.MaSV = B.MaSV AND D2.MaHP = B.MaHP)';
    ClientDataSet1.Params.ParamByName('masv').AsString := MaSV;
    ClientDataSet1.Open;

    TotalTinChi := 0;
    TongDiemSo := 0;
    CoMonRot := False;

    while not ClientDataSet1.Eof do
    begin
      tc := ClientDataSet1.FieldByName('TinChi').AsInteger;
      diem := ClientDataSet1.FieldByName('DiemMax').AsFloat;
      TotalTinChi := TotalTinChi + tc;
      TongDiemSo := TongDiemSo + (diem * tc);
      if diem < 5 then
        CoMonRot := True;
      ClientDataSet1.Next;
    end;

        DiemTB := 0;
        if TotalTinChi > 0 then
          DiemTB := TongDiemSo / TotalTinChi;

        if CoMonRot then
          xl := '⚠️ Không đạt'
        else if DiemTB >= 9 then
          xl := '🎖️ Sinh viên Xuất sắc'
        else if DiemTB >= 8 then
          xl := '🥇 Sinh viên Giỏi'
        else if DiemTB >= 7 then
          xl := '🥈 Sinh viên Khá'
        else if DiemTB >= 5 then
          xl := '🥉 Sinh viên Trung bình'
        else
          xl := '⚠️ Không đạt';
      end;
    end;
      if gdqp = '✅' then
        linkChungChi := '<a href="/chungchi-sv?masv=' + MaSV + '" target="_blank">📄 Xem chứng chỉ</a>'
      else
        linkChungChi := '—';

      HTML := HTML + '<tr><td>' + IntToStr(i) + '</td><td>' + HoTen + '</td><td>' + gdqp +
                    '</td><td>' + xl + '</td><td>' + linkChungChi + '</td></tr>';
      Inc(i);

      ClientDataSet1.Close;
      ClientDataSet1.CommandText :=
        'SELECT MaSV, HoLot + '' '' + Ten AS HoTen, GDQP FROM HSSV WHERE MaLop = :ml ORDER BY Ten';
      ClientDataSet1.Params.ParamByName('ml').AsString := MaLop;
      ClientDataSet1.Open;
      ClientDataSet1.First;
      ClientDataSet1.MoveBy(i - 1);
    end;

    HTML := HTML + '</tbody></table>';
  end;

  HTML := HTML + '</body></html>';
  Response.Content := HTML;
  Handled := True;
end;

procedure TWebModule1.WebModule1WebModule1KetQuaActionAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  MaSV, HoTen, HTML, DiemChu, MaHP, loai: string;
  TotalTinChi, TinChiDat, TongHocPhi, HocPhiDaNop: Integer;
  ACount, BCount, CCount, DCount, FCount: Integer;
  TongDiemSo, DiemTichLuy, DiemMax: Double;
  CoMonRot, DaCoGDQP: Boolean;
  DanhHieu: string;
  Offset: Integer;
  DaTinh: TList<string>;
begin
  MaSV := Trim(Request.QueryFields.Values['masv']);
  if MaSV = '' then
  begin
    HTML := '<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8">' +
      '<title>Tra cứu GDQP</title>' +
      '<style>body{font-family:Segoe UI,sans-serif;background:#f0f8ff;text-align:center;}' +
      'input[type=text]{padding:10px;width:250px;font-size:16px;border-radius:8px;border:1px solid #ccc;}' +
      'input[type=submit]{padding:10px 20px;background:#007bff;color:white;border:none;border-radius:8px;font-weight:bold;cursor:pointer;}' +
      'input[type=submit]:hover{background:#0056b3;}</style></head><body>' +
       '<div style="background:linear-gradient(to right, #f0fdff, #fff3f6); padding:12px 30px; margin:auto auto; border-radius:12px;  max-width:1200px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 4px 12px rgba(0,0,0,0.05);">' +
  '  <div style="display:flex;align-items:center;gap:10px;">' +
  '    <img src="/logotruong.png" alt="logo" style="height:40px;">' +
  '    <span style="font-weight:bold;font-size:20px;color:#b30059;">GDQP</span>' +
  '  </div>' +
  '  <div style="display:flex;align-items:center;gap:30px;font-weight:bold;font-size:16px;">' +
  '    <a href="/" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🏠</span> Trang chủ</a>' +
  '    <a href="/ketqua" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🖋️</span> Học tập</a>' +
   '    <a href="/chungchi" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">📅️</span> Chứng chỉ GDQP</a>' +
 '    <a href="https://www.ttn.edu.vn/index.php/ttgdqp" target="_blank" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">ℹ️</span> Thông tin</a>' +
 '    <a href="/download" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">💾</span> Tải phần mềm</a>' +
   '    <a href="/donate" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🎁</span> Tài trợ</a>' +
  '  </div>' +
  '</div>' +
      '<h2>Tra cứu kết quả Giáo dục Quốc phòng</h2>' +
      '<form method="get" action="/ketqua">' +
      '<input type="text" name="masv" placeholder="Nhập mã sinh viên" style="padding:10px;width:250px;font-size:16px;border-radius:8px;border:1px solid #ccc;">' +
      '<input type="submit" value="Tra cứu" style="padding:10px 20px;background:#007bff;color:white;border:none;border-radius:8px;font-weight:bold;cursor:pointer;margin-left:10px;">';
    Response.Content := HTML;
    Handled := True;
    Exit;
  end;

  if not SQLConnection1.Connected then
    SQLConnection1.Connected := True;

  ClientDataSet1.Close;
  ClientDataSet1.CommandText := 'SELECT HoLot + '' '' + Ten AS HoTen FROM HSSV WHERE MaSV = :masv';
  ClientDataSet1.Params.ParamByName('masv').AsString := MaSV;
  ClientDataSet1.Open;
  HoTen := ClientDataSet1.FieldByName('HoTen').AsString;

  ClientDataSet1.Close;
  ClientDataSet1.CommandText :=
    'SELECT B.MaHP, B.DiemMax, B.DiemChu, B.HocPhi, CAST(B.DaNop AS INT) AS DaNop, ' +
    'B.Thi1, B.Thi2, B.BoPhan, B.DiemSo, HP.TenHP, HP.TinChi ' +
    'FROM BangDiem B JOIN HocPhan HP ON B.MaHP = HP.MaHP ' +
    'WHERE B.MaSV = :masv AND HP.MaHP LIKE ''QP%'' ' +
    'ORDER BY B.MaHP, B.DiemMax DESC';
  ClientDataSet1.Params.ParamByName('masv').AsString := MaSV;
  ClientDataSet1.Open;

  TotalTinChi := 0;
  TinChiDat := 0;
  TongHocPhi := 0;
  HocPhiDaNop := 0;
  TongDiemSo := 0;
  CoMonRot := False;
  ACount := 0;
  BCount := 0;
  CCount := 0;
  DCount := 0;
  FCount := 0;
  DaTinh := TList<string>.Create;

  ClientDataSet1.First;
  while not ClientDataSet1.Eof do
  begin
    TongHocPhi := TongHocPhi + Round(ClientDataSet1.FieldByName('HocPhi').AsFloat);
    if ClientDataSet1.FieldByName('DaNop').AsInteger = 1 then
      HocPhiDaNop := HocPhiDaNop + Round(ClientDataSet1.FieldByName('HocPhi').AsFloat);
    ClientDataSet1.Next;
  end;

  ClientDataSet1.First;
  while not ClientDataSet1.Eof do
  begin
    MaHP := ClientDataSet1.FieldByName('MaHP').AsString;
    DiemMax := ClientDataSet1.FieldByName('DiemMax').AsFloat;
    DiemChu := UpperCase(Trim(ClientDataSet1.FieldByName('DiemChu').AsString));

    // Thống kê chỉ tính một bản ghi cao nhất cho mỗi học phần
    if not DaTinh.Contains(MaHP) then
    begin
      TotalTinChi := TotalTinChi + ClientDataSet1.FieldByName('TinChi').AsInteger;
      if DiemMax >= 5 then
        TinChiDat := TinChiDat + ClientDataSet1.FieldByName('TinChi').AsInteger
      else
        CoMonRot := True;

      TongDiemSo := TongDiemSo + (DiemMax * ClientDataSet1.FieldByName('TinChi').AsInteger);

      // Tính loại điểm
      if Copy(MaSV, 1, 2) = '19' then
      begin
        if DiemChu = 'A' then Inc(ACount)
        else if DiemChu = 'B' then Inc(BCount)
        else if DiemChu = 'C' then Inc(CCount)
        else if DiemChu = 'D' then Inc(DCount)
        else if DiemChu = 'F' then Inc(FCount);
      end
      else
      begin
        if DiemChu = 'P' then Inc(ACount)
        else if DiemChu = 'F' then Inc(FCount);
      end;

      DaTinh.Add(MaHP);
    end;

    ClientDataSet1.Next;
  end;
  DaTinh.Free;

   if TotalTinChi > 0 then
    DiemTichLuy := TongDiemSo / TotalTinChi
  else
    DiemTichLuy := 0;
  Offset := 314 - Round(DiemTichLuy / 10 * 314);

  // Xếp loại
  if CoMonRot then
    DanhHieu := '⚠️ Không đạt'
  else if DiemTichLuy >= 9 then
    DanhHieu := '🎖️ Xuất sắc'
  else if DiemTichLuy >= 8 then
    DanhHieu := '🥇 Giỏi'
  else if DiemTichLuy >= 7 then
    DanhHieu := '🥈 Khá'
  else if DiemTichLuy >= 5 then
    DanhHieu := '🥉 Trung bình'
  else
    DanhHieu := '⚠️ Không đạt';

  HTML := '<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><title>Kết quả học tập</title>' +
  '<style>body{font-family:Segoe UI,sans-serif;background:#f0f8ff}' +
  '.title{text-align:center;margin-bottom:20px;font-size:20px;}' +
  '.grid{display:flex;justify-content:space-between;gap:30px;margin-bottom:30px;}' +
  '.box{flex:1;background:#fff;border-radius:8px;padding:20px;box-shadow:0 0 10px rgba(0,0,0,0.05);}' +
  '</style></head><body>' +
    '<div style="background:linear-gradient(to right, #f0fdff, #fff3f6); padding:12px 30px; margin:auto auto; border-radius:12px;  max-width:1200px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 4px 12px rgba(0,0,0,0.05);">' +
  '  <div style="display:flex;align-items:center;gap:10px;">' +
  '    <img src="/logotruong.png" alt="logo" style="height:40px;">' +
  '    <span style="font-weight:bold;font-size:20px;color:#b30059;">GDQP</span>' +
  '  </div>' +
  '  <div style="display:flex;align-items:center;gap:30px;font-weight:bold;font-size:16px;">' +
  '    <a href="/" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🏠</span> Trang chủ</a>' +
  '    <a href="/ketqua" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🖋️</span> Học tập</a>' +
   '    <a href="/chungchi" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">📅️</span> Chứng chỉ GDQP</a>' +
 '    <a href="https://www.ttn.edu.vn/index.php/ttgdqp" target="_blank" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">ℹ️</span> Thông tin</a>' +
 '    <a href="/download" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">💾</span> Tải phần mềm</a>' +
   '    <a href="/donate" style="text-decoration:none;color:#212529;"><span style="font-size:18px;">🎁</span> Tài trợ</a>' +
  '  </div>' +
  '</div>' +
  '<div class="title"><h2>Kết quả học tập của sinh viên: <span style="color:#007bff;">' +
  HoTen + ' – ' + MaSV + '</span></h2></div>' +
  '<div class="grid">' +

  '<div class="box">' +
  '<div style="width:90%;margin:auto;">' +
  '<h3 style="font-weight:bold;margin:0;">Thống kê học phí</h3>' +
  '<div style="height:4px;margin:10px 0 20px;background:linear-gradient(to right, #6e00ff, #ff66cc);border-radius:2px;"></div>' +
  '</div>' +
  '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;">' +
  '<div style="font-size:16px;color:#6c5ce7;">✔️ Tổng học phí đã nộp</div>' +
  '<div style="font-size:22px;font-weight:bold;margin-bottom:15px;">' + FormatFloat('#,##0', HocPhiDaNop) + ' VNĐ</div>' +
  '<div style="font-size:16px;color:#d63031;">❌ Học phí chưa nộp</div>' +
  '<div style="font-size:22px;font-weight:bold;color:#d63031;">' + FormatFloat('#,##0', TongHocPhi - HocPhiDaNop) + ' VNĐ</div>' +
  '</div>' +
  '</div>';

  HTML := HTML +
  '<div class="box">' +
  '<div style="width:90%;margin:auto;">' +
  '<h3 style="font-weight:bold;margin:0;">📊 Thống kê điểm</h3>' +
  '<div style="height:4px;margin:10px 0 20px;background:linear-gradient(to right, #6e00ff, #ff66cc);border-radius:2px;"></div>' +
  '</div>';

  if Copy(MaSV, 1, 2) = '19' then
  begin
  HTML := HTML + '<div style="display:grid;grid-template-columns:repeat(3, 1fr);gap:20px;max-width:600px;margin:auto;">' +

    '<div style="display:flex;align-items:center;background:#e0f7ff;border-radius:12px;padding:10px 15px;">' +
    '<div style="width:40px;height:40px;background:#00dffc;color:white;border-radius:50%;text-align:center;line-height:40px;font-weight:bold;">A</div>' +
    '<div style="margin-left:10px;">' +
    '<div style="font-weight:bold;">Tín chỉ A</div>' +
    '<div>' + IntToStr(ACount) + '</div>' +
    '</div></div>' +

    '<div style="display:flex;align-items:center;background:#e0f7ff;border-radius:12px;padding:10px 15px;">' +
    '<div style="width:40px;height:40px;background:#2ecc71;color:white;border-radius:50%;text-align:center;line-height:40px;font-weight:bold;">B</div>' +
    '<div style="margin-left:10px;">' +
    '<div style="font-weight:bold;">Tín chỉ B</div>' +
    '<div>' + IntToStr(BCount) + '</div>' +
    '</div></div>' +

    '<div style="display:flex;align-items:center;background:#e0f7ff;border-radius:12px;padding:10px 15px;">' +
    '<div style="width:40px;height:40px;background:#f1c40f;color:white;border-radius:50%;text-align:center;line-height:40px;font-weight:bold;">C</div>' +
    '<div style="margin-left:10px;">' +
    '<div style="font-weight:bold;">Tín chỉ C</div>' +
    '<div>' + IntToStr(CCount) + '</div>' +
    '</div></div>' +

    '<div style="grid-column:1 / span 1;display:flex;align-items:center;background:#e0f7ff;border-radius:12px;padding:10px 15px;justify-self:center;">' +
    '<div style="width:40px;height:40px;line-height:40px;background:#e67e22;color:white;border-radius:50%;text-align:center;font-weight:bold;">D</div>' +
    '<div style="margin-left:10px;">' +
    '<div style="font-weight:bold;">Tín chỉ D</div>' +
    '<div>' + IntToStr(DCount) + '</div>' +
    '</div></div>' +

    '<div style="grid-column:2 / span 1;display:flex;align-items:center;background:#e0f7ff;border-radius:12px;padding:10px 15px;justify-self:center;">' +
    '<div style="width:40px;height:40px;line-height:40px;background:#e74c3c;color:white;border-radius:50%;text-align:center;font-weight:bold;">F</div>' +
    '<div style="margin-left:10px;">' +
    '<div style="font-weight:bold;">Tín chỉ F</div>' +
    '<div>' + IntToStr(FCount) + '</div>' +
    '</div></div>' +
    '</div>';
end
else
begin
  HTML := HTML + '<div style="display:flex;justify-content:center;gap:20px;">' +
    '<div style="display:flex;align-items:center;background:#e0f7ff;border-radius:12px;padding:10px 15px;">' +
    '<div style="width:40px;height:40px;background:#6c5ce7;color:white;border-radius:50%;text-align:center;line-height:40px;font-weight:bold;">P</div>' +
    '<div style="margin-left:10px;">' +
    '<div style="font-weight:bold;">Tín chỉ P</div>' +
    '<div>' + IntToStr(ACount + BCount + CCount + DCount) + '</div>' +
    '</div></div>' +
    '<div style="display:flex;align-items:center;background:#e0f7ff;border-radius:12px;padding:10px 15px;">' +
    '<div style="width:40px;height:40px;background:#e74c3c;color:white;border-radius:50%;text-align:center;line-height:40px;font-weight:bold;">F</div>' +
    '<div style="margin-left:10px;">' +
    '<div style="font-weight:bold;">Tín chỉ F</div>' +
    '<div>' + IntToStr(FCount) + '</div>' +
    '</div></div>' +

  '</div>';
end;
HTML := HTML + '</div>';
  HTML := HTML +
  '<div class="box" style="text-align:center;">' +
  '<h3>🎓 Điểm tích lũy</h3>' +
  '<svg width="120" height="120">' +
  '<defs><linearGradient id="gradColor" x1="0%" y1="0%" x2="100%" y2="100%">' +
  '<stop offset="0%" stop-color="#00c6ff"/>' +
  '<stop offset="50%" stop-color="#6e00ff"/>' +
  '<stop offset="100%" stop-color="#ff66cc"/>' +
  '</linearGradient></defs>' +
  '<circle cx="60" cy="60" r="50" stroke="#eee" stroke-width="10" fill="none"/>' +
  '<circle cx="60" cy="60" r="50" stroke="url(#gradColor)" stroke-width="10" fill="none" ' +
  'stroke-dasharray="314" stroke-dashoffset="' + IntToStr(Offset) + '" stroke-linecap="round" ' +
  'transform="scale(-1,1) translate(-120,0) rotate(-90 60 60)"/>' +
  '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="20" font-weight="bold" fill="#007bff">' +
  FormatFloat('#0.00', DiemTichLuy) + '</text>' +
  '</svg>' +
  '<p style="margin-top:10px;"><strong>Danh hiệu sinh viên:</strong> ' + DanhHieu + '</p>' +
  '</div></div>';
  HTML := HTML +
    '<div style="margin-top:40px;">' +
    '<table style="width:100%;border-collapse:collapse;background:white;border:1px solid #ccc;">' +
    '<thead style="background:#e0f7ff;">' +
    '<tr>' +
    '<th style="padding:10px;border:1px solid #ccc;">Môn học</th>' +
    '<th style="padding:10px;border:1px solid #ccc;">Bộ phận</th>' +
    '<th style="padding:10px;border:1px solid #ccc;">Thi chính</th>' +
    '<th style="padding:10px;border:1px solid #ccc;">Cải thiện</th>' +
    '<th style="padding:10px;border:1px solid #ccc;">Kết quả</th>' +
    '<th style="padding:10px;border:1px solid #ccc;">Tín chỉ</th>' +
    '<th style="padding:10px;border:1px solid #ccc;">Loại</th>' +
    '</tr></thead><tbody>';

  ClientDataSet1.First;
  while not ClientDataSet1.Eof do
  begin
    HTML := HTML +
      '<tr>' +
      '<td style="padding:8px;border:1px solid #ccc;text-align:center;">' + ClientDataSet1.FieldByName('TenHP').AsString + '</td>' +
      '<td style="border:1px solid #ccc;text-align:center;">' + ClientDataSet1.FieldByName('BoPhan').AsString + '</td>' +
      '<td style="border:1px solid #ccc;text-align:center;">' + ClientDataSet1.FieldByName('Thi1').AsString + '</td>' +
      '<td style="border:1px solid #ccc;text-align:center;">' + ClientDataSet1.FieldByName('Thi2').AsString + '</td>' +
      '<td style="border:1px solid #ccc;text-align:center;">' + FormatFloat('#0.00', ClientDataSet1.FieldByName('DiemMax').AsFloat) + '</td>' +
      '<td style="border:1px solid #ccc;text-align:center;">' + IntToStr(ClientDataSet1.FieldByName('TinChi').AsInteger) + '</td>' +
      '<td style="border:1px solid #ccc;text-align:center;">' + ClientDataSet1.FieldByName('DiemChu').AsString + '</td>' +
      '</tr>';
    ClientDataSet1.Next;
  end;

  HTML := HTML + '</tbody></table></div></body></html>';
  Response.Content := HTML;
  Handled := True;
end;

procedure TWebModule1.WebModule1WebQRAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  HTML: string;
begin
  HTML :=
    '<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><title>Ủng hộ hệ thống</title>' +
    '<style>' +
    'body { margin:0; padding:0; font-family:Segoe UI, sans-serif; background: linear-gradient(to right, #e0f7ff, #ffe0f7); text-align:center; }' +
    '.container { max-width:600px; margin:80px auto; background:white; padding:40px; border-radius:20px; box-shadow:0 8px 30px rgba(0,0,0,0.05); }' +
    'img { max-width:300px; width:100%; border-radius:12px; margin:20px 0; }' +
    'button { padding:10px 20px; background:#007bff; color:white; border:none; border-radius:8px; font-weight:bold; cursor:pointer; }' +
    'button:hover { background:#0056b3; }' +
    '</style></head><body>' +
    '<div class="container">' +
    '<h2 style="color:#b30059;">Ủng hộ phát triển Website 🎁</h2>' +
    '<p>Quét mã QR bên dưới để đóng góp cho dự án GDQP</p>' +
    '<img src="/qrcode.jpg" alt="Mã QR">' +
    '<br><br>' +
   '<button onclick="window.location.href=''/''">← Quay lại trang chủ</button>' +
    '</div>' +
    '</body></html>';
  Response.Content := HTML;
  Handled := True;
end;

procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  FilePath: string;
begin
  // Xử lý logo trường
  if SameText(Request.PathInfo, '/logotruong.png') then
  begin
    FilePath := ExtractFilePath(ParamStr(0)) + 'public\logotruong.png';
    if FileExists(FilePath) then
    begin
      Response.ContentType := 'image/png';
      Response.ContentStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
      Response.ContentStream.Position := 0;
      Response.ContentLength := Response.ContentStream.Size;
      Handled := True;
    end
    else
    begin
      Response.Content := 'File not found';
      Response.StatusCode := 404;
      Handled := True;
    end;
  end

  // Xử lý ảnh QR code
  else if SameText(Request.PathInfo, '/qrcode.jpg') then
  begin
    FilePath := ExtractFilePath(ParamStr(0)) + 'public\qrcode.jpg';
    if FileExists(FilePath) then
    begin
      Response.ContentType := 'image/jpeg';
      Response.ContentStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
      Response.ContentStream.Position := 0;
      Response.ContentLength := Response.ContentStream.Size;
      Handled := True;
    end
    else
    begin
      Response.Content := 'File not found';
      Response.StatusCode := 404;
      Handled := True;
    end;
  end

  // Xử lý ảnh chứng chỉ
  else if SameText(Request.PathInfo, '/chungchi2.jpg') then
  begin
    FilePath := ExtractFilePath(ParamStr(0)) + 'public\chungchi2.jpg';
    if FileExists(FilePath) then
    begin
      Response.ContentType := 'image/jpeg';
      Response.ContentStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
      Response.ContentStream.Position := 0;
      Response.ContentLength := Response.ContentStream.Size;
      Handled := True;
    end
    else
    begin
      Response.Content := 'File not found';
      Response.StatusCode := 404;
      Handled := True;
    end;
  end;
end;


end.
