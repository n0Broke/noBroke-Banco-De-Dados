CREATE DATABASE noBroke;
USE noBroke;

CREATE TABLE empresa(
	id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL,
    email VARCHAR(60) NOT NULL UNIQUE,
    cnpj CHAR(14) NOT NULL UNIQUE,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
 );

 CREATE TABLE usuario(
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60),
    cpf CHAR(11) UNIQUE NOT NULL,
    email VARCHAR(60) UNIQUE NOT NULL,
    senha VARCHAR(45) NOT NULL,
    ativo TINYINT NOT NULL, -- 0 Para inativo e 1 para ativo
    fk_empresa INT NOT NULL,
    fk_adm INT,
    FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa),
    FOREIGN KEY (fk_adm) REFERENCES usuario(id_usuario)
 );
 
 CREATE TABLE servidor(
	id_servidor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    sistema_operacional VARCHAR(40) NOT NULL,
    fk_empresa INT NOT NULL,
    FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
 );
 
 CREATE TABLE componente(
	id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    especificacao VARCHAR(60) NOT NULL,
    capacidade VARCHAR(45) NOT NULL,
    unidade_medida VARCHAR(45) NOT NULL
 );
 
 CREATE TABLE tipo_componente(
	id_tipo INT,
    fk_componente INT,
    fk_servidor INT,
    nome_componente VARCHAR(45) NOT NULL,
    valor_max DECIMAL(10,2) NOT NULL,
    valor_min DECIMAL(10) NOT NULL,
    PRIMARY KEY (id_tipo, fk_componente, fk_servidor),
    FOREIGN KEY (fk_componente) REFERENCES componente(id_componente),
    FOREIGN KEY (fk_servidor) REFERENCES servidor(id_servidor)
 );