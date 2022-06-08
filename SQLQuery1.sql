﻿create database quanlidiemsv
go

use quanlidiemsv
go

create table lop
(
	malop char(10) primary key,
	tenlop nvarchar(100)
)
go
--tạo bảng thông tin giaovien
create table giaovien
(	
	magv char(10) primary key NOT NULL,
	tengv nvarchar(50),
	sdt char(15),
	diachi nvarchar(100),
	gioitinh varchar(15),
	email char(50)
)
go

-- tạo bảng học sinh 
create table hocsinh
(
	mahs char(10) primary key NOT NULL,
	tenhs nvarchar(50),
	sdt_phuhuynh char(15),
	gioitinh varchar(15),
	malop char(10) references lop(malop),
)
go

--tao bảng điểm 

create table diem
(

	mahs char(10) references hocsinh(mahs),
	malop char(10) references lop(malop),
	mamh char(10) references mon_hoc(mamh),
--ki1
	diem_mieng_ki_1 float,
	diem_15_ki_1 float,
	diem_45_ki_1 float,
	diem_cuoiki_ki_1 float,
	diem_tb_ki_1 float,
	ghichu_ki_1 nvarchar(50),
	hocluc_ki_1 nvarchar(20),
--ki2
	diem_mieng_ki_2 float,
	diem_15_ki_2 float,
	diem_45_ki_2 float,
	diem_cuoiki_ki_2 float,
	diem_tb_ki_2 float,
	ghichu_ki_2 nvarchar(50),
	hocluc_ki_2 nvarchar(20),
--canam
	diem_tb_canam float
)
go

--tao bảng môn học 
create table mon_hoc
(
	mamh char(10) primary key,
	ten_mon_hoc nvarchar(15),
	magv char(10) references giaovien(magv)

)
go

-- tao ham tinh diem trung binh môn học
 create function dtb
 (@ma_mh char(10), @diem1 float, @diem2 float, @diem3 float)
 return float
 as
 begin
	@dtb
 end


  select *from diem

--nhập bảng lớp 
insert LOP values
('2022_10A', '10A'),
('2022_10B', '10B');


--nhập bảng giáo viên 
insert giaovien values
('0001', 'NGUYEN THI PHUONG','0123456789','HAI BA TRUNG','NU','phuong@gmail.com'),
('0002', '','','','','');
insert giaovien values
('0003', 'NGUYEN THI THAO','0123456322','HOANG MAI','NU','thao@gmail.com'),
('0004', 'NGUYEN THI HAU','0123456789','HOAN KIEM','NU','hau@gmail.com'),
('0005', 'DAO PHUONG HANG','0123456559','THANH XUAN','NU','hang@gmail.com'),
('0006', 'HA THU THUY ','123456789','HAI BA TRUNG','NU','thuy@gmail.com'),
('0007', 'NGUYEN VIET HUNG ','012784789','QUAN_HAI_BA_CHUNG','NAM','hung@gmail.com');


--nhập bảng học sinh
insert hocsinh values
('00001', 'NGUYEN THI DIU','0987654321','NU','2022_10A')
;
--nhập bảng môn học

insert mon_hoc values
('TA', N'Tiếng Anh', '0001'),
('GDCD', N'Giáo dục công dân', '0002');
insert mon_hoc values
('TO', N'Toán', '0003'),
('VA', N'Văn', '0004'),
('SI', N'Sinh', '0005'),
('LI', N'Lí', '0006'),
('HO', N'Hóa', '0007');

--nhập bảng điểm

insert diem values
('00001', '2022_10A','TA','1','2','3','4','5','tot','gioi','1','2','3','4','5','tot','gioi', 9);

select * from lop
select * from giaovien
select * from hocsinh
select * from mon_hoc
select * from diem
