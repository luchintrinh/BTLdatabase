IF(EXISTS(SELECT name FROM sys.databases WHERE name='BTLNHOM11'))
DROP DATABASE BTLNHOM11
GO
CREATE DATABASE BTLNHOM11
GO
USE BTLNHOM11
GO
--tạo bảng khối

CREATE TABLE khoi
(
	khoi_ma CHAR(10) PRIMARY KEY,
	khoi_ten NVARCHAR(50) NOT NULL,
);
GO

--tạo bảng lớp
CREATE TABLE lop
(
	lop_ma CHAR(10) PRIMARY KEY,
	khoi_ma CHAR(10) REFERENCES khoi(khoi_ma),
	lop_ten NVARCHAR(50) NOT NULL,
);
GO

--tạo bảng học sinh 
CREATE TABLE hs
(	
	hs_ma CHAR(10) PRIMARY KEY,
	lop_ma CHAR(10) REFERENCES lop(lop_ma),
	hs_ten NVARCHAR(50) NOT NULL,
	hs_gioitinh NCHAR(20) NOT NULL,
	hs_ngaysinh DATE NOT NULL,
	hs_diachi NVARCHAR(100) NOT NULL,
	hs_sdt CHAR(10) NOT NULL
);
GO
--tọa bảng giáo viên
CREATE TABLE gv
(
	gv_ma CHAR(10) PRIMARY KEY,
	gv_ten NVARCHAR(50) NOT NULL,
	gv_gioitinh NCHAR(20) NOT NULL,
	gv_diachi NVARCHAR(100) NOT NULL,
	gv_sdt CHAR(10) NOT NULL
);
GO
--tạo bảng môn học
CREATE TABLE mh
(
	mh_ma CHAR(10) PRIMARY KEY,
	mh_ten NVARCHAR(50) NOT NULL,
	gv_ma CHAR(10) REFERENCES gv(gv_ma)
);
GO
--tạo bảng điểm học kì 1 
CREATE TABLE ki_1
(	
	hs_ma CHAR(10) REFERENCES dbo.hs(hs_ma),
	mh_ma CHAR(10) REFERENCES mh(mh_ma),
	ki_1_diem1 FLOAT CHECK(ki_1_diem1<=10.0),
	ki_1_diem2 FLOAT CHECK(ki_1_diem2<=10.0),
	ki_1_diem3 FLOAT CHECK(ki_1_diem3<=10.0),
	ki_1_diemtk FLOAT,--điểm trung bình
	ki_1_hk NCHAR(20),--hạnh kiểm
	ki_1_hl NCHAR(20), --học lực
);
GO
--tạo bảng điểm kì 2
CREATE TABLE ki_2
(	
	hs_ma CHAR(10) REFERENCES dbo.hs(hs_ma),
	mh_ma CHAR(10) REFERENCES mh(mh_ma),
	ki_2_diem1 FLOAT CHECK(ki_2_diem1<=10.0),
	ki_2_diem2 FLOAT CHECK(ki_2_diem2<=10.0),
	ki_2_diem3 FLOAT CHECK(ki_2_diem3<=10.0),
	ki_2_diemtk FLOAT, --điểm trung bình
	ki_2_hk NCHAR(20),--hạnh kiểm
	ki_2_hl NCHAR(20), --học lực
);
GO
--tạo bảng điểm cả năm
CREATE TABLE ca_nam
(	
	hs_ma CHAR(10) REFERENCES dbo.hs(hs_ma),
	mh_ma CHAR(10) REFERENCES mh(mh_ma),
	ca_nam_dtb FLOAT,
	ca_nam_hocluc NCHAR(20),
	ca_nam_hk NCHAR(20) NOT NULL
);
GO


--***************TẠO FUNCTION XÉT HỌC LỰC HỌC SINH*****************
CREATE FUNCTION f_xethocluc (@dtb FLOAT)
RETURNS NCHAR(20)
AS
BEGIN
	DECLARE @hocluc NCHAR(20)
    IF(@dtb>=9.0) SET @hocluc= N'Xuất sắc'
	ELSE IF(@dtb>=8.0 AND @dtb<9.0) SET @hocluc= N'Giỏi'
	ELSE IF(@dtb<8.0 AND @dtb>=6.5) SET @hocluc= N'Khá'
	ELSE IF(@dtb<6.5 AND @dtb>=5) SET @hocluc= N'Trung bình'
	ELSE SET @hocluc=N'Yếu'
	RETURN @hocluc
