DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_PRICES_FOR_CELLPHONES;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_PRICES_FOR_CELLPHONES(in product_id_val int, in data text)
BEGIN
    DECLARE color_val VARCHAR(50) DEFAULT '';
    DECLARE price_base_val double DEFAULT 0;
    DECLARE discount_val double DEFAULT 0;
    DECLARE status_val VARCHAR(50);
    DECLARE desk_val VARCHAR(50) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    SET data = REPLACE(REPLACE(REPLACE(REPLACE(data, 'NONE', '\'*\''), '"', ''), '"', ''), '\'', '"');

    IF JSON_VALID(data) = 1
    THEN
        SET n = JSON_LENGTH(data);
    END IF;


    -- Lặp qua từng phần tử trong dữ liệu JSON
    WHILE i < n
        DO
            SET color_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].color')));
            SET desk_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].desk')));
            SET @price_base_val_temp =
                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                                                            JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].price_base'))),
                                                            'đ', ''),
                                                    '.',
                                                    ''), '*', ''), '"', ''), '₫', '');
            SET @discount_val_temp =
                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                                                            JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].discount'))),
                                                            'đ', ''),
                                                    '.',
                                                    ''), '*', ''), '"', ''), '₫', '');
            SET status_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, '].status')));

            IF color_val REGEXP '[0-9]' THEN
                SET @temp = desk_val;
                SET desk_val = color_val;
                SET color_val = @temp;
            END IF;

            SET color_val = COALESCE(color_val, '');
            SET desk_val = COALESCE(desk_val, '');

            IF @discount_val_temp REGEXP '[0-9]' THEN
                SET discount_val = cast(@discount_val_temp as double);
            ELSE
                SET discount_val = 0.0;
            END IF;

            IF @price_base_val_temp REGEXP '[0-9]' THEN
                SET price_base_val = cast(@price_base_val_temp as double);
            ELSE
                SET price_base_val = 0.0;
            END IF;

            IF discount_val > price_base_val
            THEN
                SET @TEMP = price_base_val;
                SET price_base_val = discount_val;
                SET discount_val = @TEMP;
            END IF;

            IF price_base_val = 0 AND (status_val is not null OR status_val != '') THEN
                SET status_val = 'Hết hàng';
            ELSE
                SET status_val = 'Còn hàng';
            END IF;


            -- Chèn vào bảng prices
            INSERT INTO data_warehouse_staging.product_cellphones_prices_staging (product_id, color, desk, price_base, discount, status)
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

