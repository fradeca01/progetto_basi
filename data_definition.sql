CREATE TABLE Fornitore(
	nome VARCHAR(100) PRIMARY KEY,
	indirizzo VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Progetto(
	codice_aziendale INT PRIMARY KEY,
	budget INT NOT NULL,
	durata_in_mesi INT NULL
);

CREATE TABLE Competenza(nome VARCHAR(100) PRIMARY KEY);

CREATE TABLE Dipartimento(
	nome VARCHAR(100) PRIMARY KEY,
	recapito INT UNIQUE NOT NULL,
	email VARCHAR(100),
	numero_afferenti INT,
	ultimo_acquisto VARCHAR(100),
	data_ultimo_acquisto DATE,
	FOREIGN KEY (ultimo_acquisto) REFERENCES Fornitore ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Dipendente(
	matricola INT PRIMARY KEY,
	nome VARCHAR(100) NOT NULL,
	cognome VARCHAR(100) NOT NULL,
	data_assunzione DATE NOT NULL,
	qualifica VARCHAR(100) NOT NULL,
	data_di_nascita DATE NOT NULL,
	data_laurea DATE NULL,
	data_dottorato DATE NULL,
	classe_laurea VARCHAR(50) NULL,
	classe_dottorato VARCHAR(50) NULL,
	dipartimento VARCHAR(100) NOT NULL,
	FOREIGN KEY (dipartimento) REFERENCES Dipartimento ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Matrimonio(
	coniuge1 INT PRIMARY KEY,
	coniuge2 INT UNIQUE NOT NULL,
	FOREIGN KEY (coniuge1) REFERENCES Dipendente ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (coniuge2) REFERENCES Dipendente ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Possiede(
	competenza VARCHAR(100),
	matricola INT,
	PRIMARY KEY (competenza, matricola),
	FOREIGN KEY (competenza) REFERENCES Competenza ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (matricola) REFERENCES Dipendente ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Coinvolge(
	matricola INT,
	competenza VARCHAR(100),
	progetto INT,
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