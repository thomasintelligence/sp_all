                
                
                SELECT
                listId AS ID_SYSTEM,
                litlName AS STATUS_SYSTEM,
                frofOfficeName AS OFFICE_NAME,
                CONCAT(
                 IF (ISNULL(mmbsFirstName), '', mmbsFirstName), ' ',   
                        IF (ISNULL(mmbsMateName), '', mmbsMateName), ' ',
                        IF (ISNULL(mmbsLastName), '', mmbsLastName)
                ) AS NAME, 

                
                lstlName AS 'CONDITION',
                lsclName AS STATUS,
                ltlgName AS LEGAL,
                listListingPrice AS 'PRICE',
                listTitle AS TITLE,
                listDescription AS 'DESCRIPTION',
                listStreetName AS ADDRESS,
                mctrDescription AS COUNTRY,
                mprvDescription AS PROVINCE,
                mctyDescription AS CITY,
                msdsDescription AS DISTRICT,
                listBlock AS BLOCK,
                listHouseNumber AS 'NUMBER',
                listPostalCode AS POST_CODE,
                listLandSize AS LAND_SIZE,
                listBuildingSize AS BUILDING_SIZE,
                CONCAT(listBedroom,' + ',IF (ISNULL(listMaidRoom), '0', listMaidRoom)) AS BEDROOM,
                CONCAT(listBathroom,' + ',IF (ISNULL(listMaidBathroom), '0', listMaidBathroom)) AS BATHROOM

                FROM listing
                JOIN memberships ON listMmbsId = mmbsId
                JOIN franchise_office ON listOfficeId = frofId
                JOIN master_listing_type_language ON listType = litlLityId AND litlLangId = 2
                LEFT JOIN master_country ON mctrId = listCountryId
                LEFT JOIN master_province ON mprvId = listProvinceId
                LEFT JOIN master_city ON mctyId = listCityId
                LEFT JOIN master_listing_status_language ON lstlMlstId = listListingStatusId AND lstlLangId = 2 
                JOIN master_listing_category_language ON 	lsclMlscId = listListingCategoryId AND lsclLangId = 2 
                LEFT JOIN master_legal_term_language ON ltlgMltrId = listLegalTermId AND ltlgLangId = 2
                LEFT JOIN master_district ON msdsId = listDistrictId
                
                WHERE listMmbsId IS NOT NULL AND listOfficeId IS NOT NULL AND listType <> 1