END
GO

--****************TẠO TRIGGER***************
--tính điểm trung bình kì 1
CREATE TRIGGER trg_tinhdtb1 ON dbo.ki_1 AFTER INSERT
AS
BEGIN
    UPDATE dbo.ki_1 SET ki_1_diemtk=ROUND((ki_1_diem1+ki_1_diem2*2+ki_1_diem3*3)/6, 1)
END
GO

--tính điểm trung bình kì 2
CREATE TRIGGER trg_tinhdtb2 ON dbo.ki_2 AFTER INSERT
AS
BEGIN
    UPDATE dbo.ki_2 SET ki_2_diemtk=ROUND((ki_2_diem1+ki_2_diem2*2+ki_2_diem3*3)/6, 1)
END
GO

--xét học lực cho học sinh bảng 1
CREATE TRIGGER trg_hocluc1 ON dbo.ki_1 AFTER INSERT 
AS
BEGIN
	UPDATE dbo.ki_1 SET ki_1_hl=dbo.f_xethocluc(ki_1_diemtk)
END
GO

--xét học lực kì 2
CREATE TRIGGER trg_hocluc2 ON dbo.ki_2 AFTER INSERT 
AS
BEGIN
	UPDATE dbo.ki_2 SET ki_2_hl=dbo.f_xethocluc(ki_2_diemtk)
END
GO

--tính điểm trung bình bảng cả năm khi thêm điểm kì 1
CREATE TRIGGER trg_tinhtoan1 ON dbo.ki_1 AFTER UPDATE
AS
BEGIN
    UPDATE dbo.ca_nam SET ca_nam_dtb=ROUND((ki_1_diemtk+ki_2_diemtk*2)/3, 1) FROM dbo.ki_1, dbo.ki_2, dbo.hs, dbo.mh WHERE ca_nam.hs_ma=hs.hs_ma AND dbo.ca_nam.mh_ma=mh.mh_ma
	AND dbo.ki_1.hs_ma=hs.hs_ma AND dbo.ki_1.mh_ma=mh.mh_ma AND ki_2.hs_ma=hs.hs_ma AND ki_2.hs_ma=hs.hs_ma AND ki_2.mh_ma=mh.mh_ma
END
GO


--tính điểm trung bình bảng cả năm khi thêm điểm kì 2
alter TRIGGER trg_tinhtoan2 ON dbo.ki_2 AFTER UPDATE
AS
BEGIN
	DECLARE @tb1 FLOAT
    DECLARE @tb2 FLOAT
	SELECT @tb1=AVG(dbo.ki_1.ki_1_diemtk) FROM dbo.ki_1 GROUP BY hs_ma
	SELECT @tb1=AVG(dbo.ki_2.ki_2_diemtk) FROM dbo.ki_2 GROUP BY hs_ma
    UPDATE dbo.ca_nam SET ca_nam_dtb=ROUND((@tb1+@tb2*2)/3, 1) FROM dbo.ki_1, dbo.ki_2, dbo.hs, dbo.mh WHERE ca_nam.hs_ma=hs.hs_ma AND dbo.ca_nam.mh_ma=mh.mh_ma
	AND dbo.ki_1.hs_ma=hs.hs_ma AND dbo.ki_1.mh_ma=mh.mh_ma AND ki_2.hs_ma=hs.hs_ma AND ki_2.hs_ma=hs.hs_ma AND ki_2.mh_ma=mh.mh_ma
END
GO
--xét học lực cho bảng cả năm 
CREATE TRIGGER trg_xethocluccanam ON dbo.ca_nam AFTER UPDATE
AS
BEGIN
    UPDATE dbo.ca_nam SET ca_nam_hocluc=dbo.f_xethocluc(ca_nam_dtb)
END
GO


----****************************NHẬP NHẬP DỮ LIỆU******************
--nhập khối 10, 11, 12 với mã lần lượt là: K1, K2, K3
INSERT INTO dbo.khoi
(
    khoi_ma,
    khoi_ten
)
VALUES
(   'K1', -- khoi_ma - char(10)
    N'khối 10' -- khoi_ten - nvarchar(50)
    ),
(   'K2', -- khoi_ma - char(10)
    N'Khối 11' -- khoi_ten - nvarchar(50)
    ),
(   'K3', -- khoi_ma - char(10)
    N'Khối 12' -- khoi_ten - nvarchar(50)
    );
GO


--nhập bảng lớp 

--nhập lớp với ma lớp theo cấu trúc L1, L2, ........

