CREATE DOMAIN DOM_TELEFONO AS INTEGER
	CONSTRAINT c_telefono_valido
	CHECK (VALUE BETWEEN 1000000000 AND 9999999999);

CREATE DOMAIN DOM_NATURALE AS INTEGER
	CONSTRAINT c_non_negativo
	CHECK (VALUE >= 0);

CREATE TABLE Fornitore(
	nome VARCHAR(100) PRIMARY KEY,
	via VARCHAR(100) NOT NULL,
	civico VARCHAR(5) NOT NULL,
	cap VARCHAR(5) NOT NULL
);

CREATE TABLE Progetto(
	codice_aziendale DOM_NATURALE PRIMARY KEY,
	budget DOM_NATURALE NOT NULL,
	durata_in_mesi DOM_NATURALE
);

CREATE TABLE Competenza(nome VARCHAR(100) PRIMARY KEY);

CREATE TABLE Dipartimento(
	nome VARCHAR(100) PRIMARY KEY,
	recapito DOM_TELEFONO UNIQUE NOT NULL,
	email VARCHAR(100),
	numero_afferenti DOM_NATURALE,
	ultimo_acquisto VARCHAR(100),
	data_ultimo_acquisto DATE,
	FOREIGN KEY (ultimo_acquisto) REFERENCES Fornitore ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Dipendente(
	matricola DOM_NATURALE PRIMARY KEY,
	nome VARCHAR(100) NOT NULL,
	cognome VARCHAR(100) NOT NULL,
	data_assunzione DATE NOT NULL,
	qualifica VARCHAR(100) NOT NULL,
	data_di_nascita DATE NOT NULL,
	data_laurea DATE,
	data_dottorato DATE,
	classe_laurea VARCHAR(50),
	classe_dottorato VARCHAR(50),
	dipartimento VARCHAR(100) NOT NULL,
	FOREIGN KEY (dipartimento) REFERENCES Dipartimento ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Matrimonio(
	coniuge1 DOM_NATURALE PRIMARY KEY,
	coniuge2 DOM_NATURALE UNIQUE NOT NULL,
	FOREIGN KEY (coniuge1) REFERENCES Dipendente ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (coniuge2) REFERENCES Dipendente ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Possiede(
	competenza VARCHAR(100),
	matricola DOM_NATURALE,
	PRIMARY KEY (competenza, matricola),
	FOREIGN KEY (competenza) REFERENCES Competenza ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (matricola) REFERENCES Dipendente ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Coinvolge(
	matricola DOM_NATURALE,
	competenza VARCHAR(100),
	progetto DOM_NATURALE,
	PRIMARY KEY (matricola, competenza, progetto),
	FOREIGN KEY (matricola) REFERENCES Dipendente ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (competenza) REFERENCES Competenza ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (progetto) REFERENCES Progetto ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Fornisce(
	dipartimento VARCHAR(100),
	fornitore VARCHAR(100),
	PRIMARY KEY (dipartimento, fornitore),
	FOREIGN KEY (dipartimento) REFERENCES Dipartimento ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (fornitore) REFERENCES Fornitore ON UPDATE CASCADE ON DELETE CASCADE
)