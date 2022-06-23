if exists(select name from sys.databases where name='quanlidiemsv')
drop database quanlidiemsv
go

create database quanlidiemsv
go

use quanlidiemsv
go
--********************************************KHU VỰC TẠO BẢNG******************************************************************8
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
--tao bảng môn học 
create table mon_hoc
(
	mamh char(10) primary key,
	ten_mon_hoc nvarchar(100),
	magv char(10) references giaovien(magv)

)
go
--tạo bảng lớp
create table lop
(
	malop char(10) primary key,
	tenlop nvarchar(100)
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

--them cột cho bảng điểm
alter table diem add hocluc nvarchar(20);
go



--****************************************************KHU VỰC HÀM TÍNH TOÁN, KHÔNG SỬA PHẦN NÀY NHA  **********************************************************

-- tao ham tinh diem trung binh môn
CREATE FUNCTION TB
(	@diem1 float,
	@diem2 float,
	@diem3 float,
	@diem4 float
)
 returns float
 as
 begin
	declare @dtb float
	set @dtb=(@diem1+@diem2+@diem3*2+@diem4*3)/7
	return @dtb
 end;
 go



--tạo hàm trả về học lực ki 1
create function hocluc1
(@dtb float)
returns char(20)
as
begin 
	declare @xet char(10)
	if @dtb>9
	set @xet='xuat sac'
	else if @dtb<9 and @dtb>=8
	set @xet='gioi'
	else if @dtb<8 and @dtb>=6.5
	set @xet='kha'
	else if @dtb<6.5 and @dtb>=5
	set @xet='TB'
	else set @xet='yeu'

	return @xet
end;
go
--***************************************************************KHU VỰC TẠO THỦ TỤC HÀM**************************************************************** 
--thủ tục nhập bảng lớp
create proc sp_nhaplop @malop  char(10), @tenlop nvarchar(100)
as
begin
	if(exists(select *from lop where @malop=malop)) print N'Lớp này đã tồn tại'
	else insert into lop values(@malop, @tenlop)
end
go
 
--thủ tục nhập bảng môn học
create proc sp_nhapmonhoc @mamh char(10), @ten_mon_hoc nvarchar(100), @magv char(10)
as
begin
	if(not exists(select *from giaovien where magv like @magv))  print N'giao viên môn này chưa tồn tại'
	else if(exists(select *from mon_hoc where mamh like @mamh)) print N'môn học này đã tồn tại'
	else insert into mon_hoc values(@mamh, @ten_mon_hoc, @magv)
end
go


--thủ tục nhập bảng giảng viên
create proc sp_nhapgv @magv char(10), @tengv nvarchar(100), @sdt char(15), @diachi nvarchar(100), @gioitinh varchar(15), @email char(50)
as
begin
	if(exists(select *from giaovien where magv like @magv))  print N'giáo viên môn này đã tồn tại tồn tại'
	else insert into giaovien values(@magv, @tengv, @sdt, @diachi, @gioitinh, @email)
end
go
--thủ tục nhập hàm lớp
create proc sp_nhahs @mahs char(10), @tenhs nvarchar(50), @sdt_phuhuynh char(15), @gioitinh varchar(15), @malop char(10)
as
begin
	if(exists(select *from hocsinh where @mahs=mahs)) print N'Sinh viên này đã tồn tại'
	else if(not exists(select * from lop where @malop like malop)) print N'lớp học này chưa tồn tại '
	else insert into hocsinh values(@mahs, @tenhs, @sdt_phuhuynh, @gioitinh, @malop)
end
go
--thủ tục nhập diểm
create proc sp_nhapdiem @mahs char(10), @mamh char(10), @diem_mieng_ki_1 float, @diem_15_ki_1 float , @diem_45_ki_1 float, @diem_cuoiki_ki_1 float, @diem_tb_ki_1 float, @ghichu_ki_1 nvarchar(50),
@hocluc_ki_1 nvarchar(20), @diem_mieng_ki_2 float, @diem_15_ki_2 float, @diem_45_ki_2 float, @diem_cuoiki_ki_2 float, @diem_tb_ki_2 float, @ghichu_ki_2 nvarchar(50), @hocluc_ki_2 nvarchar(20),
@diem_tb_canam float, @hocluc nvarchar(20)
as
begin
	if(exists(select *from diem where mahs like @mahs and mamh like @mamh))	print N'Điểm này đã tồn tại'
	else if(not exists(select * from hocsinh where mahs like @mahs))	print N'Sinh viên này chưa tồn tại, hãy bổ sung thêm tại bảng sinh viên'
	else if(not exists(select * from mon_hoc where mamh like @mamh))	print N'môn học này chưa tồn tại, hay bổ sung thêm môn học này'
	else insert into diem values(@mahs, @mamh, @diem_mieng_ki_1, @diem_15_ki_1, @diem_45_ki_1, @diem_cuoiki_ki_1, @diem_tb_ki_1, @ghichu_ki_1, @hocluc_ki_1,
	@diem_mieng_ki_2, @diem_15_ki_2, @diem_45_ki_2, @diem_cuoiki_ki_2, @diem_tb_ki_2, @ghichu_ki_1, @hocluc_ki_2,@diem_tb_canam, @hocluc)
end
go
--thủ tục xóa dư liệu bảng lớp
create proc sp_xoalop  @malop char(10)
as
begin 
	if(exists(select *from hocsinh where @malop like malop)) print N'lớp học này còn tồn tại ở bảng học sinh, hãy xóa ở đó trước'
	else delete from lop where @malop like malop
end
go

--thủ tuc xóa bảng học sinh
create proc sp_xoahocsinh  @mahs char(10)
as
begin 
	if(exists(select * from diem where @mahs like mahs))	print N'sinh viên đang còn ràng buộc với bảng điểm, hãy xóa ở bảng điểm trước'
	else delete from hocsinh where @mahs like mahs
end
go

--thủ tục xóa bảng giáo viên
create proc sp_xoagiaovien  @magv char(10)
as
begin 
	if(exists(select * from mon_hoc where @magv like magv))	print N'giáo viên đang còn ràng buộc với bảng môn học, hãy xóa ở đó trước'
	else delete from giaovien where @magv like magv
end
go

--thủ tuc xóa môn học
create proc sp_xoamonhoc  @mamh char(10)
as
begin 
	if(exists(select * from diem where @mamh like mamh))	print N'môn học đang còn ràng buộc với bảng điểm, hãy xóa ở đó trước'
	else if(not exists(select * from mon_hoc where @mamh like mamh)) print N'môn học này không tồn tại, hãy nhập lại'
	else delete from mon_hoc where @mamh like mamh
end
go

--thủ tục xóa bảng điểm

create proc sp_xoadiem @mahs char(10), @mamh char(10)
as
begin
	if(not exists(select * from diem where @mahs like mahs or @mamh like mamh))  print N'điểm này không đúng, vui lòng nhập lại'
	else delete from diem where @mahs like mahs and @mamh like mamh
end
go
--thủ tục in thông tin sinh viên theo msv
create proc sp_inthongtin @mahs char(10)
as
begin
	select mahs,tenhs, malop, mamh, diemtrungbinh, hocluc 
	from tim_sinh_vien
	where mahs like @mahs
	--tính điểm trung bình và học lực
	select mahs, tenhs, avg(diemtrungbinh) as dtb from tim_sinh_vien
	group by mahs, tenhs
	having mahs=@mahs
end
go



--***********************************************************TẠO TRIGGER **************************************************************************
--update khi insert dữ liệu vào
create trigger capnhat on diem after insert 
as
begin 
	print'trigger'
	update diem set diem_tb_ki_1=ROUND(dbo.TB(diem_mieng_ki_1 ,diem_15_ki_1, diem_45_ki_1, diem_cuoiki_ki_1), 1);
	update diem set diem_tb_ki_2=round(dbo.TB(diem_mieng_ki_2 ,diem_15_ki_2, diem_45_ki_2, diem_cuoiki_ki_2), 1);
	update diem set diem_tb_canam=ROUND(diem_tb_ki_1+diem_tb_ki_2*2, 1)/3;
	update diem set hocluc_ki_1=dbo.hocluc1(diem_tb_ki_1);
	update diem set hocluc_ki_2=dbo.hocluc1(diem_tb_ki_2);
	update diem set hocluc=dbo.hocluc1(diem_tb_canam);
end
go

--*****************************************************KHU VỰC NHẬP DỮ LIỆU VÀO BẢNG*************************************************************
--nhập bảng lớp 

exec sp_nhaplop '2022_10A', '10A'
exec sp_nhaplop '2022_10B', '10B'
exec sp_nhaplop '2022_10C', '10C'
go

--nhập bảng giáo viên 

exec sp_nhapgv '0001', 'NGUYEN THI PHUONG','0123456789','HAI BA TRUNG','NU','phuong@gmail.com'
exec sp_nhapgv '0002', '','','','',''
exec sp_nhapgv '0003', 'NGUYEN THI THAO','0123456322','HOANG MAI','NU','thao@gmail.com'
exec sp_nhapgv '0004', 'NGUYEN THI HAU','0123456789','HOAN KIEM','NU','hau@gmail.com'
exec sp_nhapgv '0005', 'DAO PHUONG HANG','0123456559','THANH XUAN','NU','hang@gmail.com'
exec sp_nhapgv '0006', 'HA THU THUY ','123456789','HAI BA TRUNG','NU','thuy@gmail.com'
exec sp_nhapgv '0007', 'NGUYEN VIET HUNG ','012784789','QUAN_HAI_BA_CHUNG','NAM','hung@gmail.com'
go

--nhập bảng môn học
exec sp_nhapmonhoc 'TA', N'Tiếng Anh', '0001'
exec sp_nhapmonhoc 'GDCD', N'Giáo dục công dân', '0002'
exec sp_nhapmonhoc 'TO', N'Toán', '0003'
exec sp_nhapmonhoc 'VA', N'Văn', '0004'
exec sp_nhapmonhoc 'SI', N'Sinh', '0005'
exec sp_nhapmonhoc 'LI', N'Lí', '0006'
exec sp_nhapmonhoc 'HO', N'Hóa', '0007'
go

--nhập bảng học sinh
--nhập học sinh lớp 10A
exec sp_nhahs '00001', 'NGUYEN THI DIU','0987654321','NU','2022_10A'
exec sp_nhahs '00002', 'NGUYEN VAN DUNG','0982394743','NAM','2022_10A'
exec sp_nhahs '00003', 'DANG THI HONG NHUNG','0456372819','NU','2022_10A'
exec sp_nhahs '00004', 'HOANG MINH KHAI','0234561789','NAM','2022_10A'
exec sp_nhahs '00005', 'TRAN NGOC NHI','0456123789','NU','2022_10A'
go


--nhập học sinh lớp 10B
exec sp_nhahs '00006', 'TRAN VAN QUYET','0555567749','NAM','2022_10B'
exec sp_nhahs '00007', 'NGUYEN THAY HUAN','0678912345','NAM','2022_10B'
exec sp_nhahs '00008', 'TRAN VAN DAN','0987612345','NAM','2022_10B'
exec sp_nhahs '00009', 'NGUYEN THI THANH TU','0654783921','NU','2022_10B'
exec sp_nhahs '00010', 'NGUYEN VAN AI','0999666777','KHONG RO','2022_10B'
go  


--nhập học sinh lớp 10C
exec sp_nhahs '00011', 'NGUYEN VAN CO','0888888888','NAM','2022_10C'
exec sp_nhahs '00012', 'NGUYEN THI BAP','0555555555','NU','2022_10C'
exec sp_nhahs '00013', 'PHAM TRAM LOI','0123456789','NAM','2022_10C'
exec sp_nhahs '00014', 'LY THANH MINH','0234561789','NAM','2022_10C'
exec sp_nhahs '00015', 'TRAN BOC BACH','0765432198','NU','2022_10C'
go  

--nhập bảng điểm
--nhập điểm học sinh lớp 10A
exec sp_nhapdiem '00001','VA',8.5,8.0,8.5,8.5, 0,'tot',NULL,8.0,8.0,8.0,9.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00001','TA',8.5,8.0,8.5,8.0, 0,'tot',NULL,8.5,8.0,8.5,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00001','GDCD',8.5,9.5,8.5,9.5, 0,'tot',NULL,8.5,8.5,8.0,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00002','GDCD',9.0,9.5,9.0,9.5, 0,'tot',NULL,9.0,8.0,8.5,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00002','VA',8.0,8.5,9.0,9.5, 0,'tot',NULL,8.5,8.0,8.5,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00002','TO',8.0,8.5,8.0,8.5, 0,'tot',NULL,8.0,9.0,9.5,10, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00003','GDCD',9.0,9.5,9.0,9.5, 0,'tot',NULL,9.0,9.5,9.5,9.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00003','LI',8.5,8.5,8.0,8.5, 0,'tot',NULL,8.0,8.0,8.5,8.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00003','TA',8.0,8.5,8.5,8.5, 0,'tot',NULL,8.0,8.0,9.5,9.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00004','TO',10.0,10.0,9.5,10.0, 0,'tot',NULL,10.0,9.5,10.0,10.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00004','VA',8.0,9.5,9.0,8.5, 0,'tot',NULL,10.0,8.5,9.0,10.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00004','TA',8.0,8.5,9.0,9.5, 0,'tot',NULL,8.0,9.0,9.5,9.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00005','TO',8.0,8.5,9.0,8.5, 0,'tot',NULL,8.0,9.0,9.5,10, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00005','VA',7.5,8.5,9.0,9.5, 0,'tot',NULL,8.0,9.0,9.5,9.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00005','SI',9.0,9.5,8.0,9.5, 0,'tot',NULL,9.0,8.0,9.5,9.0, 0,'tot',NULL, 0,NULL
go


--nhập điểm học sinh lớp 10B
exec sp_nhapdiem '00006','VA',8.5,9.0,8.5,9.5, 0,'tot',NULL,8.0,9.0,9.0,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00006', 'TA',7.5,8.0,8.5,9.0, 0,'tot',NULL,8.5,8.0,8.5,9.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00006','GDCD',3.5,2.5,3.2,4.5, 0,'kha',NULL,5.5,3.5,4.0,4.5, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00007', 'GDCD',9.0,9.5,9.0,9.5, 0,'kha',NULL,9.0,8.0,7.5,9.5, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00007', 'VA',8.0,8.5,9.0,9.5, 0,'kha',NULL,8.5,8.0,7.5,7.5, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00007', 'TO',8.0,8.5,8.0,8.5, 0,'tot',NULL,8.0,9.0,9.5,10, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00008', 'LI',8.5,8.5,8.0,8.5, 0,'tot',NULL,8.0,8.0,8.5,8.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00008', 'GDCD',9.0,9.5,9.0,9.5, 0,'tot',NULL,9.0,9.5,9.5,9.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00008', 'TA',2.0,3.5,2.5,2.5, 0,'tot',NULL,2.0,3.0,3.5,5.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00009', 'TO',10.0,10.0,9.5,10.0, 0,'tot',NULL,10.0,9.5,10.0,10.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00009', 'VA',8.0,9.5,9.0,8.5, 0,'tot',NULL,10.0,8.5,9.0,10.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00009', 'TA',8.0,8.5,9.0,9.5, 0,'tot',NULL,8.0,9.0,9.5,9.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00010', 'TO',8.0,8.5,9.0,8.5, 0,'tot',NULL,8.0,9.0,9.5,10, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00010', 'VA',7.5,8.5,9.0,9.5, 0,'tot',NULL,8.0,9.0,9.5,9.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00010', 'SI',9.0,9.5,8.0,9.5, 0,'tot',NULL,9.0,8.0,9.5,9.0, 0,'tot',NULL, 0,NULL
go



--nhập điểm học sinh lớp 10C
exec sp_nhapdiem '00011', 'SI',9.0,8.5,8.5,9.0, 0,'tot',NULL,8.5,8.0,9.0,9.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00011', 'GDCD',8.5,8.0,8.5,8.0, 0,'tot',NULL,8.5,8.0,8.5,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00011', 'TO',5.5,5.5,6.5,6.5, 0,'tot',NULL,6.0,6.5,7.0,6.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00012', 'SI',9.0,9.5,9.0,9.5, 0,'tot',NULL,9.0,8.0,8.5,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00012', 'GDCD',8.0,8.5,9.0,9.5, 0,'tot',NULL,8.5,8.0,8.5,8.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00012', 'TO',5.0,5.5,6.0,6.5, 0,'tot',NULL,5.0,6.0,7.5,7.0, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00013', 'GDCD',5.0,5.5,5.0,5.5, 0,'kha',NULL,5.0,5.5,5.5,5.0, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00013', 'TA',6.5,6.5,6.0,6.5, 0,'kha',NULL,6.0,6.0,6.5,6.0, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00013', 'HO',5.0,4.5,4.5,5.5, 0,'kha',NULL,4.0,5.0,5.5,4.5, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00014', 'VA',10.0,10.0,9.5,10.0, 0,'kha',NULL,10.0,9.5,10.0,10.0, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00014', 'TA',8.0,9.5,9.0,8.5, 0,'kha',NULL,10.0,8.5,9.0,10.0, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00014', 'GDCD',5.0,5.5,5.0,5.5, 0,'kha',NULL,5.0,5.0,5.5,5.0, 0,'kha',NULL, 0,NULL
exec sp_nhapdiem '00015', 'TO',8.0,8.5,9.0,8.5, 0,'tot',NULL,8.0,9.0,9.5,10, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00015', 'VA',6.5,6.5,7.0,7.5, 0,'tot',NULL,6.0,6.0,7.5,6.5, 0,'tot',NULL, 0,NULL
exec sp_nhapdiem '00015', 'LI',8.0,8.5,8.0,8.5, 0,'tot',NULL,8.0,8.0,7.5,9.0, 0,'tot',NULL, 0,NULL
go

--***************************************************KHU VỰC TRUY XUẤT DỮ LIỆU******************************************************************

--**********TẠO VIEW****************

--tạo bảng view thông tin cụ thể sinh viên
create view tim_sinh_vien
as
	select hocsinh.mahs, tenhs, gioitinh, malop, mamh, diem_tb_canam as diemtrungbinh, hocluc
	from hocsinh, diem
	where diem.mahs like hocsinh.mahs
go
--tạo bảng view thông tin chung cho sinh viên
create view sinhvientong
as
	select mahs, tenhs, gioitinh, malop, round(avg(diemtrungbinh), 1) as dtb from tim_sinh_vien
	group by mahs, tenhs, gioitinh, malop
go
select * from sinhvientong
--************CÁC THỦ TỤC TRUY VẤN**********************
--1. in ra học lực sinh viên
--tìm học sinh có mã học sinh 00001
	exec sp_inthongtin '00001'

--2. in ra điểm tổng kết của tất cả sinh viên theo thứ tự giảm dần
	select mahs, tenhs, round(avg(diemtrungbinh), 1) as dtb from tim_sinh_vien
	group by mahs, tenhs
	order by dtb desc  --sắp xếp giảm dần, nếu tăng dần asc
--3. in ra sinh viên có điểm tổng kết lớn hơn 8
	select * from sinhvientong where dtb>8
--4. in ra sinh viên có điểm tổng kết nhỏ hơn hoặc bằng 8
	select * from sinhvientong where dtb<=8
--5. đếm số sinh viên có điểm lớn hơn 7.5
	select COUNT(mahs)	as songuoi from sinhvientong
	where dtb>7.5
--6. 
select * from lop
select * from giaovien
select * from hocsinh
select * from mon_hoc
select * from diem
