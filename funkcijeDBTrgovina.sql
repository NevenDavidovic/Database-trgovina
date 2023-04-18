CREATE DATABASE trgovina;
USE trgovina;
CREATE TABLE kupac (
 id INTEGER NOT NULL,
 ime VARCHAR(10) NOT NULL,
 prezime VARCHAR(15) NOT NULL,
 PRIMARY KEY (id)
);
CREATE TABLE zaposlenik (
 id INTEGER NOT NULL,
 ime VARCHAR(10) NOT NULL,
 prezime VARCHAR(15) NOT NULL,
 oib CHAR(11) NOT NULL,
 datum_zaposlenja DATETIME NOT NULL,
 PRIMARY KEY (id)
);
CREATE TABLE artikl (
 id INTEGER NOT NULL,
 naziv VARCHAR(20) NOT NULL,
 cijena NUMERIC(10,2) NOT NULL,
 PRIMARY KEY (id)
);

CREATE TABLE racun (
 id INTEGER NOT NULL,
 id_zaposlenik INTEGER NOT NULL,
 id_kupac INTEGER NOT NULL,
 broj VARCHAR(100) NOT NULL,
 datum_izdavanja DATETIME NOT NULL,
 PRIMARY KEY (id),
 FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id),
 FOREIGN KEY (id_kupac) REFERENCES kupac (id)
);
CREATE TABLE stavka_racun (
 id INTEGER NOT NULL,
 id_racun INTEGER NOT NULL,
 id_artikl INTEGER NOT NULL,
 kolicina INTEGER NOT NULL,
 PRIMARY KEY (id),
 FOREIGN KEY (id_racun) REFERENCES racun (id) ON DELETE CASCADE,
 FOREIGN KEY (id_artikl) REFERENCES artikl (id),
 UNIQUE (id_racun, id_artikl)
);

INSERT INTO kupac VALUES (1, 'Lea', 'Fabris'),
 (2, 'David', 'Sirotić'),
 (3, 'Tea', 'Bibić');
