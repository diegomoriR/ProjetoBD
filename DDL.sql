DROP TABLE Iniciativa;
DROP TABLE Evento;
DROP TABLE Promotor;
DROP TABLE Pessoa; 
DROP TABLE Organizacao;
DROP TABLE Espaco;
DROP TABLE Promove;
DROP TABLE Recurso;
DROP TABLE Atividade;
DROP TABLE Inscricao;
DROP TABLE Sessao;
DROP TABLE Atua_em;
DROP TABLE Requer;
DROP TABLE Dispoe;
DROP TABLE Inscricao_sessao;
DROP TABLE Historico_sessao;

CREATE TABLE Iniciativa (
	iniciativa_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	nome varchar
);

CREATE TABLE Evento (
	evento_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	iniciativa_id integer NOT NULL,
	edicao varchar,
	data_inicio date,
	data_fim date,
	CONSTRAINT fk_iniciativa_id FOREIGN KEY (iniciativa_id) REFERENCES Iniciativa(iniciativa_id) ON DELETE CASCADE
);

CREATE TABLE Promotor (
	promotor_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	email varchar
);

CREATE TABLE Pessoa (
	promotor_id integer,
	CPF varchar,
	nome varchar,
	CONSTRAINT pk_pessoa PRIMARY KEY(promotor_id),
	CONSTRAINT fk_pessoa_id FOREIGN KEY(promotor_id) REFERENCES Promotor(promotor_id) ON DELETE CASCADE,
	CONSTRAINT uq_CPF UNIQUE(CPF)
);

CREATE TABLE Organizacao (
	promotor_id integer,
	CNPJ varchar,
	razao_social varchar,
	CONSTRAINT pk_organizacao PRIMARY KEY(promotor_id),
	CONSTRAINT fk_organizacao_id FOREIGN KEY(promotor_id) REFERENCES Promotor(promotor_id) ON DELETE CASCADE,
	CONSTRAINT uq_CNPJ UNIQUE(CNPJ)
);

CREATE TABLE Espaco (
	espaco_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	nome varchar NOT NULL,
	capacidade integer NOT NULL
);

CREATE TABLE Promove (
	evento_id integer,
	promotor_id integer,
	papel varchar NOT NULL,
	CONSTRAINT pk_promove PRIMARY KEY(evento_id, promotor_id),
	CONSTRAINT fk_evento_id FOREIGN KEY(evento_id) REFERENCES Evento(evento_id) ON DELETE CASCADE,
	CONSTRAINT fk_promotor_id FOREIGN KEY(promotor_id) REFERENCES Promotor(promotor_id) ON DELETE CASCADE
);

CREATE TABLE Recurso (
	recurso_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	nome varchar NOT NULL
);

CREATE TABLE Atividade (
	atividade_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	evento_id integer,
	titulo varchar,
	tipo varchar,
	exige_inscricao boolean,
	funcao_organizacao varchar,
	CONSTRAINT fk_evento_atividade FOREIGN KEY (evento_id) REFERENCES Evento(evento_id)
);

CREATE TABLE Inscricao (
	inscricao_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	evento_id integer,
	status varchar,
	CONSTRAINT fk_inscricao_evento FOREIGN KEY (evento_id) REFERENCES Evento(evento_id) 
);

CREATE TABLE Sessao (
	sessao_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	atividade_id integer,
	espaco_id integer,
	inicio date,
	fim date,
	vagas integer,
	status varchar,
	CONSTRAINT fk_sessao_atividade FOREIGN KEY (atividade_id) REFERENCES Atividade(atividade_id),
	CONSTRAINT fk_sessao_espaco FOREIGN KEY (espaco_id) REFERENCES Espaco(espaco_id)
);

CREATE TABLE Atua_Em (
	pessoa_id integer,
	atividade_id integer,
	funcao varchar,
	CONSTRAINT pk_atuaem PRIMARY KEY (pessoa_id, atividade_id),
	CONSTRAINT fk_atua_pessoa FOREIGN KEY (pessoa_id) REFERENCES Pessoa(promotor_id),
	CONSTRAINT fk_atua_atividade FOREIGN KEY (atividade_id) REFERENCES Atividade(atividade_id)
);

CREATE TABLE Requer (
	atividade_id integer,
	recurso_id integer,
	CONSTRAINT pk_requer PRIMARY KEY (atividade_id, recurso_id),
	CONSTRAINT fk_requer_atividade FOREIGN KEY (atividade_id) REFERENCES Atividade(atividade_id),
	CONSTRAINT fk_requer_recurso FOREIGN KEY (recurso_id) REFERENCES Recurso(recurso_id)
);

CREATE TABLE Dispoe (
	espaco_id integer,
	recurso_id integer,
	quantidade integer,
	CONSTRAINT pk_dispoe PRIMARY KEY (espaco_id, recurso_id),
	CONSTRAINT fk_dispoe_espaco FOREIGN KEY (espaco_id) REFERENCES Espaco(espaco_id),
	CONSTRAINT fk_dispoe_recurso FOREIGN KEY (recurso_id) REFERENCES Recurso(recurso_id)
);

CREATE TABLE Inscricao_sessao (
	inscricao_id integer,
	sessao_id integer,
	status varchar,
	posicao_espera integer,
	CONSTRAINT pk_inscricao_sessao PRIMARY KEY (inscricao_id, sessao_id),
	CONSTRAINT fk_IS_inscricao FOREIGN KEY (inscricao_id) REFERENCES Inscricao(inscricao_id),
	CONSTRAINT fk_IS_sessao FOREIGN KEY (sessao_id) REFERENCES Sessao(sessao_id)
);

CREATE TABLE Historico_sessao (
	id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	sessao_id integer,
	espaco_ant integer,
	inicio_ant date,
	fim_ant date,
	alterado_em date,
	CONSTRAINT fk_hs_sessao FOREIGN KEY (sessao_id) REFERENCES Sessao(sessao_id),
	CONSTRAINT fk_hs_espaco FOREIGN KEY (espaco_ant) REFERENCES Espaco(espaco_id)
);
