	-- Kiểm tra và xóa database nếu tồn tại
    IF EXISTS (SELECT * FROM sys.databases WHERE name = 'BANHANG_NHOM4')
BEGIN
	USE master
    ALTER DATABASE BANHANG_NHOM4 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE BANHANG_NHOM4
END;
GO 
CREATE DATABASE BANHANG_NHOM4 
GO
USE BANHANG_NHOM4;
--Tạo bảng KHÁCH HÀNG
	CREATE TABLE KHACHHANG
	(
		MAKHACHHANG CHAR(10) PRIMARY KEY,
		TENCONGTY NVARCHAR(50),
		TENGIAODICH NVARCHAR(50) NOT NULL,
		DIACHI NVARCHAR(50) NOT NULL,
		EMAIL VARCHAR(50) UNIQUE,
		DIENTHOAI VARCHAR(11) UNIQUE NOT NULL,
		FAX VARCHAR(10) UNIQUE
	)
--Tạo bảng NHÂN VIÊN
	CREATE TABLE NHANVIEN 
	(
		MANHANVIEN CHAR(10) PRIMARY KEY,
		HO NVARCHAR(10) NOT NULL,
		TEN NVARCHAR(10) NOT NULL,
		NGAYSINH DATETIME NOT NULL,
		NGAYLAMVIEC DATE NOT NULL,
		DIACHI NVARCHAR(50) NOT NULL,
		DIENTHOAI VARCHAR(10) UNIQUE NOT NULL,
		LUONGCOBAN DECIMAL(15,5) NOT NULL,
		PHUCAP DECIMAL(15,5)
	)
--Tạo bảng ĐƠN ĐẶT HÀNG
	CREATE TABLE DONDATHANG 
	(
		SOHOADON CHAR(10) PRIMARY KEY,
		MAKHACHHANG CHAR(10),
		MANHANVIEN CHAR(10),
		NGAYDATHANG DATE NOT NULL,
		NGAYGIAOHANG DATE,
		NGAYCHUYENHANG DATE,
		NOIGIAOHANG NVARCHAR(50) NOT NULL
			
	)
--Tạo bảng NHÀ CUNG CẤP
	CREATE TABLE NHACUNGCAP
	(
		MACONGTY CHAR(10) PRIMARY KEY,
		TENCONGTY NVARCHAR(50) NOT NULL,
		TENGIAODICH NVARCHAR(50) NOT NULL,
		DIACHI NVARCHAR(80),
		DIENTHOAI VARCHAR(11) UNIQUE NOT NULL,
		FAX VARCHAR(10) UNIQUE,
		EMAIL VARCHAR(50) UNIQUE
	)
--Tạo bảng LOẠI HÀNG
	CREATE TABLE LOAIHANG 
	(
		MALOAIHANG CHAR(10) PRIMARY KEY,
		TENLOAIHANG NVARCHAR(30)
	)
--Tạo Bảng MẶT HÀNG
	CREATE TABLE MATHANG 
	(
		MAHANG CHAR(10) PRIMARY KEY,
		TENHANG NVARCHAR(50) NOT NULL,
		MACONGTY CHAR(10),
		MALOAIHANG CHAR(10) ,
		SOLUONG FLOAT CHECK(SOLUONG >= 0),
		DONVITINH NVARCHAR(10) NOT NULL,
		GIAHANG MONEY CHECK(GIAHANG > 0),
		
	)
--Tạo bảng CHI TIẾT ĐẶT HÀNG
	CREATE TABLE CHITIETDATHANG 
	(
		SOHOADON CHAR(10) NOT NULL,
		MAHANG CHAR(10) NOT NULL,
		GIABAN MONEY CHECK(GIABAN > 0),
		SOLUONG FLOAT CHECK(SOLUONG > 0),
		MUCGIAMGIA DECIMAL(10,2) CHECK(MUCGIAMGIA >= 0),
			
	)
            ------------------------------ RÀNG BUỘC DATABASE ------------------------------

                     -------------Ràng buộc địa chỉ đa trị -> đơn trị--------------
