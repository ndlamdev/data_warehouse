DROP PROCEDURE IF EXISTS data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_CELLPHONES;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_CELLPHONES(IN v_date date)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id int;
    DECLARE v_id_product_dw int;
    DECLARE v_source varchar(255) character set utf8mb4 collate utf8mb4_general_ci;
    DECLARE v_name varchar(255);
    DECLARE v_date_dim_id int;
    DECLARE v_before_camera varchar(255);
    DECLARE v_after_camera varchar(255);
    DECLARE v_battery_capacity varchar(255);
    DECLARE v_os varchar(255);
    DECLARE v_chipset varchar(255);

    -- Khai báo con trỏ để duyệt qua dữ liệu
    DECLARE cursor_data CURSOR FOR
        SELECT id,
               source,
               name,
               date_dim_id,
               before_camera,
               after_camera,
               battery_capacity,
               os,
               chipset
        FROM data_warehouse_staging.products_cellphones_staging;

    -- Xử lý lỗi khi không có dữ liệu
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    IF v_date is null
    THEN
        SET v_date = CURDATE();
    END IF;

    UPDATE data_warehouse_control.file_logs
    SET status      = 'TRANSFORM_PROCESSING',
        date_update = NOW()
    where file_config_id = 1
      and date = v_date;

    -- Mở con trỏ
    OPEN cursor_data;

    read_data:
    LOOP
        FETCH cursor_data INTO v_id, v_source, v_name, v_date_dim_id, v_before_camera, v_after_camera, v_battery_capacity, v_os, v_chipset;

        IF done THEN
            LEAVE read_data;
        END IF;

        CALL data_warehouse_control.EXPIRED_PRODUCT_CELLPHONES(@expired, v_source);
        
        IF @expired = 1
        THEN
            INSERT data_warehouse_staging.products_warehouse
            (source,
             name,
             date_dim_id,
             before_camera,
             after_camera,
             battery_capacity,
             os,
             chipset,
             expired)
                VALUE
                (v_source,
                 v_name,
                 v_date_dim_id,
                 v_before_camera,
                 v_after_camera,
                 v_battery_capacity,
                 v_os,
                 v_chipset,
                 -1);

            SELECT id
            INTO v_id_product_dw
            FROM data_warehouse_staging.products_warehouse
            WHERE source = v_source
              AND expired = -1;

            INSERT INTO data_warehouse_staging.product_prices_warehouse (product_id, color, desk, price_base, discount, `status`)
            SELECT v_id_product_dw, p_t.color, p_t.desk, p_t.price_base, p_t.discount, p_t.status
            FROM data_warehouse_staging.product_cellphones_prices_staging as p_t
            WHERE p_t.product_id = v_id;

            INSERT INTO data_warehouse_staging.product_images_warehouse (product_id, image_url)
            SELECT v_id_product_dw, p_t.image_url
            FROM data_warehouse_staging.product_cellphones_images_staging as p_t
            WHERE p_t.product_id = v_id;
        END IF;

    END LOOP;

    -- Đóng con trỏ
    CLOSE cursor_data;

    UPDATE data_warehouse_control.file_logs
    SET status      = 'TRANSFORM_DONE',
        date_update = NOW()
    where file_config_id = 1
      and date = v_date;
END;

DELIMITER ;