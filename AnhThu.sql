--Lệnh xóa Database nếu đã tồn tại
--DROP DATABASE IF EXISTS BANHANG_NHOM4;
--Lệnh tạo Database 
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
		LUONGCOBAN DECIMAL(10,5) NOT NULL,
		PHUCAP DECIMAL(10,5)
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
			FOREIGN KEY (MAKHACHHANG) REFERENCES KHACHHANG(MAKHACHHANG)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
			FOREIGN KEY (MANHANVIEN) REFERENCES NHANVIEN(MANHANVIEN)
				ON DELETE CASCADE
				ON UPDATE CASCADE
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
		TENLOAIHANG NVARCHAR(20)
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
			FOREIGN KEY (MACONGTY) REFERENCES NHACUNGCAP(MACONGTY)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
			FOREIGN KEY (MALOAIHANG) REFERENCES LOAIHANG(MALOAIHANG)
				ON DELETE CASCADE
				ON UPDATE CASCADE
	)
--Tạo bảng CHI TIẾT ĐẶT HÀNG
	CREATE TABLE CHITIETDATHANG 
	(
		SOHOADON CHAR(10),
		MAHANG CHAR(10),
		GIABAN MONEY CHECK(GIABAN > 0),
		SOLUONG FLOAT CHECK(SOLUONG > 0),
		MUCGIAMGIA MONEY CHECK(MUCGIAMGIA >= 0),
			PRIMARY KEY (SOHOADON, MAHANG),
			FOREIGN KEY(SOHOADON) REFERENCES DONDATHANG(SOHOADON)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
			FOREIGN KEY(MAHANG) REFERENCES MATHANG(MAHANG)
				ON DELETE CASCADE
				ON UPDATE CASCADE
	)
--Ràng buộc Database
--Ràng buộc địa chỉ đa trị -> đơn trị
--Thêm bảng Quốc Gia
CREATE TABLE QUOCGIA
(
    MAQG char(10) PRIMARY KEY,
    TENQG nvarchar(100)
)
--Thêm bảng Thành Phố
CREATE TABLE THANHPHO
(
    MATP char(10) PRIMARY KEY,
    TENTP nvarchar(100),
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
    TENQH nvarchar(100),
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
    TENPX nvarchar(100),
    MAQH char(10),
    FOREIGN KEY (MAQH) REFERENCES QUANHUYEN(MAQH)
        ON DELETE 
			CASCADE
        ON UPDATE 
			CASCADE
)
--Tách cột địa chỉ bảng KHACHHANG thành 2 cột
ALTER TABLE KHACHHANG
DROP COLUMN DIACHI
ALTER TABLE KHACHHANG
ADD MAPX char(10),
    SONHATENDUONG nvarchar(100)
ALTER TABLE KHACHHANG
ADD CONSTRAINT FK_KHACHHANG_MAPX 
		FOREIGN KEY (MAPX) REFERENCES PHUONGXA(MAPX)
			ON DELETE 
				CASCADE
			ON UPDATE 
				CASCADE;
--Tách cột địa chỉ bảng NHACUNGCAP thành 2 cột
ALTER TABLE NHACUNGCAP
DROP COLUMN DIACHI
ALTER TABLE NHACUNGCAP
ADD MAPX char(10),
    SONHATENDUONG nvarchar(100)
ALTER TABLE NHACUNGCAP
ADD CONSTRAINT FK_NHACUNGCAP_MAPX 
		FOREIGN KEY (MAPX) REFERENCES PHUONGXA(MAPX)
			ON DELETE 
				NO ACTION
			ON UPDATE 
				NO ACTION;
--Tách cột địa chỉ bảng DONDATHANG thành 2 cột
ALTER TABLE DONDATHANG
DROP COLUMN NOIGIAOHANG
ALTER TABLE DONDATHANG
ADD MAPX char(10),
    DIACHICUTHE nvarchar(100)
ALTER TABLE DONDATHANG
ADD CONSTRAINT FK_DONDATHANG_MAPX 
		FOREIGN KEY (MAPX) REFERENCES PHUONGXA(MAPX)
			ON DELETE 
				NO ACTION
			ON UPDATE 
				NO ACTION;
--Ràng buộc các giá trị thứ tự về ngày
ALTER TABLE DONDATHANG
ADD CONSTRAINT DF_DONDATHANG_NGAYDATHANG 
		DEFAULT GETDATE() FOR NGAYDATHANG,
    CONSTRAINT CK_DONDATHANG_NGAYCHUYENHANG 
		CHECK(NGAYCHUYENHANG >= NGAYDATHANG),
    CONSTRAINT CK_DONDATHANG_NGAYGIAOHANG 
		CHECK(NGAYGIAOHANG >= NGAYCHUYENHANG);
