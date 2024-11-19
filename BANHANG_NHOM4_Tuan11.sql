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
	----Bảng KHACHHANG
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
----Bảng NHANVIEN
ALTER TABLE NHANVIEN
	DROP COLUMN DIACHI
ALTER TABLE NHANVIEN
	ADD MAPX char(5),
		SONHATENDUONG nvarchar(80),
		--- Liên kết khóa ngoại đến bảng PHUONGXA
	 CONSTRAINT FK_NHANVIEN_MAPX 
		FOREIGN KEY (MAPX) REFERENCES PHUONGXA(MAPX)
			ON DELETE 
				NO ACTION
			ON UPDATE 
				NO ACTION;
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
-- Bảng LOAIHANG với danh mục mới
INSERT INTO LOAIHANG (MALOAIHANG, TENLOAIHANG) 
VALUES
    ('MLH1001', N'Thực phẩm'),
    ('MLH1002', N'Đồ uống'),
    ('MLH1003', N'Đồ dùng sinh hoạt'),
    ('MLH1004', N'Đồ vệ sinh'),
    ('MLH1005', N'Văn phòng phẩm'),
    ('MLH1006', N'Chăm sóc cá nhân'),
    ('MLH1007', N'Đồ điện tử'),
    ('MLH1008', N'Đồ gia dụng'),
    ('MLH1009', N'Thời trang'),
    ('MLH1010', N'Thể thao & Dã ngoại');


-- Bảng NHACUNGCAP
INSERT INTO NHACUNGCAP (MACONGTY, TENCONGTY, TENGIAODICH, MAPX, SONHATENDUONG, DIENTHOAI, FAX, EMAIL) 
VALUES
    -- Nhà cung cấp thực phẩm
    ('NCC001', N'Công ty CP Thực phẩm Sạch', N'Clean Food', 'PX001', N'22 Đường Số 1', '0901234567', '0901234568', 'cleanfood@email.com'),
    ('NCC002', N'Công ty TNHH Thực phẩm Việt', N'Viet Foods', 'PX002', N'15 Nguyễn Huệ', '0912345678', '0912345679', 'vietfoods@email.com'),
    
    -- Nhà cung cấp đồ uống
    ('NCC003', N'Công ty CP Vinamilk', N'Vinamilk', 'PX003', N'10 Tân Trào', '0923456789', '0923456790', 'vinamilk@email.com'),
    ('NCC004', N'Công ty TNHH Coca-Cola VN', N'Coca-Cola', 'PX004', N'156 Nguyễn Lương Bằng', '0934567890', '0934567891', 'cocacola@email.com'),
    
    -- Nhà cung cấp đồ dùng sinh hoạt và vệ sinh
    ('NCC005', N'Công ty TNHH Unilever VN', N'Unilever', 'PX005', N'39 Lê Duẩn', '0945678901', '0945678902', 'unilever@email.com'),
    ('NCC006', N'Công ty TNHH P&G Việt Nam', N'P&G', 'PX006', N'27 Nguyễn Thị Minh Khai', '0956789012', '0956789013', 'pg@email.com'),
    
    -- Nhà cung cấp văn phòng phẩm
    ('NCC007', N'Công ty CP Thiên Long', N'Thien Long', 'PX007', N'44 Vũ Trọng Phụng', '0967890123', '0967890124', 'thienlong@email.com'),
    
    -- Nhà cung cấp đồ điện tử
    ('NCC008', N'Công ty TNHH Samsung Việt Nam', N'Samsung', 'PX008', N'15 Lê Lợi', '0978901234', '0978901235', 'samsung@email.com'),
    
    -- Nhà cung cấp đồ gia dụng
    ('NCC009', N'Công ty CP Sunhouse', N'Sunhouse', 'PX009', N'88 Hai Bà Trưng', '0989012345', '0989012346', 'sunhouse@email.com'),
    
    -- Nhà cung cấp thời trang
    ('NCC010', N'Công ty CP May Việt Tiến', N'Viet Tien', 'PX010', N'63 Nguyễn Du', '0990123456', '0990123457', 'viettien@email.com');


	-- Bảng MATHANG
