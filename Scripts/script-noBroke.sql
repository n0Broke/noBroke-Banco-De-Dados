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
alter table servidor add column portaSerial VARCHAR(45);
alter table servidor add column hostServer VARCHAR(45);
alter table servidor add column endereco VARCHAR(45);
alter table servidor add column chaveSSH VARCHAR(45);
alter table servidor add column ambiente VARCHAR(45);
alter table servidor add column localizacao VARCHAR(45);

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

Drop table grupo_pessoas;

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

INSERT INTO componente (nome, especificacao) VALUES 
('Processador', 'Intel Xeon Gold'),
('Memória RAM', 'DDR4'),
('Disco Rígido', 'SSD NVMe'),
('Rede', 'Interface Ethernet');

INSERT INTO usuario (nome, cpf, email, senha, fk_empresa, fk_adm, fk_funcao) VALUES 
('José Valfogo', '11122233344', 'jose@valfogo.com', 'hash_senha_123', 1, NULL, 1),
('Luiz Silva', '55566677788', 'luiz@dtic.gov.br', 'seguranca_2026', 2, NULL, 1);

INSERT INTO usuario 
(nome, cpf, email, senha, fk_empresa, fk_adm, fk_funcao) 
VALUES 
('Gaby', '12345678900', 'gaby@nobroke.com', 'hash_gaby_123', 1, NULL, 1),
('Isabela', '98765432100', 'isabela@nobroke.com', 'hash_isa_456', 1, NULL, 2);

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

INSERT INTO tipo_componente
(fk_servidor, fk_formato, fk_componente, nome_componente, valor_max_critico, valor_min_critico, capacidade)
VALUES
(3, 1, 4, 'volume_requisicoes_http', 800.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 4, 4, 'latencia_p95_ordens', 800.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'ordens_com_sucesso', 100.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'respostas_http_5xx', 100.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'erro_500', 100.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'erro_501', 100.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'erro_502', 100.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'erro_503', 100.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'erro_504', 100.00, 0.00, 'Dashboard HTTP - Requisições'),
(3, 1, 4, 'erro_505', 100.00, 0.00, 'Dashboard HTTP - Requisições');

CREATE VIEW tratamento AS
SELECT 
                tipo.nome_componente, 
                formato.unidade_medida 
            FROM tipo_componente tipo
            JOIN servidor ON tipo.fk_servidor = servidor.id_servidor
            JOIN formato ON tipo.fk_formato = formato.id_formato;
            
            

INSERT INTO servidor 
(nome, sistema_operacional, fk_empresa, portaSerial, hostServer, endereco, chaveSSH, ambiente, localizacao)
VALUES
('NB1-SRV-CORE-01', 'Ubuntu 22.04 LTS', 1, 'COM3', '10.0.1.10', '/srv/core01', 'ssh-core01.pem', 'Produção', 'São Paulo'),
('NB1-SRV-CORE-02', 'Ubuntu 22.04 LTS', 1, 'COM4', '10.0.1.11', '/srv/core02', 'ssh-core02.pem', 'Produção', 'São Paulo'),
('NB1-SRV-API-01', 'Debian 11', 1, 'COM5', '10.0.1.12', '/srv/api01', 'ssh-api01.pem', 'Produção', 'Rio de Janeiro'),
('NB1-SRV-API-02', 'Debian 11', 1, 'COM6', '10.0.1.13', '/srv/api02', 'ssh-api02.pem', 'Produção', 'Rio de Janeiro'),
('NB1-SRV-AUTH-01', 'Ubuntu 20.04', 1, 'COM7', '10.0.1.14', '/srv/auth01', 'ssh-auth01.pem', 'Homologação', 'Campinas'),
('NB1-SRV-MONITOR-01', 'Ubuntu 22.04', 1, 'COM8', '10.0.1.15', '/srv/monitor01', 'ssh-monitor01.pem', 'Produção', 'Curitiba'),
('NB1-SRV-BACKUP-01', 'Rocky Linux 9', 1, 'COM9', '10.0.1.16', '/srv/backup01', 'ssh-backup01.pem', 'Backup', 'São Paulo'),
('NB1-SRV-DASH-01', 'Windows Server 2022', 1, 'COM10', '10.0.1.17', '/srv/dash01', 'ssh-dash01.pem', 'Produção', 'Brasília');


