DELIMITER //
CREATE TRIGGER add_billing_new
AFTER INSERT
   ON event_fee FOR EACH ROW

BEGIN
    
    INSERT INTO billing
    SELECT 
    NULL,
    feelName,
    IF(mfeeMfqyId = 3, "Monthly", IF(mfeeMfqyId = 4, "Days", IF(mfeeMfqyId = 5, "Yearly", "Undefined" ))) AS Deskripsi,
    NOW(),
    NEW.efeeAmount,
    NOW(),
    "SYSTEM",
    NULL,
    NULL,
    NULL
    FROM master_fee 
    JOIN master_fee_language ON mfeeId =  feelMfeeId AND feelLangId = 1
    WHERE mfeeId = NEW.efeeMfeeId;

END; //


DELIMITER ;