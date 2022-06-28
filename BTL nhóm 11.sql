IF(EXISTS(SELECT name FROM sys.databases WHERE name='BTLNHOM11'))
DROP DATABASE BTLNHOM11
GO

CREATE DATABASE BTLNHOM11
GO

USE BTLNHOM11
GO

--TẠO BẢNG KHỐI

CREATE TABLE khoi
(
	khoi_ma CHAR(10) PRIMARY KEY,
	khoi_ten NVARCHAR(50) NOT NULL,
);
GO

--TẠO BẢNG LỚP

CREATE TABLE lop
(
	lop_ma CHAR(10) PRIMARY KEY,
	khoi_ma CHAR(10) REFERENCES khoi(khoi_ma),
	lop_ten NVARCHAR(50) NOT NULL,
);
GO

--TẠO BẢNG HỌC SINH

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

--TẠO BẢNG GIÁO VIÊN

CREATE TABLE gv
(
	gv_ma CHAR(10) PRIMARY KEY,
	gv_ten NVARCHAR(50) NOT NULL,
	gv_gioitinh NCHAR(20) NOT NULL,
	gv_diachi NVARCHAR(100) NOT NULL,
	gv_sdt CHAR(10) NOT NULL
);
GO

--TẠO BẢNG MÔN HỌC

CREATE TABLE mh
(
	mh_ma CHAR(10) PRIMARY KEY,
	mh_ten NVARCHAR(50) NOT NULL,
	gv_ma CHAR(10) REFERENCES gv(gv_ma)
);
GO

--TẠO BẢNG ĐIỂM MÔN HỌC

CREATE TABLE diemmh
(	
	hs_ma CHAR(10) REFERENCES dbo.hs(hs_ma),
	mh_ma CHAR(10) REFERENCES mh(mh_ma),
	diem1 FLOAT CHECK(diem1<=10.0),
	diem2 FLOAT CHECK(diem2<=10.0),
	diem3 FLOAT CHECK(diem3<=10.0),
	diemtk FLOAT--điểm trung bình
);
GO

--TẠO BẢNG ĐIỂM TỔNG KẾT

CREATE TABLE ca_nam
(	
	hs_ma CHAR(10) REFERENCES dbo.hs(hs_ma),
	ca_nam_dtb FLOAT,
	ca_nam_hocluc NCHAR(20),
	ca_nam_hk NCHAR(20) NOT NULL
);
GO


--TẠO VIEW ĐIỂM SINH VIÊN TRONG LỚP 
CREATE VIEW v_tonghop
AS
SELECT dbo.khoi.khoi_ma, dbo.khoi.khoi_ten, dbo.lop.lop_ten, dbo.lop.lop_ma, hs.hs_ma, dbo.hs.hs_ten, hs.hs_gioitinh, hs.hs_ngaysinh, hs.hs_diachi, hs.hs_sdt, dbo.mh.mh_ten, dbo.gv.gv_ten, dbo.diemmh.diem1, dbo.diemmh.diem2, dbo.diemmh.diem3, dbo.diemmh.diemtk
FROM dbo.khoi, dbo.lop, dbo.hs, dbo.mh, dbo.gv, dbo.diemmh
WHERE  khoi.khoi_ma=dbo.lop.khoi_ma AND lop.lop_ma=dbo.hs.lop_ma AND hs.hs_ma=dbo.diemmh.hs_ma AND dbo.mh.mh_ma=dbo.diemmh.mh_ma AND gv.gv_ma=mh.gv_ma
GO