INSERT INTO MATHANG (MAHANG, TENHANG, MACONGTY, MALOAIHANG, SOLUONG, DONVITINH, GIAHANG) 
VALUES
    -- Thực phẩm  
    ('MMH1001', N'Thịt heo xay', 'NCC001', 'MLH1001', 35, N'Kg', 120000),
    ('MMH1002', N'Cá hồi phi lê', 'NCC001', 'MLH1001', 20, N'Kg', 350000),
    
    -- Đồ uống
    ('MMH1003', N'Coca Cola 330ml', 'NCC004', 'MLH1002', 5000, N'Lon', 10000),
    ('MMH1004', N'Sữa tươi Vinamilk 1L', 'NCC003', 'MLH1002', 3000, N'Chai', 8000),
    ('MMH1005', N'Sữa hộp XYZ', 'NCC003', 'MLH1002', 2000, N'Hộp', 5000),
    
    -- Đồ dùng sinh hoạt
    ('MMH1006', N'Chổi lau nhà', 'NCC003', 'MLH1003', 200, N'Cái', 85000),
    ('MMH1007', N'Khăn lau bếp', 'NCC003', 'MLH1003', 800, N'Gói', 25000),
    
    -- Đồ vệ sinh  
    ('MMH1008', N'Bột giặt OMO', 'NCC005', 'MLH1004', 1200, N'Túi', 85000),
    ('MMH1009', N'Nước rửa chén Sunlight', 'NCC005', 'MLH1004', 1500, N'Chai', 35000),
    
    -- Chăm sóc cá nhân
    ('MMH1010', N'Dầu gội Head & Shoulders', 'NCC006', 'MLH1006', 1800, N'Chai', 95000),
    ('MMH1011', N'Kem đánh răng P/S', 'NCC006', 'MLH1006', 2000, N'Tuýp', 32000),

	-- Thời trang
    ('MMH1012', N'Sơ mi nam', 'NCC010', 'MLH1010', 200, N'Cái', 300000),
	('MMH1013', N'Thắt lưng', 'NCC010', 'MLH1010', 500, N'Cái', 220000),
	('MMH1014', N'Quần tây', 'NCC010', 'MLH1010', 150, N'Cái', 540000);

-- Bảng KHACHHANG
-- Thêm dữ liệu mới cho bảng KHACHHANG
INSERT INTO KHACHHANG (MAKHACHHANG, TENCONGTY, TENGIAODICH, MAPX, SONHATENDUONG, EMAIL, DIENTHOAI, FAX) 
VALUES
	-- 3 khách hàng tự do, không thuộc khách hàng doanh nghiệp
    ('MKH1001', DEFAULT, N'Nguyễn Văn An', 'PX001', N'123 Lê Lợi', 'nguyenvanan@email.com', '0123456789', '0123456790'),
    ('MKH1002', DEFAULT, N'Trần Thị Bình', 'PX002', N'456 Nguyễn Huệ', 'tranthib@email.com', '0234567890', '0234567891'),
    ('MKH1003', DEFAULT, N'Lê Hoàng Phương', 'PX003', N'789 Lê Lai', 'lehoangp@email.com', '0345678901', '0345678902'),
    
    -- 2 khách hàng công ty từ bảng NHACUNGCAP nhưng không đúng các thông tin khác không chính xác
    ('MKH1004', N'Công ty CP Vinamilk', N'Vinamilk', 'PX005', N'K65/95 Tô Hiến Thành', 'auto@gamil.com', '0991123456', '0991123456'),
    ('MKH1005', N'Công ty TNHH Coca-Cola VN', N'Coca-Cola', 'PX005', N'634 Lê Duẫn', 'auto2@gmail.com', '0567892233', '0567892233'),
    
    -- Các khách hàng doanh nghiệp khác
    ('MKH1006', N'Công ty TNHH Siêu thị BigC', N'BigC', 'PX006', N'987 Lê Duẩn', 'bigc@email.com', '0678901234', '0678901235'),
    ('MKH1007', N'Cửa hàng Bách Hóa Xanh', N'BHX', 'PX007', N'147 Nguyễn Du', 'bhx@email.com', '0789012345', '0789012346'),
    ('MKH1008', N'Siêu thị Winmart', N'Winmart', 'PX008', N'258 Hai Bà Trưng', 'winmart@email.com', '0890123456', '0890123457'),
    ('MKH1009', N'Cửa hàng Circle K', N'Circle K', 'PX009', N'369 Lý Tự Trọng', 'circlek@email.com', '0901234567', '0901234568'),
    ('MKH1010', N'Siêu thị MiniMart', N'MiniMart', 'PX010', N'159 Nam Kỳ Khởi Nghĩa', 'minimart@email.com', '0912345678', '0912345679');

