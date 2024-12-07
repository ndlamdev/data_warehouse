DROP PROCEDURE IF EXISTS data_warehouse_control.PROCESS_DATA_TABLE_THE_GIOI_DI_DONG_TEMP;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.PROCESS_DATA_TABLE_THE_GIOI_DI_DONG_TEMP(in v_date DATE)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_source TEXT character set utf8mb4 collate utf8mb4_general_ci;
    DECLARE v_name TEXT;
    DECLARE v_images TEXT;
    DECLARE v_specifications TEXT;
    DECLARE v_prices TEXT;

    -- 1. Đọc các dòng dữ liệu trong table_temp
    DECLARE cursor_data CURSOR FOR
        SELECT source, name, images, specifications, prices FROM data_warehouse_staging.products_the_gioi_di_dong_temp;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- 2. Tham số v_date == null
    IF v_date is null
    THEN
        -- 2.1 Set v_date = ngày hiện tại
        SET v_date = CURDATE();
    END IF;

    -- 3. Cập nhật log thành 'STAGING_PROCESS'
    UPDATE data_warehouse_control.file_logs
    SET status      = 'STAGING_PROCESS',
        date_update = now()
    where file_config_id = 2
      and date = v_date;

    -- 4. Truncate table prices_staging
    TRUNCATE TABLE data_warehouse_staging.product_the_gioi_di_dong_prices_staging;
    -- 5. Truncate table images_staging
    TRUNCATE TABLE data_warehouse_staging.product_the_gioi_di_dong_images_staging;
    -- 6. Tắt FOREIGN_KEY_CHECKS
    SET FOREIGN_KEY_CHECKS = 0;
    -- 7. Truncate table staging
    TRUNCATE TABLE data_warehouse_staging.products_the_gioi_di_dong_staging;
    -- 8. Bật FOREIGN_KEY_CHECKS
    SET FOREIGN_KEY_CHECKS = 1;

    -- Mở con trỏ
    OPEN cursor_data;

    -- 9. Duyệt các dòng dữ liệu
    read_data:
    LOOP
        FETCH cursor_data INTO v_source, v_name, v_images, v_specifications, v_prices;

        -- 9.1 Hoàn thành
        IF done THEN
            LEAVE read_data;
        END IF;

        -- 10. Thêm dữ liệu vào staging
        INSERT INTO data_warehouse_staging.products_the_gioi_di_dong_staging (source, name, date, date_dim_id)
        SELECT t.source,
               t.name,
               t.v_date,
               dd.id
        FROM (SELECT v_source AS source, v_name AS name, v_date) AS t
                 JOIN
             data_warehouse_staging.date_dim dd ON dd.date = t.v_date;

        -- 11. Select id dữ liệu staging vừa insert
        select id
        INTO @product_id
        from data_warehouse_staging.products_the_gioi_di_dong_staging as pdw
        where pdw.source = v_source
          and pdw.date = v_date
        limit 1;

        -- 12. Chạy procedure thêm giá
        CALL data_warehouse_control.INSERT_PRICES_FOR_THE_GIOI_DI_DONG(@product_id, v_prices);
        -- 13. Chạy procedure thêm thông số kĩ thuật
        CALL data_warehouse_control.INSERT_SPECIFICATION_FOR_THE_GIOI_DI_DONG(@product_id, v_specifications);
        -- 14. Chạy procedure thêm hình ảnh
        CALL data_warehouse_control.INSERT_IMAGES_FOR_THE_GIOI_DI_DONG(@product_id, v_images);
    END LOOP;

    CLOSE cursor_data;

    -- 15. Cập nhật log thành 'STAGING_DONE'
    UPDATE data_warehouse_control.file_logs
    SET status      = 'STAGING_DONE',
        date_update = now()
    where file_config_id = 2
      and date = v_date;

END;

DELIMITER ;

