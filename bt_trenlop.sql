create database qlktx
go
use qlktx
go

create table NV( 
	manv char(10) primary key NOT NULL,
	hoten nvarchar(30),
	ngaysinh date ,
	gioitinh nchar(5),
	dt int)
go
create table ktx(
	maktx char(10) primary key NOT NULL,
	tenktx char(10),
	manv char(10) references NV(manv),
	slphong int)
go
create table Phong(
	maphong char(10) primary key NOT NULL,
	maktx char(10)references ktx(maktx),
	slot int check(slot<15))
go
create table SV(
	masv char(10) primary key NOT NULL,
	hoten nvarchar(30),
	lop char(10),
	khoa varchar(50),
	ngaysinh date,
	gioitinh nchar(5))
go
create table phanphong(
	namhoc char(5),
	maphong char(10) references Phong(maphong),
	masv char(10) references SV(masv),
	tungay date,
	denngay date)
go

create 
