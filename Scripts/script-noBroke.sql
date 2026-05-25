#DROP DATABASE noBroke;
#CREATE DATABASE noBroke;
USE noBroke;

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL,
    email VARCHAR(60) NOT NULL UNIQUE,
    cnpj CHAR(14) NOT NULL UNIQUE,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE funcao (
    id_funcao INT PRIMARY KEY AUTO_INCREMENT,
    nome_funcao VARCHAR(45) NOT NULL
);

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    email VARCHAR(60) UNIQUE NOT NULL,
    senha VARCHAR(225) NOT NULL,
    ativo TINYINT NOT NULL DEFAULT 1,
    fk_empresa INT NOT NULL,
    fk_adm INT NULL,
    fk_funcao INT NOT NULL,
    
    FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa),
    FOREIGN KEY (fk_adm) REFERENCES usuario(id_usuario) ON DELETE SET NULL,
    FOREIGN KEY (fk_funcao) REFERENCES funcao(id_funcao)
);


CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    especificacao VARCHAR(60) NOT NULL
);

CREATE TABLE formato (
    id_formato INT PRIMARY KEY AUTO_INCREMENT,
    unidade_medida VARCHAR(45),
    tipo_uso VARCHAR (45)
);

CREATE TABLE servidor (
    id_servidor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL UNIQUE,
    sistema_operacional VARCHAR(40) NOT NULL,
    fk_empresa INT NOT NULL,
    FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa),
    portaSerial VARCHAR(45),
    hostServer VARCHAR(45),
	endereco VARCHAR(45),
	chaveSSH VARCHAR(45),
	ambiente VARCHAR(45),
	localizacao VARCHAR(45)
);

CREATE TABLE tipo_componente (
    id_tipo INT AUTO_INCREMENT,
    fk_servidor INT NOT NULL,
    fk_formato INT NOT NULL,
    fk_componente INT NOT NULL,
    nome_componente VARCHAR(45) NOT NULL,
    valor_max_critico DECIMAL(10,2) NOT NULL,
    valor_min_critico DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_tipo, fk_componente, fk_servidor, fk_formato),
    FOREIGN KEY (fk_componente) REFERENCES componente(id_componente),
    FOREIGN KEY (fk_servidor) REFERENCES servidor(id_servidor),
    FOREIGN KEY (fk_formato) REFERENCES formato(id_formato),
    capacidade VARCHAR(45)
);

CREATE TABLE alerta (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    fk_tipo INT NOT NULL,
    fk_componente INT NOT NULL,                
    descricao VARCHAR(225) NOT NULL,
    valor_capturado DECIMAL(5,2),
    data_alerta DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (fk_tipo, fk_componente) REFERENCES tipo_componente(id_tipo, fk_componente)
);


INSERT INTO empresa (nome, email, cnpj) VALUES 
('Valfogo Monitoring', 'contato@valfogo.com.br', '12345678000199'),
('DTIC Solutions', 'suporte@dtic.gov.br', '98765432000188');


INSERT INTO funcao (nome_funcao) VALUES 
('Administrador'), 
('Analista de TI'), 
('Visualizador');


INSERT INTO formato (unidade_medida) VALUES 
('%'), ('GHz'), ('GB'), ('MB/s');

INSERT INTO componente (nome, especificacao) VALUES 
('Processador', 'Intel Xeon Gold'),
('Memória RAM', 'DDR4'),
('Disco Rígido', 'SSD NVMe'),
('Rede', 'Interface Ethernet');

INSERT INTO usuario (nome, cpf, email, senha, fk_empresa, fk_adm, fk_funcao) VALUES 
('José Valfogo', '11122233344', 'jose@valfogo.com', 'hash_senha_123', 1, NULL, 1),
('Luiz Silva', '55566677788', 'luiz@dtic.gov.br', 'seguranca_2026', 2, NULL, 1);

INSERT INTO usuario (nome, cpf, email, senha, fk_empresa, fk_adm, fk_funcao) VALUES 
('Richard Oliveira', '99988877766', 'richard@valfogo.com', 'user_pass_456', 1, 1, 2);

INSERT INTO servidor (nome, sistema_operacional, fk_empresa) VALUES 
('NB1-SRV-Argos-01', 'Ubuntu 22.04 LTS', 1),
('NB1-SRV-Argos-DB', 'Debian 11', 1),
('NB1-SRV-DTIC-PROD', 'Windows Server 2022', 2),
('NB1-luiz', 'Ubuntu 22.04 LTS', 2);

INSERT INTO tipo_componente (id_tipo,fk_servidor, fk_formato, fk_componente, nome_componente, valor_max_critico, valor_min_critico, capacidade) VALUES 
(1, 1,1,1, 'cpu_percent', 12.00, 0.50,'3.7 Ghz'),  
(2, 2,2,1, 'ram_percent', 28.00, 22.00, '16 GB'),    
(3, 3,1,2, 'disk_percent', 90.00, 80.00, '1 TB'), 
(4, 1,2,2, 'total_processos', 87.00, 62.00, null); 


INSERT INTO tipo_componente 
(fk_componente, fk_servidor, fk_formato, nome_componente, valor_max_critico, valor_min_critico) VALUES
(1, 4, 1, 'cpu_percent', 90.00, 0.00),
(1, 4, 2, 'cpu_freq_current', 4.00, 0.80),
(2, 4, 1, 'ram_percent', 95.00, 0.00),
(2, 4, 3, 'ram_used_gb', 14.00, 0.00),
(3, 4, 1, 'disk_percent', 90.00, 0.00),
(4, 4, 4, 'latencia_resposta_ms', 500.00, 0.00);

INSERT INTO alerta (fk_tipo, fk_componente, descricao, valor_capturado) VALUES 
(1, 1, 'Uso de CPU acima do limite operacional durante o pregão', 12.50),
(2, 1, 'Memória RAM atingindo nível crítico de paginação', 29.50),
(3, 2, 'Espaço em disco insuficiente para logs do Home Broker', 95.00);

INSERT INTO alerta (fk_tipo, fk_componente, descricao, valor_capturado) VALUES 
(1, 1, 'Uso de CPU acima do limite de atenção no servidor luiz', 78.50),
(3, 2, 'Uso de RAM atingiu nível crítico no servidor luiz', 96.20),
(2, 1, 'Pico de processamento detectado', 85.00);

CREATE VIEW tratamento AS
SELECT 
                tipo.nome_componente, 
                formato.unidade_medida 
            FROM tipo_componente tipo
            JOIN servidor ON tipo.fk_servidor = servidor.id_servidor
            JOIN formato ON tipo.fk_formato = formato.id_formato;
            
            
# ==========================================
# CÓDIGOS PARA TESTE
# USE noBroke;
show tables;
select*from usuario;
select*from servidor;
select*from componente;
select*from tipo_componente;
select*from alerta;
select*from empresa;
select*from formato;
select*from funcao;

# desc tipo_componente;
# desc alerta;

# ============================================================
# SELECTS

 SELECT 
	tipo.nome_componente, 
    formato.unidade_medida 
            FROM tipo_componente tipo
            JOIN servidor ON tipo.fk_servidor = servidor.id_servidor
            JOIN formato ON tipo.fk_formato = formato.id_formato
            WHERE servidor.nome = 'luiz';

select*from servidor Where fk_empresa = 2;