--Ràng buộc về giá trị mặc định của số lượng và mức giảm giá
ALTER TABLE CHITIETDATHANG
ADD CONSTRAINT DF_CHITIETDATHANG_SOLUONG 
		DEFAULT 1 FOR SOLUONG,
    CONSTRAINT DF_CHITIETDATHANG_MUCGIAMGIA 
		DEFAULT 0 FOR MUCGIAMGIA;
--Ràng buộc về số điện thoại 10 or 11 số cho bảng Khách Hàng
ALTER TABLE KHACHHANG
ADD CONSTRAINT CK_KHACHHANG_DIENTHOAI 
		CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
		   OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
--Ràng buộc về số điện thoại 10 or 11 số cho bảng Nhân Viên
ALTER TABLE NHANVIEN
ADD CONSTRAINT CK_NHANVIEN_DIENTHOAI 
		CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
		   OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
--Ràng buộc về số điện thoại 10 or 11 số cho bảng Nhà Cung Cấp
ALTER TABLE NHACUNGCAP
	ADD CONSTRAINT CK_NHACUNGCAP_DIENTHOAI 
		CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
		   OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
--Ràng buộc về email bắt đầu bằng chữ cái + phải có @
ALTER TABLE KHACHHANG
    ADD CONSTRAINT CK_KHACHHANG_EMAIL
		CHECK (Email LIKE '[a-zA-Z]%@%_');
ALTER TABLE NHACUNGCAP
    ADD CONSTRAINT CK_NHACUNGCAP_EMAIL
		CHECK (Email LIKE '[a-zA-Z]%@%_');
--Ràng buộc ngày sinh của nhân viên phải đủ 18 tuổi và không quá 60 tuổi
ALTER TABLE NHANVIEN
	ADD CONSTRAINT CK_NHANVIEN_NGAYSINH
		CHECK (DATEDIFF(DAY, Ngaysinh, GETDATE()) / 360 >= 18 
		   And DATEDIFF(DAY, Ngaysinh, GETDATE()) / 360 <=60  );
--Ràng buộc TENCONGTY trong bảng KHACHHANG
ALTER TABLE KHACHHANG
ADD CONSTRAINT DF_KHACHHANG_TENCONGTY
	DEFAULT N'Khách hàng cá nhân' FOR TENCONGTY;

----Insert dữ liệu cho các bảng
--Nhập dữ liệu Quốc Gia
INSERT INTO QUOCGIA (maQG, tenQG)
VALUES ('QG001', N'Việt Nam');
--Nhập dữ liệu Thành Phố
INSERT INTO THANHPHO (maTP, tenTP, maQG)
VALUES ('TP001', N'Thành phố Đà Nẵng', 'QG001'),
	   ('TP002', N'Thủ đô Hà Nội', 'QG001'),
	   ('TP003', N'Thành phố Hồ Chí Minh', 'QG001'),
       ('TP004', N'Tỉnh Hải Phòng', 'QG001'),
       ('TP005', N'Thành phố Hải Dương', 'QG001'),
       ('TP006', N'Tỉnh Nghệ An', 'QG001'),
       ('TP007', N'Tỉnh Điện Biên', 'QG001'),
	   ('TP008', N'Thành phố Thái Bình', 'QG001'),
       ('TP009', N'Thành phố Nam Định', 'QG001'),
	   ('TP010', N'Thành phố Yên Bái', 'QG001'),
       ('TP011', N'Tỉnh Quảng Nam', 'QG001');
--Nhập dữ liệu Quận Huyện
INSERT INTO QUANHUYEN (maQH, tenQH, maTP)
VALUES ('QH001', N'Quận Liên Chiểu', 'TP001'),
	   ('QH002', N'Quận Thanh Khê', 'TP001'),
	   ('QH003', N'Quận Ngũ Hành Sơn', 'TP002'),
	   ('QH004', N'Quận Hải Châu', 'TP002'),
	   ('QH005', N'Quận Cẩm Lệ', 'TP003'),
	   ('QH006', N'Quận Sơn Trà', 'TP004'),
	   ('QH007', N'Huyện Hòa Vang', 'TP005'),
	   ('QH008', N'Huyện đảo Hoàng Sa', 'TP006'),
	   ('QH009', N'Quận Hoàn Kiếm', 'TP007'),
	   ('QH010', N'Quận Cầu Giấy', 'TP011');
