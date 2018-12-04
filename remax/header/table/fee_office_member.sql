

--
-- Table structure for table `master_fee_agent`
--

CREATE TABLE `master_fee_agent` (
`feeaId` smallint(5) unsigned NOT NULL,
  `feeaCode` varchar(50) DEFAULT NULL,
  `feeaCompId` smallint(8) unsigned DEFAULT NULL,
  `feeaCreatedTime` datetime DEFAULT NULL,
  `feeaCreatedUserId` varchar(255) DEFAULT '',
  `feeaDelete` int(1) DEFAULT '0'
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `master_fee_agent_language`
--

CREATE TABLE `master_fee_agent_language` (
`fealId` int(10) unsigned NOT NULL,
  `fealFeeaId` smallint(5) unsigned NOT NULL,
  `fealLangId` tinyint(3) unsigned NOT NULL,
  `fealNick` varchar(25) DEFAULT NULL,
  `fealName` varchar(255) DEFAULT NULL,
  `fealCreatedUserId` varchar(255) DEFAULT NULL,
  `fealCreatedTime` datetime DEFAULT NULL,
  `fealUpdatedUserId` varchar(255) DEFAULT NULL,
  `fealUpdatedTime` datetime DEFAULT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `master_formula_fee`
--

CREATE TABLE `master_formula_fee` (
`msffId` int(11) NOT NULL,
  `msffName` varchar(100) DEFAULT NULL,
  `msffData` text,
  `msffCreatedUserId` varchar(255) DEFAULT NULL,
  `msffCreatedTime` datetime DEFAULT NULL,
  `msffUpdatedUserId` varchar(255) DEFAULT NULL,
  `msffUpdatedTime` datetime DEFAULT NULL,
  `msffDelete` int(1) DEFAULT NULL,
  `msffCompId` smallint(8) DEFAULT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `membership_franchise_fee`
--

CREATE TABLE `membership_franchise_fee` (
`mffeId` int(10) unsigned NOT NULL,
  `mffeMmbsId` int(10) unsigned DEFAULT NULL,
  `mffeFrofId` mediumint(8) unsigned DEFAULT NULL,
  `mffeFeeaId` smallint(5) unsigned DEFAULT NULL,
  `mffeMoneter` float DEFAULT NULL,
  `mffePercentage` float DEFAULT NULL,
  `mffeSequence` int(10) unsigned NOT NULL,
  `mffeEndDate` datetime DEFAULT NULL,
  `mffeCutoffDate` date DEFAULT NULL,
  `mffeCutoffDay` smallint(5) DEFAULT NULL,
  `mffeCutoffTime` time DEFAULT NULL,
  `mffeCutoffType` smallint(5) DEFAULT NULL,
  `mffeCutoffSettingDate` date DEFAULT NULL,
  `mffeCutoffSettingDay` smallint(5) DEFAULT NULL,
  `mffeCutoffSettingTime` time DEFAULT NULL,
  `mffeCutoffSettingType` smallint(5) DEFAULT NULL,
  `mffeCreatedUserId` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `mffeCreatedTime` datetime DEFAULT NULL,
  `mffeUpdatedUserId` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `mffeUpdatedTime` datetime DEFAULT NULL,
  `mffeDelete` int(1) DEFAULT '0',
  `mffeMfeeChildId` smallint(5) DEFAULT NULL,
  `mffeStartDate` datetime DEFAULT NULL,
  `mffeCompId` smallint(8) unsigned DEFAULT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `master_fee_agent`
--
ALTER TABLE `master_fee_agent`
 ADD PRIMARY KEY (`feeaId`);

--
-- Indexes for table `master_fee_agent_language`
--
ALTER TABLE `master_fee_agent_language`
 ADD PRIMARY KEY (`fealId`), ADD UNIQUE KEY `fealMfeeId_2` (`fealFeeaId`,`fealLangId`), ADD KEY `fealLangId` (`fealLangId`), ADD KEY `fealMfeeId` (`fealFeeaId`);

--
-- Indexes for table `master_formula_fee`
--
ALTER TABLE `master_formula_fee`
 ADD PRIMARY KEY (`msffId`);

--
-- Indexes for table `membership_franchise_fee`
--
ALTER TABLE `membership_franchise_fee`
 ADD PRIMARY KEY (`mffeId`), ADD KEY `membership_franchise_fee_ibfk_1` (`mffeFrofId`), ADD KEY `membership_franchise_fee_ibfk_2` (`mffeFeeaId`), ADD KEY `membership_franchise_fee_ibfk_7` (`mffeCutoffSettingType`), ADD KEY `membership_franchise_fee_ibfk_8` (`mffeMfeeChildId`), ADD KEY `membership_franchise_fee_ibfk_6` (`mffeCutoffType`), ADD KEY `mmfeMmbsId` (`mffeMmbsId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `master_fee_agent`
--
ALTER TABLE `master_fee_agent`
MODIFY `feeaId` smallint(5) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `master_fee_agent_language`
--
ALTER TABLE `master_fee_agent_language`
MODIFY `fealId` int(10) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `master_formula_fee`
--
ALTER TABLE `master_formula_fee`
MODIFY `msffId` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1;
--
-- AUTO_INCREMENT for table `membership_franchise_fee`
--
ALTER TABLE `membership_franchise_fee`
MODIFY `mffeId` int(10) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `master_fee_agent_language`
--
ALTER TABLE `master_fee_agent_language`
ADD CONSTRAINT `master_fee_agent_language_ibfk_1` FOREIGN KEY (`fealFeeaId`) REFERENCES `master_fee_agent` (`feeaId`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `master_fee_agent_language_ibfk_2` FOREIGN KEY (`fealLangId`) REFERENCES `language` (`langId`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `membership_franchise_fee`
--
ALTER TABLE `membership_franchise_fee`
ADD CONSTRAINT `FK_mffeFeeaId` FOREIGN KEY (`mffeFeeaId`) REFERENCES `master_fee_agent` (`feeaId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
ADD CONSTRAINT `membership_franchise_fee_ibfk_` FOREIGN KEY (`mffeCutoffSettingType`) REFERENCES `cutoff_type` (`cutyId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
ADD CONSTRAINT `membership_franchise_fee_ibfk_6` FOREIGN KEY (`mffeCutoffType`) REFERENCES `cutoff_type` (`cutyId`) ON DELETE NO ACTION ON UPDATE NO ACTION;


