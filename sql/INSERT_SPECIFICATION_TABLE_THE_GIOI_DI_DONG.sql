DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_SPECIFICATION_TABLE_THE_GIOI_DI_DONG;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_SPECIFICATION_TABLE_THE_GIOI_DI_DONG(in product_id_val int, in data text)
BEGIN
    DECLARE before_camera_val VARCHAR(255) DEFAULT '';
    DECLARE after_camera_val VARCHAR(255) DEFAULT '';
    DECLARE battery_capacity_val VARCHAR(255) DEFAULT '';
    DECLARE os_val VARCHAR(255) DEFAULT '';
    DECLARE chipset_val VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    SET data = REPLACE(data, '"', '');
    SET data = REPLACE(data, '\'', '"');

    SET n = JSON_LENGTH(data);

    read_loop:
    WHILE i < n
        DO
            SET before_camera_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Độ phân giải camera trước:"')));

            IF before_camera_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET after_camera_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Độ phân giải camera sau:"')));

            IF after_camera_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET battery_capacity_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Dung lượng pin:"')));

            IF battery_capacity_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET os_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Hệ điều hành:"')));

            IF os_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET chipset_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Chip xử lý (CPU):"')));

            IF chipset_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    UPDATE data_warehouse_staging.products_daily
    SET before_camera    = before_camera_val,
        after_camera     = after_camera_val,
        battery_capacity = battery_capacity_val,
        os               = os_val,
        chipset          = chipset_val
    WHERE id = product_id_val;
END //

DELIMITER ;