CREATE PROC sp_nhaplop @malop CHAR(10), @makhoi CHAR(10), @tenlop NVARCHAR(50)
AS
BEGIN
	IF(EXISTS(SELECT lop_ma FROM dbo.lop WHERE lop_ma=@malop)) PRINT N'Lớp này đã tồn tại'
	ELSE IF(NOT EXISTS(SELECT khoi_ma FROM khoi WHERE khoi_ma=@makhoi)) PRINT N'Lớp này chưa tồn tại'
	ELSE INSERT INTO dbo.lop
	(
	    lop_ma,
	    khoi_ma,
	    lop_ten
	)
	VALUES
	(   @malop, -- lop_ma - char(10)
	    @makhoi, -- khoi_ma - char(10)
	    @tenlop -- lop_ten - nvarchar(50)
	    )
END
GO
EXEC dbo.sp_nhaplop @malop = 'L1',  -- char(10)
                    @makhoi = 'K1', -- char(10)
                    @tenlop = N'10A' -- nvarchar(50)
EXEC dbo.sp_nhaplop @malop = 'L2',  -- char(10)
                    @makhoi = 'K2', -- char(10)
                    @tenlop = N'11A' -- nvarchar(50)
EXEC dbo.sp_nhaplop @malop = 'L3',  -- char(10)
                    @makhoi = 'K3', -- char(10)
                    @tenlop = N'12A' -- nvarchar(50)

--nhập bảng sinh viên
--nhập mã học sinh dạng HS1, HS2, ..............
CREATE PROC sp_nhaphs
	@hs_ma CHAR(10) ,
	@lop_ma CHAR(10),
	@hs_ten NVARCHAR(50),
	@hs_gioitinh NCHAR(20),
	@hs_ngaysinh DATE,
	@hs_diachi NVARCHAR(100),
	@hs_sdt CHAR(10)
AS
BEGIN 
	IF(EXISTS(SELECT hs_ma FROM dbo.hs WHERE hs_ma=@hs_ma)) PRINT N'Sinh viên này đã tồn tại trên hệ thống'
	ELSE IF(NOT EXISTS(SELECT lop_ma FROM dbo.lop WHERE lop_ma=@lop_ma)) PRINT N'Lớp này chưa tồn tại'
	ELSE INSERT INTO dbo.hs
	(
	    hs_ma,
	    lop_ma,
	    hs_ten,
	    hs_gioitinh,
	    hs_ngaysinh,
	    hs_diachi,
	    hs_sdt
	)
	VALUES
	(   @hs_ma,        -- hs_ma - char(10)
	    @lop_ma,        -- lop_ma - char(10)
	    @hs_ten,       -- hs_ten - nvarchar(50)
	    @hs_gioitinh,       -- hs_gioitinh - nchar(20)
	    @hs_ngaysinh, -- hs_ngaysinh - date
	    @hs_diachi,       -- hs_diachi - nvarchar(100)
	    @hs_sdt         -- hs_sdt - char(10)
	    )
END
GO

EXEC sp_nhaphs 'HS1', 'L1', N'Lù Chín Trình', N'nam', '2002-02-26', N'Lào Cai', '0215466455'
EXEC sp_nhaphs 'HS2', 'L1', N'Vũ Thị Tuyết', N'nữ', '2002-08-09', N'Ninh Bình', '025615122'
EXEC sp_nhaphs 'HS3', 'L2', N'Nguyễn Thành Đạt', N'nam', '2002-09-07', N'Hải Dương', '0218755'
EXEC sp_nhaphs 'HS4', 'L3', N'Lê Phương Thảo', N'nữ', '2002-01-17', N'Hà Nội', '026516455'

--nhập giảng viên
--cú pháp mã GV: GV1, GV2,.............
INSERT INTO dbo.gv
(
    gv_ma,
    gv_ten,
    gv_gioitinh,
    gv_diachi,
    gv_sdt
)
VALUES
	('GV1',  -- gv_ma - char(10)
    N'Lê Hoài Thu', -- gv_ten - nvarchar(50)
    N'Nữ', -- gv_gioitinh - nchar(20)
    N'Hà Nội', -- gv_diachi - nvarchar(100)
    '11565550'   -- gv_sdt - char(10)
    ),

	('GV2',  -- gv_ma - char(10)
    N'Nguyễn Mạnh Đức', -- gv_ten - nvarchar(50)
    N'nam', -- gv_gioitinh - nchar(20)
    N'Hà Nội', -- gv_diachi - nvarchar(100)
    '032062264'   -- gv_sdt - char(10)
    ),

	('GV3',  -- gv_ma - char(10)
    N'Phan Văn Trường', -- gv_ten - nvarchar(50)
    N'nam', -- gv_gioitinh - nchar(20)
    N'Hà Nội', -- gv_diachi - nvarchar(100)
    '012626566'   -- gv_sdt - char(10)
    )

