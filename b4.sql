-- Số lượng Trigger: 01 Trigger
-- Thời điểm kích hoạt: BEFORE INSERT và BEFORE UPDATE.

-- Logic xử lý ngoại lệ:
-- Ngoại lệ 1 (Hủy lịch): Trong câu lệnh SELECT COUNT, chúng ta thêm điều kiện status <> 'Cancelled'.
-- Ngoại lệ 2 (Trùng chính nó): Khi UPDATE, chúng ta phải loại trừ ID của bản ghi hiện tại ra khỏi danh sách kiểm tra bằng điều kiện id <> NEW.id.

DELIMITER //

CREATE TRIGGER tg_check_double_booking_insert
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Kiểm tra xem bác sĩ đã có lịch nào trùng giờ mà chưa bị hủy hay chưa
    SELECT COUNT(*) INTO v_count
    FROM appointments
    WHERE doctor_id = NEW.doctor_id 
      AND appointment_time = NEW.appointment_time
      AND status <> 'Cancelled';

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

CREATE TRIGGER tg_check_double_booking_update
BEFORE UPDATE ON appointments
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(*) INTO v_count
    FROM appointments
    WHERE doctor_id = NEW.doctor_id 
      AND appointment_time = NEW.appointment_time
      AND status <> 'Cancelled'
      AND id <> NEW.id;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

DELIMITER ;

INSERT INTO appointments (doctor_id, appointment_time, status) 
VALUES (1, '2026-05-10 08:00:00', 'Pending');

INSERT INTO appointments (doctor_id, appointment_time, status) 
VALUES (1, '2026-05-10 08:00:00', 'Pending');


UPDATE appointments
SET status = 'Cancelled' 
WHERE doctor_id = 1 AND appointment_time = '2026-05-10 08:00:00';

INSERT INTO appointments (doctor_id, appointment_time, status) 
VALUES (1, '2026-05-10 08:00:00', 'Pending');


UPDATE appointments 
SET status = 'Completed' 
WHERE id = 10; 