INSERT INTO servidor 
(nome, sistema_operacional, fk_empresa, portaSerial, hostServer, endereco, chaveSSH, ambiente, localizacao)
VALUES
('NB2-SRV-HTTP-01', 'Ubuntu 22.04 LTS', 2, 'COM11', '10.0.2.10', '/srv/http01', 'ssh-http01.pem', 'Produção', 'Brasília'),
('NB2-SRV-HTTP-02', 'Ubuntu 22.04 LTS', 2, 'COM12', '10.0.2.11', '/srv/http02', 'ssh-http02.pem', 'Produção', 'Brasília'),
('NB2-SRV-B3-01', 'Debian 12', 2, 'COM13', '10.0.2.12', '/srv/b301', 'ssh-b301.pem', 'Produção', 'São Paulo'),
('NB2-SRV-B3-02', 'Debian 12', 2, 'COM14', '10.0.2.13', '/srv/b302', 'ssh-b302.pem', 'Produção', 'São Paulo'),
('NB2-SRV-ORDENS-01', 'Ubuntu 22.04', 2, 'COM15', '10.0.2.14', '/srv/ordens01', 'ssh-ordens01.pem', 'Produção', 'Rio de Janeiro'),
('NB2-SRV-ORDENS-02', 'Ubuntu 22.04', 2, 'COM16', '10.0.2.15', '/srv/ordens02', 'ssh-ordens02.pem', 'Produção', 'Rio de Janeiro'),
('NB2-SRV-METRICAS-01', 'Windows Server 2019', 2, 'COM17', '10.0.2.16', '/srv/metricas01', 'ssh-metricas01.pem', 'Homologação', 'Belo Horizonte'),
('NB2-SRV-ETL-01', 'Ubuntu 20.04', 2, 'COM18', '10.0.2.17', '/srv/etl01', 'ssh-etl01.pem', 'Produção', 'Curitiba');

