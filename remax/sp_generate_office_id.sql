DELIMITER $$

CREATE PROCEDURE `sp_generate_office_id`(IN `officeId` INT)
    NO SQL
BEGIN
    DECLARE officeNo varchar(20);
    DECLARE cityId integer;
    DECLARE areaCode varchar(20);
    DECLARE anyOfficeNo varchar(20);
    DECLARE anySameNo INT;
    DECLARE maxNo varchar(10);
    DECLARE digitNoMax integer DEFAULT 5;
    DECLARE digitNo integer DEFAULT 3;
    DECLARE digitArea integer DEFAULT 3;
    DECLARE alp CHAR(1);
    DECLARE numCode INT DEFAULT 1;
    DECLARE excCode INT DEFAULT 409010;
    DECLARE warningCode INT DEFAULT 409011;
    DECLARE maxNoCode INT DEFAULT 409012;
    DECLARE haveNoCode INT DEFAULT 409013;
    DECLARE sameNoCode INT DEFAULT 409014;
    
    DECLARE exit handler for sqlexception
    BEGIN
        SELECT excCode as 'ErrorCode';
    END;

    DECLARE exit handler for sqlwarning
    BEGIN
        SELECT warningCode as 'ErrorCode';
    END;


    
    body:BEGIN 
            SELECT frofOfficeNo INTO anyOfficeNo FROM franchise_office WHERE frofId = officeId;
            IF anyOfficeNo IS NOT NULL THEN
                SELECT haveNoCode as 'ErrorCode';
                LEAVE body;
            END IF;

            SELECT frofMctyId INTO cityId FROM franchise_office WHERE frofId = officeId;
 
            SELECT mctyAreaCode INTO areaCode FROM master_city WHERE mctyId = cityId;
            
            
              SELECT MAX( CAST(IFNULL(SUBSTRING(frofOfficeNo,digitNoMax),0) AS UNSIGNED)) INTO maxNo FROM franchise_office;
            
            SELECT MAX(SUBSTRING(frofOfficeNo,-digitNo-1,1)) INTO alp FROM franchise_office;
            
            IF alp = "Z" and LENGTH(REPLACE(maxNo,"9","")) = 0 THEN 
                SELECT maxNoCode as 'ErrorCode';
                LEAVE body;
            END IF;

            SELECT func_extra_no(maxNo, alp) INTO alp;
   
            SELECT func_format_no(areaCode, digitArea) INTO areaCode;
            
            SELECT func_get_available_no(maxNo) INTO maxNo;

            SELECT func_format_no(maxNo, digitNo) INTO maxNo;            
               
           -- SELECT func_format_office_id(numCode, areaCode, alp, maxNo) INTO officeNo;
           
            SELECT func_format_office_id(numCode, areaCode,  maxNo) INTO officeNo;
            
            SELECT COUNT(*) INTO anySameNo FROM franchise_office WHERE frofOfficeNo = officeNo;
            IF anySameNo <> 0 THEN
                SELECT sameNoCode as 'ErrorCode';
                LEAVE body;
            END IF;

            UPDATE franchise_office SET frofOfficeNo = officeNo WHERE frofId = officeId;
         
    END body;    


    
    
    SELECT '201';
	
    
    
END$$
DELIMITER ;