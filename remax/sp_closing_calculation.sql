BEGIN
	
	
	
	DECLARE cekAmountAndPercentage DOUBLE DEFAULT 0;

	
	
	DECLARE totalnumber INTEGER;
	DECLARE officenumber VARCHAR(50);
	
	
	DECLARE multiCobrokingStatus INTEGER;
	
	DECLARE xxxxMmbsId INTEGER;
	DECLARE xxxxOffice INTEGER;
	DECLARE xxxxPercentage DOUBLE;
	DECLARE xxxxMoneter DOUBLE;
	DECLARE xxxxType DOUBLE;
	DECLARE xxxxValue DOUBLE;


	DECLARE listingStatus INTEGER;
	DECLARE listingPrice DOUBLE;
	DECLARE listingCode VARCHAR(50);
	DECLARE pajak DOUBLE DEFAULT 0;
	DECLARE pajak_uang DOUBLE DEFAULT 0;
	DECLARE cekTax INTEGER DEFAULT 0;
	DECLARE cek INTEGER DEFAULT 0;
	DECLARE listAggId INTEGER;
	DECLARE listAggMemberId INTEGER; 
	DECLARE listAggMoneter DOUBLE;
    DECLARE listAggPercentage DOUBLE;
	DECLARE listCommInclude INTEGER;
	DECLARE comm DOUBLE DEFAULT 0;
	DECLARE listFranchiseId INTEGER; 
	DECLARE listOwner INTEGER;
	DECLARE sisaSelling DOUBLE;
	DECLARE sisaListing DOUBLE;
	
	DECLARE sisaMaSelling DOUBLE;
	DECLARE sisaMaListing DOUBLE;
	
	
	DECLARE feeHOList DOUBLE DEFAULT 0;
	DECLARE feeHOSell DOUBLE DEFAULT 0;
	
	
	DECLARE feeMAList DOUBLE DEFAULT 0;
	DECLARE feeMASell DOUBLE DEFAULT 0;
	
	DECLARE tipe VARCHAR(20);
	DECLARE closingId INTEGER;
	
	DECLARE cekLead INTEGER DEFAULT 0;
	DECLARE leadMemberId INTEGER;
	DECLARE leadFranchiseId INTEGER;
	DECLARE leadPercentage DOUBLE;
	
	DECLARE cekCoor INTEGER DEFAULT 0;
	DECLARE coorMemberId INTEGER;
	DECLARE coorFranchiseId INTEGER;
	DECLARE coorPercentage DOUBLE;

	DECLARE seq INTEGER DEFAULT 0;
	DECLARE hirarki INTEGER DEFAULT 1;
	
    DECLARE finished INTEGER DEFAULT 0;
	DECLARE finished_cobroking INTEGER DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        SELECT '409009' as 'ErrorMessage';
    END;
	
	START TRANSACTION;
 	
	/*
	TEMPORARY
	*/

	CREATE TEMPORARY TABLE IF NOT EXISTS `franchise_comm` (
	  `frcoId` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	  `frcoListId` int(11) NOT NULL,
	  `frcoFrofId` int(11) NOT NULL,
	  `frcoMfeeId` int(11) NOT NULL,
	  `frcoName` varchar(50) NOT NULL,
	  `frcoValue` double DEFAULT 0
	) AUTO_INCREMENT=1;

	CREATE TEMPORARY TABLE IF NOT EXISTS `member_comm` (
	  `mmcoId` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	  `mmcoListId` int(11) NOT NULL,
	  `mmcoAgtyId` int(11) NOT NULL,
	  `mmcoMmbsId` int(11) DEFAULT NULL,
	  `mmcoPercentage` float DEFAULT NULL,
	  `mmcoMoneter` bigint(12) DEFAULT NULL,
	  `mmcoSequence` int(11) NOT NULL,
	  `mmcoValue` double DEFAULT 0
	) AUTO_INCREMENT=1;
	
	CREATE TEMPORARY TABLE IF NOT EXISTS `cobroking_comm` (
	  `kingId` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
	  `kingListId` int(11) NOT NULL,
	  `kingAgtyId` int(11) NOT NULL,
	  `kingMmbsId` int(11) DEFAULT NULL,
	  `kingOffice` int(11) DEFAULT NULL,
	  `kingPercentage` float DEFAULT NULL,
	  `kingMoneter` bigint(12) DEFAULT NULL,
	  `kingSequence` int(11) NOT NULL,
	  `kingValue` double DEFAULT 0
	) AUTO_INCREMENT=1;



	SELECT listIdListing, listMmbsId, listListingStatusId, listListingPrice, listOfficeId, COALESCE(listCommissionPercentage,0), COALESCE(listCommissionMoneter,0), listCommissionInclude
	FROM listing WHERE listId = listingId 
	INTO listingCode, listOwner, listingStatus, listingPrice, listFranchiseId, listAggPercentage, listAggMoneter, listCommInclude;
    
	IF price IS NOT NULL AND price <> 0 THEN
		SET listingPrice = price;
	END IF;
	
	
	IF sellFranchiseId IS NULL THEN
		SELECT mmbsFranchise FROM membership_franchise WHERE mmbsMemberId = agentId LIMIT 1 INTO sellFranchiseId;
	END IF;
	
	
