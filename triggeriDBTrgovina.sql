-- TRIGERI OKIDAČI --

-- DEFINIRANJE TRIGERA:

-- DELIMITER //
-- CREATE TRIGGER p_artikl
	-- {BEFORE|AFTER} {INSERT|UPDATE|DELETE} ON TABLE
    -- FOR EACH ROW
-- BEGIN
-- END //
-- DELIMITER ;

# ZADATAK: Kod unosa artikla pretvori naziv u velika slova prije spremanja. 
-- u trigerima imammo new i old, gdje u new prilikom spremanja novih podataaka mijenjao, kod old mijenjamo postojeće vrijednosti?
DROP TRIGGER v_slova;
DELIMITER //
CREATE TRIGGER v_slova
 	BEFORE INSERT ON artikl
    FOR EACH ROW
BEGIN
	SET new.naziv= UPPER(new.naziv);
END //
DELIMITER ;



INSERT INTO artikl VALUES (24,'Kruh',10.0);
SELECT * FROM artikl;

UPDATE artikl SET naziv = 'Kruh' WHERE id = 24;
SELECT * FROM artikl;

-- Prilikom unosa računa postavi *datum izdavanja* na trenutni datum

DELIMITER //
CREATE TRIGGER d_datum_izdavanja
	BEFORE INSERT ON racun
    FOR EACH ROW
BEGIN
	
    SET new.datum_izdavanja= NOW();

END //
DELIMITER ;


INSERT INTO racun VALUES (34,12,1,'00004',NULL);
SELECT * FROM racun;

# Zadatak: Osiguraj da će *količina* na stavki računa uvijek biti pozitivna,
# ako je količina manja od 1 onda ju je potrebno postaviti na 1:

DELIMITER //
CREATE TRIGGER kol_artikl
	BEFORE INSERT ON stavka_racun
    FOR EACH ROW
BEGIN
	IF new.kolicina<0 THEN
		SET new.kolicina =1;
    END IF;
END //
DELIMITER ;


INSERT INTO stavka_racun VALUES (45,33,23,-10);
SELECT * FROM stavka_racun;

-- kada se UPDATEA onda kolicina ako se updatea bude negativna opet ubacena  u tablicu

UPDATE stavka_racun SET kolicina= -50 WHERE id= 45;
SELECT * FROM stavka_racun;

DELETE FROM stavka_racun WHERE id=45;

-- KORIŠTENJE PROCEDURE UNUTAR TRIGERA

DELIMITER //
CREATE PROCEDURE ispravi_kolicinu(INOUT p_kolicina INTEGER)
BEGIN
	IF p_kolicina<0 THEN
		SET p_kolicina=1;
	END IF;

END //
DELIMITER;


DELIMITER //
CREATE TRIGGER kol_artikl_i_procedura
	BEFORE INSERT ON stavka_racun
    FOR EACH ROW
BEGIN
	CALL ispravi_kolicinu(new.kolicina);
    
END //
DELIMITER ;

-- Malo kompliciranij stvari

# Stare i nove vrijednosti kod ažuriranja: Osiguraj da se datum računa ne može nikad izmijeniti:
DROP TRIGGER ol_pr;
DELIMITER //
CREATE TRIGGER ol_pr 
	BEFORE UPDATE ON racun
    FOR EACH ROW
BEGIN
	
    IF new.datum_izdavanja != old.datum_izdavanja THEN
		SET new.datum_izdavanja = old.datum_izdavanja;
	END IF;
END //
DELIMITER ;

-- druga solucija
DELIMITER //
CREATE TRIGGER ol_pr_greska
	BEFORE UPDATE ON racun
    FOR EACH ROW
BEGIN
	
    IF new.datum_izdavanja != old.datum_izdavanja THEN
			SIGNAL SQLSTATE '40000' SET MESSAGE_TEXT = "Ne možeš mijenjati datume";
	END IF;
END //
DELIMITER ;


UPDATE racun SET datum_izdavanja = NOW() WHERE id= 33;

-- 	Error Code: 1644. Ne možeš mijenjati datume	0.000 sec

# zadatak: osiguraj da cijena novog artikla ne bude veća od najskupljeg artikla:
DROP TRIGGER cijena_naj;
DELIMITER //
CREATE TRIGGER cijena_naj 
	BEFORE INSERT ON artikl
    FOR EACH ROW
BEGIN
	DECLARE max_cijena DECIMAL(10,2);
    SELECT  MAX(cijena) INTO max_cijena
    FROM artikl;
    
    IF new.cijena>max_cijena THEN
		SIGNAL SQLSTATE '40001' SET MESSAGE_TEXT = "Preskupo";
	END IF;
    
END //
DELIMITER //;

INSERT INTO artikl VALUES (25,'Jabuke',100.0);

-- Error Code: 1644. Preskupo

-- AFTER OKIDAČ
-- ne dopušta mijenjanje podatak u bazi

DELIMITER //
CREATE TRIGGER after_t 
	AFTER INSERT ON artikl
    FOR EACH ROW
BEGIN
	-- u atrinutu nije moguće mijenjati vrijednosti SET new.cijena= new.cijena + 100;
    -- moguće je izbaciti grešku
	IF new.cijena > 100 THEN
		SIGNAL SQLSTATE '40002' SET MESSAGE_TEXT = "opet preskupo";
	END IF;
    
END //
DELIMITER ;

-- after TRIGGERE ćemo koristiti kada želimo dodatno napraviti neku provjeru kada su podaci već spremljeni u bazu. 
-- kada želimo napraviti dodatnu provjeru kakad asu ti podaci već spremljeni u bazu i u tom slučaju se mogu pokrenut neke procedure da ažuriraju neke druge tablice
-- BEFORE TRIGERI za validaciju podataka

-- INSERT TRIGERI imaju modifikator NEW
-- UPDATE --> ima odifikatore new i old
-- DELETE--> OLD 

-- FOR EACH ROW-trigger se pokreće 1 za svaki redak














