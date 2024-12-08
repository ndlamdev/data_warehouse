DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_SPECIFICATION_FOR_CELLPHONES;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_SPECIFICATION_FOR_CELLPHONES(in product_id_val int, in data text)
BEGIN
    DECLARE before_camera_val VARCHAR(255) DEFAULT '';
    DECLARE after_camera_val VARCHAR(255) DEFAULT '';
    DECLARE battery_capacity_val VARCHAR(255) DEFAULT '';
    DECLARE os_val VARCHAR(255) DEFAULT '';
    DECLARE chipset_val VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    SET data = REPLACE(REPLACE(data, '"', ''), '\'', '"');

    IF JSON_VALID(data) = 1
    THEN
        SET n = JSON_LENGTH(data);
    ELSE
        UPDATE data_warehouse_staging.products_cellphones_staging
        SET before_camera    = before_camera_val,
            after_camera     = after_camera_val,
            battery_capacity = battery_capacity_val,
            os               = os_val,
            chipset          = chipset_val
        WHERE id = product_id_val;
    END IF;

    read_loop:
    WHILE i < n
        DO
            SET before_camera_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Camera trước"')));

            IF before_camera_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET after_camera_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Camera sau"')));

            IF after_camera_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET battery_capacity_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Pin"')));

            IF battery_capacity_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET os_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Hệ điều hành"')));

            IF os_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    read_loop:
    WHILE i < n
        DO
            SET chipset_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']."Chipset"')));

            IF chipset_val IS NOT NULL THEN
                leave read_loop;
            END IF;

            SET i = i + 1;
        END WHILE;
    SET i = 0;

    UPDATE data_warehouse_staging.products_cellphones_staging
    SET before_camera    = before_camera_val,
        after_camera     = after_camera_val,
        battery_capacity = battery_capacity_val,
        os               = os_val,
        chipset          = chipset_val
    WHERE id = product_id_val;
END //

DELIMITER ;
