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
		MAKHACHHANG CHAR(7) PRIMARY KEY,
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
		MANHANVIEN CHAR(7) PRIMARY KEY,
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
		SOHOADON CHAR(7) PRIMARY KEY,
		MAKHACHHANG CHAR(7),
		MANHANVIEN CHAR(7),
		NGAYDATHANG DATE NOT NULL,
		NGAYGIAOHANG DATE,
		NGAYCHUYENHANG DATE,
		NOIGIAOHANG NVARCHAR(100) 
			
	)
--Tạo bảng NHÀ CUNG CẤP
	CREATE TABLE NHACUNGCAP
	(
		MACONGTY CHAR(7) PRIMARY KEY,
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
		MALOAIHANG CHAR(7) PRIMARY KEY,
		TENLOAIHANG NVARCHAR(30)
	)
--Tạo Bảng MẶT HÀNG
	CREATE TABLE MATHANG 
	(
		MAHANG CHAR(7) PRIMARY KEY,
		TENHANG NVARCHAR(50) NOT NULL,
		MACONGTY CHAR(7),
		MALOAIHANG CHAR(7) ,
		SOLUONG FLOAT CHECK(SOLUONG >= 0),
		DONVITINH NVARCHAR(10) NOT NULL,
		GIAHANG MONEY CHECK(GIAHANG > 0),
		
	)
--Tạo bảng CHI TIẾT ĐẶT HÀNG
	CREATE TABLE CHITIETDATHANG 
	(
		SOHOADON CHAR(7) NOT NULL,
		MAHANG CHAR(7) NOT NULL,
		GIABAN MONEY CHECK(GIABAN > 0),
		SOLUONG FLOAT CHECK(SOLUONG > 0),
		MUCGIAMGIA DECIMAL(10,2) CHECK(MUCGIAMGIA >= 0),
			
	)
            ------------------------------ RÀNG BUỘC DATABASE ------------------------------

                     -------------Ràng buộc địa chỉ đa trị -> đơn trị--------------
