/*
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

-- Mysql Version: 5.5.16
-- PHP Version : 5.3.8

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


DROP TABLE IF EXISTS `comments`;
CREATE TABLE IF NOT EXISTS `comments` (
  `commentId` int(11) NOT NULL AUTO_INCREMENT,
  `text` longtext NOT NULL,
  `userId` int(11) NOT NULL,
  `referedComment` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `state` enum('new','approved','rejected','suspended') NOT NULL,
  `page` varchar(512) NOT NULL,
  `product` varchar(256) NOT NULL,
  `version` varchar(128) NOT NULL,
  `visible` enum('true','false') NOT NULL,
  PRIMARY KEY (`commentId`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

ALTER TABLE comments AUTO_INCREMENT = 1;


DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `userId` int(11) NOT NULL AUTO_INCREMENT,
  `userName` varchar(128) NOT NULL,
  `email` varchar(256) NOT NULL,
  `name` varchar(256) NOT NULL,
  `company` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL,
  `date` datetime NOT NULL,
  `level` enum('user','admin','moderator') NOT NULL DEFAULT 'user',
  `status` enum('created','validated','suspended') NOT NULL DEFAULT 'created',
  `notifyAll` enum('yes','no') NOT NULL DEFAULT 'no',
  `notifyReply` enum('yes','no') NOT NULL DEFAULT 'no',
  `notifyPage` enum('yes','no') NOT NULL DEFAULT 'no',
  PRIMARY KEY (`userId`),
  UNIQUE KEY `userName` (`userName`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;


INSERT INTO `users` (`userId`, `userName`, `email`, `name`, `company`, `password`, `date`, `level`, `status`, `notifyAll`, `notifyReply`, `notifyPage`) VALUES
(1, 'anonymous', 'anonymous@anonymous.com', 'Anonymous', 'NA', '5ea722eade385e12481779133307e64c', '2012-01-01 00:00:00', 'user', 'validated', 'no', 'no', 'no');

DROP TABLE IF EXISTS `webhelp`;
CREATE TABLE IF NOT EXISTS `webhelp` (
  `parameter` varchar(256) NOT NULL,
  `value` varchar(512) NOT NULL,
  `product` varchar(256) NOT NULL,
  `version` varchar(256) NOT NULL,
  UNIQUE KEY `parameter` (`parameter`,`product`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


INSERT INTO `webhelp` (`parameter`, `value`, `product`, `version`) VALUES
('databaseVersion', '1', 'oXygen','@PRODUCT_VERSION@');


/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */
