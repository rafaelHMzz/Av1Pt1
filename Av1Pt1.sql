create database ex1
GO
use ex1

create table cliente (
cod int identity not null primary key,
nome varchar(100) not null,
telefone varchar(15) not null
)

insert into cliente values
('fulano', '11 1234-5678'),
('Cicrano', '11 8765-4321'),
('Beltrano', '11 1111-1111'),
('Ross', '11 1234-1234')


create table produto (
cod int identity not null primary key,
nome varchar(100) not null,
v_unit decimal(7,2) not null
)

insert into produto values
('Refrigerante garrafa 1L', 25.00),
('Salgadinho 400g', 22.50),
('Pão francês kg', 14.00)

create table venda (
cod_cli int not null,
cod_prod int not null,
data_hora datetime not null,
qnt int not null,
v_unit decimal(7,2) not null,
v_total decimal(7,2) not null,
foreign key (cod_cli) references cliente(cod),
foreign key (cod_prod) references produto(cod),
constraint PK_Venda primary key(cod_cli, cod_prod, data_hora)
)

create table bonus (
id int identity not null primary key,
valor decimal(7,2) not null,
premio varchar(100) not null
)

insert into bonus values
(1000.00, 'Jogo de Copos'),
(2000.00, 'Jogo de Pratos'),
(3000.00, 'Jogo de Talheres'),
(4000.00, 'Jogo de Porcelana'),
(5000.00, 'Jogo de Cristais')

GO
CREATE PROCEDURE sp_criarvenda (@cod_cli int, @cod_prod int, @qnt int)
AS
	DECLARE @data_hora DATETIME,
			@v_total decimal(7,2),
			@v_unit decimal(7,2)
	BEGIN
		IF (@cod_cli IS NULL OR @cod_prod IS NULL OR @qnt IS NULL)
			BEGIN
				RAISERROR ('Algum dos dados está incorreto!',16,1)
			END
		ELSE
			BEGIN
				SET @data_hora = GETDATE()
				SET @v_unit = (SELECT v_unit FROM produto WHERE cod = @cod_prod)
				SET @v_total = @v_unit * @qnt
				INSERT INTO venda (cod_cli, cod_prod, data_hora, qnt, v_unit, v_total) VALUES (@cod_cli, @cod_prod, @data_hora, @qnt, @v_unit, @v_total)
			END
	END

GO
CREATE FUNCTION fn_tabelabonus (@cod_cli int)
RETURNS @tabela TABLE (
cod int,
nome varchar(100),
v_gasto decimal(7,2),
v_bonus decimal(7,2),
premio varchar(50),
v_sobra decimal(7,2)
)
AS
BEGIN
	DECLARE @v_gasto decimal(7,2),
			@v_bonus decimal(7,2),
			@premio varchar(50),
			@v_sobra decimal(7,2),
			@i int
	INSERT INTO @tabela (cod, nome) SELECT cod, nome FROM cliente WHERE cod = @cod_cli
	
	SET @v_gasto = (SELECT SUM(v_total) FROM venda WHERE cod_cli = @cod_cli)
	SET @i = 1
	
	WHILE (@i <= (SELECT COUNT(id) FROM bonus))
		BEGIN
			IF @v_gasto < 1000
				BEGIN
					SET @v_bonus = 0.0
					SET @premio = 'Nenhum'
					SET @v_sobra = @v_gasto
				END
			ELSE
				BEGIN
					IF @v_gasto > 5000
						BEGIN
							SET @v_bonus = 5000
							SET @premio = (SELECT premio FROM bonus WHERE id = 5)
							SET @v_sobra = @v_gasto - 5000
						END
					ELSE
						BEGIN
							IF @v_gasto >= (SELECT valor FROM bonus WHERE id = @i) AND @v_gasto < (@i + 1) * 1000
								BEGIN
									IF @v_gasto > (SELECT valor FROM bonus WHERE id = @i)
										BEGIN
											SET @v_bonus = (SELECT valor FROM bonus WHERE id = @i)
											SET @premio = (SELECT premio FROM bonus WHERE id = @i)
											SET @v_sobra = @v_gasto - (SELECT valor FROM bonus WHERE id = @i)
										END
									ELSE
										BEGIN
											SET @v_bonus = @v_gasto
											SET @premio = (SELECT premio FROM bonus WHERE id = @i)
											SET @v_sobra = 0.0
										END
								END
						END
				END
		SET @i = @i + 1
		END
	UPDATE @tabela SET v_gasto = @v_gasto
	UPDATE @tabela SET v_bonus = @v_bonus
	UPDATE @tabela SET premio = @premio
	UPDATE @tabela SET v_sobra = @v_sobra
	RETURN
END

select * from cliente
select * from produto
select * from venda
select * from bonus

EXEC sp_criarvenda 1,1, 200
EXEC sp_criarvenda 2,1, 400
EXEC sp_criarvenda 3,1, 2
EXEC sp_criarvenda 4,3, 200

select * from dbo.fn_tabelabonus(1)
select * from dbo.fn_tabelabonus(2)
select * from dbo.fn_tabelabonus(3)
select * from dbo.fn_tabelabonus(4)



	





