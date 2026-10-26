DROP TABLE Iniciativa ON DELETE CASCADE;
DROP TABLE Evento ON DELETE CASCADE;
DROP TABLE 

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
	CONSTRAINT fk_promotor_id FOREIGN KEY(promotor_id) REFERENCES Promotor(promotor_id) ON DELETE CASCADE,
	CONSTRAINT uq_CPF UNIQUE(CPF)
);