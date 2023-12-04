USE master
CREATE DATABASE ex10
GO
USE ex10

CREATE TABLE Medicamento (				
Codigo			INT			NOT NULL,
Nome			VARCHAR(50)	NOT NULL,
Apresentacao  	VARCHAR(50) NOT NULL,
Unidade			VARCHAR(30)	NOT NULL, 	 
Preco_Composto	DECIMAL(7,2)NOT NULL
PRIMARY KEY (Codigo)
)
GO
 
 INSERT INTO Medicamento VALUES 
(1,	 'Acetato de medroxiprogesterona',  	'150 mg/ml',  			    'Ampola',		6.700),
(2,	 'Aciclovir',							'200mg/comp.',  			'Comprimido',  	0.280),
(3,	 'Ácido Acetilsalicílico',  			'500mg/comp.',  			'Comprimido',  	0.035),
(4,	 'Ácido Acetilsalicílico',  			'100mg/comp.',  			'Comprimido',  	0.030),
(5,	 'Ácido Fólico',  						'5mg/comp.',				'Comprimido',  	0.054),
(6,	 'Albendazol',							'400mg/comp. mastigável',  	'Comprimido',  	0.560),
(7,	 'Alopurinol',  						'100mg/comp.',  			'Comprimido',  	0.080),
(8,	 'Amiodarona',  						'200mg/comp.',  			'Comprimido',  	0.200),
(9,	 'Amitriptilina(Cloridrato)',  			'25mg/comp.',  				'Comprimido',  	0.220),
(10, 'Amoxicilina',  						'500mg/cáps.',  			'Cápsula',  	0.190)

CREATE TABLE Cliente(					
CPF			CHAR(11)		NOT NULL,
Nome		VARCHAR(50)		NOT NULL,	
Rua			VARCHAR(30)		NOT NULL,
Numero		INT				NOT NULL,	
Bairro		VARCHAR(30)		NOT NULL,
Telefone	CHAR(08)		NOT NULL,
PRIMARY KEY (CPF)
)
GO
INSERT INTO Cliente (CPF, Nome, Rua, Numero, Bairro, Telefone)
VALUES
(34390898700, 'Maria Zélia', 'Anhaia', 65, 'Barra Funda', '92103762'),
(21345986290, 'Roseli Silva', 'Xv. De Novembro', 987, 'Centro', '82198763'),
(86927981825, 'Carlos Campos', 'Voluntários da Pátria', 1276, 'Santana', '98172361'),
(31098120900, 'João Perdizes', 'Carlos de Campos', 90, 'Pari', '61982371');


CREATE TABLE Vendas (					
    Nota_Fiscal         INT             NOT NULL,
    CPF_cliente         CHAR(11)        NOT NULL,
    Codigo_Medicamento  INT             NOT NULL,
    Quantidade          INT             NOT NULL,
    Valor_Total         DECIMAL(7,2)    NOT NULL,
    Data_Venda          DATE            NOT NULL
    PRIMARY KEY (CPF_cliente,Codigo_Medicamento)
    FOREIGN KEY (CPF_cliente) REFERENCES Cliente(CPF),
    FOREIGN KEY (Codigo_Medicamento) REFERENCES Medicamento(Codigo)
)
GO

INSERT INTO Vendas VALUES
(31501,	'86927981825',	10,	3,	0.57,	'2020-11-01'),
(31501,	'86927981825',	2,	10,	2.8,	'2020-11-01'),
(31501,	'86927981825',	5,	30,	1.05,	'2020-11-01'),
(31501,	'86927981825',	8,	30,	6.6,	'2020-11-01'),
(31502,	'34390898700',	8,	15,	3,		'2020-11-01'),
(31502,	'34390898700',	2,	10,	2.8,	'2020-11-01'),
(31502,	'34390898700',	9,	10,	2.2,	'2020-11-01'),
(31503,	'31098120900',	1,	20,	134,	'2020-11-02')

--Nome, apresentação, unidade e valor unitário dos remédios que ainda não foram vendidos. Caso a unidade de cadastro seja comprimido, mostrar Comp.
SELECT 
    M.Nome AS 'Nome do Remédio',
    M.Apresentacao AS 'Apresentação',
    CASE 
        WHEN M.Unidade = 'Comprimido' THEN 'Comp.'
        ELSE M.Unidade 
    END AS 'Unidade de Cadastro',
    M.Preco_Composto  AS 'Valor Unitário'
FROM 
    Medicamento M
WHERE 
   NOT EXISTS(
   SELECT 1
   FROM Vendas V
   WHERE V.Codigo_Medicamento = M.Codigo)

--Nome dos clientes que compraram Amiodarona
SELECT C.nome
FROM Cliente C
INNER JOIN Vendas V ON V.CPF_cliente = C.CPF
INNER JOIN Medicamento M ON M.Codigo = V.Codigo_Medicamento
WHERE M.Nome LIKE 'Amiodarona%'

--CPF do cliente, endereço concatenado, nome do medicamento (como nome de remédio),  apresentação do remédio, unidade, preço proposto, quantidade vendida e valor
SELECT C.CPF, 
       C.Rua + ' ' + C.Bairro + ' ' + cast(C.rua as VARCHAR(05)) AS endereco,
	   M.Nome AS nome_remedio,
	   M.Apresentacao,
	   M.Unidade,
	   M.Preco_Composto,
	   V.Quantidade,
	   V.valor_total
FROM Cliente C
INNER JOIN Vendas V ON V.CPF_cliente = C.CPF
INNER JOIN Medicamento M ON M.Codigo = V.Codigo_Medicamento

--Data de compra, convertida, de Carlos Campos
SELECT CONVERT(varchar(20), V.Data_Venda, 103) as data_convert
FROM Vendas V
INNER JOIN  Cliente C ON C.CPF = V.CPF_cliente
WHERE C.Nome = 'Carlos Campos'

--Alterar o nome da  Amitriptilina(Cloridrato) para Cloridrato de Amitriptilina
UPDATE Medicamento
SET nome = 'Cloridrato de Amitriptilina'
WHERE nome = 'Amitriptilina(Cloridrato)'