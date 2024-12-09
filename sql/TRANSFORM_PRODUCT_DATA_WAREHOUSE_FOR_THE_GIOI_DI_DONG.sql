DROP PROCEDURE IF EXISTS data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_THE_GIOI_DI_DONG;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_THE_GIOI_DI_DONG(IN v_date date)
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
        FROM data_warehouse_staging.products_the_gioi_di_dong_staging;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- 1. Kiểm tra tham số đầu vào có phải null không
    IF v_date is null
    THEN
        -- 1.1. Set tham số ngày là hôm chạy
        SET v_date = CURDATE();
    END IF;

    -- 2. Cập nhật trạng thái của log thành 'TRANSFORM_PROCESSING'
    UPDATE data_warehouse_control.file_logs
    SET status      = 'TRANSFORM_PROCESSING',
        date_update = NOW()
    where file_config_id = 2
      and date = v_date;

    OPEN cursor_data;

    -- 3. Duyệt các dòng dữ liệu
    read_data:
    LOOP
        FETCH cursor_data INTO v_id, v_source, v_name, v_date_dim_id, v_before_camera, v_after_camera, v_battery_capacity, v_os, v_chipset;

        -- 3.1. Kiểm tra hết dữ liệu
        IF done THEN
            LEAVE read_data;
        END IF;

        -- 3.2. Cập nhật thời gian hết hạn của sản phẩm
        CALL data_warehouse_control.EXPIRED_PRODUCT_the_gioi_di_dong(@expired, v_source);

        -- 3.3. Kiểm trả sản phẩm có hết hạn hay không
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

            -- 3.3.2. Select id của sản phẩm vừa thêm vào
            SELECT id
            INTO v_id_product_dw
            FROM data_warehouse_staging.products_warehouse
            WHERE source = v_source
              AND expired = -1;

            -- 3.3.3. Thêm dữ liệu giá của sản phẩm từ bảng staging sang warehouse
            INSERT INTO data_warehouse_staging.product_prices_warehouse (product_id, color, desk, price_base, discount, `status`)
            SELECT v_id_product_dw, p_t.color, p_t.desk, p_t.price_base, p_t.discount, p_t.status
            FROM data_warehouse_staging.product_the_gioi_di_dong_prices_staging as p_t
            WHERE p_t.product_id = v_id;

            -- 3.3.4. Thêm dữ liệu hình ảnh của sản phẩm từ bảng staging sang warehouse
            INSERT INTO data_warehouse_staging.product_images_warehouse (product_id, image_url)
            SELECT v_id_product_dw, p_t.image_url
            FROM data_warehouse_staging.product_the_gioi_di_dong_images_staging as p_t
            WHERE p_t.product_id = v_id;
        END IF;

    END LOOP;

    CLOSE cursor_data;

    -- 4. Cập nhật log thành 'TRANSFORM_DONE'
    UPDATE data_warehouse_control.file_logs
    SET status      = 'TRANSFORM_DONE',
        date_update = NOW()
    where file_config_id = 2
      and date = v_date;
END;

DELIMITER ;