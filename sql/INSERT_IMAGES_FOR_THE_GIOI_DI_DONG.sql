DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_IMAGES_FOR_THE_GIOI_DI_DONG;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_IMAGES_FOR_THE_GIOI_DI_DONG(in product_id_val int, in data text)
BEGIN
    DECLARE image_val VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    -- 1. Thay đổi các ký tự đặc biệt.
    SET data = REPLACE(REPLACE(REPLACE(data, 'NONE', '\'*\''), '"', ''), '\'', '"');

    -- 2. Kiểm tra có đúng với định dạng json không
    IF JSON_VALID(data) = 1
    THEN
        -- 2.1 Đêm số phần từ trong mảng json
        SET n = JSON_LENGTH(data);
    END IF;

    -- 3. Lặp qua từng phần tử trong mảng json
    WHILE i < n
        DO
            -- 3.1. Lấy dữ liệu hình
            SET image_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']')));

            -- 3.2. Kiểm tra có phải dữ liệu hình không
            IF image_val != '*' THEN
                -- 3.2.1. Thêm 1 dòng dữ liệu hình
                INSERT INTO data_warehouse_staging.product_the_gioi_di_dong_images_staging(product_id, image_url)
                VALUES (product_id_val, image_val);
            END IF;

            SET i = i + 1;
            SET image_val = '';
        END WHILE;


END;

DELIMITER ;