--Thêm bảng Quốc Gia
CREATE TABLE QUOCGIA
(
    MAQG char(10) PRIMARY KEY,
    TENQG nvarchar(50)
)
--Thêm bảng Thành Phố
CREATE TABLE THANHPHO
(
    MATP char(10) PRIMARY KEY,
    TENTP nvarchar(50),
    MAQG char(10),
    FOREIGN KEY (MAQG) REFERENCES QUOCGIA(MAQG)
        ON DELETE 
			CASCADE
        ON UPDATE 
			CASCADE
)
--Thêm bảng Quận Huyện
CREATE TABLE QUANHUYEN
(
    MAQH char(10) PRIMARY KEY,
    TENQH nvarchar(50),
    MATP char(10),
    FOREIGN KEY (MATP) REFERENCES THANHPHO(MATP)
        ON DELETE 
			CASCADE
        ON UPDATE 
			CASCADE
)
--Thêm bảng Phường Xã
CREATE TABLE PHUONGXA
(
    MAPX char(10) PRIMARY KEY,
    TENPX nvarchar(50),
    MAQH char(10),
    FOREIGN KEY (MAQH) REFERENCES QUANHUYEN(MAQH)
        ON DELETE 
			CASCADE
        ON UPDATE 
			CASCADE
)
       -------- Sửa đổi lại các bảng có địa chỉ sau khi thêm các bảng chi tiết về địa chỉ--------

				-----------------Tách cột địa chỉ ở các bảng thành 2 cột-------------------
	----Bảng KHACHHANG----
ALTER TABLE KHACHHANG
	DROP COLUMN DIACHI
ALTER TABLE KHACHHANG
	ADD MAPX char(10),
		SONHATENDUONG nvarchar(80),
		--- Liên kết khóa ngoại đến bảng PHUONGXA
	 CONSTRAINT FK_KHACHHANG_MAPX 
		FOREIGN KEY (MAPX) REFERENCES PHUONGXA(MAPX)
			ON DELETE 
				CASCADE
			ON UPDATE 
				CASCADE;
--- Bảng NHACUNGCAP
ALTER TABLE NHACUNGCAP
	DROP COLUMN DIACHI
ALTER TABLE NHACUNGCAP
	ADD MAPX char(10),
		SONHATENDUONG nvarchar(100),
	--- Liên kết khóa ngoại đến bảng PHUONGXA
		CONSTRAINT FK_NHACUNGCAP_MAPX 
			FOREIGN KEY (MAPX) REFERENCES PHUONGXA(MAPX)
				ON DELETE 
					NO ACTION
				ON UPDATE 
					NO ACTION;
-- Bảng DONDATHANG 
ALTER TABLE DONDATHANG
	DROP COLUMN NOIGIAOHANG
ALTER TABLE DONDATHANG
	ADD MAPX char(10),
		DIACHICUTHE nvarchar(100),
	--- Liên kết khóa ngoại đến bảng PHUONGXA
	 CONSTRAINT FK_DONDATHANG_MAPX 
		FOREIGN KEY (MAPX) REFERENCES PHUONGXA(MAPX)
			ON DELETE 
				NO ACTION
			ON UPDATE 
				NO ACTION;

--- Ràng buộc TENCONGTY trong bảng KHACHHANG
ALTER TABLE KHACHHANG
ADD CONSTRAINT DF_KHACHHANG_TENCONGTY
	DEFAULT N'Khách hàng cá nhân' FOR TENCONGTY

		-------------Bổ sung các khóa ngoại, ràng buộc cho các bảng ----------------------

              ---------------------Bảng DONDATHANG -------------------------
ALTER TABLE DONDATHANG
	ADD CONSTRAINT FK_DONDATHANG_KHACHHANG FOREIGN KEY (MAKHACHHANG) REFERENCES KHACHHANG(MAKHACHHANG)
				ON DELETE 
					CASCADE
				ON UPDATE 
					CASCADE,
		CONSTRAINT FK_DONDATHANG_NHANVIEN FOREIGN KEY (MANHANVIEN) REFERENCES NHANVIEN(MANHANVIEN)
				ON DELETE 
					CASCADE
				ON UPDATE 
					CASCADE,
				--------Bổ sung các khóa ràng buộc về thứ tự ngày-------
		CONSTRAINT DF_DONDATHANG_NGAYDATHANG 
				DEFAULT GETDATE() FOR NGAYDATHANG,
		CONSTRAINT CK_DONDATHANG_NGAYCHUYENHANG 
				CHECK(NGAYCHUYENHANG >= NGAYDATHANG),
		CONSTRAINT CK_DONDATHANG_NGAYGIAOHANG 
				CHECK(NGAYGIAOHANG >= NGAYCHUYENHANG);

				     ------------------ Bảng NHACUNGCAP	----------------------
