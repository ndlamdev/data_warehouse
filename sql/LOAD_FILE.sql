
create procedure data_warehouse_control.LOAD_FILE(IN fileConfigId int)
BEGIN
    DECLARE v_database_staging VARCHAR(255);
    DECLARE v_table_temp VARCHAR(255);
    DECLARE v_location_file_save VARCHAR(255);
    DECLARE v_format_file VARCHAR(255);
    DECLARE v_file_name VARCHAR(255);
    DECLARE v_status VARCHAR(50);
    DECLARE v_log_id int;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT configs.database_staging,
               configs.table_temp,
               configs.location_file_save,
               configs.format_file,
               logs.file_name,
               logs.status,
               logs.id
        FROM data_warehouse_control.file_configs as configs
                 JOIN data_warehouse_control.file_logs as logs on logs.file_config_id = configs.id
        WHERE configs.id = fileConfigId
          and logs.date = CURDATE();
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Mở CURSOR
    OPEN cur;

    read_loop:
    LOOP
        -- Đọc dữ liệu từ CURSOR vào các biến
        FETCH cur INTO v_database_staging, v_table_temp, v_location_file_save, v_format_file, v_file_name, v_status, v_log_id;

        -- Kiểm tra nếu đã đọc hết dữ liệu
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Xử lý dữ liệu
        IF v_status = 'CRAWL_SUCCESS'
        THEN
            SET @sql_write_log1 = CONCAT(
                    'UPDATE data_warehouse_control.file_logs SET date_update = NOW(), status = ''LOADING_FILE'' WHERE id = ',
                    v_log_id, ';');

            -- Xóa dữ liệu trong bảng tạm (không dùng PREPARE)
            SET @sql_clear_temp = CONCAT('TRUNCATE TABLE ', v_database_staging, '.', v_table_temp, ';');

            -- Tải dữ liệu từ file vào bảng tạm (không dùng PREPARE)
            SET @sql_load_file =
                    CONCAT('LOAD DATA LOCAL INFILE ''', v_location_file_save, '/', v_file_name, '.', v_format_file,
                           ''' INTO TABLE ',
                           v_database_staging, '.', v_table_temp,
                           ' FIELDS TERMINATED BY '','' ENCLOSED BY ''"'' LINES TERMINATED BY ''\\n'' IGNORE 1 ROWS;');


            -- Cập nhật trạng thái trong bảng file_logs
            SET @sql_write_log2 = CONCAT(
                    'UPDATE data_warehouse_control.file_logs SET date_update = NOW(), status = ''LOAD_FILE_SUCCESS'' WHERE id = ',
                    v_log_id, ';');

            select @sql_write_log1, @sql_clear_temp, @sql_load_file, @sql_write_log2;
        END IF;
    END LOOP;

    -- Đóng CURSOR sau khi sử dụng
    CLOSE cur;
END;