-- Bảng NHANVIEN
INSERT INTO NHANVIEN (MANHANVIEN, HO, TEN, NGAYSINH, NGAYLAMVIEC, SONHATENDUONG, MAPX, DIENTHOAI, LUONGCOBAN, PHUCAP) 
VALUES
    ('MNV1001', N'Nguyễn', N'An', '15-05-1990', '01-01-2015', N'234 Kim Mã', 'PX001', '0123123123', 8000000, 1000000),
    ('MNV1002', N'Trần', N'Bình', '20-08-1992', '15-03-2016', N'567 Láng Hạ', 'PX003', '0234234234', 8000000, 1500000),
    ('MNV1003', N'Lê', N'Cường', '10-12-1988', '01-06-2014', N'890 Đội Cấn', 'PX004', '0345345345', 10000000, 2000000),
    ('MNV1004', N'Phạm', N'Dung', '25-03-1995', '01-09-2018', N'123 Ba Đình', 'PX005', '0456456456', 10000000, 800000),
    ('MNV1005', N'Hoàng', N'Em', '30-07-1993', '15-12-2017', N'456 Hoàn Kiếm', 'PX006', '0567567567', 8000000, 1200000),
    ('MNV1006', N'Đặng', N'Phương', '05-11-1991', '01-08-2016', N'789 Hai Bà Trưng', 'PX007', '0678678678', 10000000, 1800000),
    ('MNV1007', N'Vũ', N'Giang', '18-02-1994', '15-01-2019', N'321 Đống Đa', 'PX008', '0789789789', 800000, 700000),
    ('MNV1008', N'Mai', N'Hương', '22-09-1989', '01-11-2015', N'654 Cầu Giấy', 'PX009', '0890890890', 8000000, 2500000),
    ('MNV1009', N'Bùi', N'Linh', '12-04-1996', '01-03-2020', N'987 Tây Hồ', 'PX010', '0901901901', 800000, 900000),
    ('MNV1010', N'Đỗ', N'Minh', '28-06-1992', '15-05-2017', N'147 Long Biên', 'PX002', '0912912912', 8000000, 1600000);

-- Bảng DONDATHANG
INSERT INTO DONDATHANG (SOHOADON, MAKHACHHANG, MANHANVIEN, NGAYDATHANG, NGAYCHUYENHANG, NGAYGIAOHANG, MAPX, NOIGIAOHANG) 
VALUES
    ('MHD1001', 'MKH1001', 'MNV1003', '15-01-2022', null, null, null, null),
    ('MHD1002', 'MKH1002', 'MNV1002', '10-02-2022', '11-02-2022', '15-02-2022', 'PX002', N'117 Nguyễn Huệ'),
    ('MHD1003', 'MKH1003', 'MNV1003', '05-03-2023', '06-03-2023', '10-03-2023', 'PX003', N'789 Lê Lai'),
    ('MHD1004', 'MKH1004', 'MNV1004', '20-04-2022', '22-04-2022', '25-04-2022', null,null),
    ('MHD1005', 'MKH1005', 'MNV1005', '15-05-2023', null, null, 'PX005', N'654 Trần Hưng Đạo'),
    ('MHD1006', 'MKH1006', 'MNV1006', '10-06-2022', '12-06-2022', '15-06-2022', 'PX006', N'12 Lê Thánh Tông'),
    ('MHD1007', 'MKH1007', 'MNV1007', '25-07-2023', '26-07-2023', '30-07-2023', 'PX007', N'23 Bùi Viện'),
    ('MHD1008', 'MKH1008', 'MNV1008', '15-08-2022', null, null, 'PX008', N'45 Nguyễn Du'),
    ('MHD1009', 'MKH1009', 'MNV1008', '10-09-2023', '12-09-2023', '15-09-2023', null, null),
    ('MHD1010', 'MKH1010', 'MNV1010', '05-10-2022', '07-10-2022', '10-10-2022', null, null),
	('MHD1011', 'MKH1001', 'MNV1002', '20-10-2022', null, null, 'PX001', N'123 Lê Lợi'),
    ('MHD1012', 'MKH1003', 'MNV1004', '18-08-2023', '19-08-2023', '23-08-2023', 'PX003', N'789 Lê Lai'),
    ('MHD1013', 'MKH1005', 'MNV1006', '15-06-2022', null, null, 'PX005', N'654 Trần Hưng Đạo'),
    ('MHD1014', 'MKH1007', 'MNV1008', '30-09-2022', '01-10-2022', '05-10-2022', 'PX007', N'23 Bùi Viện'),
    ('MHD1015', 'MKH1009', 'MNV1010', '05-11-2023', '06-11-2023', '10-11-2023', null, null);

