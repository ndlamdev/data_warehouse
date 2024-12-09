DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_PRICES_FOR_THE_GIOI_DI_DONG;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_PRICES_FOR_THE_GIOI_DI_DONG(in product_id_val int, in data text)
BEGIN
    DECLARE color_val VARCHAR(50) DEFAULT '';
    DECLARE price_base_val double DEFAULT 0;
    DECLARE discount_val double DEFAULT 0;
    DECLARE status_val VARCHAR(50);
    DECLARE desk_val VARCHAR(50) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    -- 1. Thay đổi các ký tự đặc biệt.
    SET data = REPLACE(REPLACE(REPLACE(REPLACE(data, 'NONE', '\'*\''), '"', ''), '"', ''), '\'', '"');

    -- 2. Kiểm tra có phải định dạng json không
    IF JSON_VALID(data) = 1
    THEN
        -- 2.1 Đêm số phần từ trong mảng json
        SET n = JSON_LENGTH(data);
    END IF;

    -- 3. Lặp qua từng phần tử trong mảng json
    WHILE i < n
        DO
            -- 3.1 Lấy màu
            SET color_val = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].color'))), '');
            -- 3.2 Lấy bộ nhớ
            SET desk_val = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].desk'))), '');
            -- 3.3 lấy giá gốc
            SET @price_base_val_temp =
                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                                                            JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].price_base'))),
                                                            'đ', ''), '.', ''), '*', ''), '"', ''), '₫', '');

            -- 3.4 Lấy giá giảm
            SET @discount_val_temp =
                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                                                            JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].discount'))),
                                                            'đ', ''), '.', ''), '*', ''), '"', ''), '₫', '');

            -- 3.5 Lấy trạng thái
            SET status_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].status')));

            -- 3.6 Kiểm tra trong màu có số không
            IF color_val REGEXP '[0-9]' THEN
                SET @temp = desk_val;
                SET desk_val = color_val;
                SET color_val = @temp;
            END IF;

            -- 3.7. Kiểm tra trong giá giảm có số không
            IF @discount_val_temp REGEXP '[0-9]' THEN
                -- 3.7.1. Ép kiểu dữ liệu thành số
                SET discount_val = cast(@discount_val_temp as double);
                -- 3.7.2. Số giá giảm thành 0
                SET discount_val = 0.0;
            END IF;

            -- 3.8. Kiểm tra trong giá gốc có số không
            IF @price_base_val_temp REGEXP '[0-9]' THEN
                -- 3.8.1. Ép kiểu dữ liệu thành số
                SET price_base_val = cast(@price_base_val_temp as double);
            ELSE
                -- 3.8.2. Số giá giảm thành 0
                SET price_base_val = 0.0;
            END IF;

            -- 3.9 Kiểm tra giá giảm có lớn hơn giá gốc không
            IF discount_val > price_base_val
            THEN
                SET @TEMP = price_base_val;
                SET price_base_val = discount_val;
                SET discount_val = @TEMP;
            END IF;

            -- 3.10.1. Set trạng thái thành hết hàng
            IF price_base_val = 0 AND (status_val is not null OR status_val != '') THEN
                -- 3.10.1. Set trạng thái thành hết hàng
                SET status_val = 'Hết hàng';
            ELSE
                -- 3.10.2. Set trạng thái thành còn hàng
                SET status_val = 'Còn hàng';
            END IF;

            -- 3.11. Chèn vào bảng prices
            INSERT INTO data_warehouse_staging.product_the_gioi_di_dong_prices_staging (product_id, color, desk, price_base, discount, status)
            VALUES (product_id_val, color_val, desk_val, price_base_val, discount_val,
                    status_val);

            SET i = i + 1;
            SET desk_val = '';
            SET color_val = '';
            set price_base_val = 0.0;
            set discount_val = 0.0;
            SET status_val = '';
        END WHILE;


END;

DELIMITER ;

