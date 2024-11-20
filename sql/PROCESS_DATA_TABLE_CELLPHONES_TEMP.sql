DROP PROCEDURE IF EXISTS data_warehouse_control.PROCESS_DATA_TABLE_CELLPHONES_TEMP;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.PROCESS_DATA_TABLE_CELLPHONES_TEMP(in date DATE)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_source TEXT character set utf8mb4 collate utf8mb4_general_ci;
    DECLARE v_name TEXT;
    DECLARE v_images TEXT;
    DECLARE v_specifications TEXT;
    DECLARE v_prices TEXT;

    -- Khai báo con trỏ để duyệt qua dữ liệu
    DECLARE cursor_data CURSOR FOR
        SELECT source, name, images, specifications, prices FROM data_warehouse_staging.product_cellphones_temp;

    -- Xử lý lỗi khi không có dữ liệu
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    IF date is null
    THEN
        SET date = CURDATE();
    END IF;

    UPDATE data_warehouse_control.file_logs
    SET status      = 'DAILY_LOADING',
        date_update = NOW()
    where file_config_id = 1
      and date = date;

    -- Mở con trỏ
    OPEN cursor_data;

    read_data:
    LOOP
        FETCH cursor_data INTO v_source, v_name, v_images, v_specifications, v_prices;

        IF done THEN
            LEAVE read_data;
        END IF;

        UPDATE data_warehouse_staging.products_data_warehouse
        SET active = false
        WHERE source = v_source;

        INSERT INTO data_warehouse_staging.products_data_warehouse (source, name, date, date_dim_id, active)
        SELECT t.source,
               t.name,
               t.date,
               dd.id,
               t.active
        FROM (SELECT v_source AS source, v_name AS name, date, true as active) AS t
                 JOIN
             data_warehouse_staging.date_dim dd ON dd.date = t.date;

        SET @product_id =
                (select id
                 from data_warehouse_staging.products_data_warehouse as pdw
                 where pdw.source = v_source
                   and pdw.date = date
                 limit 1);
        CALL data_warehouse_control.INSERT_PRICES(@product_id, v_prices);
        CALL data_warehouse_control.INSERT_SPECIFICATION_TABLE_CELLPHONES(@product_id, v_specifications);
        CALL data_warehouse_control.INSERT_IMAGES(@product_id, v_images);
    END LOOP;

    -- Đóng con trỏ
    CLOSE cursor_data;

    UPDATE data_warehouse_control.file_logs
    SET status      = 'DAILY_SUCCESS',
        date_update = NOW()
    where file_config_id = 1
      and date = date;

END;

DELIMITER ;

