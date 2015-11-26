-- phpMyAdmin SQL Dump
-- version 4.0.10.10
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1:3306
-- Время создания: Ноя 07 2015 г., 21:19
-- Версия сервера: 5.5.45
-- Версия PHP: 5.3.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `lab3`
--

-- --------------------------------------------------------

--
-- Структура таблицы `st29`
--

CREATE TABLE IF NOT EXISTS `st29` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fio` varchar(256) NOT NULL,
  `age` int(11) NOT NULL,
  `dolzh` varchar(256) NOT NULL,
  `comp` varchar(256) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=32 ;

--
-- Дамп данных таблицы `st29`
--

INSERT INTO `st29` (`id`, `fio`, `age`, `dolzh`, `comp`) VALUES
(1, 'Вадик', 56, '0', '-'),
(5, 'Вазген', 100, '1', 'Газпром'),
(14, 'Димон', 11, '1', 'ЦБ'),
(30, 'Игорь', 55, '0', '-'),
(31, 'Бадюк', 45, '1', 'Бадюкпро');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