ALTER TABLE NHACUNGCAP
		---------Bổ sung ràng buộc về định dạng của email, số điện thoại---------
    ADD CONSTRAINT CK_NHACUNGCAP_EMAIL
				CHECK (EMAIL LIKE '[a-zA-Z]%@%_'),
		CONSTRAINT CK_NHACUNGCAP_DIENTHOAI 
				CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
						 OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

				     -------------------- Bảng MATHANG ------------------------
ALTER TABLE MATHANG 
		------- Thêm khóa phụ đến bảng NHACUNGCAP và LOAIHANG
	ADD CONSTRAINT FK_MATHANG_NHACUNGCAP FOREIGN KEY (MACONGTY) REFERENCES NHACUNGCAP(MACONGTY)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
		CONSTRAINT FK_MATHANG_LOAIHANG FOREIGN KEY (MALOAIHANG) REFERENCES LOAIHANG(MALOAIHANG)
				ON DELETE CASCADE
				ON UPDATE CASCADE
	
				    ------------------ Bảng CHITIETDATHANG --------------------
ALTER TABLE CHITIETDATHANG
	--- Liên kết khóa ngoại đến bảng DONDATHANG và MATHANG
	ADD CONSTRAINT FK_CHITIETDATHANG_DONDATHANG	FOREIGN KEY(SOHOADON) REFERENCES DONDATHANG(SOHOADON)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
		CONSTRAINT FK_CHITIETDATHANG_MATHANG FOREIGN KEY(MAHANG) REFERENCES MATHANG(MAHANG)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
	--- SET SOHOADON và MAHANG làm khóa chính 
		CONSTRAINT PK_CHITIETDATHANG_SOHOADON_MAHANG PRIMARY KEY (SOHOADON, MAHANG),
	--- Bổ sung các ràng buộc cho số lượng và mức giảm giá
		CONSTRAINT DF_CHITIETDATHANG_SOLUONG 
				DEFAULT 1 FOR SOLUONG,
		CONSTRAINT DF_CHITIETDATHANG_MUCGIAMGIA 
				DEFAULT 0 FOR MUCGIAMGIA;

				      ------------------ Bảng KHACHHANG -------------------
ALTER TABLE KHACHHANG
	ADD CONSTRAINT CK_KHACHHANG_DIENTHOAI 
			CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
					 OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		CONSTRAINT CK_KHACHHANG_EMAIL
			CHECK (EMAIL LIKE '[a-zA-Z]%@%_');

				      ------------------- Bảng NHANVIEN ---------------------
--Ràng buộc về số điện thoại 10 or 11 số cho bảng Nhân Viên
ALTER TABLE NHANVIEN
	ADD CONSTRAINT CK_NHANVIEN_DIENTHOAI 
			CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
					OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		--Ràng buộc ngày sinh của nhân viên phải đủ 18 tuổi và không quá 60 tuổi
		CONSTRAINT CK_NHANVIEN_NGAYSINH
			CHECK (DATEDIFF(DAY, Ngaysinh, GETDATE()) / 360 >= 18 
					 And DATEDIFF(DAY, Ngaysinh, GETDATE()) / 360 <=60  );

	     -------------------------------- INSERT DỮ LIỆU ------------------------------

--- Bảng Quốc Gia---
INSERT INTO QuocGia
	VALUES ('QG001', N'Việt Nam'); 

-- Bảng Tỉnh/Thành Phố 
INSERT INTO THANHPHO(MATP, TENTP, MAQG)
	VALUES
	('TT001', N'Hà Nội', 'QG001'),
	('TT048', N'Đà Nẵng', 'QG001'),
	('TT046', N'Thừa Thiên Huế', 'QG001'),
	('TT079', N'Hồ Chí Minh', 'QG001'),
	('TT045', N'Quảng Trị', 'QG001'),
	('TT044', N'Quảng Bình', 'QG001'),
	('TT031', N'Hải Phòng', 'QG001'),
	('TT037', N'Ninh Bình', 'QG001'),
	('TT038', N'Thanh Hóa', 'QG001'),
	('TT040', N'Nghệ An', 'QG001');