--********************THỦ TỤC IN RA THÔNG TIN ĐIÊM CỦA HS THEO MÃ HỌC SINH************
CREATE PROC sp_hstheoma @mahs CHAR(10)
AS
BEGIN
    IF(NOT EXISTS(SELECT hs_ma FROM v_tonghop WHERE hs_ma=@mahs)) PRINT N'học sinh này không tồn tại, vui lòng kiểm tra lại'
	ELSE 
		BEGIN
			DECLARE @dtb FLOAT 
			DECLARE @hl NCHAR(10)
			DECLARE @hk NCHAR(10)
			SELECT @dtb=ca_nam_dtb FROM dbo.ca_nam WHERE hs_ma=@mahs
			SELECT @hl=ca_nam_hocluc FROM dbo.ca_nam WHERE hs_ma=@mahs
			SELECT @hk=ca_nam_hk FROM dbo.ca_nam WHERE hs_ma=@mahs
			SELECT * FROM v_tonghop WHERE @mahs=hs_ma ORDER BY diemtk DESC --sắp xếp theo thứ tự giảm dần, nếu tăng dần ASC
			PRINT (N'điểm trung bình cả năm: '+ CONVERT(NVARCHAR, CONVERT(NVARCHAR, @dtb) ))
			PRINT (N'học lực cả năm: '+ CONVERT(NVARCHAR, @hl))
			PRINT (N'hạnh kiểm cả năm: ')+CONVERT(NVARCHAR, @hk)
		END
END
GO




--*******************THỦ TỤC IN BẢNG ĐIỂM CÁC MÔN CỦA HỌC SINH THEO LỚP ***********
CREATE PROC sp_svtheolop @malop CHAR(10)
AS
BEGIN
    IF(NOT EXISTS(SELECT lop_ma FROM dbo.lop WHERE lop_ma=@malop )) PRINT N'lớp này không tồn tại, hãy kiểm tra lại !!'
	ELSE SELECT khoi.khoi_ten, lop.lop_ten, hs.hs_ten, dbo.ca_nam.ca_nam_dtb, dbo.ca_nam.ca_nam_hocluc, dbo.ca_nam.ca_nam_hk 
	FROM dbo.khoi, dbo.lop, dbo.hs, dbo.ca_nam
	WHERE dbo.khoi.khoi_ma=dbo.lop.khoi_ma AND dbo.lop.lop_ma=dbo.hs.lop_ma AND dbo.hs.hs_ma=dbo.ca_nam.hs_ma AND @malop= dbo.lop.lop_ma
	ORDER BY hs.hs_ten
END
GO


--*******************THỦ TỤC ĐẾM SỐ HỌC SINH CỦA TỪNG LỚP*************
CREATE PROC sp_demsv 
AS
BEGIN
    SELECT lop_ma, COUNT(hs_ma) AS soluong FROM v_tonghop GROUP BY lop_ma 
END
GO

--******************FUNCTION ĐẾM SỐ HỌC SINH HẠNH KIỂM KHÁ**********************
CREATE FUNCTION f_demhkkha ()
RETURNS int
AS
BEGIN
    DECLARE @dem INT 
	SELECT @dem=COUNT(hs_ma) FROM dbo.ca_nam WHERE ca_nam_hk=N'khá'
	RETURN @dem
END
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

CREATE  TRIGGER trg_tinhdtb ON dbo.diemmh AFTER INSERT
AS
BEGIN
    UPDATE dbo.diemmh SET diemtk=ROUND((diem1+diem2*2+diem3*3)/6, 1)

END
GO


--*********TÍNH ĐIỂM TRUNG BÌNH TẤT CẢ CÁC MÔN CỦA 1 HỌC SINH*************


CREATE FUNCTION f_dtbcanam (@mahs CHAR(10))
RETURNS FLOAT
AS
BEGIN
	DECLARE @dtb FLOAT
	SELECT @dtb= AVG(diemtk) FROM dbo.diemmh GROUP BY hs_ma HAVING @mahs=hs_ma
	RETURN @dtb
END
GO

--************TRIGGER TÍNH HỌC LỰC, HẠNH KIỂM BẢNG ĐIỂM CẢ NĂM HỌC*************


