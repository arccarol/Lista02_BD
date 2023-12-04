USE master
CREATE DATABASE ex07
GO
USE ex07

CREATE TABLE Cliente(								
RG			CHAR(9)		NOT NULL,
CPF			CHAR(11)	NOT NULL,
Nome		VARCHAR(50) NOT NULL,
Logradouro	VARCHAR(30)	NOT NULL,
Numero		INT			NOT NULL
PRIMARY KEY (RG)
)
GO
INSERT INTO Cliente	VALUES
('29531844',	'34519878040',	'Luiz André',	'R. Astorga',		500),
('13514996x',	'84984285630',	'Maria Luiza',	'R. Piauí',			174),
('121985541',	'23354997310',	'Ana Barbara',	'Av. Jaceguai',		1141),
('23987746x',	'43587669920',	'Marcos Alberto',	'R. Quinze',	22)

CREATE TABLE Fornecedor(																		
Codigo			INT				NOT NULL,	
Nome			VARCHAR(50)		NOT NULL,
Logradouro		VARCHAR(30)		NOT NULL,
Numero			INT			    NULL,	
Pais			CHAR(04)		NOT NULL,
Area			INT				NOT NULL,
Telefone		CHAR(10)		NULL,
CNPJ			CHAR(14)		NULL,
Cidade			VARCHAR(30)		NULL,
Transporte		VARCHAR(15)		NULL,
Moeda			CHAR(5)			NOT NULL
PRIMARY KEY (Codigo)
)
GO
INSERT INTO Fornecedor VALUES
(1,	'Clone',		'Av. Nações Unidas, 12000',	12000,	'BR',	55,	'1141487000',		NULL,			  'São Paulo',   NULL,	    'R$'),
(2,	'Logitech',		'28th Street, 100',			100,	'USA',	1,	'2127695100',		NULL,			  NULL,		    'Avião',	'US$'),
(3,	'LG',			'Rod. Castello Branco',		NULL,	'BR',	55,	'800664400',		'4159978100001',  'Sorocaba',	 NULL,	     'R$'),
(4,	'PcChips',		'Ponte da Amizade',			NULL,	'PY',	595, NULL,				NULL,			  NULL,	        'Navio',	'US$')

CREATE TABLE Mercadoria(								
Codigo				INT			 NOT NULL,
Descricao			VARCHAR(50)  NOT NULL,
Preco				DECIMAL(7,2) NOT NULL,
Qtd					INT			 NOT NULL,
Cod_Fornecedor		INT			 NOT NULL
PRIMARY KEY (Codigo)
FOREIGN KEY (Cod_Fornecedor) REFERENCES Fornecedor(Codigo)
)
GO
INSERT INTO Mercadoria VALUES
(10,	'Mouse',		24,		30,	1),
(11,	'Teclado',		50,		20,	1),
(12,	'Cx. De Som',	30,		8,	2),
(13,	'Monitor 17',	350,	4,	3),
(14,	'Notebook',		1500,	7,	4)

CREATE TABLE Pedido(						
Nota_Fiscal			INT				NOT NULL,	
Valor				DECIMAL(7,2)	NOT NULL,
Data_Compra			DATE			NOT NULL,
RG_Cliente			CHAR(9)			NOT NULL
PRIMARY KEY	(Nota_Fiscal)
FOREIGN KEY (RG_Cliente) REFERENCES Cliente(RG)
)
GO
INSERT INTO Pedido	VALUES
(1001,	754,		'2018-04-01',	'121985541'),
(1002,	350,		'2018-04-02',	'121985541'),
(1003,	30,		'2018-04-02',	'29531844'),
(1004,	1500,	'2018-04-03',	'13514996x')

--Pede-se: (Quando o endereço concatenado não tiver número, colocar só o logradouro e o país, quando tiver colocar, também o número)
SELECT 
    CASE 
        WHEN Numero IS NULL OR Numero = '' THEN CONCAT(Logradouro, ', ', Pais) 
        ELSE CONCAT(Logradouro, ', ', Numero, ' - ', Pais)
    END AS 'Endereço Concatenado'
FROM 
    Fornecedor;