-- Bảng Quận/Huyện
INSERT INTO QUANHUYEN(MAQH, TENQH, MATP)
VALUES
	('QH001', N'Quận Ba Đình', 'TT001'),
	('QH002', N'Quận Hoàn Kiếm', 'TT001'),
	('QH003', N'Quận Hải Châu', 'TT048'),
	('QH004', N'Quận Sơn Trà', 'TT048'),
	('QH005', N'Quận Hải An', 'TT031'),
	('QH006', N'Quận Lê Chân', 'TT031'),
	('QH007', N'Huyện Phong Điền', 'TT046'),
	('QH008', N'Huyện Hương Trà', 'TT046'),
	('QH009', N'Huyện Lệ Thủy', 'TT044'),
	('QH010', N'Huyện Quảng Trạch', 'TT044');

-- Bảng Phường/Xã
INSERT INTO PHUONGXA(MAPX, TENPX, MAQH)
	VALUES
	('PX001', N'Phường Kim Mã', 'QH001'),
	('PX002', N'Phường Trúc Bạch', 'QH001'),
	('PX003', N'Phường Hàng Bông', 'QH002'),
	('PX004', N'Phường Cửa Nam', 'QH002'),
	('PX005', N'Phường Thuận Phước', 'QH003'),
	('PX006', N'Phường Bình Hiên', 'QH003'),
	('PX007', N'Phường An Hải Bắc', 'QH004'),
	('PX008', N'Phường Mân Thái', 'QH004'),
	('PX009', N'Phường Đằng Hải', 'QH005'),
	('PX010', N'Phường Đằng Lâm', 'QH005');

--Đổi định dạng ngày nhập vào thành dd/MM/yyyy
SET DATEFORMAT dmy;

-- Bảng LOAIHANG
INSERT INTO LOAIHANG (MALOAIHANG, TENLOAIHANG) 
VALUES
	('LH001', N'Thực phẩm đóng hộp'),  
	('LH002', N'Đồ uống giải khát'),   
	('LH003', N'Bánh kẹo'),            
	('LH004', N'Gia vị'),              
	('LH005', N'Sữa và sản phẩm sữa'), 
	('LH006', N'Mì và bún'),           
	('LH007', N'Gạo và ngũ cốc'),      
	('LH008', N'Rau củ quả'),          
	('LH009', N'Thịt và hải sản'),     
	('LH010', N'Đồ gia dụng');

-- Bảng NHACUNGCAP
INSERT INTO NHACUNGCAP (MACONGTY, TENCONGTY, TENGIAODICH, MAPX, SONHATENDUONG, DIENTHOAI, FAX, EMAIL) 
VALUES
	('NCC001', N'Công ty TNHH Nestlé Việt Nam', N'Nestlé VN', 'PX001', N'22 Đường Số 1', '0901234567', '0901234568', 'nestle@email.com'),
	('NCC002', N'Công ty CP Vinamilk', N'Vinamilk', 'PX003', N'10 Tân Trào', '0912345678', '0912345679', 'vinamilk@email.com'),
	('NCC003', N'Công ty TNHH Unilever VN', N'Unilever', 'PX005', N'156 Nguyễn Lương Bằng', '0923456789', '0923456790', 'unilever@email.com'),
	('NCC004', N'Công ty TNHH Coca-Cola VN', N'Coca-Cola', 'PX002', N'485 Nguyễn Văn Cừ', '0934567890', '0934567891', 'cocacola@email.com'),
	('NCC005', N'Công ty CP Masan Consumer', N'Masan', 'PX004', N'39 Lê Duẩn', '0945678901', '0945678902', 'masan@email.com'),
	('NCC006', N'Công ty TNHH P&G Việt Nam', N'P&G', 'PX006', N'27 Nguyễn Thị Minh Khai', '0956789012', '0956789013', 'pg@email.com'),
	('NCC007', N'Công ty CP Acecook Việt Nam', N'Acecook', 'PX007', N'44 Vũ Trọng Phụng', '0967890123', '0967890124', 'acecook@email.com'),
	('NCC008', N'Công ty TNHH Pepsi Việt Nam', N'Pepsi', 'PX008', N'15 Lê Lợi', '0978901234', '0978901235', 'pepsi@email.com'),
	('NCC009', N'Công ty CP Kinh Đô', N'Kinh Do', 'PX009', N'88 Hai Bà Trưng', '0989012345', '0989012346', 'kinhdo@email.com'),
	('NCC010', N'Công ty TNHH Lavie', N'Lavie', 'PX010', N'63 Nguyễn Du', '0990123456', '0990123457', 'lavie@email.com');

