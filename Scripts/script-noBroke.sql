Create DATABASE noBroke;
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

CREATE TABLE permissao (
    id_permissao INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(225),
    fk_funcao INT NOT NULL,
    FOREIGN KEY (fk_funcao) REFERENCES funcao(id_funcao)
);

CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    especificacao VARCHAR(60) NOT NULL,
    capacidade VARCHAR(45) NOT NULL
);

CREATE TABLE formato (
    id_formato INT PRIMARY KEY AUTO_INCREMENT,
    unidade_medida VARCHAR(45)
);

CREATE TABLE servidor (
    id_servidor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    sistema_operacional VARCHAR(40) NOT NULL,
    fk_empresa INT NOT NULL,
    FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE tipo_componente (
    id_tipo INT,
    fk_componente INT NOT NULL,
    fk_servidor INT NOT NULL,
    fk_formato INT NOT NULL,
    nome_componente VARCHAR(45) NOT NULL,
    valor_max_critico DECIMAL(10,2) NOT NULL,
    valor_min_critico DECIMAL(10,2) NOT NULL,
    valor_max_atencao DECIMAL(10,2) NOT NULL,
    valor_min_atencao DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (id_tipo, fk_componente, fk_servidor, fk_formato),
    
    FOREIGN KEY (fk_componente) REFERENCES componente(id_componente),
    FOREIGN KEY (fk_servidor) REFERENCES servidor(id_servidor),
    FOREIGN KEY (fk_formato) REFERENCES formato(id_formato)
);

CREATE TABLE alerta (
    id_alerta INT PRIMARY KEY AUTO_INCREMENT,
    fk_tipo INT NOT NULL,
    fk_componente INT NOT NULL,                
    descricao VARCHAR(225) NOT NULL,
    valor_capturado DECIMAL(5,2),
    data_alerta DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (fk_tipo, fk_componente) 
        REFERENCES tipo_componente(id_tipo, fk_componente)
);


INSERT INTO empresa (nome, email, cnpj) VALUES 
('Valfogo Monitoring', 'contato@valfogo.com.br', '12345678000199'),
('DTIC Solutions', 'suporte@dtic.gov.br', '98765432000188');


INSERT INTO funcao (nome_funcao) VALUES 
('Administrador'), 
('Analista de TI'), 
('Visualizador');


INSERT INTO formato (unidade_medida) VALUES 
('%'), ('GHz'), ('GB'), ('MB/s'), ('°C');


INSERT INTO componente (nome, especificacao, capacidade) VALUES 
('Processador', 'Intel Xeon Gold', '3.4'),
('Memória RAM', 'DDR4', '32'),
('Disco Rígido', 'SSD NVMe', '1024'),
('Rede', 'Interface Ethernet', '10');


INSERT INTO permissao (descricao, fk_funcao) VALUES 
('Acesso total ao sistema', 1),
('Visualizar dashboards e alertas', 2),
('Apenas visualização de relatórios', 3);


INSERT INTO usuario (nome, cpf, email, senha, fk_empresa, fk_adm, fk_funcao) VALUES 
('José Valfogo', '11122233344', 'jose@valfogo.com', 'hash_senha_123', 1, NULL, 1),
('Luiz Silva', '55566677788', 'luiz@dtic.gov.br', 'seguranca_2026', 2, NULL, 1);

-- Usuário comum (Gerenciado pelo José Valfogo - ID 1)
INSERT INTO usuario (nome, cpf, email, senha, fk_empresa, fk_adm, fk_funcao) VALUES 
('Richard Oliveira', '99988877766', 'richard@valfogo.com', 'user_pass_456', 1, 1, 2);

-- Servidores
INSERT INTO servidor (nome, sistema_operacional, fk_empresa) VALUES 
('SRV-Argos-01', 'Ubuntu 22.04 LTS', 1),
('SRV-Argos-DB', 'Debian 11', 1),
('SRV-DTIC-PROD', 'Windows Server 2022', 2);

INSERT INTO servidor (nome, sistema_operacional, fk_empresa) VALUES 
('luiz', 'Ubuntu 22.04 LTS', 2);

INSERT INTO tipo_componente (id_tipo, fk_componente, fk_servidor, fk_formato, nome_componente, valor_max_critico, valor_min_critico, valor_max_atencao, valor_min_atencao) VALUES 
(1, 1, 4, 1, 'Uso de CPU', 90.00, 0.00, 75.00, 0.00),
(2, 2, 4, 1, 'Uso de RAM', 95.00, 0.00, 80.00, 0.00),
(3, 3, 4, 3, 'Espaço em Disco', 900.00, 10.00, 800.00, 50.00);

INSERT INTO alerta (fk_tipo, fk_componente, descricao, valor_capturado) VALUES 
(1, 1, 'Uso de CPU acima do limite de atenção no servidor', 78.50),
(2, 2, 'Uso de RAM atingiu nível crítico no servidor', 96.20),
(1, 1, 'Pico de processamento detectado', 85.00);