-- Bảng CHITIETDATHANG
INSERT INTO CHITIETDATHANG (SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA) 
VALUES
    ('MHD1001', 'MMH1001', 180000, 21, 5),    
    ('MHD1002', 'MMH1003', 11000, 110, 12),   
    ('MHD1003', 'MMH1004', 9000, 10, 5),     
    ('MHD1004', 'MMH1005', 6000, 10, 5),      
    ('MHD1005', 'MMH1006', 95000, 80, 10),     
    ('MHD1006', 'MMH1007', 30000, 50, 5),     
    ('MHD1007', 'MMH1008', 95000, 80, 5),     
    ('MHD1008', 'MMH1009', 42000, 17, 15),    
    ('MHD1009', 'MMH1010', 110000, 150, 12),   
    ('MHD1010', 'MMH1002', 390000, 20, 3),     
    ('MHD1011', 'MMH1001', 125000, 40, 5),    
    ('MHD1012', 'MMH1001', 125000, 19, 3),     
    ('MHD1013', 'MMH1003', 11000, 50, 3),      
    ('MHD1014', 'MMH1003', 11000, 40, 3),      
    ('MHD1015', 'MMH1007', 30000, 15, 3);      


	    ------------------------------------ TUẦN 8 - UPADTE  ------------------------------------

------a. Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
UPDATE DONDATHANG
SET NGAYCHUYENHANG = NGAYDATHANG
WHERE NGAYCHUYENHANG IS NULL;


		   ------------ b. Tăng số lượng hàng của những mặt hàng do công ty VINAMILK cung cấp lên gấp đôi ------------------
UPDATE MATHANG
SET SOLUONG = SOLUONG * 2
WHERE MACONGTY = 'NCC002'


	-------------c. Cập nhật giá trị của trường NOIGIAOHANG trong bảng DONDATHANG bằng địa chỉ của khách hàng đối với những đơn đặt hàng 
						--------chưa xác định được nơi giao hàng (giá trị trường NOIGIAOHANG bằng NULL).

UPDATE DONDATHANG
SET NOIGIAOHANG = KH.SONHATENDUONG, MAPX = KH.MAPX
FROM KHACHHANG AS KH
WHERE NOIGIAOHANG IS NULL AND KH.MAKHACHHANG = DONDATHANG.MAKHACHHANG;



		-------------------  d. Cập nhật lại thông tin khách hàng giống với thông tin từ bảng NHACUNGCAP -------------------------
      -------- nếu tên công ty và tên giao dịch tại bảng KHACHHANG trùng với tên công ty và mã giao dịch tại bảng NHACUNGCAP ---------

UPDATE KHACHHANG
SET MAPX = NCC.MAPX, SONHATENDUONG = NCC.SONHATENDUONG, 
	FAX = NCC.FAX, DIENTHOAI = NCC.DIENTHOAI, EMAIL = NCC.EMAIL
FROM NHACUNGCAP AS NCC
WHERE NCC.TENCONGTY = KHACHHANG.TENCONGTY AND NCC.TENGIAODICH = KHACHHANG.TENGIAODICH


			--------------e. Tăng lương lên gấp rưỡi cho những nhân viên bán được số lượng hàng nhiều hơn 100 trong năm 2022-----------------