--nhập bảng môn học
--mã môn học theo cấu trúc: MH1, MH2,...
CREATE PROC sp_nhapmh @mamh CHAR(10), @tenmh nvarchar(50), @ma_gv CHAR(10)
AS
BEGIN
    IF(EXISTS(SELECT mh_ma FROM dbo.mh WHERE mh_ma=@mamh)) PRINT N'môn học này đã tồn tại'
	ELSE IF(NOT EXISTS(SELECT gv_ma FROM dbo.gv WHERE gv_ma = @ma_gv)) PRINT N'giảng viên này chưa tồn tại'
	ELSE INSERT INTO dbo.mh
	(
	    mh_ma,
	    mh_ten,
	    gv_ma
	)
	VALUES
	(   @mamh,  -- mh_ma - char(10)
	    @tenmh, -- mh_ten - nvarchar(50)
	    @ma_gv   -- gv_ma - char(10)
	    )
END
GO

EXEC sp_nhapmh 'MH1', N'Hóa học', 'GV2'
EXEC sp_nhapmh 'MH2', N'Toán', 'GV1'
EXEC sp_nhapmh 'MH3', N'Văn', 'GV3'


--Nhập bảng điểm kì 1

CREATE PROC sp_nhapdiem1 
	@hs_ma CHAR(10),
	@mh_ma CHAR(10),
	@ki_1_diem1 FLOAT,
	@ki_1_diem2 FLOAT,
	@ki_1_diem3 FLOAT,
	@ki_1_diemtk FLOAT,--điểm trung bình
	@ki_1_hk NCHAR(20),--hạnh kiểm
	@ki_1_hl NCHAR(20) --học lực
AS
 BEGIN
     IF(EXISTS(SELECT mh_ma, hs_ma FROM dbo.ki_1 WHERE mh_ma=@mh_ma AND hs_ma=@hs_ma)) PRINT N'sinh viên với bộ môn này đã có điểm'
	 ELSE IF(NOT EXISTS(SELECT mh_ma FROM dbo.mh WHERE mh_ma=@mh_ma)) PRINT N'Môn học này chưa tồn tại'
	 ELSE IF(NOT EXISTS(SELECT hs_ma FROM dbo.hs WHERE hs_ma=@hs_ma)) PRINT N'Học sinh này chưa tồn tại'
	 ELSE INSERT INTO dbo.ki_1
	 (
	     hs_ma,
	     mh_ma,
	     ki_1_diem1,
	     ki_1_diem2,
	     ki_1_diem3,
	     ki_1_diemtk,
	     ki_1_hk,
	     ki_1_hl
	 )
	 VALUES
	 (   @hs_ma,  -- hs_ma - char(10)
	     @mh_ma,  -- mh_ma - char(10)
	     @ki_1_diem1, -- ki_1_diem1 - float
	     @ki_1_diem2, -- ki_1_diem2 - float
	     @ki_1_diem3, -- ki_1_diem3 - float
	     @ki_1_diemtk, -- ki_1_diemtk - float
	     @ki_1_hk, -- ki_1_hk - nchar(20)
	     @ki_1_hl  -- ki_1_hl - nchar(20)
	     )
 END
 GO
 EXEC sp_nhapdiem1 'HS1', 'MH1', 6, 9, 5.6, NULL, N'Tốt',NULL
  EXEC sp_nhapdiem1 'HS2', 'MH1', 7, 7, 7.6, NULL, N'Tốt',NULL
   EXEC sp_nhapdiem1 'HS3', 'MH2', 6, 9, 5.6, NULL, N'Khá',NULL
    EXEC sp_nhapdiem1 'HS4', 'MH3', 8, 9, 4.6, NULL, N'Tốt',NULL
	EXEC sp_nhapdiem1 'HS2', 'MH2', 5, 3, 8.6, NULL, N'Tốt',NULL


