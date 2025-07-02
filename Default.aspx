<%@ Page Language="VB" Debug="true"  validateRequest="false" enableEventValidation="false" viewStateEncryptionMode ="Never" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace ="FunctionsComClass" %>
<%@ Import Namespace ="System.Net" %>
<%@ Import Namespace ="System.Net.Http" %>
<%@ Import Namespace ="System.IO" %>
<%@ Import Namespace ="System.Net.Http.Headers" %>
<%@ Import Namespace ="System.Text" %>
<%@ Import Namespace ="System.Web.Script.Serialization" %>
<%@ Import Namespace ="System.Net.HttpWebResponse" %>


<script language="VB" runat="server">
    Dim mySqlConnection As SqlConnection = New SqlConnection(ConfigurationSettings.AppSettings("con"))
    'Private con As New SqlConnection("Data Source=SureshDasari;Integrated Security=true;Initial Catalog=MySampleDB")
    Dim strAccount, StrTenKH, StrDiaChiGiaoDich, strGoiCuoc, strIPAdd As String
    Dim intTrangThai, intNhacNoId As Integer

    Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        Dim msg As String
        Dim msgar As Array
        If Not IsPostBack Then
            'strIPAdd = HttpContext.Current.Request.UserHostAddress
            strIPAdd = HttpContext.Current.Request.Params.AllKeys(32).ToString
            msg = HttpContext.Current.Request.UserHostAddress.ToString + " " + HttpContext.Current.Request.Browser.Browser.ToString + " " + HttpContext.Current.Request.Browser.Platform.ToString + "" + HttpContext.Current.Request.Browser.Win32.ToString + "isMobile = " + HttpContext.Current.Request.Browser.IsMobileDevice.ToString + " UserHostName = " + HttpContext.Current.Request.UserHostName.ToString
            CallApiWithBasicAuth()





















            'msg = FunctionsComClass.CheckIPAccount("10.4.196.12").ToString
            ' msg = strIPAdd 'FunctionsComClass.CheckIPAccount(strIPAdd).ToString
            If (msg.StartsWith("0|")) Then
                msgar = Split(msg, "|")
                strAccount = msgar(1).ToString()
                lblAccount.Text = strAccount.ToString

                ' ThongTinKH()
            Else
                lblAccount.Text = msg
                btnGiaHan.Visible = False
            End If
            'NoCuoc()
            '
        End If
        If (lblTrangThai.Text = "Setup") Then
            'If (strIPAdd = "10.1.2.56") Then
            If (lblDoiTac.Text = "SPT1") Then
                Response.Redirect("ThiCongSPT.aspx?MaHD=" + FunctionsComClass.Encrypt(lblMaHD.Text))
            Else
                Response.Redirect("ThiCongSPT.aspx?MaHD=" + FunctionsComClass.Encrypt(lblMaHD.Text))
            End If
        End If
        'btnGiaHan
        If (lblTrangThai.Text = "Disable") Or (lblTrangThai.Text = "Pause") Or (lblTrangThai.Text = "") Or (intTrangThai > 3) Then
            btnGiaHan.Visible = False
        End If



    End Sub
    Private Sub CallApiWithBasicAuth()
        Dim username As String = "admin"
        Dim password As String = "admin177"
        Dim apiUrl As String = "http://192.168.88.1:8088/rest/ip/dhcp-server/lease?.proplist=address,mac-address&address=192.168.88.250"

        Dim request As HttpWebRequest = CType(WebRequest.Create(apiUrl), HttpWebRequest)
        request.Method = "GET"

        ' Tạo chuỗi base64 username:password
        Dim credentials As String = Convert.ToBase64String(Encoding.ASCII.GetBytes(username & ":" & password))
        request.Headers(HttpRequestHeader.Authorization) = "Basic " & credentials

        Try
            Using response As HttpWebResponse = CType(request.GetResponse(), HttpWebResponse)
                Using reader As New StreamReader(response.GetResponseStream())
                    Dim result As String = reader.ReadToEnd()
                    ' Khởi tạo bộ phân tích JSON
                    Dim serializer As New JavaScriptSerializer()
                    Dim dataList As List(Of Dictionary(Of String, Object)) = serializer.Deserialize(Of List(Of Dictionary(Of String, Object)))(result)

                    ' Duyệt từng phần tử trong array
                    For Each item As Dictionary(Of String, Object) In dataList
                        Dim id As String = item(".id").ToString
                        Dim MacAddress As String = item("mac-address").ToString()
                        Dim address As String = item("address").ToString()
                        'Dim age As Integer = Convert.ToInt32(item("age"))

                        lblChuTB.Text = MacAddress

                    Next

                End Using
            End Using
        Catch ex As Exception
            Response.Write("Lỗi gọi API: " & ex.Message)
        End Try
    End Sub

    Sub ThongTinKH()
        Dim mySqlCommand As SqlCommand
        Dim mySqlDataReader As SqlDataReader

        Dim strSQL As String = "Select MaHD,TenKH, DiaChiGiaoDich,GOICUOC,TrangThai,DaiLy FROM HDFttx  where Account = " + "'" + lblAccount.Text + "'"
        mySqlCommand = New SqlCommand(strSQL, mySqlConnection)
        mySqlConnection.Open()
        mySqlDataReader = mySqlCommand.ExecuteReader(System.Data.CommandBehavior.CloseConnection)
        While (mySqlDataReader.Read())
            'txtMaHD.Te = mySqlDataReader("MaHD").ToString.Trim
            StrTenKH = mySqlDataReader("TenKH").ToString.Trim
            StrDiaChiGiaoDich = mySqlDataReader("Diachigiaodich").ToString.Trim
            lblTrangThai.Text = mySqlDataReader("TrangThai").ToString.Trim
            lblDoiTac.Text = mySqlDataReader("DaiLy").ToString.Trim
            lblMaHD.Text = mySqlDataReader("MaHD").ToString.Trim
            lblChuTB.Text = StrTenKH.ToString
            lblDiaChiLapDat.Text = StrDiaChiGiaoDich.ToString

        End While
        mySqlDataReader.Close()
        mySqlConnection.Close()
    End Sub
    Protected Sub NoCuoc()
        Dim mySqlCommand As SqlCommand
        Dim mySqlDataReader As SqlDataReader

        Dim strSQL As String = "Select * FROM NhacNo  where (Account = " + "'" + lblAccount.Text + "') AND NhacNoId=(Select Max(NhacNoId) From NhacNo  where (Account = " + "'" + lblAccount.Text + "')) AND (YEAR(THOIGIAN) = YEAR({ fn NOW() })) AND (MONTH(THOIGIAN) = MONTH({ fn NOW() }))"
        mySqlCommand = New SqlCommand(strSQL, mySqlConnection)
        mySqlConnection.Open()
        mySqlDataReader = mySqlCommand.ExecuteReader(System.Data.CommandBehavior.CloseConnection)
        While (mySqlDataReader.Read())
            'txtMaHD.Te = mySqlDataReader("MaHD").ToString.Trim
            lblCuoc.Text = mySqlDataReader("SoTien").ToString.Trim
            lblNoiDung.Text = mySqlDataReader("Noidung").ToString.Trim
            intTrangThai = mySqlDataReader("TrangThai").ToString.Trim

        End While
        mySqlDataReader.Close()
        mySqlConnection.Close()
    End Sub

    Protected Sub btnGiaHan_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim StrResult, strMsg, strSubject, strNoiDung As String
        StrResult = "" 'FunctionsComClass.OpenDebtAccount(lblAccount.Text, Session("USERNAME")).ToString
        If (StrResult.StartsWith("0|")) Then
            lblMessage.Visible = True
            lblMessage.Text = "Gia hạn thành công, Quý khách vui lòng tắt nguồn modem rồi bật lại để sử dụng Internet"
            strMsg = "Gia hạn thành công"
        Else
            lblMessage.Visible = True
            lblMessage.Text = "Gia hạn không thành công!"
            strMsg = "Gia hạn không thành công"
        End If
        FunctionsComClass.GhiLog(strMsg, "btnGiaHan_Click", lblAccount.Text)
        strSubject = "Khach hang: " + lblAccount.Text + " da thuc hien ra han no cuoc: " + strMsg + ". Sales lien he KH de thu cuoc"
        FunctionsComClass.SendEmailTelegram(";;;", strSubject, strSubject)
        CapNhatGiaHan()
    End Sub
    Protected Sub CapNhatGiaHan()
        Dim StrSQLUPDATE As String
        Dim mySqlCommand As SqlCommand

        intTrangThai =intTrangThai+1
        StrSQLUPDATE = " UPDATE NhacNo set TrangThai=@p_TrangThai,THOIGIAN_GIAHAN=@p_THOIGIAN_GIAHAN where NhacNoID=@p_NhacNoId"
        mySqlCommand = New SqlCommand(StrSQLUPDATE, mySqlConnection)
        mySqlCommand.Parameters.Add(New SqlParameter("@p_TrangThai", intTrangThai))
        mySqlCommand.Parameters.Add(New SqlParameter("@p_THOIGIAN_GIAHAN", Now()))
        mySqlCommand.Parameters.Add(New SqlParameter("@p_TrangThai", intNhacNoId))
        mySqlConnection.Open()
        Try
            mySqlCommand.ExecuteNonQuery()
        Catch ex As Exception
            lblMessage.Text = "Loi xay ra qua trinh gia han"
        End Try


    End Sub
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
   
    <title>Hỗ trợ - chăm sóc khách hàng</title>
	<meta http-equiv="Content-type" content="text/html;charset=UTF-8">
	<meta name="SKYPE_TOOLBAR" content="SKYPE_TOOLBAR_PARSER_COMPATIBLE">
	<meta name="format-detection" content="telephone=no">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
	<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
	<!--[if lt IE 9]>
	<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
	<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
	<![endif]-->

	<link href='https://fonts.googleapis.com/css?family=Roboto:300,400,700,500&subset=latin,vietnamese,latin-ext' rel='stylesheet' type='text/css'>
	<link href="https://fonts.googleapis.com/css?family=Roboto+Condensed:400,700&amp;subset=vietnamese" rel="stylesheet">

	<link href="https://fonts.googleapis.com/css?family=Open+Sans:400,600,700" rel="stylesheet">

	<link rel="icon" href="../NoCuoc/images/front/favicon.ico" type="image/x-icon">
	<link rel="stylesheet" type="text/css" href="./fonts/font-awesome.min.css"/>
	<link rel="stylesheet" type="text/css" href="./css/bootstrap.css"/>
	<link rel="stylesheet" type="text/css" href="./css/jquery.mmenu.all.css"/>
	<link rel="stylesheet" type="text/css" href="./css/camera.css"/>
	<link rel="stylesheet" type="text/css" href="./css/slick.css"/>
	<link rel="stylesheet" type="text/css" href="./css/common.css"/>
	<link rel="stylesheet" type="text/css" href="./css/animate.css"/>
	<link rel="stylesheet" type="text/css" href="./css/css-hex.css"/>
	