UPDATE NHANVIEN
SET LUONGCOBAN = LUONGCOBAN * 1.5
WHERE MANHANVIEN IN (
    SELECT MANHANVIEN
    FROM DONDATHANG as d,CHITIETDATHANG as c
    WHERE YEAR(NGAYDATHANG) = 2022 and d.SOHOADON = c.SOHOADON
    GROUP BY d.MANHANVIEN
    HAVING SUM(SOLUONG) > 100
);


	-------------------- f. Tăng phụ cấp lên bằng 50% lương cho những nhân viên bán được hàng nhiều nhất -----------------------
UPDATE NHANVIEN
SET PHUCAP=LUONGCOBAN * 0.5
WHERE MANHANVIEN IN (SELECT MANHANVIEN
					 FROM DONDATHANG JOIN CHITIETDATHANG ON DONDATHANG.SOHOADON=CHITIETDATHANG.SOHOADON
					 GROUP BY MANHANVIEN
					 HAVING SUM(SOLUONG) >= ALL
						(SELECT SUM(SOLUONG)
						 FROM DONDATHANG JOIN CHITIETDATHANG ON DONDATHANG.SOHOADON=CHITIETDATHANG.SOHOADON
						 GROUP BY MANHANVIEN))


		----------------g. Giảm 25% lương của những nhân viên trong năm 2023 không lập được bất kỳ đơn đặt hàng nào-------------------
UPDATE NHANVIEN
SET LUONGCOBAN = LUONGCOBAN * 0.75
WHERE MANHANVIEN NOT IN (
    SELECT MANHANVIEN
    FROM DONDATHANG
    WHERE YEAR(NGAYDATHANG) = 2023)


			--------------------------------------- BÀI TẬP CÁ NHÂN -----------------------------------------------


-- 1. Địa chỉ và điện thoại của nhà cung cấp có tên giao dịch [VINAMILK]  là gì?
SELECT SONHATENDUONG, MAPX, DIENTHOAI
FROM NHACUNGCAP
WHERE TENGIAODICH = 'VINAMILK'

-- 2. Loại hàng thực phẩm do những công ty nào cung cấp và địa chỉ của các công ty đó là gì?
SELECT DISTINCT TENLOAIHANG, NHACUNGCAP.MACONGTY, TENCONGTY, SONHATENDUONG
FROM LOAIHANG 
INNER JOIN MATHANG ON LOAIHANG.MALOAIHANG = MATHANG.MALOAIHANG
INNER JOIN NHACUNGCAP ON MATHANG.MACONGTY=NHACUNGCAP.MACONGTY
WHERE TENLOAIHANG = N'Thực phẩm'

-- 3. Những khách hàng nào (tên giao dịch) đã đặt mua mặt hàng Sữa hộp XYZ của công ty?
SELECT DISTINCT TENGIAODICH
FROM MATHANG 
INNER JOIN CHITIETDATHANG ON MATHANG.MAHANG=CHITIETDATHANG.MAHANG
INNER JOIN DONDATHANG ON CHITIETDATHANG.SOHOADON=DONDATHANG.SOHOADON
INNER JOIN KHACHHANG ON DONDATHANG.MAKHACHHANG=KHACHHANG.MAKHACHHANG
WHERE TENHANG = N'Sữa hộp XYZ'

-- 4. Những đơn đặt hàng nào yêu cầu giao hàng ngay tại công ty đặt hàng và những đơn đó là của công ty nào?
SELECT SOHOADON, TENCONGTY, TENGIAODICH, NGAYDATHANG, NOIGIAOHANG
FROM DONDATHANG 
INNER JOIN KHACHHANG ON DONDATHANG.NOIGIAOHANG=KHACHHANG.SONHATENDUONG