--Thêm bảng Quốc Gia
CREATE TABLE QUOCGIA
(
    MAQG char(5) PRIMARY KEY,
    TENQG nvarchar(50)
)
--Thêm bảng Thành Phố
CREATE TABLE THANHPHO
(
    MATP char(5) PRIMARY KEY,
    TENTP nvarchar(50),
    MAQG char(5),
    FOREIGN KEY (MAQG) REFERENCES QUOCGIA(MAQG)
        ON DELETE 
			CASCADE
        ON UPDATE 
			CASCADE
)
--Thêm bảng Quận Huyện
CREATE TABLE QUANHUYEN
(
    MAQH char(5) PRIMARY KEY,
    TENQH nvarchar(50),
    MATP char(5),
    FOREIGN KEY (MATP) REFERENCES THANHPHO(MATP)
        ON DELETE 
			CASCADE
        ON UPDATE 
			CASCADE
)
--Thêm bảng Phường Xã
CREATE TABLE PHUONGXA
(
    MAPX char(5) PRIMARY KEY,
    TENPX nvarchar(50),
    MAQH char(5),
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
	ADD MAPX char(5),
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
	ADD MAPX char(5),
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
	 ADD MAPX char(5),
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
	('MLH1001', N'Thực phẩm đóng hộp'),  
	('MLH1002', N'Đồ uống giải khát'),   
	('MLH1003', N'Bánh kẹo'),            
	('MLH1004', N'Gia vị'),              
	('MLH1005', N'Sữa và sản phẩm sữa'), 
	('MLH1006', N'Mì và bún'),           
	('MLH1007', N'Gạo và ngũ cốc'),      
	('MLH1008', N'Rau củ quả'),          
	('MLH1009', N'Thịt và hải sản'),     
	('MLH1010', N'Đồ gia dụng');

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
-- Bảng MATHANG
INSERT INTO MATHANG (MAHANG, TENHANG, MACONGTY, MALOAIHANG, SOLUONG, DONVITINH, GIAHANG) 
VALUES
	('MMH1001', N'Sữa tươi Vinamilk 1L', 'NCC002', 'MLH1005', 1000, N'Hộp', 25000),
	('MMH1002', N'Coca Cola 330ml', 'NCC004', 'MLH1002', 2000, N'Lon', 10000),
	('MMH1003', N'Mì gói Hảo Hảo', 'NCC007', 'MLH1006', 5000, N'Gói', 3500),
	('MMH1004', N'Bánh Oreo', 'NCC009', 'MLH1003', 1500, N'Gói', 15000),
	('MMH1005', N'Nước khoáng Lavie', 'NCC010', 'MLH1002', 3000, N'Chai', 8000),
	('MMH1006', N'Bột giặt Omo', 'NCC003', 'MLH1009', 800, N'Túi', 85000),
	('MMH1007', N'Dầu ăn Neptune', 'NCC005', 'MLH1004', 1200, N'Chai', 45000),
	('MMH1008', N'Sữa chua Vinamilk', 'NCC002', 'MLH1005', 2500, N'Hộp', 5000),
	('MMH1009', N'Pepsi 330ml', 'NCC008', 'MLH1002', 1800, N'Lon', 10000),
	('MMH1010', N'Bánh Kit Kat', 'NCC001', 'MLH1003', 2000, N'Gói', 12000);

-- Bảng KHACHHANG
INSERT INTO KHACHHANG (MAKHACHHANG, TENCONGTY, TENGIAODICH, MAPX, SONHATENDUONG, EMAIL, DIENTHOAI, FAX) 
VALUES
	('MKH1001', N'Công ty CP Masan Consumer', 'Masan', 'PX001', N'123 Lê Lợi', 'bigc@email.com', '0123456789', '0123456790'),
	('MKH1002', N'Công ty TNHH Coca-Cola VN', N'Coca-Cola', 'PX002', N'456 Nguyễn Huệ', 'coopmart@email.com', '0234567890', '0234567891'),
	('MKH1003', N'Cửa hàng Bách Hóa Xanh', N'BHX', 'PX003', N'789 Lê Lai', 'bhx@email.com', '0345678901', '0345678902'),
	('MKH1004', N'Siêu thị Vinmart', N'Vinmart', 'PX004', N'321 Phan Chu Trinh', 'vinmart@email.com', '0456789012', '0456789013'),
	('MKH1005', DEFAULT, N'Lê Ngọc Tân', 'PX005', N'654 Trần Hưng Đạo', 'sveleven@email.com', '0567890123', '0567890124'),
	('MKH1006', DEFAULT, N'Nguyễn Văn An', 'PX006', N'987 Lê Duẩn', 'nguyenvana@email.com', '0678901234', '0678901235'),
	('MKH1007', DEFAULT, N'Trần Thị Bình', 'PX007', N'147 Nguyễn Du', 'tranthib@email.com', '0789012345', '0789012346'),
	('MKH1008', N'Circle K', N'Circle K', 'PX008', N'258 Hai Bà Trưng', 'circlek@email.com', '0890123456', '0890123457'),
	('MKH1009', N'Công ty CP Kinh Đô', N'Kinh Do', 'PX009', N'369 Lý Tự Trọng', 'ministop@email.com', '0901234567', '0901234568'),
	('MKH1010', N'Công ty CP Acecook Việt Nam', N'Acecook', 'PX010', N'159 Nam Kỳ Khởi Nghĩa', 'familymart@email.com', '0912345678', '0912345679');

	-- Bảng NHANVIEN
INSERT INTO NHANVIEN (MANHANVIEN, HO, TEN, NGAYSINH, NGAYLAMVIEC, DIACHI, DIENTHOAI, LUONGCOBAN, PHUCAP) 
VALUES
	('MNV1001', N'Nguyễn', N'An', '15-05-1990', '01-01-2015', N'234 Kim Mã', '0123123123', 10000000, 1000000),
	('MNV1002', N'Trần', N'Bình', '20-08-1992', '15-03-2016', N'567 Láng Hạ', '0234234234', 12000000, 1500000),
	('MNV1003', N'Lê', N'Cường', '10-12-1988', '01-06-2014', N'890 Đội Cấn', '0345345345', 15000000, 2000000),
	('MNV1004', N'Phạm', N'Dung', '25-03-1995', '01-09-2018', N'123 Ba Đình', '0456456456', 9000000, 800000),
	('MNV1005', N'Hoàng', N'Em', '30-07-1993', '15-12-2017', N'456 Hoàn Kiếm', '0567567567', 11000000, 1200000),
	('MNV1006', N'Đặng', N'Phương', '05-11-1991', '01-08-2016', N'789 Hai Bà Trưng', '0678678678', 13000000, 1800000),
	('MNV1007', N'Vũ', N'Giang', '18-02-1994', '15-01-2019', N'321 Đống Đa', '0789789789', 8500000, 700000),
	('MNV1008', N'Mai', N'Hương', '22-09-1989', '01-11-2015', N'654 Cầu Giấy', '0890890890', 14000000, 2500000),
	('MNV1009', N'Bùi', N'Linh', '12-04-1996', '01-03-2020', N'987 Tây Hồ', '0901901901', 9500000, 900000),
	('MNV1010', N'Đỗ', N'Minh', '28-06-1992', '15-05-2017', N'147 Long Biên', '0912912912', 12500000, 1600000);


-- Bảng DONDATHANG
INSERT INTO DONDATHANG (SOHOADON, MAKHACHHANG, MANHANVIEN, NGAYDATHANG, NGAYCHUYENHANG, NGAYGIAOHANG, MAPX, NOIGIAOHANG) 
VALUES
    ('MHD1001', 'MKH1001', 'MNV1001', '15-01-2022', null, null, 'PX001', null),
    ('MHD1002', 'MKH1002', 'MNV1002', '10-02-2022', '11-02-2022', '15-02-2022', 'PX002', N'117 Nguyễn Huệ'),
    ('MHD1003', 'MKH1003', 'MNV1003', '05-03-2023', '06-03-2023', '10-03-2023', 'PX003', N'789 Lê Lai'),
    ('MHD1004', 'MKH1004', 'MNV1004', '20-04-2022', '22-04-2022', '25-04-2022', 'PX004',null),
    ('MHD1005', 'MKH1005', 'MNV1005', '15-05-2023', null, null, 'PX005', N'654 Trần Hưng Đạo'),
    ('MHD1006', 'MKH1006', 'MNV1006', '10-06-2022', '12-06-2022', '15-06-2022', 'PX006', N'12 Lê Thánh Tông'),
    ('MHD1007', 'MKH1007', 'MNV1007', '25-07-2023', '26-07-2023', '30-07-2023', 'PX007', N'23 Bùi Viện'),
    ('MHD1008', 'MKH1008', 'MNV1008', '15-08-2022', null, null, 'PX008', N'45 Nguyễn Du'),
    ('MHD1009', 'MKH1009', 'MNV1009', '10-09-2023', '12-09-2023', '15-09-2023', 'PX009', null),
    ('MHD1010', 'MKH1010', 'MNV1010', '05-10-2022', '07-10-2022', '10-10-2022', 'PX010', null),
	('MHD1011', 'MKH1001', 'MNV1002', '20-10-2022', null, null, 'PX001', N'123 Lê Lợi'),
    ('MHD1012', 'MKH1003', 'MNV1004', '18-08-2023', '19-08-2023', '23-08-2023', 'PX003', N'789 Lê Lai'),
    ('MHD1013', 'MKH1005', 'MNV1006', '15-06-2022', null, null, 'PX005', N'654 Trần Hưng Đạo'),
    ('MHD1014', 'MKH1007', 'MNV1008', '30-09-2022', '01-10-2022', '05-10-2022', 'PX007', N'23 Bùi Viện'),
    ('MHD1015', 'MKH1009', 'MNV1010', '05-11-2023', '06-11-2023', '10-11-2023', 'PX009', null);

-- Bảng CHITIETDATHANG
INSERT INTO CHITIETDATHANG (SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA) 
VALUES
	('MHD1001', 'MMH1001', 26000, 21, 10),
	('MHD1002', 'MMH1002', 11000, 110, 12),
	('MHD1003', 'MMH1003', 4000, 10, 5),
	('MHD1004', 'MMH1004', 16000, 10, 5),
	('MHD1005', 'MMH1005', 9000, 80, 10),
	('MHD1006', 'MMH1006', 90000, 50, 5),
	('MHD1007', 'MMH1007', 48000, 80, 5),
	('MHD1008', 'MMH1008', 5500, 17, 15),
	('MHD1009', 'MMH1009', 11000, 150, 12),
	('MHD1010', 'MMH1010', 13000, 20, 3),
	('MHD1011', 'MMH1001', 13000, 5, 5),
	('MHD1012', 'MMH1001', 13000, 19, 3),
	('MHD1013', 'MMH1002', 13000, 50, 3),
	('MHD1014', 'MMH1002', 13000, 40, 3),
	('MHD1015', 'MMH1006', 13000, 15, 3);




	       ------------------------------ UPDATE DỮ LIỆU ------------------------------------