CREATE TRIGGER trg_capnhatdiemcanam ON dbo.diemmh AFTER INSERT
AS
BEGIN
	UPDATE dbo.ca_nam SET ca_nam_dtb=dbo.f_dtbcanam(hs_ma)
	UPDATE dbo.ca_nam SET ca_nam_hocluc=dbo.f_xethocluc(ca_nam_dtb)
END
GO


--UPDATE ĐIỂM THÀNH PHẦN 


CREATE PROC sp_thaydoi @mahs CHAR(10), @mamh CHAR(10), @diem1 FLOAT, @diem2 FLOAT, @diem3 FLOAT
AS
BEGIN
	IF(NOT EXISTS(SELECT hs_ma, mh_ma FROM dbo.diemmh WHERE hs_ma=@mahs AND mh_ma=@mamh)) PRINT N'môn học môn học của học sinh này không tồn tại'
	ELSE UPDATE dbo.diemmh SET diem1=@diem1, diem2=@diem2, diem3=@diem3 WHERE mh_ma=@mamh AND hs_ma=@mahs 
END
GO
EXEC dbo.sp_thaydoi @mahs = 'HS1',   -- char(10)
                    @mamh = 'MH1',   -- char(10)
                    @diem1 = 5.0, -- float
                    @diem2 = 9.5, -- float
                    @diem3 = 9.6  -- float


SELECT * FROM dbo.ca_nam
SELECT * FROM dbo.diemmh



--TẠO TRIGGER ĐỂ UPDATE ĐIỂM VÀ HỌC LỰC SAU KHI THAY ĐỔI ĐIỂM THÀNH PHẦN


CREATE TRIGGER trg_capnhat ON dbo.diemmh AFTER UPDATE
AS
BEGIN
	UPDATE dbo.diemmh SET diemtk=(diem1+diem2*2+diem3*3)/6 
	UPDATE dbo.ca_nam SET ca_nam_dtb=dbo.f_dtbcanam(hs_ma)
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
GO


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
GO


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
	GO
    

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
GO



--Nhập bảng điểm môn học

CREATE PROC sp_nhapdiemmh
	@hs_ma CHAR(10),
	@mh_ma CHAR(10),
	@diem1 FLOAT,
	@diem2 FLOAT,
	@diem3 FLOAT,
	@diemtk FLOAT,
	@HK NCHAR(10)
AS
 BEGIN
     IF(EXISTS(SELECT mh_ma, hs_ma FROM dbo.diemmh WHERE mh_ma=@mh_ma AND hs_ma=@hs_ma)) PRINT N'sinh viên với bộ môn này đã có điểm'
	 ELSE IF(NOT EXISTS(SELECT mh_ma FROM dbo.mh WHERE mh_ma=@mh_ma)) PRINT N'Môn học này chưa tồn tại'
	 ELSE IF(NOT EXISTS(SELECT hs_ma FROM dbo.hs WHERE hs_ma=@hs_ma)) PRINT N'Học sinh này chưa tồn tại'
	 ELSE INSERT INTO dbo.diemmh
	 (
	     hs_ma,
	     mh_ma,
	     diem1,
	     diem2,
	     diem3,
	     diemtk
	 )
	 VALUES
	 (   @hs_ma,  -- hs_ma - char(10)
	     @mh_ma,  -- mh_ma - char(10)
	     @diem1, -- diem1 - float
	     @diem2, -- diem2 - float
	     @diem3, -- diem3 - float
	     @diemtk -- diemtk - float
	   )
		IF(NOT EXISTS(SELECT hs_ma FROM dbo.ca_nam WHERE hs_ma=@hs_ma))
		INSERT INTO dbo.ca_nam
		(
		    hs_ma,
		    ca_nam_dtb,
		    ca_nam_hocluc,
		    ca_nam_hk
		)
		VALUES
		(   @hs_ma,  -- hs_ma - char(10)
		    0.0, -- ca_nam_dtb - float
		    N'', -- ca_nam_hocluc - nchar(20)
		    @HK  -- ca_nam_hk - nchar(20)
		    )
 END
 GO

 EXEC sp_nhapdiemmh 'HS1', 'MH1', 6, 9, 5.6, NULL, N'tốt'
  EXEC sp_nhapdiemmh 'HS2', 'MH1', 7, 7, 7.6, NULL, N'khá'
   EXEC sp_nhapdiemmh 'HS3', 'MH2', 6, 9, 5.6, NULL, N'tốt'
    EXEC sp_nhapdiemmh 'HS4', 'MH3', 8, 9, 4.6, NULL, N'tốt'
	EXEC sp_nhapdiemmh 'HS2', 'MH2', 5, 3, 8.6, NULL, N'khá'