</head>
<body>
    <form id="form1" runat="server">
	<div id="wrapper">
		<header>
			<div class="container">
				<div class="m-logo">
					<h1>
						<a href="">
							&nbsp;<div class="detail">
								<p>Website CSKH - nhắc nợ cước</p>
								<span>Sài Gòn Postel-Chi nhánh Hà Nội</span>
							</div>
						</a>
					</h1>
				</div>
			</div>
		</header>
		<div id="content">
			<div class="container">
				<div class="m-content">
				<div class="m-user">
					<p>Account: <asp:Label ID="lblAccount" runat="server" Text="Account"></asp:Label></p>
					<p class="name">Chủ thuê bao: <asp:Label ID="lblChuTB" runat="server" Text="Label"></asp:Label></p>
					<p class="add">Địa chỉ lắp đặt: 
                        <span><asp:Label ID="lblDiaChiLapDat" runat="server" Text="Label"></asp:Label></span></p>
						<asp:Label ID="lblTrangThai" runat="server" visible="false"></asp:Label>
                    <asp:Label ID="lblDoiTac" runat="server" visible="false"></asp:Label>
                    <asp:Label ID="lblMaHD" runat="server" visible="false"></asp:Label>
				</div>
				<div class="m-service text-center">
					
					<br />
                                               <asp:Label ID="lblMessage" runat="server" visible=false BackColor=Red Font-Bold=true Font-Size=Medium ></asp:Label>
				</div> 
				</div>
				<div class="m-content">
					<div class="part1">
						<h3>Nguyên nhân truy cập internet không thành công</h3>
						<div class="detail">
							<p>Quý khách bị chặn dịch vụ Internet do chưa thanh toán tiền cước với số tiền: <span>
                                <asp:Label ID="lblCuoc" runat="server" Text=""></asp:Label></span> VNĐ</p>
							<ul class="m-info">
								<li>
									<h5 class="pop1">Chi tiết tháng nợ cước</h5>
									<div class="s-pop1">
										<p>Nợ cước: <span> <asp:Label runat="server" ID="lblNoiDung"> </asp:Label> </span></p>
									</div>
								</li>
								<li>
									<h5 class="pop2">Chi tiết tiền cước</h5>
									<div class="s-pop2">
										<p>Tiền nợ: <span>.....</span> <span>VNĐ</span></p>
									</div>
								</li>
								<li><h5 class="pop3">Gia hạn nợ cước</h5></li>
							</ul>
						</div>
					</div>
					<div class="clear"></div>
					<div class="part1">
						<h3>Thanh toán chuyển khoản qua Ngân Hàng</h3>
						<div class="detail">
							<p>Chủ tài khoản: CHI NHÁNH CÔNG TY CỔ PHẦN DỊCH VỤ BƯU CHÍNH VIỄN THÔNG SÀI GÒN TẠI THÀNH PHỐ HÀ NỘI</p>
							<div class="container">
                                <div class="row pop1" >
                                    <div class="col-xs-2">
                                        <p class="sub ">1. Ngân hàng VCB:</p>
                                    </div>
                                    
                                    <div class="col-xs-10" >
                                       <p class="pop1"> - Tên chủ TK: CN CTCP DV B.CHINH V.THONG SG TAI TP.HN</p>
                                       <p class="pop2"> - Số TK: 0011004263876 tại NH TMCP Ngoại thương Việt nam (Vietcombank)</p>
                                    </div>

                              </div>
                                <div class="row">
                                    <div class="col-xs-2">
                                        <p class="sub ">2. Ngân hàng BIDV:</p>
                                    </div>
                                    
                                    <div class="col-xs-10">
                                       <p> - Tên chủ TK: CN CTY CP DV Buu chinh vien thong Sai Gon tai TP Ha Noi</p>
                                       <p> - Số TK: 12210001776852 Ngân hàng Đầu tư và phát triển Việt Nam (BIDV) chi nhánh Hà Thành</p>
                                    </div>

                              </div>
                                <div class="row">
                                    <div class="col-xs-2">
                                        <p class="sub ">3. Ngân hàng ACB:</p>
                                    </div>
                                    
                                    <div class="col-xs-10">
                                       <p> - Tên TK: CNCT CP DVBCVT SAI GON tại TP HN</p>
                                       <p> - Số TK: 2803289 tại Ngân hàng TMCP Á Châu (ACB) – Chi nhánh Hà Nội</p>
                                    </div>

                              </div>
                                <div class="row">
                                    <div class="col-xs-2">
                                        <p class="sub ">4. Ngân hàng MB:</p>
                                    </div>
                                    
                                    <div class="col-xs-10">
									
                                       <p> - Tên TK: CN CTCP DV B.CHINH V.THONG SG TAI TP.HN</p>
                                       <p> - Số TK: 03601011231235 tại NH TMCP Hàng Hải Việt Nam (Maritime Bank) – PDG Hàng Đậu</p> 
									  
                                    </div>

                              </div>
                            </div>
                           
                           
						
						<p>(*)Nội dung chuyển khoản: Thanh toán cước Internet hợp đồng số: <asp:Label ID="lblMaHopDong" runat="server" Font-Size ="Medium" BorderColor ="Black"  ></asp:Label>: điện thoại liên hệ: ... để nhận thông báo xác nhận chuyển khoản</p>		
						
							</div>
						</div>
					
					<div class="clear"></div>
					<div class="part1">
						<h3>Gia hạn sử dụng dịch vụ Internet</h3>
						<div class="detail">
							<p>Nếu quý khách hàng chưa thể thanh toán tiền cước Internet, quý khách có thể tạm thời sử dụng dịch vụ bằng cách bấm vào nút "Gia hạn cước nợ" ở dưới.</p>
							<table class="m-card">
								<tr>
									<th>Số lần đã gia hạn (*)</th>
									<td>---</td>
								</tr>
								<tr>
									<th>Lần gia hạn gần nhất</th>
									<td>---</td>
								</tr>
							</table>
							<p class="sub">(*) Tính từ thời điểm quý khách hàng đóng tiền cước gần nhất.</p>
							<div class="m-tips">
								<p class="tips">Chú ý:</p>
								<ul>
									<li>Mỗi lần gia hạn, quý khách sẽ được sử dụng dịch vụ trong vòng 24h kể từ thời điểm tiến hành gia hạn hoặc đến thời điểm chặn cước của hệ thống</li>
									
									<li>Quý khách hàng chỉ có thể gia hạn tối đa <strong>3 lần</strong>. Nếu quá số lần cho phép, quý khách vui lòng thanh toán tiền cước để tiếp tục sử dụng dịch vụ.</li>
								</ul>
							</div>
							<div class="clear"></div>
							<div class="m-addpay">
									<ul class="add">
										
										
									</ul>
									<div class="m-service text-center" >
					                <asp:Button ID="btnGiaHan" runat="server" 
                                                Text="Gia hạn nợ cước" onclick="btnGiaHan_Click" Font-Bold=true Font-Size=Medium visible="true" />
                                                
					
				</div>
                                	
							</div>
						</div>
					</div>
				</form>
				</div>
			</div>
			
		</div> <!-- end content -->
		
		<footer>
			<div class="container">
				<div class="footer">
					<p>Số điện thoại hỗ trợ của Trung tâm chăm sóc khách hàng - SPT Chi nhánh Hà Nội: 19007155</p>
				</div>
			</div>
		</footer>

	</div> <!-- end wrapper -->


	<script type="text/javascript" src="../NoCuoc/js/jquery-1.9.1.js"></script>
	<script type="text/javascript" src="../NoCuoc/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="../NoCuoc/js/smoothscroll.js"></script>
	<script type="text/javascript" src="../NoCuoc/js/jquery.mmenu.all.min.js"></script>
	<script type="text/javascript" src="../NoCuoc/js/jquery.easing.1.3.js"></script>
	<script type="text/javascript" src="../NoCuoc/js/camera.js"></script>
	<script type="text/javascript" src="../NoCuoc/js/slick.min.js"></script>
	<script type="text/javascript" src="../NoCuoc/js/common.js"></script>
    </form>
</body>
</html>
