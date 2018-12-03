DELIMITER $$

CREATE PROCEDURE `sp_membership_franchise_fee_calculation`(IN `agentId` INT, IN `closingId` INT, IN `listingId` INT, IN `franchiseId` INT, INOUT `value` DOUBLE, INOUT `feeHO` DOUBLE, IN `tipe` VARCHAR(20), IN `hirarki` INT, INOUT `seq` INT)
    NO SQL
BEGIN

	DECLARE fee INTEGER;
	DECLARE frFeeId INTEGER;
	DECLARE frFeeName VARCHAR(50);
	DECLARE frFeeMoneter DOUBLE;
	DECLARE frFeePercentage DOUBLE;
	DECLARE frFeeFROM INTEGER;
	DECLARE frFeeValue DOUBLE DEFAULT 0;
	DECLARE frFeeMinus INTEGER;
	DECLARE sisaComm DOUBLE DEFAULT 0;
	DECLARE jumlah INTEGER DEFAULT 0;			
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE membership_franchise_fee_cursor CURSOR for SELECT mffeFeeaId, mffeId, fealName, COALESCE(mffePercentage,0), COALESCE(mffeMoneter,0)
	FROM membership_franchise_fee 
	JOIN master_fee_agent ON (membership_franchise_fee.mffeFeeaId = master_fee_agent.feeaId)
	JOIN master_fee_agent_language ON master_fee_agent.feeaId = master_fee_agent_language.fealFeeaId
	WHERE mffeFrofId = franchiseId AND mffeMmbsId = agentId
	AND fealLangId = 1
	ORDER BY mffeSequence ASC;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
	
	
	SET frFeeMinus = 3;
	SET sisaComm = value;	
	

	OPEN membership_franchise_fee_cursor;
	start_loop3: LOOP
	FETCH membership_franchise_fee_cursor INTO fee, frFeeId, frFeeName, frFeePercentage, frFeeMoneter;
	IF finished = 1 THEN 
		LEAVE start_loop3;
	ELSE		

	
		SET seq = seq + 1;	
		
		SET frFeeValue = value;
		SET frFeeValue = frFeeValue * frFeePercentage/100;
		SET frFeeValue = frFeeValue + frFeeMoneter;
		
		IF frFeeMinus = 3 THEN
			SET sisaComm = sisaComm - frFeeValue;
			SET feeHO = feeHO + frFeeValue;
		END IF;
		
		
		INSERT INTO calculation_detail(ccldGroup, ccldMasterFee,ccldSisi, ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldHierarki, ccldSequence, ccldFromApi, ccldFromId, ccldBlock, ccldCreatedTime) 
		VALUES ('MOF',fee, tipe, franchiseId, closingId, CONCAT(frFeeName,' ',tipe), frFeeValue, frFeeMinus, hirarki, seq, 'api/membershipfranchisefee', frFeeId, 'sp_membership_franchise_fee_calculation Block 1', NOW());
		
		

	END IF;
	END LOOP start_loop3;
	CLOSE membership_franchise_fee_cursor;		
					
	SET value = sisaComm;
	
	
    
END$$
DELIMITER ;