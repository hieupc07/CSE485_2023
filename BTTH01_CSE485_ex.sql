#a
SELECT * from baiviet,theloai  WHERE baiviet.ma_tloai = theloai.ma_tloai and theloai.ten_tloai = "Nhạc trữ tình";
#b
SELECT * FROM baiviet,tacgia WHERE baiviet.ma_tgia = tacgia.ma_tgia and tacgia.ten_tgia = "Nhacvietplus";
#c
SELECT theloai.ten_tloai
FROM theloai
LEFT JOIN baiviet ON theloai.ma_tloai = baiviet.ma_tloai
WHERE baiviet.ma_tloai IS NULL;
#d
SELECT baiviet.ma_bviet, baiviet.tieude, baiviet.ten_bhat, tacgia.ten_tgia, theloai.ten_tloai, baiviet.ngayviet FROM baiviet,tacgia,theloai 
where baiviet.ma_tgia = tacgia.ma_tgia and baiviet.ma_tloai = theloai.ma_tloai;
#e
SELECT theloai.ten_tloai, COUNT(*) AS soLuong
FROM baiviet,theloai where baiviet.ma_tloai = theloai.ma_tloai
GROUP BY theloai.ten_tloai
ORDER BY soLuong DESC
LIMIT 1;

SELECT theloai.ten_tloai, COUNT(*) AS so_bai_viet
FROM baiviet
INNER JOIN theloai ON baiviet.ma_tloai = theloai.ma_tloai
GROUP BY baiviet.ma_tloai
HAVING COUNT(*) = (SELECT COUNT(*) AS so_bai_viet
                   FROM baiviet
                   GROUP BY ma_tloai
                   ORDER BY so_bai_viet DESC
                   LIMIT 1);
#f
SELECT tacgia.ten_tgia, COUNT(*) AS soLuong
FROM baiviet,tacgia where baiviet.ma_tgia = tacgia.ma_tgia
GROUP BY tacgia.ma_tgia
ORDER BY soLuong DESC
LIMIT 2;

#g
SELECT * FROM baiviet
WHERE ten_bhat LIKE "%yêu%" or ten_bhat LIKE "%thương%" or ten_bhat LIKE "%anh%" or ten_bhat LIKE "%em%";

#h
SELECT * FROM baiviet
WHERE tieude LIKE "%yêu%" or tieude LIKE "%thương%" or tieude LIKE "%anh%" or tieude LIKE "%em%" 
or ten_bhat LIKE "%yêu%" or ten_bhat LIKE "%thương%" or ten_bhat LIKE "%anh%" or ten_bhat LIKE "%em%";

SELECT *
FROM baiviet
WHERE ten_bhat REGEXP 'yêu|thương|anh|em'
   OR tieude REGEXP 'yêu|thương|anh|em';

#i
CREATE VIEW vw_Music AS 
SELECT baiviet.ma_bviet,baiviet.tieude,baiviet.ten_bhat,baiviet.tomtat,baiviet.noidung,baiviet.ngayviet,baiviet.hinhanh,theloai.ten_tloai,tacgia.ten_tgia
FROM baiviet 
JOIN theloai ON baiviet.ma_tloai = theloai.ma_tloai
JOIN tacgia ON baiviet.ma_tgia = tacgia.ma_tgia;


#j

DELIMITER //
CREATE PROCEDURE sp_DSBaiViet (IN tenTL VARCHAR(50))
BEGIN
   DECLARE maTL varchar(50);
   SELECT ma_tloai INTO maTL FROM theloai WHERE ten_tloai = tenTL;
   IF maTL IS NULL THEN
      SELECT 'Khong tim thay the loai ' AS 'Error';
   ELSE
      SELECT baiviet.ma_bviet, baiviet.tieude, tacgia.ten_tgia 
      FROM baiviet 
      JOIN tacgia ON baiviet.ma_tgia = tacgia.ma_tgia 
      WHERE baiviet.ma_tloai = maTL;
   END IF;
END//

DELIMITER ;
#gọi procedure
CALL sp_DSBaiViet('Rock')



#k
ALTER TABLE theloai ADD SLBaiViet INT DEFAULT 0;
UPDATE theloai 
SET SLBaiViet = (
  SELECT COUNT(*) FROM baiviet 
  WHERE baiviet.ma_tloai = theloai.ma_tloai
  GROUP BY baiviet.ma_tloai
);

DELIMITER //
CREATE TRIGGER tg_CapNhatTheLoai AFTER INSERT ON baiviet FOR EACH ROW
BEGIN
    IF (NEW.ma_tloai IS NOT NULL) THEN
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = NEW.ma_tloai) WHERE ma_tloai = NEW.ma_tloai;
    END IF;
END;

DELIMITER //
CREATE TRIGGER tg_CapNhatTheLoai_2 AFTER UPDATE ON baiviet FOR EACH ROW
BEGIN
    IF (NEW.ma_tloai != OLD.ma_tloai AND OLD.ma_tloai IS NOT NULL) THEN
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = NEW.ma_tloai) WHERE ma_tloai = NEW.ma_tloai;
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = OLD.ma_tloai) WHERE ma_tloai = OLD.ma_tloai;
    ELSEIF (NEW.ma_tloai IS NULL AND OLD.ma_tloai IS NOT NULL) THEN
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = OLD.ma_tloai) WHERE ma_tloai = OLD.ma_tloai;
    ELSEIF (NEW.ma_tloai IS NOT NULL AND OLD.ma_tloai IS NULL) THEN
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = NEW.ma_tloai) WHERE ma_tloai = NEW.ma_tloai;
    ELSEIF (NEW.ma_tloai IS NOT NULL AND OLD.ma_tloai IS NOT NULL AND NEW.ma_tloai = OLD.ma_tloai) THEN
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = NEW.ma_tloai) WHERE ma_tloai = NEW.ma_tloai;
    ELSEIF (NEW.ma_tloai IS NOT NULL AND OLD.ma_tloai IS NOT NULL AND NEW.ma_tloai != OLD.ma_tloai) THEN
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = NEW.ma_tloai) WHERE ma_tloai = NEW.ma_tloai;
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = OLD.ma_tloai) WHERE ma_tloai = OLD.ma_tloai;
    END IF;
END;//

DELIMITER ;

DELIMITER //
CREATE TRIGGER tg_CapNhatTheLoai_3 AFTER DELETE ON baiviet FOR EACH ROW
BEGIN
    IF (OLD.ma_tloai IS NOT NULL) THEN
        UPDATE theloai SET SLBaiViet = (SELECT COUNT(*) FROM baiviet WHERE ma_tloai = OLD.ma_tloai) WHERE ma_tloai = OLD.ma_tloai;
    END IF;
END;//

DELIMITER ;

#l
CREATE TABLE `btth01_cse485`.`users` (
	`username` VARCHAR(50) NOT NULL , 
	`pass_word` VARCHAR(20) NOT NULL , 
	`fullname` VARCHAR(50) NOT NULL , 
	`age` INT NOT NULL , 
	`access` VARCHAR(10) NOT NULL DEFAULT 'user' , 
	PRIMARY KEY (`username`)) 
	ENGINE = InnoDB;
INSERT INTO `users` (`username`, `pass_word`, `fullname`, `age`, `access`) 
	VALUES ('admin', 'admin6868', 'Admin', '22', 'admin'), 
	('0343282228', 'quangthai1704', 'Nguyễn Quang Thái', '21', 'user');