INSERT INTO tipo_componente
(fk_componente, fk_servidor, fk_formato, nome_componente, valor_max_critico, valor_min_critico, capacidade)
VALUES
(1, 5, 1, 'cpu_percent', 90.00, 0.00, '3.8 GHz'),
(1, 5, 2, 'cpu_freq_current', 4.20, 0.80, 'Intel Xeon'),
(2, 5, 1, 'ram_percent', 95.00, 0.00, '64 GB'),
(2, 5, 3, 'ram_used_gb', 58.00, 0.00, '64 GB'),
(3, 5, 1, 'disk_percent', 92.00, 0.00, '2 TB'),
(1, 6, 1, 'cpu_percent', 90.00, 0.00, '3.8 GHz'),
(1, 6, 2, 'cpu_freq_current', 4.20, 0.80, 'Intel Xeon'),
(2, 6, 1, 'ram_percent', 95.00, 0.00, '64 GB'),
(2, 6, 3, 'ram_used_gb', 58.00, 0.00, '64 GB'),
(3, 6, 1, 'disk_percent', 92.00, 0.00, '2 TB'),
(4, 6, 4, 'latencia_resposta_ms', 500.00, 0.00, 'Rede Corporativa'),
(1, 7, 1, 'cpu_percent', 88.00, 0.00, '3.6 GHz'),
(1, 7, 2, 'cpu_freq_current', 4.00, 0.80, 'AMD EPYC'),
(2, 7, 1, 'ram_percent', 93.00, 0.00, '128 GB'),
(2, 7, 3, 'ram_used_gb', 120.00, 0.00, '128 GB'),
(3, 7, 1, 'disk_percent', 90.00, 0.00, '4 TB'),
(4, 7, 4, 'latencia_resposta_ms', 400.00, 0.00, 'Rede API'),
(1, 8, 1, 'cpu_percent', 88.00, 0.00, '3.6 GHz'),
(1, 8, 2, 'cpu_freq_current', 4.00, 0.80, 'AMD EPYC'),
(2, 8, 1, 'ram_percent', 93.00, 0.00, '128 GB'),
(2, 8, 3, 'ram_used_gb', 120.00, 0.00, '128 GB'),
(3, 8, 1, 'disk_percent', 90.00, 0.00, '4 TB'),
(4, 8, 4, 'latencia_resposta_ms', 400.00, 0.00, 'Rede API'),
(1, 9, 1, 'cpu_percent', 85.00, 0.00, '3.4 GHz'),
(1, 9, 2, 'cpu_freq_current', 3.90, 0.80, 'Intel Xeon'),
(2, 9, 1, 'ram_percent', 90.00, 0.00, '32 GB'),
(2, 9, 3, 'ram_used_gb', 28.00, 0.00, '32 GB'),
(3, 9, 1, 'disk_percent', 88.00, 0.00, '1 TB'),
(4, 9, 4, 'latencia_resposta_ms', 350.00, 0.00, 'Rede Auth'),
(1, 10, 1, 'cpu_percent', 80.00, 0.00, '3.2 GHz'),
(1, 10, 2, 'cpu_freq_current', 3.80, 0.80, 'Intel Xeon'),
(2, 10, 1, 'ram_percent', 89.00, 0.00, '32 GB'),
(2, 10, 3, 'ram_used_gb', 27.00, 0.00, '32 GB'),
(3, 10, 1, 'disk_percent', 85.00, 0.00, '2 TB'),
(4, 10, 4, 'latencia_resposta_ms', 320.00, 0.00, 'Rede Monitoramento'),
(1, 11, 1, 'cpu_percent', 75.00, 0.00, '3.0 GHz'),
(1, 11, 2, 'cpu_freq_current', 3.50, 0.80, 'AMD Ryzen'),
(2, 11, 1, 'ram_percent', 85.00, 0.00, '16 GB'),
(2, 11, 3, 'ram_used_gb', 14.00, 0.00, '16 GB'),
(3, 11, 1, 'disk_percent', 80.00, 0.00, '8 TB'),
(4, 11, 4, 'latencia_resposta_ms', 280.00, 0.00, 'Rede Backup'),
(1, 12, 1, 'cpu_percent', 87.00, 0.00, '4.0 GHz'),
(1, 12, 2, 'cpu_freq_current', 4.50, 0.80, 'Intel Xeon'),
(2, 12, 1, 'ram_percent', 94.00, 0.00, '64 GB'),
(2, 12, 3, 'ram_used_gb', 60.00, 0.00, '64 GB'),
(3, 12, 1, 'disk_percent', 91.00, 0.00, '2 TB'),
(4, 12, 4, 'latencia_resposta_ms', 450.00, 0.00, 'Dashboard HTTP'),
(1, 13, 1, 'cpu_percent', 89.00, 0.00, '3.9 GHz'),
(1, 13, 2, 'cpu_freq_current', 4.40, 0.80, 'Intel Xeon'),
(2, 13, 1, 'ram_percent', 95.00, 0.00, '128 GB'),
(2, 13, 3, 'ram_used_gb', 118.00, 0.00, '128 GB'),
(3, 13, 1, 'disk_percent', 92.00, 0.00, '4 TB'),
(4, 13, 4, 'latencia_resposta_ms', 500.00, 0.00, 'HTTP Requests'),
(1, 14, 1, 'cpu_percent', 89.00, 0.00, '3.9 GHz'),
(1, 14, 2, 'cpu_freq_current', 4.40, 0.80, 'Intel Xeon'),
(2, 14, 1, 'ram_percent', 95.00, 0.00, '128 GB'),
(2, 14, 3, 'ram_used_gb', 118.00, 0.00, '128 GB'),
(3, 14, 1, 'disk_percent', 92.00, 0.00, '4 TB'),
(4, 14, 4, 'latencia_resposta_ms', 500.00, 0.00, 'HTTP Requests'),
(1, 15, 1, 'cpu_percent', 93.00, 0.00, '4.2 GHz'),
(1, 15, 2, 'cpu_freq_current', 4.80, 0.80, 'AMD Threadripper'),
(2, 15, 1, 'ram_percent', 97.00, 0.00, '256 GB'),
(2, 15, 3, 'ram_used_gb', 240.00, 0.00, '256 GB'),
(3, 15, 1, 'disk_percent', 94.00, 0.00, '8 TB'),
(4, 15, 4, 'latencia_resposta_ms', 700.00, 0.00, 'Integração B3'),
(1, 16, 1, 'cpu_percent', 93.00, 0.00, '4.2 GHz'),
(1, 16, 2, 'cpu_freq_current', 4.80, 0.80, 'AMD Threadripper'),
(2, 16, 1, 'ram_percent', 97.00, 0.00, '256 GB'),
(2, 16, 3, 'ram_used_gb', 240.00, 0.00, '256 GB'),
(3, 16, 1, 'disk_percent', 94.00, 0.00, '8 TB'),
(4, 16, 4, 'latencia_resposta_ms', 700.00, 0.00, 'Integração B3'),
(1, 17, 1, 'cpu_percent', 91.00, 0.00, '4.1 GHz'),
(1, 17, 2, 'cpu_freq_current', 4.60, 0.80, 'Intel Xeon'),
(2, 17, 1, 'ram_percent', 96.00, 0.00, '128 GB'),
(2, 17, 3, 'ram_used_gb', 122.00, 0.00, '128 GB'),
(3, 17, 1, 'disk_percent', 93.00, 0.00, '6 TB'),
(4, 17, 4, 'latencia_resposta_ms', 650.00, 0.00, 'Servidor de Ordens'),
(1, 18, 1, 'cpu_percent', 91.00, 0.00, '4.1 GHz'),
(1, 18, 2, 'cpu_freq_current', 4.60, 0.80, 'Intel Xeon'),
(2, 18, 1, 'ram_percent', 96.00, 0.00, '128 GB'),
(2, 18, 3, 'ram_used_gb', 122.00, 0.00, '128 GB'),
(3, 18, 1, 'disk_percent', 93.00, 0.00, '6 TB'),
(4, 18, 4, 'latencia_resposta_ms', 650.00, 0.00, 'Servidor de Ordens'),
(1, 19, 1, 'cpu_percent', 86.00, 0.00, '3.7 GHz'),
(1, 19, 2, 'cpu_freq_current', 4.10, 0.80, 'AMD Ryzen'),
(2, 19, 1, 'ram_percent', 90.00, 0.00, '64 GB'),
(2, 19, 3, 'ram_used_gb', 54.00, 0.00, '64 GB'),
(3, 19, 1, 'disk_percent', 89.00, 0.00, '2 TB'),
(4, 19, 4, 'latencia_resposta_ms', 430.00, 0.00, 'Servidor Métricas'),
(1, 20, 1, 'cpu_percent', 84.00, 0.00, '3.5 GHz'),
(1, 20, 2, 'cpu_freq_current', 3.90, 0.80, 'Intel Xeon'),
(2, 20, 1, 'ram_percent', 88.00, 0.00, '32 GB'),
(2, 20, 3, 'ram_used_gb', 29.00, 0.00, '32 GB'),
(3, 20, 1, 'disk_percent', 87.00, 0.00, '1 TB'),
(4, 20, 4, 'latencia_resposta_ms', 300.00, 0.00, 'Servidor ETL');

