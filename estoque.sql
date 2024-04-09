CREATE TABLE Fornecedores (
    fornecedor_id NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    endereco VARCHAR2(255),
    telefone VARCHAR2(20)
);

CREATE TABLE Categorias (
    categoria_id NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    descricao VARCHAR2(255)
);

CREATE TABLE Produtos (
    produto_id NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    descricao VARCHAR2(255),
    preco NUMBER(10, 2),
    quantidade_em_estoque NUMBER,
    fornecedor_id NUMBER,
    categoria_id NUMBER,
    FOREIGN KEY (fornecedor_id) REFERENCES Fornecedores(fornecedor_id),
    FOREIGN KEY (categoria_id) REFERENCES Categorias(categoria_id)
);

CREATE TABLE Movimentacao_Estoque (
    movimentacao_id NUMBER PRIMARY KEY,
    tipo_movimentacao VARCHAR2(50),
    data_movimentacao DATE,
    produto_id NUMBER,
    quantidade NUMBER,
    FOREIGN KEY (produto_id) REFERENCES Produtos(produto_id)
);


-- Inserir um fornecedor
INSERT INTO Fornecedores (fornecedor_id, nome, endereco, telefone)
VALUES (1, 'TechEle', 'Rua principio, 123', '(11) 98765- 8888');

-- Inserir uma categoria
INSERT INTO Categorias (categoria_id, nome, descricao)
VALUES (1, 'Eletrônicos', 'Produtos eletrônicos de última geração');

-- Inserir um fornecedor com fornecedor_id = 2
INSERT INTO Fornecedores (fornecedor_id, nome, endereco, telefone)
VALUES (2, 'PedroSmarth', ' Rua das ortas 133 ', '(11) 988-8888');

-- Inserir uma categoria com categoria_id = 2
INSERT INTO Categorias (categoria_id, nome, descricao)
VALUES (2, 'Eletrotouch', 'Produtos eletronicos');


INSERT INTO Produtos (produto_id, nome, descricao, preco, quantidade_em_estoque, fornecedor_id, categoria_id)
VALUES (1, 'TV LED 50 polegadas', 'TV de alta definição com tecnologia LED', 1999.99, 10, 1, 1);

INSERT INTO Produtos (produto_id, nome, descricao, preco, quantidade_em_estoque, fornecedor_id, categoria_id)
VALUES (2, 'Smartphone Galaxy S22', 'Smartphone com câmera de alta resolução e tela OLED', 1299.99, 20, 2, 2);



SELECT * FROM Fornecedores WHERE fornecedor_id = 2;
SELECT * FROM Categorias WHERE categoria_id = 2;

DROP PACKAGE Estoque_Package;


CREATE OR REPLACE PACKAGE Estoque_Package AS
    PROCEDURE Atualizar_Qtde_Estoque(p_produto_id IN NUMBER, p_quantidade IN NUMBER);
END Estoque_Package;
/

CREATE OR REPLACE PACKAGE BODY Estoque_Package AS
    PROCEDURE Atualizar_Qtde_Estoque(p_produto_id IN NUMBER, p_quantidade IN NUMBER) AS
    BEGIN
        UPDATE Produtos
        SET quantidade_em_estoque = quantidade_em_estoque + p_quantidade
        WHERE produto_id = p_produto_id;
    END Atualizar_Qtde_Estoque;
END Estoque_Package;
/


BEGIN
    Estoque_Package.Atualizar_Qtde_Estoque(1, 10); -- Atualiza a quantidade em estoque do produto com ID 1 em 10 unidades
    COMMIT; -- Confirma a transação
END;
/

SELECT produto_id FROM Produtos;

SELECT * FROM Produtos;

CREATE OR REPLACE PACKAGE BODY Estoque_Package AS
    PROCEDURE Adicionar_Produto(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_preco IN NUMBER, p_quantidade IN NUMBER, p_fornecedor_id IN NUMBER, p_categoria_id IN NUMBER) AS
    BEGIN
        INSERT INTO Produtos (produto_id, nome, descricao, preco, quantidade_em_estoque, fornecedor_id, categoria_id)
        VALUES (produto_seq.NEXTVAL, p_nome, p_descricao, p_preco, p_quantidade, p_fornecedor_id, p_categoria_id);
    END Adicionar_Produto;
END Estoque_Package;





CREATE SEQUENCE produto_seq START WITH 1 INCREMENT BY 1;





-- Chamar a procedure para adicionar um novo produto
BEGIN
    Estoque_Package.Adicionar_Produto(' Maquina de Lavar', 'produtos eletronicos', 10000, 5, 1, 1);
    COMMIT; 
END;
/




CREATE SEQUENCE movimentacao_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PACKAGE Estoque_Package AS
    PROCEDURE Atualizar_Qtde_Estoque(p_produto_id IN NUMBER, p_quantidade IN NUMBER);
    PROCEDURE Adicionar_Produto(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_preco IN NUMBER, p_quantidade IN NUMBER, p_fornecedor_id IN NUMBER, p_categoria_id IN NUMBER);
    PROCEDURE Adicionar_Movimentacao(p_tipo_movimentacao IN VARCHAR2, p_data_movimentacao IN DATE, p_produto_id IN NUMBER, p_quantidade IN NUMBER);
END Estoque_Package;


