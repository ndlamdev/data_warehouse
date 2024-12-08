DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_SPECIFICATION_FOR_THE_GIOI_DI_DONG;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_SPECIFICATION_FOR_THE_GIOI_DI_DONG(in product_id_val int, in data text)
BEGIN
    DECLARE before_camera_val VARCHAR(255) DEFAULT '';
    DECLARE after_camera_val VARCHAR(255) DEFAULT '';
    DECLARE battery_capacity_val VARCHAR(255) DEFAULT '';
    DECLARE os_val VARCHAR(255) DEFAULT '';
    DECLARE chipset_val VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    -- 1. Thay đổi các ký tự đặc biệt.
    SET data = REPLACE(REPLACE(data, '"', ''), '\'', '"');

    -- 2. Kiểm tra có đúng với định dạng json không
    IF JSON_VALID(data) = 1
    THEN
        -- 2.1 Đêm số phần từ trong mảng json
        SET n = JSON_LENGTH(data);
    ELSE
        -- 2.2 Cập nhật thông số kĩ thuật thành string emty
        UPDATE data_warehouse_staging.products_the_gioi_di_dong_staging
        SET before_camera    = before_camera_val,
            after_camera     = after_camera_val,
            battery_capacity = battery_capacity_val,
            os               = os_val,
            chipset          = chipset_val
        WHERE id = product_id_val;
    END IF;

    -- 3. Lặp qua từng phần tử trong mảng json
    read_loop:
    WHILE i < n
        DO
            -- 3.1. Lấy dữ liệu camera trước
            SET before_camera_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Độ phân giải camera trước:"')));

            -- 3.2. Kiểm tra dữ liệu có phải null không
            IF before_camera_val IS NOT NULL THEN
                -- 3.2.1. Thoát vòng lặp
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    -- 4. Lặp qua từng phần tử trong mảng json
    read_loop:
    WHILE i < n
        DO
            -- 4.1. Lấy dữ liệu camera sau
            SET after_camera_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Độ phân giải camera sau:"')));

            -- 4.2. Kiểm tra dữ liệu có phải null không
            IF after_camera_val IS NOT NULL THEN
                -- 4.2.1. Thoát vòng lặp
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    -- 5. Lặp qua từng phần tử trong mảng json
    read_loop:
    WHILE i < n
        DO
            -- 5.1. Dung lượng Pin
            SET battery_capacity_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Dung lượng pin:"')));

            -- 5.2. Kiểm tra dữ liệu có phải null không
            IF battery_capacity_val IS NOT NULL THEN
                -- 5.2.1. Thoát vòng lặp
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    -- 6. Lặp qua từng phần tử trong mảng json
    read_loop:
    WHILE i < n
        DO
            -- 6.1. Lấy dữ hệ điều hành
            SET os_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Hệ điều hành:"')));

            -- 6.2. Kiểm tra dữ liệu có phải null không
            IF os_val IS NOT NULL THEN
                -- 6.2.1. Thoát vòng lặp
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    -- 7. Lặp qua từng phần tử trong mảng json
    read_loop:
    WHILE i < n
        DO
            -- 7.1. Lấy dữ liệu chipset
            SET chipset_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Chip xử lý (CPU):"')));

            -- 7.2. Kiểm tra dữ liệu có phải null không
            IF chipset_val IS NOT NULL THEN
                -- 7.2.1. Thoát vòng lặp
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    -- 8. Cập nhật dữ liệu thông số kỹ thuật
    UPDATE data_warehouse_staging.products_the_gioi_di_dong_staging
    SET before_camera    = before_camera_val,
        after_camera     = after_camera_val,
        battery_capacity = battery_capacity_val,
        os               = os_val,
        chipset          = chipset_val
    WHERE id = product_id_val;
END;

DELIMITER ;
