CALL data_warehouse_control.PROCESS_DATA_TABLE_THE_GIOI_DI_DONG_TEMP(null);
CALL data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_THE_GIOI_DI_DONG(null);
CALL data_warehouse_control.TRANSFORM_PRODUCT_DATA_WAREHOUSE_FOR_CELLPHONES(null);
CALL data_warehouse_control.EXPIRED_PRODUCT_THE_GIOI_DI_DONG(@expired, 'https://www.thegioididong.com/dtdd/xiaomi-14t-pro-5g-12gb-256gb');
SELECT @expired;
# SHOW FULL COLUMNS FROM data_warehouse_staging.product_the_gioi_di_dong_images_staging;


# SET FOREIGN_KEY_CHECKS = 0;
# TRUNCATE  TABLE  data_warehouse_staging.product_the_gioi_di_dong_prices_staging;
# TRUNCATE  TABLE  data_warehouse_staging.product_the_gioi_di_dong_images_staging;
# TRUNCATE  TABLE  data_warehouse_staging.products_the_gioi_di_dong_staging;
# SET FOREIGN_KEY_CHECKS = 1;

# SET FOREIGN_KEY_CHECKS = 0;
# TRUNCATE  TABLE  data_warehouse_staging.product_the_gioi_di_dong_prices_staging;
# TRUNCATE  TABLE  data_warehouse_staging.product_the_gioi_di_dong_images_staging;
# TRUNCATE  TABLE  data_warehouse_staging.products_the_gioi_di_dong_staging;
# SET FOREIGN_KEY_CHECKS = 1;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE data_warehouse_staging.product_prices_warehouse;
TRUNCATE TABLE data_warehouse_staging.product_images_warehouse;
TRUNCATE TABLE data_warehouse_staging.products_warehouse;
SET FOREIGN_KEY_CHECKS = 1;

# select fc.id, 
#        fc.procedure_load_data_temp, 
#        fl.status 
# from data_warehouse_control.file_configs as fc 
#     left join data_warehouse_control.file_logs fl 
#         on fc.id = fl.file_config_id 
# where fl.date = '2024-12-03' ;

SELECT COUNT(*)
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
WHERE p_t.source = 'https://cellphones.com.vn/iphone-15-plus.html'
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

SELECT COUNT(*)
FROM (data_warehouse_staging.products_cellphones_staging AS p_t
    LEFT JOIN data_warehouse_staging.product_cellphones_images_staging AS img_t
    ON p_t.id = img_t.product_id
    LEFT JOIN data_warehouse_staging.product_cellphones_prices_staging AS pr_t
      ON p_t.id = pr_t.product_id)
         JOIN
     (data_warehouse_staging.products_warehouse AS p_w
         LEFT JOIN data_warehouse_staging.product_images_warehouse AS img_w
         ON p_w.id = img_w.product_id
         LEFT JOIN data_warehouse_staging.product_prices_warehouse AS pr_w
      ON p_w.id = pr_w.product_id)
     ON
         p_t.source = p_w.source
WHERE p_t.source = 'https://cellphones.com.vn/iphone-15-plus.html';

SELECT id, dm.date
FROM data_warehouse_staging.date_dim as dm
WHERE dm.date = CURDATE();