INSERT INTO zaposlenik VALUES
 (11, 'Marko', 'Marić', '123451', STR_TO_DATE('01.10.2020.', '%d.%m.%Y.')),
 (12, 'Toni', 'Milovan', '123452', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.')),
 (13, 'Tea', 'Marić', '123453', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.'));
INSERT INTO artikl VALUES (21, 'Puding', 5.99),
 (22, 'Milka čokolada', 30.00),
 (23, 'Čips', 9);
INSERT INTO racun VALUES
 (31, 11, 1, '00001', STR_TO_DATE('05.10.2020.', '%d.%m.%Y.')),
 (32, 12, 2, '00002', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.')),
 (33, 12, 1, '00003', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.'));
INSERT INTO stavka_racun VALUES (41, 31, 21, 2),
 (42, 31, 22, 5),
 (43, 32, 22, 1),
 (44, 32, 23, 1);

-- primjer funkcije
DROP FUNCTION demo;

DELIMITER //
CREATE FUNCTION demo() RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
	RETURN "It works";
END //
DELIMITER ;

SELECT demo() FROM DUAL;

-- 

DELIMITER //
CREATE FUNCTION suma(a INTEGER, b INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN a + b;
END //
DELIMITER ;

SELECT suma(1,2) FROM DUAL;

DELIMITER //
CREATE FUNCTION suma2(a INTEGER, b INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE rez INTEGER DEFAULT 0;
	SET rez = a + b;
	RETURN rez;
END //
DELIMITER ;

-- spremanje rezultata izvođenja upita, napiši funkciju koja će vratiti broj artikala zapisanih u bazu podataka
SELECT COUNT(*) FROM artikl;


DELIMITER //
CREATE FUNCTION brojArtikala () RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE br INTEGER;
    SELECT COUNT(*) INTO br
    FROM artikl;
	RETURN  br;
END //
DELIMITER ;

SELECT brojArtikala() FROM DUAL;

-- Napiši funkciju koja će vratiti izraz sa informacijama o cijeni artikla(npr. 'AVG: 15, MAX:30 itd')
-- - AKO koristimo into možemo vratiti samo jedan jedini redak u upitu
DELIMITER //
CREATE FUNCTION cijene() RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	DECLARE max_cijena DECIMAL(10,2);
    DECLARE avg_cijena DECIMAL(10,2);
    DECLARE min_cijena DECIMAL(10,2);
    
    SELECT MAX(cijena), MIN(cijena), AVG(cijena) INTO  max_cijena, min_cijena, avg_cijena FROM artikl;
	RETURN  CONCAT("AVG: ", avg_cijena,"MAX: ", max_cijena, "MIN: ", min_cijena) ;
END //
DELIMITER ;


SELECT cijene() FROM DUAL;

-- napiši funkciju koja će za određeni artikl(definiran sa parametrom p_id_artikl)
-- izračunati ukupnu prodanu količinu
-- Zatim napiši upit koji će prikazati sve artikle i njihovu prodanu količinu koristeći prethodno napisanu funkciu




DELIMITER //
CREATE FUNCTION prodana_kolicina(p_id_artikl INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE kol INTEGER;
	
    SELECT SUM(kolicina) INTO kol
	FROM stavka_racun
	WHERE id_artikl = p_id_artikl;
    
    RETURN kol;
END //
DELIMITER ;

SELECT prodana_kolicina(23) FROM DUAL;

SELECT *, UPPER(naziv) FROM artikl;

SELECT *, prodana_kolicina(id) FROM artikl;


-- Napiši funkciju koja će određeni račun(definiran sa parametrom p_id_racun) izracunati ukupan iznos.
-- Zatim napisi upit koji ce prikazati sve račune i njihov iznos koristeći prethodno napisanu funkciju

SELECT *,kolicina*cijena
FROM  stavka_racun INNER JOIN artikl 
ON artikl.id=stavka_racun.id_artikl
WHERE id_racun=3;

DELIMITER //
CREATE FUNCTION prikazi_iznos_racuna(p_id_racun INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN 
DECLARE iznos DECIMAL(10,2);


SELECT *,SUM(kolicina*cijena) INTO iznos
FROM  stavka_racun INNER JOIN artikl 
ON artikl.id=stavka_racun.id_artikl
WHERE id_racun=p_id_racun;

RETURN iznos;
END //
DELIMITER ;

-- Grananje: Napiši funkciju koja će za određenu cijenu(definiranu sa parametrom p_cijena)
-- vratiti vrijednost "Jeftino", ako je cijena manja od 10, u suprotnom će vratiti vrijednost "Skupo".
-- U slučaju da je p_cijena manja ili jednaka 0 vraća vrijednost "Došlo je do greške"

 DELIMITER //
 CREATE FUNCTION procjena_cijene(p_cijena DECIMAL(10,2)) RETURNS VARCHAR(100)
 DETERMINISTIC
 BEGIN
 DECLARE info VARCHAR(100);
 
		IF p_cijena <= 0 THEN
			SET info= "Došlo je do greške!!! ";
		ELSEIF p_cijena <10 THEN
			SET info="Jeftino";
		ELSE
			SET info= "Artikl je skup";
        
        
        
        END IF;
    
    
    RETURN info;
 END //
 DELIMITER ;

SELECT *, procjena_cijene(cijena) as skupoca_artikla FROM artikl;

# Petlje : While petlja 
# Napiši funkciju koja će za broj(definiran parametrom p_x) izračunati njegov faktorijel(while loop)


DELIMITER //
CREATE FUNCTION faktorijel(p_x INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE rez INTEGER DEFAULT 1;

	WHILE p_x >0 DO
		SET rez= rez*p_x;
        SET p_x=p_x -1;
       
    END WHILE;
    
	RETURN rez;
END //
DELIMITER ;


SELECT faktorijel(3) FROM DUAL;

-- isti primjer sa do while petljom/repeat

DELIMITER //
CREATE FUNCTION faktorijel2(broj INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE rez INTEGER DEFAULT 1;

	REPEAT
		SET rez= rez*p_x;
        SET p_x=p_x -1;
	UNTIL broj= 0
    END REPEAT;
    	
	RETURN rez;
END //
DELIMITER ;

-- Pozivanje funkcija unutar funkcija
-- Napiši funkciju koja će za broj (definiran parametrom p_x) izračunati njegov faktorijel,
-- >ali to će napraviti pozivom prethodne funkcije

DELIMITER //
CREATE FUNCTION demo121(p_x INTEGER) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	DECLARE f1, f2 INTEGER;
    SET f1= faktorijel(p_x);
    SELECT faktorijel2 (p_x) INTO f2
		FROM DUAL;
	
	RETURN CONCAT("funkc.1= ", f1,"funkc-2= ",f2);
END //
DELIMITER ;