GO








--**************THỦ TUC XÓA DỮ LIỆU*****************
--xóa khối
CREATE PROC sp_xoakhoi @makhoi CHAR(10)
AS
BEGIN
    IF(NOT EXISTS(SELECT khoi_ma FROM dbo.khoi WHERE khoi_ma=@makhoi)) PRINT N'Khối này chưa tồn tại'
	ELSE IF(EXISTS(SELECT khoi_ma FROM lop WHERE khoi_ma=@makhoi)) PRINT N'Khối này còn ràng buộc tới bảng lớp'
	ELSE DELETE FROM dbo.khoi WHERE @makhoi = khoi_ma
END
GO
EXEC sp_xoakhoi 'K5'


--xóa lớp
CREATE PROC sp_xoalop @malop CHAR(10)
AS
BEGIN
    IF(NOT EXISTS(SELECT lop_ma FROM dbo.lop WHERE lop_ma=@malop)) PRINT N'lớp này chưa tồn tại'
	ELSE IF(EXISTS(SELECT lop_ma FROM dbo.hs WHERE lop_ma=@malop)) PRINT N'lớp này còn ràng buộc tới bảng học sinh'
	ELSE DELETE FROM dbo.lop WHERE @malop = lop_ma
END
GO
EXEC sp_xoalop 'L10'

--xóa sinh viên
CREATE PROC sp_xoahs @mahs CHAR(10)
AS
BEGIN
    IF(NOT EXISTS(SELECT hs_ma FROM dbo.hs WHERE hs_ma=@mahs)) PRINT N'học sinh này không tồn tại'
	ELSE IF(EXISTS(SELECT hs_ma FROM dbo.diemmh WHERE hs_ma=@mahs)) PRINT N'học sinh này còn ràng buộc với bảng điểm môn học'
	ELSE IF(EXISTS(SELECT hs_ma FROM dbo.ca_nam WHERE hs_ma=@mahs)) PRINT N'học sinh này còn ràng buộc với bảng kì cả năm'
	ELSE DELETE FROM dbo.ca_nam WHERE @mahs=hs_ma
END
GO
EXEC sp_xoahs 'HS5'



--xóa giảng viên
CREATE PROC sp_xoagv @magv CHAR(10)
AS
BEGIN
    IF(NOT EXISTS(SELECT gv_ma FROM dbo.gv WHERE @magv=gv_ma)) PRINT N'giảng viên này không tồn tại'
	ELSE IF(EXISTS(SELECT gv_ma FROM dbo.mh WHERE gv_ma=@magv)) PRINT N'giảng viên còn đg ràng buộc tới môn học'
	ELSE DELETE FROM dbo.mh WHERE @magv=gv_ma
END
GO
EXEC sp_xoagv 'GV1'