CREATE OR REPLACE PACKAGE BODY Estoque_Package AS
    PROCEDURE Atualizar_Qtde_Estoque(p_produto_id IN NUMBER, p_quantidade IN NUMBER) AS
    BEGIN
        UPDATE Produtos
        SET quantidade_em_estoque = quantidade_em_estoque + p_quantidade
        WHERE produto_id = p_produto_id;
    END Atualizar_Qtde_Estoque;

    PROCEDURE Adicionar_Produto(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_preco IN NUMBER, p_quantidade IN NUMBER, p_fornecedor_id IN NUMBER, p_categoria_id IN NUMBER) AS
    BEGIN
        INSERT INTO Produtos (produto_id, nome, descricao, preco, quantidade_em_estoque, fornecedor_id, categoria_id)
        VALUES (produto_seq.NEXTVAL, p_nome, p_descricao, p_preco, p_quantidade, p_fornecedor_id, p_categoria_id);
    END Adicionar_Produto;

    PROCEDURE Adicionar_Movimentacao(p_tipo_movimentacao IN VARCHAR2, p_data_movimentacao IN DATE, p_produto_id IN NUMBER, p_quantidade IN NUMBER) AS
    BEGIN
        IF p_tipo_movimentacao = 'ENTRADA' THEN
            UPDATE Produtos
            SET quantidade_em_estoque = quantidade_em_estoque + p_quantidade
            WHERE produto_id = p_produto_id;
        ELSIF p_tipo_movimentacao = 'SAIDA' THEN
            UPDATE Produtos
            SET quantidade_em_estoque = quantidade_em_estoque - p_quantidade
            WHERE produto_id = p_produto_id;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Tipo de movimentação inválido. Use ENTRADA ou SAIDA.');
        END IF;

        INSERT INTO Movimentacao_Estoque (movimentacao_id, tipo_movimentacao, data_movimentacao, produto_id, quantidade)
        VALUES (movimentacao_seq.NEXTVAL, p_tipo_movimentacao, p_data_movimentacao, p_produto_id, p_quantidade);
    END Adicionar_Movimentacao;
END Estoque_Package;



BEGIN
    Estoque_Package.Adicionar_Movimentacao('ENTRADA', SYSDATE, 1, 10);
    COMMIT; 
END;


-- Verificar se a nova movimentação foi adicionada corretamente

SELECT * FROM Movimentacao_Estoque WHERE produto_id = 1;


CREATE OR REPLACE FUNCTION Consultar_Estoque(p_produto_id IN NUMBER)
RETURN NUMBER
IS
    v_quantidade NUMBER;
BEGIN
    SELECT quantidade_em_estoque INTO v_quantidade
    FROM Produtos
    WHERE produto_id = p_produto_id;

    RETURN v_quantidade;
END Consultar_Estoque;
/
SELECT Consultar_Estoque(1) FROM dual;


CREATE OR REPLACE PACKAGE Estoque_Package AS
    FUNCTION Produto_Exists(p_produto_id IN NUMBER) RETURN NUMBER;
    PROCEDURE Adicionar_Produto(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_preco IN NUMBER, p_quantidade IN NUMBER, p_fornecedor_id IN NUMBER, p_categoria_id IN NUMBER);
END Estoque_Package;
/

CREATE OR REPLACE PACKAGE BODY Estoque_Package AS
    FUNCTION Produto_Exists(p_produto_id IN NUMBER) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM Produtos
        WHERE produto_id = p_produto_id;

        RETURN v_count;
    END Produto_Exists;

    PROCEDURE Adicionar_Produto(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_preco IN NUMBER, p_quantidade IN NUMBER, p_fornecedor_id IN NUMBER, p_categoria_id IN NUMBER) AS
    BEGIN
        IF Produto_Exists(p_categoria_id) > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Produto já existe.');
        END IF;

        INSERT INTO Produtos (produto_id, nome, descricao, preco, quantidade_em_estoque, fornecedor_id, categoria_id)
        VALUES (produto_seq.NEXTVAL, p_nome, p_descricao, p_preco, p_quantidade, p_fornecedor_id, p_categoria_id);
    END Adicionar_Produto;

END Estoque_Package;
/

SELECT Estoque_Package.Produto_Exists(1) FROM dual;




CREATE OR REPLACE TRIGGER Atualizar_Qtde_Estoque
AFTER INSERT ON Movimentacao_Estoque
FOR EACH ROW
DECLARE
    v_produto_id Movimentacao_Estoque.produto_id%TYPE;
    v_quantidade Movimentacao_Estoque.quantidade%TYPE;
BEGIN
    v_produto_id := :NEW.produto_id;
    v_quantidade := :NEW.quantidade;

    IF :NEW.tipo_movimentacao = 'ENTRADA' THEN
        UPDATE Produtos
        SET quantidade_em_estoque = quantidade_em_estoque + v_quantidade
        WHERE produto_id = v_produto_id;
    ELSIF :NEW.tipo_movimentacao = 'SAIDA' THEN
        UPDATE Produtos
        SET quantidade_em_estoque = quantidade_em_estoque - v_quantidade
        WHERE produto_id = v_produto_id;
    END IF;
END;


INSERT INTO Movimentacao_Estoque (movimentacao_id, tipo_movimentacao, data_movimentacao, produto_id, quantidade)
VALUES (movimentacao_seq.NEXTVAL, 'ENTRADA', SYSDATE, 1, 10);


SELECT * FROM Produtos WHERE produto_id = 1;