--Nhập dữ liệu Phường Xã
INSERT INTO PHUONGXA (maPX, tenPX, maQH)
VALUES ('PX001', N'Phường Hòa Hiệp Bắc', 'QH001'),
	   ('PX002', N'Phường Hòa Hiệp Nam', 'QH001'),
	   ('PX003', N'Phường Hòa Khánh Bắc', 'QH002'),
	   ('PX004', N'Phường Hòa Khánh Nam', 'QH002'),
	   ('PX005', N'Phường Hòa Minh', 'QH003'),
	   ('PX006', N'Phường Tam Thuận', 'QH004'),
	   ('PX007', N'Phường Thanh Khê Tây', 'QH005'),
	   ('PX008', N'Phường Thanh Khê Đông', 'QH006'),
	   ('PX009', N'Phường Chính Gián', 'QH010'),
	   ('PX010', N'Phường Vĩnh Trung', 'QH009');
--Nhập dữ liệu Nhân viên
INSERT INTO NHANVIEN (MANHANVIEN, HO, TEN, NGAYSINH, NGAYLAMVIEC, DIACHI, DIENTHOAI, LUONGCOBAN, PHUCAP)
VALUES 
('NV001', N'Nguyen', N'Anh', '1980-05-12', '2010-06-15', N'123 Lê Lợi', '0912345678', 5000000, 500000),
('NV002', N'Tran', N'Binh', '1985-11-20', '2012-08-10', N'456 Hai Bà Trưng', '0923456789', 5200000, 550000),
('NV003', N'Le', N'Cuong', '1990-03-25', '2013-02-05', N'789 Nguyễn Trãi', '0934567890', 5300000, 450000),
('NV004', N'Pham', N'Dai', '1988-07-17', '2014-09-01', N'12 Bạch Đằng', '0945678901', 5100000, 400000),
('NV005', N'Vu', N'Lam', '1982-10-30', '2011-03-12', N'34 Đinh Tiên Hoàng', '0956789012', 5500000, 600000),
('NV006', N'Ho', N'Trung', '1992-01-15', '2015-07-20', N'56 Võ Thị Sáu', '0967890123', 5600000, 500000),
('NV007', N'Nguyen', N'Hoa', '1986-09-18', '2016-11-25', N'78 Trần Hưng Đạo', '0978901234', 5400000, 650000),
('NV008', N'Dao', N'Long', '1987-04-10', '2017-05-30', N'90 Phạm Văn Đồng', '0989012345', 5700000, 480000),
('NV009', N'Hoang', N'Khanh', '1984-12-02', '2018-08-12', N'102 Nguyễn Huệ', '0990123456', 5800000, 550000),
('NV010', N'Dinh', N'Minh', '1993-06-23', '2019-01-15', N'124 Cao Thắng', '0901234567', 5900000, 520000);
--Nhập dữ liệu Nhà cung cấp
INSERT INTO NHACUNGCAP (MACONGTY, TENCONGTY, TENGIAODICH, MAPX, SONHATENDUONG, DIENTHOAI, FAX, EMAIL)
VALUES 
('NCC001',  N'Công ty CP Quốc Tế ABC', N'ABC International', 'PX001', N'123 Lê Lợi', '0987654321', '0283765432', 'vietmy@vietmypharma.com'),
('NCC002', N'Công ty CP Mỹ Phẩm Thiên Nhiên', N'ThienNhien Cosmetics', 'PX002', N'456 Hai Bà Trưng', '0978654321', '0283765433', 'thiennhien@cosmetics.com'),
('NCC003', N'Dược Phẩm Hạnh Phúc', N'HanhPhuc Pharma', 'PX003', N'789 Nguyễn Trãi', '0968654321', '0283765434', 'hanhphuc@pharma.com'),
('NCC004', N'Công ty TNHH Dược Vina', N'Vina Pharma', 'PX004', N'12 Bạch Đằng', '0958654321', '0283765435', 'vinapharma@dvn.com'),
('NCC005', N'Công ty Mỹ Phẩm Ngọc Linh', N'NgocLinh Beauty', 'PX005', N'34 Đinh Tiên Hoàng', '0948654321', '0283765436', 'ngoclinh@beauty.com'),
('NCC006', N'Tập Đoàn Dược Phẩm Hòa Bình', N'HoaBinh Pharma', 'PX006', N'56 Võ Thị Sáu', '0938654321', '0283765437', 'hoabinh@pharma.vn'),
('NCC007', N'Công ty CP Mỹ Phẩm Sắc Việt', N'SacViet Cosmetics', 'PX007', N'78 Trần Hưng Đạo', '0928654321', '0283765438', 'sacviet@cosmetics.vn'),
('NCC008', N'Nhà phân phối Sông Hồng', 'songhong@dist.vn', 'PX008', N'90 Phạm Văn Đồng', '0918654321', '0283765439', 'honghanh@pharma.com'),
('NCC009', N'Công ty TNHH Mỹ Phẩm Thanh Xuân', N'ThanhXuan Beauty', 'PX009', N'102 Nguyễn Huệ', '0908654392', '0283765481', 'minhduc@pharma.vn');
--Nhập dữ liệu Khách hàng
INSERT INTO KHACHHANG (MAKHACHHANG, TENCONGTY, TENGIAODICH, MAPX, SONHATENDUONG, EMAIL, DIENTHOAI, FAX)
VALUES 
('KH001', DEFAULT, N'ThienLong Trading', 'PX001', N'15 Lê Duẩn', 'thienlong@gmail.com', '0901234567', '0281234567'),
('KH002', DEFAULT, N'ThaiBinh Invest', 'PX002', N'22 Trần Phú', 'thaibinh@invest.com', '0912345678', '0282345678'),
('KH003', DEFAULT, N'HoangGia Dist.', 'PX003', N'10 Nguyễn Thị Minh Khai', 'hoanggia@distribution.vn', '0923456789', '0283456789'),
('KH004', DEFAULT, N'DaiDuongXanh Co.', 'PX004', N'25 Nguyễn Văn Linh', 'daiduongxanh@oceanblue.com', '0934567890', '0284567890'),
('KH005', DEFAULT, N'MinhTam Production', 'PX005', N'18 Nguyễn Trãi', 'minhtam@production.vn', '0945678901', '0285678901'),
('KH006', N'Công ty TNHH Dược Vina',  N'Vina Pharma', 'PX006', N'30 Lý Tự Trọng', 'tana@development.com', '0956789012', '0286789012'),
('KH007', N'Công ty TNHH Tâm Việt', N'TamViet Co.', 'PX007', N'45 Pasteur', 'tamviet@gmail.com', '0967890123', '0287890123'),
('KH008', N'Nhà phân phối Sông Hồng', N'SongHong Distribution', 'PX008', N'50 Cách Mạng Tháng 8', 'songhong@dist.vn', '0978901234', '0288901234'),
('KH009', N'Công ty TNHH An Phú', N'AnPhu Co.', 'PX009', N'33 Bùi Thị Xuân', 'anphu@company.com', '0989012345', '0289012345'),
('KH010', N'Công ty CP Quốc Tế ABC', N'ABC International', 'PX010', N'77 Điện Biên Phủ', 'abc@international.com', '0990123456', '0280123456');
--Nhập dữ liệu Loại hàng
INSERT INTO LOAIHANG (MALOAIHANG, TENLOAIHANG)
VALUES 
('LH001', N'Đồ điện gia dụng'),
('LH002', N'Dụng cụ nhà bếp'),
('LH003', N'Dụng cụ vệ sinh'),
('LH004', N'Đồ gia dụng phòng tắm'),
('LH005', N'Nội thất phòng khách'),
('LH006', N'Nội thất phòng ngủ'),
('LH007', N'Đèn trang trí'),
('LH008', N'Dụng cụ giặt ủi'),
('LH009', N'Thiết bị làm mát'),
('LH010', N'Thiết bị sưởi ấm');
--Nhập dữ liệu Mặt hàng
INSERT INTO MATHANG (MAHANG, TENHANG, MACONGTY, MALOAIHANG, SOLUONG, DONVITINH, GIAHANG)
VALUES 
('MH001', N'Quạt điện đứng', 'NCC001', 'LH001', 100, N'Cái', 500000),
('MH002', N'Nồi cơm điện', 'NCC002', 'LH002', 150, N'Cái', 750000),
('MH003', N'Máy hút bụi', 'NCC003', 'LH003', 50, N'Cái', 1200000),
('MH004', N'Bồn rửa mặt', 'NCC004', 'LH004', 30, N'Cái', 850000),
('MH005', N'Sofa phòng khách', 'NCC005', 'LH005', 20, N'Bộ', 5000000),
('MH006', N'Giường ngủ', 'NCC006', 'LH006', 25, N'Cái', 10000000),
('MH007', N'Đèn chùm', 'NCC007', 'LH007', 40, N'Cái', 1500000),
('MH008', N'Máy giặt', 'NCC008', 'LH008', 35, N'Cái', 6000000),
('MH009', N'Máy lạnh', 'NCC009', 'LH009', 45, N'Cái', 8000000),
('MH010', N'Máy sưởi dầu', 'NCC010', 'LH010', 60, N'Cái', 3000000);
--Nhập dữ liệu Đơn đặt hàng
INSERT INTO DONDATHANG (SOHOADON, MAKHACHHANG, MANHANVIEN, NGAYDATHANG, NGAYGIAOHANG, NGAYCHUYENHANG, MAPX, DIACHICUTHE)
VALUES 
('DH001', 'KH001', 'NV001', '2024-01-05', '2024-01-10', '2024-01-08', 'PX001', N'15 Lê Duẩn'),
('DH002', 'KH002', 'NV002', '2024-01-06', '2024-01-11', '2024-01-09', 'PX002', N'22 Trần Phú'),
('DH003', 'KH003', 'NV003', '2024-01-07', '2024-01-12', '2024-01-10', 'PX003', N'10 Nguyễn Thị Minh Khai'),
('DH004', 'KH004', 'NV001', '2024-01-08', '2024-01-13', '2024-01-11', 'PX004', N'25 Nguyễn Văn Linh'),
('DH005', 'KH005', 'NV002', '2024-01-09', '2024-01-14', '2024-01-12', 'PX005', N'18 Nguyễn Trãi'),
('DH006', 'KH006', 'NV003', '2024-01-10', '2024-01-15', '2024-01-13', 'PX006', N'30 Lý Tự Trọng'),
('DH007', 'KH007', 'NV001', '2024-01-11', '2024-01-16', '2024-01-14', 'PX007', N'45 Pasteur'),
('DH008', 'KH008', 'NV002', '2024-01-12', '2024-01-17', '2024-01-15', 'PX008', N'50 Cách Mạng Tháng 8'),
('DH009', 'KH009', 'NV003', '2024-01-13', '2024-01-18', '2024-01-16', 'PX009', N'33 Bùi Thị Xuân'),
('DH010', 'KH010', 'NV001', '2024-01-14', '2024-01-19', '2024-01-17', 'PX010', N'77 Điện Biên Phủ'),
('DH011', 'KH001', 'NV002', '2024-01-15', '2024-01-20', '2024-01-18', 'PX001', N'15 Lê Duẩn'),
('DH012', 'KH002', 'NV003', '2024-01-16', '2024-01-21', '2024-01-19', 'PX002', N'22 Trần Phú'),
('DH013', 'KH003', 'NV001', '2024-01-17', '2024-01-22', '2024-01-20', 'PX003', N'10 Nguyễn Thị Minh Khai'),
('DH014', 'KH004', 'NV002', '2024-01-18', '2024-01-23', '2024-01-21', 'PX004', N'25 Nguyễn Văn Linh'),
('DH015', 'KH005', 'NV003', '2024-01-19', '2024-01-24', '2024-01-22', 'PX005', N'18 Nguyễn Trãi');
--Nhập dữ liệu Chi tiết đơn hàng
INSERT INTO CHITIETDATHANG (SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA)
VALUES 
('DH001', 'MH001', 500000, 5, DEFAULT),
('DH001', 'MH002', 750000, 1, DEFAULT),
('DH002', 'MH003', 1200000, 1, DEFAULT),
('DH002', 'MH004', 850000, 1, DEFAULT),
('DH003', 'MH005', 5000000, 1, DEFAULT),
('DH003', 'MH006', 10000000, 2, DEFAULT),
('DH004', 'MH007', 1500000, 2, DEFAULT),
('DH004', 'MH008', 6000000, 1, DEFAULT),
('DH005', 'MH009', 8000000, 1, DEFAULT),
('DH005', 'MH010', 3000000, 1, DEFAULT),
('DH006', 'MH001', 500000, 4, DEFAULT),
('DH007', 'MH002', 750000, 1, DEFAULT),
('DH008', 'MH003', 1200000, 1,DEFAULT),
('DH009', 'MH001', 500000, 1, DEFAULT),
('DH010', 'MH011', 450000, 3, DEFAULT),  
('DH011', 'MH002', 750000, 2, DEFAULT),  
('DH011', 'MH005', 5000000, 1, DEFAULT), 
('DH012', 'MH006', 10000000, 1,DEFAULT), 
('DH012', 'MH008', 6000000, 1, DEFAULT), 
('DH013', 'MH007', 1500000, 2, DEFAULT);

