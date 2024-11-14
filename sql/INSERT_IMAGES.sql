DROP PROCEDURE IF EXISTS data_warehouse_control.INSERT_IMAGES;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.INSERT_IMAGES(in product_id_val int, in data text)
BEGIN
    DECLARE image_val VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT - 1;

    SET data = REPLACE(REPLACE(REPLACE(data, 'NONE', '\'*\''), 'None', '\'*\''), '"', '');
    SET data = REPLACE(data, '\'', '"');

    SET n = JSON_LENGTH(data);

    -- Lặp qua từng phần tử trong dữ liệu JSON
    WHILE i < n
        DO
            SET image_val = JSON_UNQUOTE(JSON_EXTRACT(data, CONCAT('$[', i, ']')));

            IF image_val != '*' THEN
                INSERT INTO data_warehouse_staging.product_images (product_id, image_url)
                VALUES (product_id_val, image_val);
            END IF;

            INSERT INTO data_warehouse_staging.product_images (product_id, image_url)
            VALUES (product_id_val, image_val);

            SET i = i + 1;
            SET image_val = '';
        END WHILE;


END //

DELIMITER ;

