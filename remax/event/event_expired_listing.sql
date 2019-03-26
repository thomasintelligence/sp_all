

delimiter |

CREATE EVENT bot_expired
    ON SCHEDULE
      EVERY 1 DAY
      STARTS '2019-03-26 00:00:00'
    DO
      BEGIN
        INSERT INTO log_expired
        SELECT NULL, CONVERT_TZ(NOW(),'GMT','Asia/Jakarta'), COUNT(*) FROM listing WHERE listType IN (3) 
        AND CONVERT_TZ(NOW(),'GMT','Asia/Jakarta') > listExpiryDate;

        UPDATE listing SET listType = '4', listUpdatedUserId = 'SYSTEM_EXPIRED', listUpdatedTime = NOW() 
        WHERE listType IN (3) 
        AND CONVERT_TZ(NOW(),'GMT','Asia/Jakarta') > listExpiryDate;
      END |

delimiter ;
        
        
        