--xóa môn học
CREATE PROC sp_xoamh @mamh CHAR(10)
AS
BEGIN
     IF(NOT EXISTS(SELECT mh_ma FROM dbo.mh WHERE mh_ma=@mamh)) PRINT N'môn học này chưa tồn tại'
	 ELSE IF(EXISTS(SELECT mh_ma FROM dbo.diemmh WHERE mh_ma=@mamh)) PRINT N'môn hoc này còn ràng buộc tới bảng điểm môn học'
	 ELSE IF(EXISTS(SELECT mh_ma FROM dbo.ca_nam WHERE mh_ma=@mamh)) PRINT N'môn hoc này còn ràng buộc tới bảng kì cả năm'
	 ELSE DELETE FROM dbo.mh WHERE mh_ma=@mamh
END
GO
EXEC sp_xoamh 'MH1'


--**********************************************************THỦ THỤC TRUY XUẤT DỮ LIỆU********************************************************


--I. tất cả thông tin tổng hợp của học sinh 

SELECT * FROM dbo.v_tonghop


--II. xuất ra bảng điểm cá nhân theo mã học sinh
--tìm bảng điểm sinh viên HS2
EXEC sp_hstheoma 'HS2'




--III.In bảng điểm theo lớp

EXEC sp_svtheolop 'L1'


--IV. đếm số học sinh trong lớp theo mã
EXEC sP_demsv





--V. in ra sinh viên có điểm tổng kết >=8.0
SELECT khoi.khoi_ten, lop.lop_ma, hs.hs_ma, hs.hs_ten, dbo.ca_nam.ca_nam_dtb, dbo.ca_nam.ca_nam_hocluc, dbo.ca_nam.ca_nam_hk FROM dbo.khoi, dbo.lop, dbo.hs, dbo.ca_nam
WHERE lop.khoi_ma=dbo.khoi.khoi_ma AND dbo.lop.lop_ma=dbo.hs.lop_ma AND hs.hs_ma=dbo.ca_nam.hs_ma AND dbo.ca_nam.ca_nam_dtb>=8.0


--VI. có bao nhiêu học sinh có hạnh kiểm khá


PRINT( N'số học sinh có hạnh kiểm khá là: '+ CONVERT(NVARCHAR, dbo.f_demhkkha()))

--VII. danh sách khối trong trường
SELECT * FROM dbo.khoi

--VIII. Danh sách lớp trong trường
SELECT * FROM dbo.lop

--IX. danh sách học sinh trong trường
SELECT * FROM dbo.hs

--X. bảng điểm 
SELECT * FROM dbo.diemmh

--XI. bảng điểm tổng kết 
SELECT * FROM dbo.ca_nam


--XII. môn học và giáo viên phụ trách
SELECT dbo.gv.gv_ma, dbo.gv.gv_ten, gv.gv_gioitinh, gv.gv_diachi, gv.gv_sdt, dbo.mh.mh_ma, dbo.mh.mh_ten
FROM mh, dbo.gv
WHERE mh.gv_ma=gv.gv_ma


--XIII. hiển thị top 3 sinh viên có điểm cao nhất

SELECT TOP(3) dbo.hs.hs_ma, dbo.hs.hs_ten, lop.lop_ten, dbo.ca_nam.ca_nam_dtb, dbo.ca_nam.ca_nam_hocluc, dbo.ca_nam.ca_nam_hk
FROM dbo.lop, dbo.hs, dbo.ca_nam
WHERE dbo.lop.lop_ma=dbo.hs.lop_ma AND dbo.hs.hs_ma=dbo.ca_nam.hs_ma

--XIV. đếm học sinh học nhiều môn nhất

SELECT hs_ma, COUNT(mh_ma) AS soluong FROM dbo.diemmh
GROUP BY hs_ma
HAVING COUNT(mh_ma)>=ALL
(SELECT COUNT(mh_ma) AS SL FROM dbo.diemmh GROUP BY mh_ma)





SELECT * FROM dbo.khoi
SELECT * FROM dbo.lop
SELECT * FROM dbo.hs
SELECT * FROM dbo.diemmh
SELECT * FROM dbo.mh
SELECT * FROM dbo.ca_nam
SELECT * FROM dbo.gv