-- 5. Tổng số tiền mà khách hàng phải trả cho mỗi đơn đặt hàng là bao nhiêu?
SELECT DONDATHANG.SOHOADON, DONDATHANG.MAKHACHHANG, TENCONGTY, TENGIAODICH, SUM(SOLUONG*GIABAN-SOLUONG*GIABAN*MUCGIAMGIA/100) as TONGTIEN
FROM KHACHHANG 
INNER JOIN DONDATHANG ON KHACHHANG.MAKHACHHANG=DONDATHANG.MAKHACHHANG
INNER JOIN CHITIETDATHANG ON DONDATHANG.SOHOADON=CHITIETDATHANG.SOHOADON
GROUP BY DONDATHANG.MAKHACHHANG, TENCONGTY, TENGIAODICH, DONDATHANG.SOHOADON

-- 6. Hãy cho biết tổng số tiền lời mà công ty thu  được từ mỗi mặt hàng trong năm 2022.
SELECT C.MAHANG, TENHANG, SUM(B.SOLUONG*GIABAN-B.SOLUONG*GIABAN*MUCGIAMGIA/100)-SUM(B.SOLUONG*GIAHANG) as TONGTIENLOI
FROM DONDATHANG AS A 
INNER JOIN CHITIETDATHANG AS B ON A.SOHOADON=B.SOHOADON
INNER JOIN MATHANG AS C ON B.MAHANG=C.MAHANG
WHERE YEAR(NGAYDATHANG) = 2022
GROUP BY C.MAHANG, TENHANG

                   ---------------------------------BT TUẦN 10--------------------------------------

-- 1. Mã hàng, tên hàng và số lượng hàng hiện có của mỗi công ty
	SELECT MH.MAHANG, (MH.SOLUONG - SUM(CTDH.SOLUONG)) AS "Số lượng hàng hiện có"
	FROM MATHANG AS MH 
	JOIN CHITIETDATHANG AS CTDH ON CTDH.MAHANG = MH.MAHANG
	GROUP BY MH.MAHANG, MH.SOLUONG

-- 2. Mỗi mặt hàng trong công ty do ai cung cấp
	SELECT MAHANG, TENHANG, TENCONGTY
	FROM NHACUNGCAP AS NCC 
	JOIN MATHANG AS MH ON NCC.MACONGTY = MH.MACONGTY

-- 3. Số tiền lương mà mỗi công ty phải trả cho nhân viên
	-- Cách 1
		UPDATE NHANVIEN
		SET PHUCAP = 0
		WHERE PHUCAP IS NULL
		SELECT MANHANVIEN, HO, TEN, (LUONGCOBAN + PHUCAP) AS "Tiền lương"
		FROM  NHANVIEN
	-- Cách 2
		SELECT MANHANVIEN, HO, TEN, LUONGCOBAN + CASE
			WHEN PHUCAP IS NULL THEN 0
			ELSE PHUCAP
			END AS "Tổng lương nhân viên"
		FROM NHANVIEN

-- 4. Những mặt hàng nào chưa được khách hàng đặt mua
	SELECT *
	FROM MATHANG
	WHERE MAHANG IN (SELECT MAHANG
	FROM MATHANG AS MH
	EXCEPT
	SELECT MAHANG
	FROM CHITIETDATHANG AS CTDH)

-- 5. Hãy cho biết mỗi khách hàng đã phải bỏ ra bao nhiêu tiền để đặt mua hàng của công ty
	SELECT KH.MAKHACHHANG, TENCONGTY, SUM(CTDH.GIABAN * SOLUONG * ((100 - MUCGIAMGIA)/100)) AS "Tổng tiền hàng"
	FROM KHACHHANG AS KH 
	JOIN DONDATHANG AS DDH ON KH.MAKHACHHANG = DDH.MAKHACHHANG
	JOIN CHITIETDATHANG AS CTDH ON DDH.SOHOADON = CTDH.SOHOADON
	GROUP BY KH.MAKHACHHANG,TENCONGTY

			----------------------------------BT TUẦN 11-----------------------------------------

-- Trùng 2,4,6,8,9,11,14,16

-- 1. Cho biết danh sách các đối tác cung cấp hàng cho công ty
	SELECT DISTINCT NCC.MACONGTY, TENCONGTY, TENGIAODICH
	FROM NHACUNGCAP AS NCC 
	JOIN MATHANG AS MH ON MH.MACONGTY = NCC.MACONGTY

