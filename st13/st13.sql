-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1
-- Время создания: Ноя 29 2015 г., 12:35
-- Версия сервера: 5.5.25
-- Версия PHP: 5.3.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `st13`
--

-- --------------------------------------------------------

--
-- Структура таблицы `st13`
--

CREATE TABLE IF NOT EXISTS `st13` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fio` varchar(250) NOT NULL,
  `age` int(11) NOT NULL,
  `pos` varchar(250) NOT NULL,
  `wage` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=13 ;

--
-- Дамп данных таблицы `st13`
--

INSERT INTO `st13` (`id`, `fio`, `age`, `pos`, `wage`) VALUES
(8, 'фыва', 56, '0', '300'),
(9, 'Михаил', 100, '0', '350'),
(10, 'Дмитрий', 11, '0', '370'),
(11, 'Церен', 59, '1', '1000000'),
(12, 'Михаил', 45, '1', '1000000');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
