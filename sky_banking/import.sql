CREATE TABLE IF NOT EXISTS `banking_users` (
  `identifier` varchar(80) NOT NULL,
  `bank_number` varchar(8) NOT NULL,
  `last_transactions` longtext,
  `last_transfers` longtext,
  `stats` longtext,
  `totals` longtext,
  PRIMARY KEY (`identifier`)
);