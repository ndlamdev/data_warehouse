DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_IMAGES_FOR_CELLPHONES;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_IMAGES_FOR_CELLPHONES(in product_id_val int, in data date)
BEGIN
    DECLARE image_val VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    SET data = REPLACE(REPLACE(REPLACE(data, 'NONE', '\'*\''), 'None', '\'*\''), '"', '');
    SET data = REPLACE(data, '\'', '"');


    IF JSON_VALID(data) = 1
    THEN
        SET n = JSON_LENGTH(data);
    END IF;

    -- Lặp qua từng phần tử trong dữ liệu JSON
    WHILE i < n
        DO
            SET image_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']')));

            IF image_val != '*' THEN
                INSERT INTO data_warehouse_staging.product_cellphones_images_staging(product_id, image_url)
                VALUES (product_id_val, image_val);
            END IF;

            SET i = i + 1;
            SET image_val = '';
        END WHILE;


END;

DELIMITER ;

