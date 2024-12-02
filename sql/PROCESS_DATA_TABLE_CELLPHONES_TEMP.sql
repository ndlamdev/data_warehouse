DROP PROCEDURE IF EXISTS data_warehouse_control.PROCESS_DATA_TABLE_CELLPHONES_TEMP;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.PROCESS_DATA_TABLE_CELLPHONES_TEMP(in v_date DATE)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_source TEXT character set utf8mb4 collate utf8mb4_general_ci;
    DECLARE v_name TEXT;
    DECLARE v_images TEXT;
    DECLARE v_specifications TEXT;
    DECLARE v_prices TEXT;

    -- Khai báo con trỏ để duyệt qua dữ liệu
    DECLARE cursor_data CURSOR FOR
        SELECT source, name, images, specifications, prices FROM data_warehouse_staging.products_cellphones_temp;

    -- Xử lý lỗi khi không có dữ liệu
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    IF v_date is null
    THEN
        SET v_date = CURDATE();
    END IF;

    UPDATE data_warehouse_control.file_logs
    SET status      = 'STAGING_PROCESS',
        date_update = NOW()
    where file_config_id = 1
      and date = v_date;

    TRUNCATE TABLE data_warehouse_staging.product_cellphones_prices_staging;
    TRUNCATE TABLE data_warehouse_staging.product_cellphones_images_staging;
    SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE TABLE data_warehouse_staging.products_cellphones_staging;
    SET FOREIGN_KEY_CHECKS = 1;
    
    -- Mở con trỏ
    OPEN cursor_data;

    read_data:
    LOOP
        FETCH cursor_data INTO v_source, v_name, v_images, v_specifications, v_prices;

        IF done THEN
            LEAVE read_data;
        END IF;

        INSERT INTO data_warehouse_staging.products_cellphones_staging (source, name, date, date_dim_id)
        SELECT t.source,
               t.name,
               t.v_date,
               dd.id
        FROM (SELECT v_source AS source, v_name AS name, v_date) AS t
                 JOIN
             data_warehouse_staging.date_dim dd ON dd.date = t.v_date;

        select id
        INTO @product_id
        from data_warehouse_staging.products_cellphones_staging as pdw
        where pdw.source = v_source
          and pdw.date = v_date
        limit 1;
        
        CALL data_warehouse_control.INSERT_PRICES_FOR_CELLPHONES(@product_id, v_prices);
        CALL data_warehouse_control.INSERT_SPECIFICATION_FOR_CELLPHONES(@product_id, v_specifications);
        CALL data_warehouse_control.INSERT_IMAGES_FOR_CELLPHONES(@product_id, v_images);
    END LOOP;

    -- Đóng con trỏ
    CLOSE cursor_data;

    UPDATE data_warehouse_control.file_logs
    SET status      = 'STAGING_DONE',
        date_update = NOW()
    where file_config_id = 1
      and date = v_date;

END;

DELIMITER ;