--	SELECT COUNT(*)+1 AS total FROM `calculation` WHERE `cclhFrofId` = sellFranchiseId INTO totalnumber;
	SELECT 	frofOfficeNo  FROM `franchise_office` WHERE `frofId` = sellFranchiseId INTO officenumber;
	
	SELECT RIGHT(cclhCode, length(cclhCode)-length(CONCAT('CLS', officenumber))) +1 FROM `calculation` WHERE cclhFrofId = sellFranchiseId ORDER BY cclhId DESC LIMIT 1 INTO totalnumber;
	
	
	INSERT INTO calculation (cclhCode, cclhMmbsId, cclhFrofId, cclhDate, cclhListId, cclhCreatedTime, cclhCustId, cclhPrice)
	VALUES (CONCAT('CLS', officenumber, totalnumber), agentId, sellFranchiseId, NOW(), listingId, NOW(), customerId, listingPrice);

	SELECT cclhId FROM calculation WHERE cclhListId = listingId ORDER BY cclhId DESC LIMIT 1 INTO closingId;
  
	INSERT INTO calculation_detail(ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
	VALUES (closingId, 'Harga Transaksi', listingPrice, 0, 'api/franchisefee', seq, NOW());
	
	SET seq = seq + 1;
	
	IF listingStatus = 1 THEN
		CALL sp_tax_calculation(closingId, listingId, listingPrice, listCommInclude, hirarki, seq);
	END IF;

    
	IF listingStatus = 1 THEN
	
		SELECT COUNT(mslaId) FROM master_lead_agent WHERE mslaListId = listingId INTO cekLead;
		IF cekLead <> 0 THEN
			SET seq = seq + 1;
			
			SELECT mslaMmbsId, mslaFrofId, mslaPercentage FROM master_lead_agent WHERE mslaListId = listingId LIMIT 1
			INTO leadMemberId, leadFranchiseId, leadPercentage;
			IF listCommInclude = 1 THEN
				SET listAggPercentage = listAggPercentage - leadPercentage;
			END IF;	
			
			CALL sp_lead_and_coordinator_commission('Lead Agent', listingId, listingPrice, leadMemberId, leadFranchiseId, leadPercentage, hirarki, seq);
		END IF;		

		SELECT COUNT(mscaId) FROM master_coordinator_agent WHERE mscaListId = listingId INTO cekCoor;
		IF cekCoor <> 0 THEN
			SET seq = seq + 1;
			
			SELECT mscaMmbsId, mscaFrofId, mscaPercentage FROM master_coordinator_agent WHERE mscaListId = listingId LIMIT 1
			INTO coorMemberId, coorFranchiseId, coorPercentage;
			IF listCommInclude = 1 THEN
				SET listAggPercentage = listAggPercentage - coorPercentage;
			END IF;
			SET leadMemberId = coorMemberId;
			SET leadFranchiseId = coorFranchiseId;
			SET leadPercentage = coorPercentage;

			CALL sp_lead_and_coordinator_commission('Coordinator Agent', listingId, listingPrice, leadMemberId, leadFranchiseId, leadPercentage, hirarki, seq);
		END IF;
	END IF;

	

	
	
	SET seq = seq + 1;
	SET comm = ( listingPrice * listAggPercentage/100) + listAggMoneter;
	INSERT INTO calculation_detail(ccldSisi,ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
	VALUES ("KT", closingId, 'Komisi Transaksi', comm, 0, 'api/franchisefee', seq, NOW());

		SELECT COUNT(mmagId) FROM member_aggrement WHERE mmagListId = listingId INTO cek;


		
		IF cek = 0 AND agentId = listOwner THEN 
			BLOCK14: BEGIN
				DECLARE mmListingValue DOUBLE DEFAULT 0; 
				DECLARE mmSellingValue DOUBLE DEFAULT 0; 
				
				/* START TAMBAH MA OFF FEE */
				DECLARE maListingValue DOUBLE DEFAULT 0; 
				DECLARE maSellingValue DOUBLE DEFAULT 0; 
				/* END TAMBAH MA OFF FEE */
				
				
				DECLARE headId INTEGER;
				DECLARE headName VARCHAR(100);
				DECLARE i INTEGER DEFAULT 0;
					
				SET sellFranchiseId = listFranchiseId;
												
				SET mmListingValue = ( comm * 50/100);
				SET mmSellingValue = ( comm * 50/100);

				

				CALL `sp_refferal_commission`(closingId, listingId, mmSellingValue, mmListingValue, customerId, seq);
				
				
				/* START TAMBAH MA OFF FEE */
				SET maListingValue = mmListingValue; 
				SET maSellingValue = mmSellingValue;
				/* END TAMBAH MA OFF FEE */
				

				CALL `sp_office_fee_calculation`(closingId, listingId, listFranchiseId, mmListingValue, feeHOList, 'Listing', hirarki, seq);
				/*
				INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
				VALUES(listingId, 1, agentId, 50, 0, 1, mmListingValue);
				*/
				CALL `sp_office_fee_calculation`(closingId, listingId, sellFranchiseId, mmSellingValue, feeHOSell, 'Selling', hirarki, seq);
				/*
				INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
				VALUES(listingId, 1, agentId, 50, 0, 1, mmSellingValue);
				*/
				

				/* START TAMBAH MA OFF FEE */
				CALL `sp_membership_franchise_fee_calculation`(agentId, closingId, listingId, listFranchiseId, maListingValue, feeMAList, 'Listing', hirarki, seq);
				INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
				VALUES(listingId, 1, agentId, 50, 0, 1, maListingValue);

				CALL `sp_membership_franchise_fee_calculation`(agentId, closingId, listingId, sellFranchiseId, maSellingValue, feeMASell, 'Selling', hirarki, seq);
				INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
				VALUES(listingId, 1, agentId, 50, 0, 1, maSellingValue);
				
				/* END TAMBAH MA OFF FEE */



				
				SELECT frofCompId FROM franchise_office WHERE frofId = listFranchiseId INTO headId;
				SELECT compName FROM company WHERE compId = headId INTO headName; 	
				
				/*	SEBELUM FEE MA OFFICE
				SET sisaSelling = mmSellingValue;
				SET sisaListing = mmListingValue;
				*/

				SET seq = seq + 1;
					
				INSERT INTO calculation_detail(ccldSisi, ccldHO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
				VALUES ("Pay", headId, closingId, CONCAT('Payable to ',headName), ABS(feeHOSell+feeHOList), 2, 'api/franchisefee', seq, NOW());
				
				/* START TAMBAH MA OFF FEE */
				
				
				SET sisaSelling = maSellingValue;
				SET sisaListing = maListingValue;
				
				
				INSERT INTO calculation_detail(ccldSisi, ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
				VALUES ("Office", listFranchiseId, closingId, CONCAT('Payable to Listing Office'), ABS(feeMAList), 3, '', seq, NOW());

				INSERT INTO calculation_detail(ccldSisi, ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
				VALUES ("Office", sellFranchiseId, closingId, CONCAT('Payable to Selling Office'), ABS(feeMASell), 3, '', seq, NOW());
				/* END TAMBAH MA OFF FEE */
				
			END BLOCK14;	
			
			SET seq = seq + 1;
			
		
			INSERT INTO calculation_detail(ccldSisi, ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
			VALUES ("Komisi", listFranchiseId, closingId, CONCAT('Komisi yang diperhitungkan'), sisaListing+sisaSelling, 0,'api/franchisefee', seq, NOW());
		
		ELSE

			BLOCK3: BEGIN
				DECLARE mmId1 INTEGER;
				DECLARE mmId2 INTEGER;
				DECLARE mmPercentage1 DOUBLE;
				DECLARE mmPercentage2 DOUBLE;
				DECLARE mmMoneter1 DOUBLE;
				DECLARE mmMoneter2 DOUBLE;
				DECLARE mmListingValue DOUBLE DEFAULT 0; 
				DECLARE mmSellingValue DOUBLE DEFAULT 0; 
				
				/* START TAMBAH MA OFF FEE */
				DECLARE maListingValue DOUBLE DEFAULT 0; 
				DECLARE maSellingValue DOUBLE DEFAULT 0; 
				/* END TAMBAH MA OFF FEE */
				
				
				
				
				DECLARE headId INTEGER;
				DECLARE headName VARCHAR(100);
				DECLARE jumlah INTEGER DEFAULT 0;
				DECLARE i INTEGER DEFAULT 0;
				
				IF sellFranchiseId IS NULL OR sellFranchiseId = 0 THEN	
					SELECT COUNT(mcmfId) FROM master_custom_split_membership_franchise
					WHERE mcmfListId = listingId AND mcmfMmbsId = agentId INTO cek;
					
					IF cek = 0 THEN
						SELECT msmfFrofId FROM master_split_membership_franchise
						WHERE msmfMmbsId = agentId LIMIT 1 INTO sellFranchiseId;
					ELSE
						SELECT mcmfFrofId FROM master_custom_split_membership_franchise
						WHERE mcmfListId = listingId AND mcmfMmbsId = agentId INTO sellFranchiseId;
					END IF;
				END IF;

				SELECT mmagMmbsId1, mmagMmbsId2, COALESCE(mmagPercentage1,0), COALESCE(mmagPercentage2,0), COALESCE(mmagMoneter1,0), COALESCE(mmagMoneter2,0)				
				FROM member_aggrement WHERE mmagListId = listingId AND (mmagAgtyId = 1 or mmagAgtyId = 6) LIMIT 1
				INTO mmId1, mmId2, mmPercentage1, mmPercentage2, mmMoneter1, mmMoneter2;
				
				/*				
				SELECT COALESCE(mmMoneter1 + ( comm * mmPercentage1/100),0) INTO mmListingValue;
				SELECT COALESCE(mmMoneter2 + ( comm * mmPercentage2/100),0) INTO mmSellingValue;
				*/
				
				/* 			TAMBAHAN		 */
				SET cekAmountAndPercentage = comm - mmMoneter1 - mmMoneter2;
				IF cekAmountAndPercentage < 0 THEN
                	SET mmListingValue = 0;
					SET mmSellingValue = 0;
				ELSE
					SELECT COALESCE(mmMoneter1 + ( cekAmountAndPercentage * mmPercentage1/100),0) INTO mmListingValue;
					SELECT COALESCE(mmMoneter2 + ( cekAmountAndPercentage * mmPercentage2/100),0) INTO mmSellingValue;
                END IF;
				
				/* 			END		 */
				
				IF mmListingValue = 0 AND mmSellingValue = 0 THEN
                	SET mmListingValue = ( comm * 50/100);
					SET mmSellingValue = ( comm * 50/100);
                    SET mmId1 = listOwner;
                    SET mmId2 = listOwner;
                END IF;
				/*
					CALL `sp_refferal_commission`(closingId, listingId, mmSellingValue, mmListingValue, customerId, seq);
				*/
				
				/*
					TAMBAH
				*/
				SELECT COUNT(*) FROM `member_aggrement_detail` WHERE `madlListId` = listingId INTO multiCobrokingStatus;
				
				
				
				/* START TAMBAH MA OFF FEE */
				SET maListingValue = mmListingValue; 
				SET maSellingValue = mmSellingValue;
				/* END TAMBAH MA OFF FEE */
				
				IF multiCobrokingStatus = 0 THEN
					
					CALL `sp_refferal_commission`(closingId, listingId, mmSellingValue, mmListingValue, customerId, seq);
				
					CALL `sp_office_fee_calculation`(closingId, listingId, listFranchiseId, mmListingValue, feeHOList, 'Listing', hirarki, seq);
					/* 
					INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
					VALUES(listingId, 1, mmId1, mmPercentage1, mmMoneter1, 1, mmListingValue);
					*/
					
					CALL `sp_office_fee_calculation`(closingId, listingId, sellFranchiseId, mmSellingValue, feeHOSell, 'Selling', hirarki, seq);
					/*
					INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
					VALUES(listingId, 1, mmId2, mmPercentage2, mmMoneter2, 1, mmSellingValue);
					*/
					

					/* START TAMBAH MA OFF FEE */
					CALL `sp_membership_franchise_fee_calculation`(mmId1, closingId, listingId, listFranchiseId, maListingValue, feeMAList, 'Listing', hirarki, seq);
					INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
					VALUES(listingId, 1, mmId1, mmPercentage1, mmMoneter1, 1, maListingValue);

					CALL `sp_membership_franchise_fee_calculation`(mmId2, closingId, listingId, sellFranchiseId, maSellingValue, feeMASell, 'Selling', hirarki, seq);
					INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
					VALUES(listingId, 1, mmId2, mmPercentage2, mmMoneter2, 1, maSellingValue);
					
					/* END TAMBAH MA OFF FEE */
					
					
				END IF;
				
				IF multiCobrokingStatus > 0 THEN
				
					SET mmListingValue = 0;
					SET mmSellingValue = 0;	
				/*
					INI PROSES NYA
				*/
				
				/*
					CALL `sp_temp_cobroking_commission`(listingId, 1);
					CALL `sp_temp_cobroking_commission`(listingId, 2);
				*/
					CALL sp_temp_cobroking_commission_fixed (listingId, 1,comm);
					CALL sp_temp_cobroking_commission_fixed (listingId, 2,comm);
			
					BLOCK99: BEGIN

					DECLARE cobroking_comm_cursor CURSOR FOR SELECT kingMmbsId, kingOffice, kingPercentage, kingMoneter, kingAgtyId, kingValue FROM cobroking_comm;	
						
					DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished_cobroking = 1;
				
					OPEN cobroking_comm_cursor;
					cobroking_start_loop:LOOP
					FETCH cobroking_comm_cursor INTO xxxxMmbsId, xxxxOffice, xxxxPercentage, xxxxMoneter, xxxxType, xxxxValue; 
					IF finished_cobroking = 1 THEN 
						LEAVE cobroking_start_loop;
					ELSE
					/*
						IF xxxxType = 1 THEN
							SET xxxxValue = 0;
							SELECT COALESCE(xxxxMoneter + ( mmListingValue * xxxxPercentage/100),0) INTO xxxxValue;
							
							CALL `sp_office_fee_calculation`(closingId, listingId, xxxxOffice, xxxxValue, feeHOList, 'Listing', hirarki, seq);
							INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
							VALUES(listingId, 1, xxxxMmbsId, xxxxPercentage, xxxxMoneter, 1, xxxxValue);
						ELSE
						
							SET xxxxValue = 0;
							SELECT COALESCE(xxxxMoneter + ( mmSellingValue * xxxxPercentage/100),0) INTO xxxxValue;
							
							CALL `sp_office_fee_calculation`(closingId, listingId, xxxxOffice, xxxxValue, feeHOSell, 'Selling', hirarki, seq);
							INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
							VALUES(listingId, 1, xxxxMmbsId, xxxxPercentage, xxxxMoneter, 1, xxxxValue);
						END IF;
					*/
					
						IF xxxxType = 1 THEN
						
							/*
							SET xxxxValue = 0;
							SELECT COALESCE(xxxxMoneter + ( comm * xxxxPercentage/100),0) INTO xxxxValue;
							*/
						
						
							CALL `sp_refferal_commission_fixed`(closingId, listingId, xxxxValue, customerId, seq, 4);
							
							CALL `sp_office_fee_calculation_fixed`(closingId, listingId, xxxxOffice, xxxxValue, feeHOList, 'Listing', hirarki, seq);
							INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
							VALUES(listingId, 1, xxxxMmbsId, xxxxPercentage, xxxxMoneter, 1, xxxxValue);
							SET mmListingValue = mmListingValue + xxxxValue;
						ELSE
							/*
							SET xxxxValue = 0;
							SELECT COALESCE(xxxxMoneter + ( comm * xxxxPercentage/100),0) INTO xxxxValue;
							*/
							
							CALL `sp_refferal_commission_fixed`(closingId, listingId, xxxxValue, customerId, seq, 5);
							
							CALL `sp_office_fee_calculation_fixed`(closingId, listingId, xxxxOffice, xxxxValue, feeHOSell, 'Selling', hirarki, seq);
							INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
							VALUES(listingId, 1, xxxxMmbsId, xxxxPercentage, xxxxMoneter, 1, xxxxValue);
							SET mmSellingValue = mmSellingValue + xxxxValue;
						END IF;

					END IF;
					END LOOP cobroking_start_loop;
					CLOSE cobroking_comm_cursor;
					END BLOCK99;
					
				END IF;
	
				/*
				SAMPAI SINI

				*/
				
			/* 
				ILANGIN DULU
				
				CALL `sp_office_fee_calculation`(closingId, listingId, listFranchiseId, mmListingValue, feeHOList, 'Listing', hirarki, seq);
				INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
				VALUES(listingId, 1, mmId1, mmPercentage1, mmMoneter1, 1, mmListingValue);

				CALL `sp_office_fee_calculation`(closingId, listingId, sellFranchiseId, mmSellingValue, feeHOSell, 'Selling', hirarki, seq);
				INSERT INTO member_comm(mmcoListId, mmcoAgtyId, mmcoMmbsId, mmcoPercentage, mmcoMoneter,mmcoSequence,mmcoValue)
				VALUES(listingId, 1, mmId2, mmPercentage2, mmMoneter2, 1, mmSellingValue);
			
			*/

				SET jumlah = 0;
				SELECT frofCompId FROM franchise_office WHERE frofId = listFranchiseId INTO headId;
				SELECT compName FROM company WHERE compId = headId INTO headName;
				 	
				/*	SEBELUM FEE MA OFFICE
				SET sisaSelling = mmSellingValue;
				SET sisaListing = mmListingValue;
				*/

				SET seq = seq + 1;
				
				INSERT INTO calculation_detail(ccldSisi, ccldHO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
				VALUES ("Pay",headId, closingId, CONCAT('Payable to ',headName), ABS(feeHOSell+feeHOList), 2, 'api/franchisefee', seq, NOW());


				/* START TAMBAH MA OFF FEE */
				
				
				SET sisaSelling = maSellingValue;
				SET sisaListing = maListingValue;
				
				
				INSERT INTO calculation_detail(ccldSisi, ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
				VALUES ("Office", listFranchiseId, closingId, CONCAT('Payable to Listing Office'), ABS(feeMAList), 3, '', seq, NOW());

				INSERT INTO calculation_detail(ccldSisi, ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
				VALUES ("Office", sellFranchiseId, closingId, CONCAT('Payable to Selling Office'), ABS(feeMASell), 3, '', seq, NOW());
				/* END TAMBAH MA OFF FEE */
				

			END BLOCK3;
			
			SET seq = seq + 1;
			
			INSERT INTO calculation_detail(ccldSisi,ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldFromApi, ccldSequence, ccldCreatedTime) 
			VALUES ("Komisi", listFranchiseId, closingId, CONCAT('Komisi yang diperhitungkan'), sisaListing+sisaSelling, 0, 'api/franchisefee', seq, NOW());

	
	END IF; 
	
	CALL `sp_temp_member_commission`(listingId, 2);
	
	CALL `sp_temp_member_commission`(listingId, 3);

	CALL `sp_calculate_temp_member_commission`(listingId, 2, sisaSelling);

	CALL `sp_calculate_temp_member_commission`(listingId, 3, sisaListing);
	    
	BLOCK10: BEGIN
		DECLARE tempType INTEGER DEFAULT 0;
	
		DECLARE commMmbsId INTEGER;
		DECLARE commFrofId INTEGER;
		DECLARE commValue INTEGER DEFAULT 0;
		DECLARE mmbsValue DOUBLE DEFAULT 0;
		DECLARE frofValue DOUBLE DEFAULT 0;	
		DECLARE frofId INTEGER;
		DECLARE percentageMmbs DOUBLE;
		DECLARE percentageFrof DOUBLE;
		DECLARE moneterMmbs INTEGER;
		DECLARE moneterFrof INTEGER;

		DECLARE seqList INTEGER DEFAULT 0;
		DECLARE seqSell INTEGER DEFAULT 0;
        DECLARE seqBroke INTEGER DEFAULT 0;
        DECLARE minBrokeId INTEGER DEFAULT 0;
        DECLARE maxBrokeId INTEGER DEFAULT 0;
                
		DECLARE jumlah INTEGER default 0;
		DECLARE cek INTEGER default 0;
		DECLARE cekCustom INTEGER default 0;
		DECLARE finished INTEGER DEFAULT 0;
		DECLARE member_id_cursor CURSOR FOR SELECT distinct(mmcoMmbsId)
		FROM member_comm WHERE mmcoListId = listingId;
			
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
			
		OPEN member_id_cursor;
		start_loop8: LOOP
			
		FETCH member_id_cursor INTO commMmbsId;
		IF finished = 1 THEN 
			LEAVE start_loop8;
		ELSE
        	IF multiCobrokingStatus > 0 THEN
				SELECT COALESCE(MAX(mmcoSequence),0) FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId AND mmcoAgtyId = 3 INTO seqList;
				
				SELECT COALESCE(MIN(mmcoSequence),0) FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId AND mmcoAgtyId = 1 INTO seqBroke;

				SELECT COALESCE(MAX(mmcoSequence),0) FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId AND mmcoAgtyId = 2 INTO seqSell;
				
				BLOCK20: BEGIN
					DECLARE commValue DOUBLE;
					DECLARE commType INTEGER;
	   
					DECLARE i INTEGER DEFAULT 0;
					DECLARE finished INTEGER DEFAULT 0;
					DECLARE comm_value_cursor CURSOR for 
					SELECT mmcoAgtyId, mmcoValue
					FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId 
					AND ((mmcoSequence = seqList AND mmcoAgtyId = 3) 
					OR (mmcoSequence = seqSell AND mmcoAgtyId = 2)
					OR (mmcoSequence = seqBroke AND	mmcoAgtyId = 1))
					ORDER BY mmcoSequence DESC LIMIT 1;
					
					DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
					
					OPEN comm_value_cursor;
					start_loop20: LOOP
				  
					FETCH comm_value_cursor INTO commType, commValue;

					IF finished = 1 THEN 
						LEAVE start_loop20;
					ELSE
						IF commType = 1 THEN
							SELECT kingAgtyId FROM cobroking_comm WHERE kingListId = listingId and kingMmbsId = commMmbsId INTO tempType;
							IF tempType = 1 THEN
								SET tipe = 'Co-Broking Listing';
							ELSE
								SET tipe = 'Co-Broking Selling';
							END IF;
						ELSE
							IF commType = 2 THEN
								SET tipe = 'Co-Selling';
							END IF;
							IF commType = 3 THEN
								SET tipe = 'Co-Listing';
							END IF;
						END IF;
						
						SELECT COUNT(mcmfId) FROM master_custom_split_membership_franchise 
						WHERE mcmfMmbsId = commMmbsId AND mcmfListId = listingId INTO cekCustom;
							
						IF commType = 2 OR tempType = 2 THEN
							IF cekCustom = 0 THEN
								CALL `sp_default_split_commission`(closingId, commMmbsId, commValue, listFranchiseId, listingId, tipe, seq);
							ELSE
								CALL `sp_custom_split_commission`(closingId, commMmbsId, commValue, listingId, tipe, seq);		
							END IF;
						END IF;
						
						IF commType = 3 OR tempType = 1 THEN
							IF cekCustom = 0 THEN
								CALL `sp_default_split_commission`(closingId, commMmbsId, commValue, sellFranchiseId, listingId, tipe, seq);
							ELSE
								CALL `sp_custom_split_commission`(closingId, commMmbsId, commValue, listingId, tipe, seq);	
							END IF;
						END IF;
					END IF;
					END LOOP start_loop20;
					CLOSE comm_value_cursor;
				END BLOCK20;
			ELSE
			
        	SELECT COALESCE(MAX(mmcoSequence),0) FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId AND mmcoAgtyId = 3 INTO seqList;
            
            SELECT COALESCE(MIN(mmcoSequence),0) FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId AND mmcoAgtyId = 1 INTO seqBroke;
	 			
            SELECT MIN(mmcoId) FROM member_comm WHERE mmcoListId = listingId AND mmcoAgtyId = 1 INTO minBrokeId;
  	
			BLOCK11: BEGIN
				DECLARE commValue DOUBLE;
				DECLARE commType INTEGER;
   
       			DECLARE i INTEGER DEFAULT 0;
				DECLARE finished INTEGER DEFAULT 0;
				DECLARE comm_value_cursor CURSOR for 
				SELECT mmcoAgtyId, mmcoValue
				FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId 
				AND ((mmcoSequence = seqList AND mmcoAgtyId = 3) 
                OR (mmcoSequence = seqBroke AND	mmcoAgtyId = 1 AND mmcoId = minBrokeId))
                ORDER BY mmcoSequence DESC LIMIT 1;
                
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
              
     			OPEN comm_value_cursor;
				start_loop9: LOOP
              
				FETCH comm_value_cursor INTO commType, commValue;
				
                   
				IF finished = 1 THEN 
					LEAVE start_loop9;
				ELSE
						IF commMmbsId = listOwner THEN
							SET tipe = 'Listing';
						ELSE
							IF commType = 1 THEN
								SET tipe = 'Listing';
							ELSE
								IF commType = 2 THEN
									SET tipe = 'Co-Selling';
								END IF;
								IF commType = 3 THEN
									SET tipe = 'Co-Listing';
								END IF;
							END IF;
						END IF;
						
						SELECT COUNT(mcmfId) FROM master_custom_split_membership_franchise 
						WHERE mcmfMmbsId = commMmbsId AND mcmfListId = listingId INTO cekCustom;
						
						IF cekCustom = 0 THEN
							CALL `sp_default_split_commission`(closingId, commMmbsId, commValue, listFranchiseId, listingId, tipe, seq);
							
						ELSE
							CALL `sp_custom_split_commission`(closingId, commMmbsId, commValue, listingId, tipe, seq);	
							
						END IF;
						
						
				END IF;
				END LOOP start_loop9;
				CLOSE comm_value_cursor;
				END BLOCK11;
				
				SELECT COALESCE(MAX(mmcoSequence),0) FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId AND mmcoAgtyId = 2 INTO seqSell;
            
	            SELECT COALESCE(MIN(mmcoSequence),0) FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId AND mmcoAgtyId = 1 INTO seqBroke;
		 			
	            SELECT MAX(mmcoId) FROM member_comm WHERE mmcoListId = listingId AND mmcoAgtyId = 1 INTO maxBrokeId;

				BLOCK18: BEGIN
					DECLARE commValue DOUBLE;
					DECLARE commType INTEGER;

					DECLARE i INTEGER DEFAULT 0;
					DECLARE finished INTEGER DEFAULT 0;
					DECLARE comm_value_cursor CURSOR for 
					SELECT mmcoAgtyId, mmcoValue
					FROM member_comm WHERE mmcoListId = listingId AND mmcoMmbsId = commMmbsId 
					AND ((mmcoSequence = seqSell AND mmcoAgtyId = 2) 
                	OR (mmcoSequence = seqBroke AND	mmcoAgtyId = 1 AND mmcoId = maxBrokeId))
                    ORDER BY mmcoSequence DESC LIMIT 1;

					DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
					
					OPEN comm_value_cursor;
					start_loop18: LOOP
					FETCH comm_value_cursor INTO commType, commValue;
					
					IF finished = 1 THEN 
						LEAVE start_loop18;
					ELSE
						IF commMmbsId = agentId THEN
							SET tipe = 'Selling';
						ELSE
							IF commType = 1 THEN
								SET tipe = 'Selling';
				
							ELSE
								IF commType = 2 THEN
									SET tipe = 'Co-Selling';
								END IF;
								IF commType = 3 THEN
									SET tipe = 'Co-Listing';
								END IF;
							END IF;
						END IF; 

					
						SELECT COUNT(mcmfId) FROM master_custom_split_membership_franchise 
						WHERE mcmfMmbsId = commMmbsId AND mcmfListId = listingId INTO cekCustom;
						
						IF cekCustom = 0 THEN
							CALL `sp_default_split_commission`(closingId, commMmbsId, commValue, sellFranchiseId, listingId, tipe, seq);
						ELSE
							CALL `sp_custom_split_commission`(closingId, commMmbsId, commValue, listingId, tipe, seq);	
						END IF;
					
					END IF;
				END LOOP start_loop18;
				CLOSE comm_value_cursor;
				END BLOCK18;
			END IF;	
			END IF;
			END LOOP start_loop8;
			CLOSE member_id_cursor;
		END BLOCK10;
		
	BLOCK12: BEGIN
		DECLARE memberId INTEGER;
		DECLARE detailId INTEGER;
		DECLARE feeNameMA VARCHAR(100);
		DECLARE feeNameFO VARCHAR(100);
		DECLARE feeFrofId INTEGER;
		DECLARE feeSisaMA DOUBLE DEFAULT 0;
		DECLARE feeSisaFO DOUBLE DEFAULT 0;
		DECLARE cek INTEGER DEFAULT 0;
		
		DECLARE finished INTEGER DEFAULT 0;
		DECLARE member_id_cursor CURSOR for SELECT distinct(ccldMAListing)
		FROM calculation_detail JOIN calculation 
		ON calculation.cclhId = calculation_detail.ccldCclhId
		WHERE cclhListId = listingId AND ccldMAListing IS NOT NULL;
			
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
		
		OPEN member_id_cursor;
		start_loop10: LOOP
			
		FETCH member_id_cursor INTO memberId;
		IF finished = 1 THEN 
			LEAVE start_loop10;
		ELSE
			SELECT SUM(ccldValue) FROM calculation_detail 
			WHERE ccldCclhId = closingId AND ccldMAListing = memberId AND ccldName LIKE 'MA %Commission' INTO feeSisaMA;
			
			SET feeNameMA = 'MA Commission'; 
			SET feeNameFO = 'FO Commission';
			
			SELECT msmfFrofId FROM master_split_membership_franchise WHERE msmfMmbsId = memberId INTO feeFrofId;

			SELECT SUM(ccldValue) FROM calculation_detail 
			WHERE ccldCclhId = closingId AND ccldFO = feeFrofId AND ccldName LIKE 'FO %Commission' INTO feeSisaFO;
			
			CALL `sp_member_fee`(listingId, closingId, memberId, feeSisaMA, feeSisaFO, seq);  

			INSERT INTO calculation_detail(ccldMAListing, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldSequence, ccldCreatedTime) 
			VALUES (memberId, closingId, CONCAT('Total ',feeNameMA), feeSisaMA, 0, seq, NOW());
			
			SELECT COUNT(ccldId) FROM calculation_detail 
			WHERE ccldCclhId = closingId AND ccldName = CONCAT('Total ',feeNameFO) AND ccldFO = feeFrofId INTO cek;
			
			IF cek = 0 THEN
				INSERT INTO calculation_detail(ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldSequence, ccldCreatedTime) 
				VALUES (feeFrofId, closingId, CONCAT('Total ',feeNameFO), feeSisaFO, 0, seq,  NOW());
			ELSE
				Update calculation_detail SET ccldValue = feeSisaFO
				WHERE ccldCclhId = closingId AND ccldName = CONCAT('Total ',feeNameFO) AND ccldFO = feeFrofId;
			END IF;
			
		END IF;
		END LOOP start_loop10;
		CLOSE member_id_cursor;
			
	END BLOCK12;

	BLOCK13: BEGIN
		DECLARE memberId INTEGER;
		DECLARE detailId INTEGER;
		DECLARE feeNameMA VARCHAR(100);
		DECLARE feeNameFO VARCHAR(100);
		DECLARE feeFrofId INTEGER;
		DECLARE feeSisaMA DOUBLE DEFAULT 0;
		DECLARE feeSisaFO DOUBLE DEFAULT 0;
		DECLARE cek INTEGER DEFAULT 0;
		
		DECLARE finished INTEGER DEFAULT 0;
		DECLARE member_id_cursor CURSOR for SELECT distinct(ccldMASelling)
		FROM calculation_detail JOIN calculation 
		ON calculation.cclhId = calculation_detail.ccldCclhId
		WHERE cclhListId = listingId AND ccldMASelling IS NOT NULL;
			
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
		
		OPEN member_id_cursor;
		start_loop11: LOOP
			
		FETCH member_id_cursor INTO memberId;
		IF finished = 1 THEN 
			LEAVE start_loop11;
		ELSE
			SELECT SUM(ccldValue) FROM calculation_detail 
			WHERE ccldCclhId = closingId AND ccldMASelling = memberId AND ccldName LIKE 'MA %Commission' INTO feeSisaMA;
			
			SET feeNameMA = 'MA Commission'; 
			SET feeNameFO = 'FO Commission';
			
			SELECT msmfFrofId FROM master_split_membership_franchise WHERE msmfMmbsId = memberId INTO feeFrofId;

			SELECT SUM(ccldValue) FROM calculation_detail 
			WHERE ccldCclhId = closingId AND ccldFO = feeFrofId AND ccldName LIKE 'FO %Commission' INTO feeSisaFO;
			
			CALL `sp_member_fee`(listingId, closingId, memberId, feeSisaMA, feeSisaFO, seq);  

			INSERT INTO calculation_detail(ccldMASelling, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldSequence, ccldCreatedTime) 
			VALUES (memberId, closingId, CONCAT('Total ',feeNameMA), feeSisaMA, 0, seq, NOW());
			
			SELECT COUNT(ccldId) FROM calculation_detail 
			WHERE ccldCclhId = closingId AND ccldName = CONCAT('Total ',feeNameFO) AND ccldFO = feeFrofId INTO cek;
			
			IF cek = 0 THEN
				INSERT INTO calculation_detail(ccldFO, ccldCclhId, ccldName, ccldValue, ccldMinus, ccldSequence, ccldCreatedTime) 
				VALUES (feeFrofId, closingId, CONCAT('Total ',feeNameFO), feeSisaFO, 0, seq,  NOW());
			ELSE
				UPDATE calculation_detail SET ccldValue = feeSisaFO
				WHERE ccldCclhId = closingId AND ccldName = CONCAT('Total ',feeNameFO) AND ccldFO = feeFrofId;
			END IF;
		END IF;
		END LOOP start_loop11;
		CLOSE member_id_cursor;
			
	END BLOCK13;
	
	UPDATE listing set listType = 5 where listId = listingId;

	COMMIT;
	
	SELECT listType FROM listing where listId = listingId;
	
END