-- 3. Cho biết họ tên, địa chỉ, năm bắt đầu làm việc trong công ty
	SELECT HO, TEN, SONHATENDUONG, TENPX, TENQH, TENTP, YEAR(NGAYLAMVIEC) AS "Năm làm việc"
	FROM NHANVIEN AS NV 
	JOIN PHUONGXA AS PX ON NV.MAPX = PX.MAPX
	JOIN QUANHUYEN AS QH ON QH.MAQH = PX.MAQH
	JOIN THANHPHO AS TP ON TP.MATP = QH.MATP
	JOIN QUOCGIA AS QG ON QG.MAQG = TP.MAQG

-- 5. Cho biết mã và tên của các mặt hàng có giá trị lớn hơn 100000 và số lượng hiện có ít hơn 50
	SELECT MAHANG, TENHANG, SOLUONG, GIAHANG
	FROM MATHANG
	WHERE GIAHANG > 100000 AND SOLUONG < 50 

-- 7. Công ty [Việt Tiến] đã cung cấp những mặt hàng nào
	SELECT MAHANG, TENHANG
	FROM MATHANG
	JOIN NHACUNGCAP NCC ON NCC.MACONGTY = MATHANG.MACONGTY
	WHERE TENCONGTY LIKE N'% Việt Tiến'

-- 10. Đơn hàng số 1 do ai đặt và do nhân viên nào lập, thời gian và địa điểm giao hàng ở đâu?
	SELECT NHANVIEN.MANHANVIEN,NHANVIEN.TEN,KHACHHANG.MAKHACHHANG,KHACHHANG.TENCONGTY,NGAYGIAOHANG,NOIGIAOHANG
	FROM NHANVIEN,KHACHHANG,DONDATHANG
	WHERE NHANVIEN.MANHANVIEN = DONDATHANG.MANHANVIEN 
	  AND KHACHHANG.MAKHACHHANG = DONDATHANG.MAKHACHHANG 
	  AND SOHOADON = 'MHD1001'

-- 12. Hãy cho biết những khách hàng nào cũng chính là đối tác cung cấp hàng của công ty (tức là cùng tên giao dịch)
	SELECT DISTINCT TENCONGTY,TENGIAODICH
	FROM DONDATHANG, KHACHHANG
	WHERE DONDATHANG.MAKHACHHANG = KHACHHANG.MAKHACHHANG 
	AND KHACHHANG.TENGIAODICH IN ( SELECT TENGIAODICH 
								   FROM NHACUNGCAP,MATHANG 
								   WHERE NHACUNGCAP.MACONGTY = MATHANG.MACONGTY )

-- 13. Trong công ty có những nhân viên nào cùng ngày sinh 
	SELECT MANHANVIEN,HO,TEN,NGAYSINH,DAY(NGAYSINH) as N'Ngày Sinh Trùng'
	FROM NHANVIEN
	WHERE DAY(NGAYSINH) IN ( SELECT  DAY(NGAYSINH)
							 FROM NHANVIEN
							 GROUP BY Day(NGAYSINH)
							 HAVING COUNT(*) > 1);
-- 15. Cho biết tên công ty,tên giao dịch,địa chỉ và điện thoại của các khách hàng và các nhà cung cấp hàng cho công ty 
	SELECT TENCONGTY,TENGIAODICH,MAPX,DIENTHOAI 
	FROM KHACHHANG
	UNION
	SELECT TENCONGTY,TENGIAODICH,MAPX,DIENTHOAI
	FROM NHACUNGCAP
-- 17. Những nhân viên nào của công ty chưa từng lập bất kỳ một hóa đơn đặt hàng nào 
	SELECT MANHANVIEN
	FROM NHANVIEN
	EXCEPT 
	SELECT MANHANVIEN
	FROM DONDATHANG

-- 18. Những nhân viên nào của công ty có lương cơ bản cao nhất
	SELECT TOP 1 WITH TIES MANHANVIEN, TEN, MAX(LUONGCOBAN) AS LUONGCOBANCAONHAT
	FROM NHANVIEN
	GROUP BY MANHANVIEN, TEN
	ORDER BY LUONGCOBANCAONHAT DESC