-- Bảng MATHANG
INSERT INTO MATHANG (MAHANG, TENHANG, MACONGTY, MALOAIHANG, SOLUONG, DONVITINH, GIAHANG) 
VALUES
	('MH001', N'Sữa tươi Vinamilk 1L', 'NCC002', 'LH005', 1000, N'Hộp', 25000),
	('MH002', N'Coca Cola 330ml', 'NCC004', 'LH002', 2000, N'Lon', 10000),
	('MH003', N'Mì gói Hảo Hảo', 'NCC007', 'LH001', 5000, N'Gói', 3500),
	('MH004', N'Bánh Oreo', 'NCC009', 'LH003', 1500, N'Gói', 15000),
	('MH005', N'Nước khoáng Lavie', 'NCC010', 'LH002', 3000, N'Chai', 8000),
	('MH006', N'Bột giặt Omo', 'NCC003', 'LH006', 800, N'Túi', 85000),
	('MH007', N'Dầu ăn Neptune', 'NCC005', 'LH004', 1200, N'Chai', 45000),
	('MH008', N'Sữa chua Vinamilk', 'NCC002', 'LH005', 2500, N'Hộp', 5000),
	('MH009', N'Pepsi 330ml', 'NCC008', 'LH002', 1800, N'Lon', 10000),
	('MH010', N'Bánh Kit Kat', 'NCC001', 'LH003', 2000, N'Gói', 12000);

-- Bảng KHACHHANG
INSERT INTO KHACHHANG (MAKHACHHANG, TENCONGTY, TENGIAODICH, MAPX, SONHATENDUONG, EMAIL, DIENTHOAI, FAX) 
VALUES
	('KH001', N'Công ty CP Masan Consumer', 'Masan', 'PX001', N'123 Lê Lợi', 'bigc@email.com', '0123456789', '0123456790'),
	('KH002', N'Công ty TNHH Coca-Cola VN', N'Coca-Cola', 'PX002', N'456 Nguyễn Huệ', 'coopmart@email.com', '0234567890', '0234567891'),
	('KH003', N'Cửa hàng Bách Hóa Xanh', N'BHX', 'PX003', N'789 Lê Lai', 'bhx@email.com', '0345678901', '0345678902'),
	('KH004', N'Siêu thị Vinmart', N'Vinmart', 'PX004', N'321 Phan Chu Trinh', 'vinmart@email.com', '0456789012', '0456789013'),
	('KH005', DEFAULT, N'Lê Ngọc Tân', 'PX005', N'654 Trần Hưng Đạo', 'sveleven@email.com', '0567890123', '0567890124'),
	('KH006', DEFAULT, N'Nguyễn Văn An', 'PX006', N'987 Lê Duẩn', 'nguyenvana@email.com', '0678901234', '0678901235'),
	('KH007', DEFAULT, N'Trần Thị Bình', 'PX007', N'147 Nguyễn Du', 'tranthib@email.com', '0789012345', '0789012346'),
	('KH008', N'Circle K', N'Circle K', 'PX008', N'258 Hai Bà Trưng', 'circlek@email.com', '0890123456', '0890123457'),
	('KH009', N'Ministop', N'Ministop', 'PX009', N'369 Lý Tự Trọng', 'ministop@email.com', '0901234567', '0901234568'),
	('KH010', N'Công ty CP Acecook Việt Nam', N'Acecook', 'PX010', N'159 Nam Kỳ Khởi Nghĩa', 'familymart@email.com', '0912345678', '0912345679');