--nhập điểm kì 2
CREATE PROC sp_nhapdiem2 
	@hs_ma CHAR(10),
	@mh_ma CHAR(10),
	@ki_2_diem1 FLOAT,
	@ki_2_diem2 FLOAT,
	@ki_2_diem3 FLOAT,
	@ki_2_diemtk FLOAT,--điểm trung bình
	@ki_2_hk NCHAR(20),--hạnh kiểm
	@ki_2_hl NCHAR(20) --học lực
AS
 BEGIN
     IF(EXISTS(SELECT mh_ma, hs_ma FROM dbo.ki_2 WHERE mh_ma=@mh_ma AND hs_ma=@hs_ma)) PRINT N'sinh viên với bộ môn này đã có điểm'
	 ELSE IF(NOT EXISTS(SELECT mh_ma FROM dbo.mh WHERE mh_ma=@mh_ma)) PRINT N'Môn học này chưa tồn tại'
	 ELSE IF(NOT EXISTS(SELECT hs_ma FROM dbo.hs WHERE hs_ma=@hs_ma)) PRINT N'Học sinh này chưa tồn tại'
	 ELSE INSERT INTO dbo.ki_2
	 (
	     hs_ma,
	     mh_ma,
	     ki_2_diem1,
	     ki_2_diem2,
	     ki_2_diem3,
	     ki_2_diemtk,
	     ki_2_hk,
	     ki_2_hl
	 )
	 VALUES
	 (   @hs_ma,  -- hs_ma - char(10)
	     @mh_ma,  -- mh_ma - char(10)
	     @ki_2_diem1, -- ki_2_diem1 - float
	     @ki_2_diem2, -- ki_2_diem2 - float
	     @ki_2_diem3, -- ki_2_diem3 - float
	     @ki_2_diemtk, -- ki_2_diemtk - float
	     @ki_2_hk, -- ki_2_hk - nchar(20)
	     @ki_2_hl  -- ki_2_hl - nchar(20)
	     )
 END
 GO
 EXEC sp_nhapdiem2 'HS1', 'MH1', 6, 9, 5.6, NULL, N'Tốt',NULL
  EXEC sp_nhapdiem2 'HS2', 'MH1', 9, 9, 8.0, NULL, N'Tốt',NULL
   EXEC sp_nhapdiem2 'HS3', 'MH2', 7, 5, 3.5, NULL, N'Tốt',NULL
    EXEC sp_nhapdiem2 'HS4', 'MH3', 8, 6, 7.5, NULL, N'Tốt',NULL
	EXEC sp_nhapdiem2 'HS2', 'MH2', 9, 3, 5, NULL, N'Tốt',NULL

CREATE VIEW v_tonghop 
AS
 SELECT dbo.khoi.khoi_ten, dbo.khoi.khoi_ma, dbo.lop.lop_ten, dbo.hs.hs_ma, dbo.hs.hs_ten, dbo.hs.hs_gioitinh, dbo.hs.hs_ngaysinh, dbo.hs.hs_diachi, dbo.hs.hs_sdt, dbo.ki_1.ki_1_diem1, 
 dbo.ki_1.ki_1_diem2, dbo.ki_1.ki_1_diem3,dbo.ki_1.ki_1_diemtk, dbo.ki_1.ki_1_hl, dbo.ki_1.ki_1_hk, dbo.ki_2.ki_2_diem1, dbo.ki_2.ki_2_diem2, dbo.ki_2.ki_2_diem3, dbo.ki_2.ki_2_diemtk, dbo.ki_2.ki_2_hl, dbo.ki_2.ki_2_hk
 FROM dbo.ki_1, dbo.ki_2, dbo.khoi, dbo.lop, dbo.hs, dbo.mh, dbo.gv
 WHERE khoi.khoi_ma=dbo.lop.khoi_ma AND dbo.lop.lop_ma=dbo.hs.lop_ma AND hs.hs_ma=dbo.ki_1.hs_ma AND dbo.hs.hs_ma=dbo.ki_2.hs_ma AND  mh.mh_ma=dbo.ki_1.mh_ma AND dbo.mh.mh_ma=dbo.ki_2.mh_ma AND 
 dbo.mh.gv_ma=dbo.gv.gv_ma

 GO

 DROP VIEW v_tonghop
 SELECT * FROM  v_tonghop
--tạo view xem điểm trung bình 




 
SELECT * FROM dbo.khoi
SELECT * FROM dbo.lop
SELECT * FROM dbo.hs
SELECT * FROM dbo.ki_1
SELECT * FROM dbo.ki_2
SELECT * FROM dbo.mh
SELECT * FROM dbo.ca_nam
SELECT * FROM dbo.gv