--Nota: (CPF deve vir sempre mascarado no formato XXX.XXX.XXX-XX e RG Sempre com um traçao antes do último dígito (Algo como XXXXXXXX-X), mas alguns tem 8 e outros 9
SELECT 
    CONCAT(
        SUBSTRING(cliente.CPF, 1, 3), '.', 
        SUBSTRING(cliente.CPF, 4, 3), '.', 
        SUBSTRING(cliente.CPF, 7, 3), '-', 
        SUBSTRING(cliente.CPF, 10, 2)
    ) AS 'CPF Formatado',
    CASE 
        WHEN LEN(cliente.RG) = 8 THEN CONCAT(SUBSTRING(cliente.RG, 1, 7), '-', SUBSTRING(cliente.RG, 8, 1))
        WHEN LEN(cliente.RG) = 9 THEN CONCAT(SUBSTRING(cliente.RG, 1, 8), '-', SUBSTRING(cliente.RG, 9, 1))
        ELSE cliente.RG
    END AS 'RG Formatado'
FROM 
    Cliente;


--Consultar 10% de desconto no pedido 1003
SELECT  valor,
        (Valor * 0.9) AS Desconto_dez
FROM Pedido
WHERE Nota_Fiscal = 1003;

--Consultar 5% de desconto em pedidos com valor maior de R$700,00
SELECT valor,
      (valor * 0.95) AS Desconto_cinco
FROM Pedido
WHERE valor > '700';

--Consultar e atualizar aumento de 20% no valor de marcadorias com estoque menor de 10
UPDATE Mercadoria
SET Preco = (Preco * 1.20)
WHERE Qtd < '10' ;

--Data e valor dos pedidos do Luiz
SELECT P.Data_Compra, P.Valor
FROM Pedido P
INNER JOIN Cliente C ON C.RG = P.RG_Cliente
WHERE C.Nome LIKE 'Luiz%'

--CPF, Nome e endereço concatenado do cliente de nota 1004
SELECT C.CPF, C.Nome, 
       C.Logradouro + ' ' + CAST(C.Numero AS Varchar(05)) AS endereco
FROM Cliente C
INNER JOIN Pedido P ON P.RG_Cliente = C.RG
WHERE P.Nota_Fiscal = '1004'

--País e meio de transporte da Cx. De som
SELECT F.Pais, F.Transporte
FROM Fornecedor F
INNER JOIN Mercadoria M ON M.Cod_Fornecedor = F.Codigo
WHERE M.Descricao = 'Cx. De Som'

--Nome e Quantidade em estoque dos produtos fornecidos pela Clone
SELECT M.Descricao, M.Qtd
FROM Mercadoria M
INNER JOIN Fornecedor F ON F.Codigo = M.Cod_Fornecedor
WHERE F.Nome LIKE '%Clone%'

--Endereço concatenado e telefone dos fornecedores do monitor. (Telefone brasileiro (XX)XXXX-XXXX ou XXXX-XXXXXX (Se for 0800), Telefone Americano (XXX)XXX-XXXX)
SELECT
    F.Logradouro + ' ' + ' '+ F.Cidade+ ' '+ F.Pais AS Endereço,
   CASE 
        WHEN F.Telefone LIKE '0800%' THEN F.Telefone
        ELSE 
            CASE 
                WHEN F.Area = 55 THEN '(' + SUBSTRING(F.Telefone, 1, 2) + ')' + SUBSTRING(F.Telefone, 3, 4) + '-' + SUBSTRING(F.Telefone, 7, 4)
                WHEN F.Area = 1 THEN '(' + SUBSTRING(F.Telefone, 1, 3) + ')' + SUBSTRING(F.Telefone, 4, 3) + '-' + SUBSTRING(F.Telefone, 7, 4)
                ELSE F.Telefone
            END
    END AS TelefoneFormatado
FROM Fornecedor F, Mercadoria m
WHERE F.Codigo = m.Cod_Fornecedor
AND m.Descricao LIKE 'Monitor%'	

--Tipo de moeda que se compra o notebook
SELECT f.Moeda
FROM Fornecedor F
INNER JOIN Mercadoria M ON m.Cod_Fornecedor = F.Codigo
WHERE m.Descricao = 'Notebook'


--Considerando que hoje é 03/02/2019, há quantos dias foram feitos os pedidos e, criar uma coluna que escreva Pedido antigo para pedidos feitos há mais de 6 meses e pedido
SELECT 
    DATEDIFF(DAY, Data_Compra, '03/02/2019') AS 'Dias desde o Pedido',
    CASE 
        WHEN DATEDIFF(MONTH, Data_Compra, '03/02/2019') > 6 THEN 'Pedido antigo'
        ELSE 'Pedido recente'
    END AS 'Status do Pedido'
FROM 
    Pedido;

--Nome e Quantos pedidos foram feitos por cada cliente
SELECT C.Nome, COUNT(P.nota_fiscal) AS quantidade
FROM Pedido P
INNER JOIN Cliente C ON C.RG = P.RG_Cliente
GROUP BY C.Nome

--RG,CPF,Nome e Endereço dos cliente cadastrados que Não Fizeram pedidos
SELECT C.RG, C.CPF, C.Nome,
       C.Logradouro + ' ' + CAST(C.Numero AS VARCHAR(05)) AS endereco
FROM Cliente C
WHERE NOT EXISTS (
        SELECT 1 
        FROM Pedido P
        WHERE P.RG_Cliente = C.RG
    );








