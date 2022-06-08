create database quanlidiemsv
go

use quanlidiemsv
go

create table lop
(
	malop char(10) primary key,
	tenlop nvarchar(100)
)
go
--tạo bảng thông tin giang vien
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
	malop char(10),
)
go

--tao bảng điểm kỳ 1

create table diem_ky1
(
	mahs char(15) references hocsinh(mahs),
	malop char(15) references lop(malop),
	diemhs1 float,
	diemhs2 float,
	diemhs3 float,
	hanhkiem varchar(50),
	ghichu
)
go

--tạo bảng điểm kỳ 2
