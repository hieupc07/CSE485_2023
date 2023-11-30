--Liệt kê các bài viết thuộc thể loại chữ tình
SELECT * FROM baiviet
WHERE ma_tloai = (SELECT ma_tloai FROM theloai WHERE ten_tloai = 'Nhạc trữ tình');

--Liệt kê các bài viết của tác giả "Nhacvietplus"
SELECT * FROM baiviet
WHERE ma_tgia = (SELECT ma_tgia FROM tacgia WHERE ten_tgia = 'Nhacvietplus');

--Liệt kê các thể loại nhạc chưa có bài viết cảm nhận nào.
SELECT * FROM theloai
WHERE ma_tloai NOT IN (SELECT DISTINCT ma_tloai FROM baiviet WHERE noidung IS NOT NULL);

--Liệt kê các bài viết với các thông tin sau: mã bài viết, tên bài viết, tên bài hát, tên tác giả, tên thể loại, ngày viết.
SELECT b.ma_bviet, b.tieude, b.ten_bhat, t.ten_tgia, tl.ten_tloai, b.ngayviet
FROM baiviet b
JOIN tacgia t ON b.ma_tgia = t.ma_tgia
JOIN theloai tl ON b.ma_tloai = tl.ma_tloai;

--Tìm thể loại có số bài viết nhiều nhất 
SELECT ma_tloai, COUNT(ma_bviet) AS so_baiviet
FROM baiviet
GROUP BY ma_tloai
ORDER BY so_baiviet DESC
LIMIT 1;

--Liệt kê 2 tác giả có số bài viết nhiều nhất 
SELECT ma_tgia, COUNT(ma_bviet) AS so_baiviet
FROM baiviet
GROUP BY ma_tgia
ORDER BY so_baiviet DESC
LIMIT 2;

--Liệt kê các bài viết về các bài hát có tựa bài hát chứa 1 trong các từ “yêu”, “thương”, “anh”, “em”
SELECT * FROM baiviet
WHERE ten_bhat LIKE '%yêu%' OR ten_bhat LIKE '%thương%' OR ten_bhat LIKE '%anh%' OR ten_bhat LIKE '%em%';

--Liệt kê các bài viết về các bài hát có tiêu đề bài viết hoặc tựa bài hát chứa 1 trong các từ “yêu”, “thương”, “anh”, “em” 
SELECT * FROM baiviet
WHERE tieude LIKE '%yêu%' OR tieude LIKE '%thương%' OR tieude LIKE '%anh%' OR tieude LIKE '%em%'
   OR ten_bhat LIKE '%yêu%' OR ten_bhat LIKE '%thương%' OR ten_bhat LIKE '%anh%' OR ten_bhat LIKE '%em%';

--Tạo 1 view có tên vw_Music để hiển thị thông tin về Danh sách các bài viết kèm theo Tên thể loại và tên tác giả 
CREATE VIEW vw_Music AS
SELECT b.ma_bviet, b.tieude, b.ten_bhat, t.ten_tgia, tl.ten_tloai, b.ngayviet
FROM baiviet b
JOIN tacgia t ON b.ma_tgia = t.ma_tgia
JOIN theloai tl ON b.ma_tloai = tl.ma_tloai;

--Tạo 1 thủ tục có tên sp_DSBaiViet với tham số truyền vào là Tên thể loại và trả về danh sách Bài viết của thể loại đó. Nếu thể loại không tồn tại thì hiển thị thông báo lỗi. 
DELIMITER //
CREATE PROCEDURE sp_DSBaiViet (IN tenTheLoai VARCHAR(50))
BEGIN
    SELECT * FROM baiviet
    WHERE ma_tloai = (SELECT ma_tloai FROM theloai WHERE ten_tloai = tenTheLoai);
END //
DELIMITER ;

--Thêm mới cột SLBaiViet vào trong bảng theloai. Tạo 1 trigger có tên tg_CapNhatTheLoai để khi thêm/sửa/xóa bài viết thì số lượng bài viết trong bảng theloai được cập nhật theo.
ALTER TABLE theloai ADD COLUMN SLBaiViet INT UNSIGNED DEFAULT 0;

-- Tạo trigger tg_CapNhatTheLoai
DELIMITER //
CREATE TRIGGER tg_CapNhatTheLoai
AFTER INSERT ON baiviet
FOR EACH ROW
BEGIN
    UPDATE theloai
    SET SLBaiViet = SLBaiViet + 1
    WHERE ma_tloai = NEW.ma_tloai;
END //
DELIMITER ;

--Bổ sung thêm bảng Users để lưu thông tin Tài khoản đăng nhập và sử dụng cho chức năng Đăng nhập/Quản trị trang web
CREATE TABLE users (
    user_id INT UNSIGNED NOT NULL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
