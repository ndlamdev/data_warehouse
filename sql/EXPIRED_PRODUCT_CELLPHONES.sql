DROP PROCEDURE IF EXISTS data_warehouse_control.EXPIRED_PRODUCT_CELLPHONES;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.EXPIRED_PRODUCT_CELLPHONES(OUT expired BIT,
                                                                   IN source_expired varchar(255) character set utf8mb4 collate utf8mb4_general_ci)
BEGIN
    DECLARE product_count INT;
    DECLARE v_data_dim_id INT;

    -- 1. Đếm số lượng sản phẩm trùng lập theo nguồn lấy
    SELECT COUNT(*)
    INTO product_count
    FROM (data_warehouse_staging.products_cellphones_staging AS p_t
        LEFT JOIN data_warehouse_staging.product_cellphones_images_staging AS img_t
        ON p_t.id = img_t.product_id
        LEFT JOIN data_warehouse_staging.product_cellphones_prices_staging AS pr_t
          ON p_t.id = pr_t.product_id)
             RIGHT JOIN
         (data_warehouse_staging.products_warehouse AS p_w
             LEFT JOIN data_warehouse_staging.product_images_warehouse AS img_w
             ON p_w.id = img_w.product_id
             LEFT JOIN data_warehouse_staging.product_prices_warehouse AS pr_w
          ON p_w.id = pr_w.product_id)
         ON
             p_t.source = p_w.source
    WHERE p_t.source = source_expired
      AND p_w.expired = -1
      AND p_w.source = p_t.source
      AND p_w.after_camera = p_t.after_camera
      AND p_w.battery_capacity = p_t.battery_capacity
      AND p_w.name = p_t.name
      AND p_w.before_camera = p_t.before_camera
      AND p_w.battery_capacity = p_t.battery_capacity
      AND p_w.os = p_t.os
      AND p_w.chipset = p_t.chipset
      And pr_w.color = pr_t.color
      And pr_w.price_base = pr_t.price_base
      And pr_w.discount = pr_t.discount
      And pr_w.status = pr_t.status
      And pr_w.desk = pr_t.desk
      AND img_w.image_url = img_t.image_url;

    -- 2. Nếu không không có sản phẩm trùng lập
    IF product_count = 0
    THEN
        -- 2.1. Set giá trị kết quả = 1
        SET expired = 1;

        -- 2.2. select id data_dim của ngày hôm nay
        SELECT id
        INTO v_data_dim_id
        FROM data_warehouse_staging.date_dim as dm
        WHERE dm.date = CURDATE();

        -- 2.3. Cập nhật thời gian hết hạn là ngày chạy
        UPDATE data_warehouse_staging.products_warehouse as pw
        SET pw.expired = v_data_dim_id
        WHERE pw.source = source_expired
          AND pw.expired = -1;
    ELSE
        -- 2.4. Set giá trị kết quả = 0
        SET expired = 0;
    END IF;
END;

DELIMITER ;