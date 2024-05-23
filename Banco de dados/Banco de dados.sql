-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Tempo de geração: 05-Out-2023 às 12:26
-- Versão do servidor: 10.5.20-MariaDB
-- versão do PHP: 7.3.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `id21214546_metereotech`
--
CREATE DATABASE Meteorotech;
-- --------------------------------------------------------

--
-- Estrutura da tabela `dados_antigos`
--
USE Meteorotech;
CREATE TABLE `dados_antigos` (
  `id` int(11) NOT NULL,
  `temperatura` decimal(5,2) DEFAULT NULL,
  `umidade` decimal(5,2) DEFAULT NULL,
  `luminosidade` int(11) DEFAULT NULL,
  `datas` date NOT NULL,
  `umidade_solo` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- índices da tabela de dados antigos
ALTER TABLE `dados_antigos`
  ADD PRIMARY KEY (`id`),
  ADD INDEX `idx_datas` (`datas`),
  ADD INDEX `idx_temperatura` (`temperatura`),
  ADD INDEX `idx_umidade` (`umidade`),
  ADD INDEX `idx_umidade_solo` (`umidade_solo`);

--
-- Estrutura da tabela `dados_atuais`
--

CREATE TABLE `dados_atuais` (
  `id` int(11) NOT NULL,
  `temperatura` decimal(5,2) DEFAULT NULL,
  `umidade` decimal(5,2) DEFAULT NULL,
  `luminosidade` int(11) DEFAULT NULL,
  `datas` timestamp NOT NULL DEFAULT current_timestamp(),
  `umidade_solo` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Adicionar índices às tabelas
ALTER TABLE `dados_atuais`
  ADD PRIMARY KEY (`id`),
  ADD INDEX `idx_temperatura` (`temperatura`),
  ADD INDEX `idx_umidade` (`umidade`),
  ADD INDEX `idx_umidade_solo` (`umidade_solo`);

--
-- Estrutura da tabela `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `nome` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `senha` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Adicionar índices às tabelas
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`);

-- Ativar o modo de transação para inserções múltiplas
SET autocommit=0;
START TRANSACTION;

--
-- Extraindo dados da tabela `dados_antigos`
--

INSERT INTO `dados_antigos` (`id`, `temperatura`, `umidade`, `luminosidade`, `datas`, `umidade_solo`) VALUES
(1, 24.00, 55.50, 750, '2023-09-01', 35.00),
(2, 23.50, 56.00, 720, '2023-08-31', 30.00),
(3, 24.50, 55.00, 760, '2023-08-30', 31.00),
(4, 24.20, 54.80, 740, '2023-08-29', 32.00),
(5, 25.50, 60.00, 500, '2023-08-02', 38.00),
(6, 25.00, 60.00, 800, '2023-09-07', 30.00),
(7, 24.00, 55.50, 750, '2023-09-06', 29.50),
(8, 23.50, 56.00, 720, '2023-09-05', 30.20),
(9, 24.50, 55.00, 760, '2023-09-04', 31.00),
(10, 24.00, 55.50, 750, '2023-09-08', 35.00),
(11, 25.00, 60.00, 800, '2023-09-09', 30.00),
(12, 25.20, 57.30, 700, '2023-09-10', 32.10);

--
-- Extraindo dados da tabela `dados_atuais`
--

INSERT INTO `dados_atuais` (`id`, `temperatura`, `umidade`, `luminosidade`, `datas`, `umidade_solo`) VALUES
(1, 25.50, 60.00, 800, '2023-09-03 05:16:18', 32.54);

-- Confirmar a transação
COMMIT;

--
-- Estrutura da tabela `usuario`
--

-- Extraindo dados da tabela `usuario`
--

INSERT INTO `usuario` (`id`, `nome`, `email`, `senha`) VALUES
(1, 'Ricardo', 'ricardofiorini9@gmail.com', 'nino');

-- Índices para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `dados_antigos`
--
ALTER TABLE `dados_antigos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de tabela `dados_atuais`
--
ALTER TABLE `dados_atuais`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
  
  -- Consultas:
  
  -- View para acessar a tabela dados antigos
  CREATE VIEW `view_dados_antigos` AS
  SELECT `id`, `temperatura`, `umidade`, `luminosidade`, `umidade_solo`, `datas`
  FROM `dados_antigos`;
  
  -- View de acesso aos dados antigos por data em ordem crescente
	CREATE VIEW `view_dados_antigos_data_crescente` AS
	SELECT * FROM `dados_antigos`
	ORDER BY `datas` ASC;
  
  -- View para acessar a tabela dados atuais
   CREATE VIEW `view_dados_atuais` AS
   SELECT `id`, `temperatura`, `umidade`, `luminosidade`, `umidade_solo`, `datas`
   FROM `dados_atuais`;
   
   -- View para acesso de todos os dados, caso precise
   CREATE VIEW `view_dados_completos` AS
	SELECT 'Antigo' AS `id`, `temperatura`, `umidade`, `luminosidade`, `umidade_solo`, `datas`
    FROM `dados_antigos`
    UNION ALL
    SELECT 'Atual' AS `id`, `temperatura`, `umidade`, `luminosidade`, `umidade_solo`, `datas`
    FROM `dados_atuais`;
    
    -- Procedimentos: 
    -- Inserir dados atuais na tabela
    
DELIMITER $$    
CREATE PROCEDURE `proc_InserirDadosAtt` (
        IN id int(11),
        IN temperatura decimal(5,2),
        IN umidade decimal(5,2),
        IN luminosidade int(11),
        IN umidade_solo decimal(5,2),
        )
BEGIN
INSERT INTO `dados_atuais`(`temperatura`, `umidade`, `luminosidade`, `umidade_solo`)
	  VALUES (temperatura, umidade, luminosidade, umidade_solo)
END $$
DELIMITER;

    -- Atualização de dados atuais por id
DELIMITER $$    
    CREATE PROCEDURE `proc_AtualizarDadosAtt`(
		IN id int(11),
        IN temperatura decimal(5,2),
        IN umidade decimal(5,2),
        IN luminosidade int(11),
        IN umidade_solo decimal(5,2)
    )
    BEGIN
		UPDATE
		SET
		`temperatura` = temperatura,
		`umidade` = umidade,
		`luminosidade` = luminosidade,
		`umidade_solo` = umidade_solo
        WHERE `id` = id;
    END
DELIMITER;

    -- Apagar dados atuais, por precaução
DELIMITER $$ 
    CREATE PROCEDURE `procExcluirDadosAtt`(
     IN in_data_ex DATE
)
BEGIN
    DELETE FROM `dados_atuais`
    WHERE `datas` = in_data_ex
END
DELIMITER;

    -- Excluir dados antigos de antes de uma data específica
DELIMITER $$ 
    CREATE PROCEDURE `proc_ExcluirDadosAnt`(
     IN in_data_limite DATE
)
BEGIN
    DELETE FROM `dados_antigos`
    WHERE `datas` < in_data_limite
END
DELIMITER;

-- Busca de dados antigos pela data
	DELIMITER $$ 
	CREATE PROCEDURE `proc_BuscarDadosAnt`(IN data_bus DATE)
	BEGIN
    SELECT * FROM `dados_antigos` 
    WHERE `datas` = data_bus;
	END
	DELIMITER;

    -- Procedimento para facilitar a autenticação
    DELIMITER $$ 
CREATE PROCEDURE `proc_AutenticarUsuario`(
    IN in_email VARCHAR(255),
    IN in_senha VARCHAR(255),
    OUT out_autenticado INT
)
BEGIN
    SELECT COUNT(*) INTO out_autenticado
    FROM usuario
    WHERE email = in_email AND senha = in_senha;
END
DELIMITER ;
  
-- Triggers:
-- Exclusão automatica de dados depois de um mes

  CREATE TRIGGER `tr_LimparDadosAnt`
  AFTER INSERT ON dados_atuais FOR EACH ROW
  SET tempo_exp = DATE_SUB(NOW(), INTERVAL 30 DAY)
  DELETE FROM dados_antigos WHERE datas < tempo_exp;
  