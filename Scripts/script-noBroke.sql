CREATE DATABASE IF NOT EXISTS noBroke;
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
    especificacao VARCHAR(60) NOT NULL,
    capacidade VARCHAR(45) NOT NULL # coluna removida
);
alter table componente drop column capacidade;

CREATE TABLE formato (
    id_formato INT PRIMARY KEY AUTO_INCREMENT,
    unidade_medida VARCHAR(45),
    tipo_uso VARCHAR (45)
);

CREATE TABLE servidor (
    id_servidor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    sistema_operacional VARCHAR(40) NOT NULL,
    fk_empresa INT NOT NULL,
    FOREIGN KEY (fk_empresa) REFERENCES empresa(id_empresa)
    
);
CREATE TABLE grupo_pessoas(
  id_grupo INT NOT NULL,
  fk_usuario INT NOT NULL,
  fk_servidor INT NOT NULL,
  nome_grupo CHAR(45) NOT NULL,
  
  PRIMARY KEY (id_grupo, fk_servidor),
  
  CONSTRAINT fk_grupo_pessoas_usuario
  FOREIGN KEY (fk_usuario)
    REFERENCES usuario (id_usuario), 
  
  CONSTRAINT fk_grupo_pessoas_servidor
    FOREIGN KEY (fk_servidor)
    REFERENCES servidor (id_servidor));

desc servidor;

CREATE TABLE tipo_componente (
    id_tipo INT AUTO_INCREMENT,
    fk_componente INT NOT NULL,
    fk_servidor INT NOT NULL,
    fk_formato INT NOT NULL,
    nome_componente VARCHAR(45) NOT NULL,
    valor_max_critico DECIMAL(10,2) NOT NULL,
    valor_min_critico DECIMAL(10,2) NOT NULL,
    valor_max_atencao DECIMAL(10,2) NOT NULL, #coluna removida
    valor_min_atencao DECIMAL(10,2) NOT NULL, #coluna removida
    
    PRIMARY KEY (id_tipo, fk_componente, fk_servidor, fk_formato),
    
    FOREIGN KEY (fk_componente) REFERENCES componente(id_componente),
    FOREIGN KEY (fk_servidor) REFERENCES servidor(id_servidor),
    FOREIGN KEY (fk_formato) REFERENCES formato(id_formato)
);
alter table tipo_componente add column capacidade VARCHAR(45); #deveria ser not null, mas vou deixar nulo pra facilitar
alter table tipo_componente drop column valor_max_atencao;
alter table tipo_componente drop column valor_min_atencao;


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
('%'), ('GHz'), ('GB'), ('MB/s');

/*
INSERT INTO componente (nome, especificacao, capacidade) VALUES 
('Processador', 'Intel Xeon Gold', '3.4'),
('Memória RAM', 'DDR4', '32'),
('Disco Rígido', 'SSD NVMe', '1024'),
('Rede', 'Interface Ethernet', '10');
*/

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
('SRV-Argos-01', 'Ubuntu 22.04 LTS', 1),
('SRV-Argos-DB', 'Debian 11', 1),
('SRV-DTIC-PROD', 'Windows Server 2022', 2);

INSERT INTO servidor (nome, sistema_operacional, fk_empresa) VALUES
('SRV-Argos-isa-BD', 'Windows Server 2022', 2);

INSERT INTO servidor (nome, sistema_operacional, fk_empresa) VALUES 
('luiz', 'Ubuntu 22.04 LTS', 2);
/*
INSERT INTO tipo_componente (id_tipo,fk_servidor, fk_formato, fk_componente, nome_componente, valor_max_critico, valor_min_critico,valor_max_atencao,valor_min_atencao) VALUES 
(1, 1,1,1, 'cpu_percent', 12.00, 0.50,0.25,0.20),  
(2, 2,2,1, 'ram_percent', 28.00, 22.00,12.00,10.00),    
(3, 3,1,2, 'disk_percent', 90.00, 80.00,79.00,60.00), 
(4, 1,2,2, 'total_processos', 87.00, 62.00,61.00,50.00);  
*/

INSERT INTO tipo_componente (id_tipo,fk_servidor, fk_formato, fk_componente, nome_componente, valor_max_critico, valor_min_critico, capacidade) VALUES 
(1, 1,1,1, 'cpu_percent', 12.00, 0.50,'3.7 Ghz'),  
(2, 2,2,1, 'ram_percent', 28.00, 22.00, '16 GB'),    
(3, 3,1,2, 'disk_percent', 90.00, 80.00, '1 TB'), 
(4, 1,2,2, 'total_processos', 87.00, 62.00);  


INSERT INTO tipo_componente 
(fk_componente, fk_servidor, fk_formato, nome_componente, valor_max_critico, valor_min_critico, valor_max_atencao, valor_min_atencao) VALUES
(1, 4, 1, 'cpu_percent', 90.00, 0.00, 75.00, 0.00),
(1, 4, 2, 'cpu_freq_current', 4.00, 0.80, 3.50, 1.00),
(2, 4, 1, 'ram_percent', 95.00, 0.00, 85.00, 0.00),
(2, 4, 3, 'ram_used_gb', 14.00, 0.00, 12.00, 0.00),
(3, 4, 1, 'disk_percent', 90.00, 0.00, 80.00, 0.00),
(4, 4, 4, 'latencia_resposta_ms', 500.00, 0.00, 200.00, 0.00);

desc tipo_componente;

INSERT INTO alerta (fk_tipo, fk_componente, descricao, valor_capturado) VALUES 
(1, 1, 'Uso de CPU acima do limite operacional durante o pregão', 12.50),
(2, 1, 'Memória RAM atingindo nível crítico de paginação', 29.50),
(3, 2, 'Espaço em disco insuficiente para logs do Home Broker', 95.00);

INSERT INTO alerta (fk_tipo, fk_componente, descricao, valor_capturado) VALUES 
(1, 1, 'Uso de CPU acima do limite de atenção no servidor luiz', 78.50),
(3, 2, 'Uso de RAM atingiu nível crítico no servidor luiz', 96.20),
(2, 1, 'Pico de processamento detectado', 85.00);

 SELECT 
	tipo.nome_componente, 
    formato.unidade_medida 
            FROM tipo_componente tipo
            JOIN servidor ON tipo.fk_servidor = servidor.id_servidor
            JOIN formato ON tipo.fk_formato = formato.id_formato
            WHERE servidor.nome = 'luiz';

CREATE VIEW tratamento AS
SELECT 
                servidor.id_servidor,
                tipo.nome_componente, 
                formato.unidade_medida 
            FROM tipo_componente tipo
            JOIN servidor ON tipo.fk_servidor = servidor.id_servidor
            JOIN formato ON tipo.fk_formato = formato.id_formato;
/*
 select * from tratamento
            join servidor on tratamento.id_servidor = servidor.id_servidor
            WHERE servidor.nome = %s;
PARA CHAMAR NA ETL OS TRATAMENTOS DOS COMPONENTES
*/
            
use nobroke;
show tables;
select*from usuario;
select*from componente;
select*from tipo_componente;
desc tipo_componente;
desc alerta;
select * from servidor;
select*from servidor Where fk_empresa = 2;
alter table servidor add column portaSerial VARCHAR(45);
alter table servidor add column hostServer VARCHAR(45);
alter table servidor add column endereco VARCHAR(45);
alter table servidor add column chaveSSH VARCHAR(45);
alter table servidor add column ambiente VARCHAR(45);
alter table servidor add column localizacao VARCHAR(45);