INSERT INTO tipo_componente
(fk_servidor, fk_formato, fk_componente, nome_componente, valor_max_critico, valor_min_critico, capacidade)
VALUES

(13, 1, 4, 'volume_requisicoes_http', 1200.00, 0.00, 'Dashboard HTTP'),
(13, 4, 4, 'latencia_p95_ordens', 900.00, 0.00, 'Dashboard HTTP'),
(13, 1, 4, 'respostas_http_5xx', 150.00, 0.00, 'Dashboard HTTP'),

(14, 1, 4, 'volume_requisicoes_http', 1200.00, 0.00, 'Dashboard HTTP'),
(14, 4, 4, 'latencia_p95_ordens', 900.00, 0.00, 'Dashboard HTTP'),
(14, 1, 4, 'respostas_http_5xx', 150.00, 0.00, 'Dashboard HTTP'),

(15, 1, 4, 'volume_requisicoes_http', 2000.00, 0.00, 'B3 Integração'),
(15, 4, 4, 'latencia_p95_ordens', 1200.00, 0.00, 'B3 Integração'),
(15, 1, 4, 'erro_503', 200.00, 0.00, 'B3 Integração'),

(16, 1, 4, 'volume_requisicoes_http', 2000.00, 0.00, 'B3 Integração'),
(16, 4, 4, 'latencia_p95_ordens', 1200.00, 0.00, 'B3 Integração'),
(16, 1, 4, 'erro_504', 200.00, 0.00, 'B3 Integração'),

(17, 1, 4, 'ordens_com_sucesso', 1000.00, 0.00, 'Servidor Ordens'),
(17, 4, 4, 'latencia_p95_ordens', 950.00, 0.00, 'Servidor Ordens'),

(18, 1, 4, 'ordens_com_sucesso', 1000.00, 0.00, 'Servidor Ordens'),
(18, 4, 4, 'latencia_p95_ordens', 950.00, 0.00, 'Servidor Ordens');


select * from usuario;