-- Bảng NHANVIEN
INSERT INTO NHANVIEN (MANHANVIEN, HO, TEN, NGAYSINH, NGAYLAMVIEC, DIACHI, DIENTHOAI, LUONGCOBAN, PHUCAP) 
VALUES
	('NV001', N'Nguyễn', N'An', '15-05-1990', '01-01-2015', N'234 Kim Mã', '0123123123', 10000000, 1000000),
	('NV002', N'Trần', N'Bình', '20-08-1992', '15-03-2016', N'567 Láng Hạ', '0234234234', 12000000, 1500000),
	('NV003', N'Lê', N'Cường', '10-12-1988', '01-06-2014', N'890 Đội Cấn', '0345345345', 15000000, 2000000),
	('NV004', N'Phạm', N'Dung', '25-03-1995', '01-09-2018', N'123 Ba Đình', '0456456456', 9000000, 800000),
	('NV005', N'Hoàng', N'Em', '30-07-1993', '15-12-2017', N'456 Hoàn Kiếm', '0567567567', 11000000, 1200000),
	('NV006', N'Đặng', N'Phương', '05-11-1991', '01-08-2016', N'789 Hai Bà Trưng', '0678678678', 13000000, 1800000),
	('NV007', N'Vũ', N'Giang', '18-02-1994', '15-01-2019', N'321 Đống Đa', '0789789789', 8500000, 700000),
	('NV008', N'Mai', N'Hương', '22-09-1989', '01-11-2015', N'654 Cầu Giấy', '0890890890', 14000000, 2500000),
	('NV009', N'Bùi', N'Linh', '12-04-1996', '01-03-2020', N'987 Tây Hồ', '0901901901', 9500000, 900000),
	('NV010', N'Đỗ', N'Minh', '28-06-1992', '15-05-2017', N'147 Long Biên', '0912912912', 12500000, 1600000);

-- Bảng DONDATHANG
INSERT INTO DONDATHANG (SOHOADON, MAKHACHHANG, MANHANVIEN, NGAYDATHANG, NGAYCHUYENHANG, NGAYGIAOHANG, MAPX, DIACHICUTHE) 
VALUES
    ('HD001', 'KH001', 'NV001', '15-01-2022', '17-01-2022', '20-01-2022', 'PX001', N'123 Lê Lợi'),
    ('HD002', 'KH002', 'NV002', '10-02-2022', '11-02-2022', '15-02-2022', 'PX002', N'117 Nguyễn Huệ'),
    ('HD003', 'KH003', 'NV003', '05-03-2023', '06-03-2023', '10-03-2023', 'PX003', N'789 Lê Lai'),
    ('HD004', 'KH004', 'NV004', '20-04-2022', '22-04-2022', '25-04-2022', 'PX004', N'321 Phan Chu Trinh'),
    ('HD005', 'KH005', 'NV005', '15-05-2023', '16-05-2023', '20-05-2023', 'PX005', N'654 Trần Hưng Đạo'),
    ('HD006', 'KH006', 'NV006', '10-06-2022', '12-06-2022', '15-06-2022', 'PX006', N'12 Lê Thánh Tông'),
    ('HD007', 'KH007', 'NV007', '25-07-2023', '26-07-2023', '30-07-2023', 'PX007', N'23 Bùi Viện'),
    ('HD008', 'KH008', 'NV008', '15-08-2022', '17-08-2022', '20-08-2022', 'PX008', N'45 Nguyễn Văn Trỗi'),
    ('HD009', 'KH009', 'NV009', '10-09-2023', '12-09-2023', '15-09-2023', 'PX009', N'678 Lê Văn Sỹ'),
    ('HD010', 'KH010', 'NV010', '05-10-2022', '06-10-2022', '10-10-2022', 'PX010', N'91 Cách Mạng Tháng 8');

-- Bảng CHITIETDATHANG
INSERT INTO CHITIETDATHANG (SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA) 
VALUES
	('HD001', 'MH001', 26000, 100, 5),
	('HD002', 'MH002', 11000, 200, 3),
	('HD003', 'MH003', 4000, 500, 2),
	('HD004', 'MH004', 16000, 150, 4),
	('HD005', 'MH005', 9000, 300, 2),
	('HD006', 'MH006', 90000, 50, 6),
	('HD007', 'MH007', 48000, 80, 3),
	('HD008', 'MH008', 5500, 200, 2),
	('HD009', 'MH009', 11000, 150, 4),
	('HD010', 'MH010', 13000, 100, 5);

	       ------------------------------ UPDATE DỮ LIỆU ------------------------------------
