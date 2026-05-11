DELIMITER //

CREATE PROCEDURE ProcessEquipmentPurchase(
    IN p_patient_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(18,2);
    DECLARE v_balance DECIMAL(18,2);
    DECLARE v_status VARCHAR(20);
    DECLARE v_total_cost DECIMAL(18,2);

START TRANSACTION;

    SELECT stock, price INTO v_stock, v_price 
    FROM Products 
    WHERE product_id = p_product_id FOR UPDATE;

    SELECT balance, status INTO v_balance, v_status 
    FROM Wallets 
    WHERE patient_id = p_patient_id FOR UPDATE;

    IF v_stock IS NULL THEN
        SET p_message = 'Thất bại: Sản phẩm không tồn tại';
        ROLLBACK;
    ELSEIF v_balance IS NULL THEN
        SET p_message = 'Thất bại: Bệnh nhân chưa có ví';
        ROLLBACK;
    ELSEIF v_stock < p_quantity THEN
        SET p_message = 'Thất bại: Kho không đủ sản phẩm';
        ROLLBACK;
    ELSEIF v_status = 'Inactive' THEN
        SET p_message = 'Thất bại: Ví đang bị khóa';
        ROLLBACK;
    ELSE
        SET v_total_cost = v_price * p_quantity;

        IF v_balance < v_total_cost THEN
            SET p_message = 'Thất bại: Số dư ví không đủ';
            ROLLBACK;
        ELSE
        
            UPDATE Products 
            SET stock = stock - p_quantity 
            WHERE product_id = p_product_id;

            UPDATE Wallets 
            SET balance = balance - v_total_cost 
            WHERE patient_id = p_patient_id;

            SET p_message = 'Thành công: Đã xử lý đơn hàng';
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;
