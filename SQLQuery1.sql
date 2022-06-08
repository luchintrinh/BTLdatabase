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

	mahs char(15) references hocsinh(mahs),
	malop char(15) references lop(malop),
	ten_mon_hoc nvarchar(15) references mon_hoc(ten_mon_hoc),
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
	diem_tb_canam float,




)
go

--tao bảng môn học 
create table mon_hoc
(
	ten_mon_hoc nvarchar(15),
	magv char(10) references giaovien(magv)

)
go


  

--nhập bảng lớp 
insert LOP values
('2022_10A', '10A'),
('2022_10B', '10B');


--nhập bảng giáo viên 
insert giaovien values
('0001', 'NGUYEN THI PHUONG','0123456789','QUAN_HAI_BA_CHUNG','NU','phuong@gmail.com'),
('0002', '','','','','');


--nhập bảng học sinh
insert hocsinh values
('00001', 'NGUYEN THI DIU','0987654321','NU','2022_10A'),
('00002', '','','','');

--nhập bảng điểm
insert diem values
('00001', '2022_10A','TOAN','1','2','3','4','5','tot','gioi','1','2','3','4','5','tot','gioi','diem_tb_canam'),
('00002',  '2022_10A','TOAN','1','2','3','4','5','tot','gioi','1','2','3','4','5','tot','gioi','diem_tb_canam' );




