DROP PROCEDURE IF EXISTS data_warehouse_control.LOAD_FILE;

DELIMITER //

CREATE PROCEDURE data_warehouse_control.LOAD_FILE(IN fileConfigId int, IN v_date date)
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
          and ((v_date is null AND logs.date = CURDATE()) or logs.date = v_date);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Mở CURSOR
    OPEN cur;

    read_loop:
    LOOP
        -- 1. đọc database_staging, table_temp, location_file_save, format_file, file_name, status, id
        FETCH cur INTO v_database_staging, v_table_temp, v_location_file_save, v_format_file, v_file_name, v_status, v_log_id;

        -- Kiểm tra nếu đã đọc hết dữ liệu
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 2. Kiểm tra status == 'CRAWL_SUCCESS'
        IF v_status != 'CRAWL_SUCCESS'
        THEN
            -- 2.1. Trả về Null
            LEAVE read_loop;
        END IF;

        -- 3. Tạo câu lệnh sql cập nhật status khi bắt đầu load file
        SET @sql_write_log1 = CONCAT(
                'UPDATE data_warehouse_control.file_logs SET date_update = NOW(), status = ''LOADING_FILE'' WHERE id = ',
                v_log_id, ';');

        -- 4. Tạo câu lệnh sql TRUNCATE table_temp
        SET @sql_clear_temp = CONCAT('TRUNCATE TABLE ', v_database_staging, '.', v_table_temp, ';');

        -- 5. Tạo câu lệnh load file.
        SET @sql_load_file =
                CONCAT('LOAD DATA LOCAL INFILE ''', v_location_file_save, '/', v_file_name, '.', v_format_file,
                       ''' INTO TABLE ',
                       v_database_staging, '.', v_table_temp,
                       ' FIELDS TERMINATED BY '','' ENCLOSED BY ''"'' LINES TERMINATED BY ''\\n'' IGNORE 1 ROWS;');


        -- 6. Tạo câu lệnh cập nhật status khi kết thúc load file
        SET @sql_write_log2 = CONCAT(
                'UPDATE data_warehouse_control.file_logs SET date_update = NOW(), status = ''LOAD_FILE_SUCCESS'' WHERE id = ',
                v_log_id, ';');

        -- 7. Trả về 4 câu lệnh đã tạo
        select @sql_write_log1, @sql_clear_temp, @sql_load_file, @sql_write_log2;
    END LOOP;

    -- Đóng CURSOR sau khi sử dụng
    CLOSE cur;
END;

DELIMITER ;

