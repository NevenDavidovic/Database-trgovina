# Materijalizirani pogledi 

# ZADATAK: Napraviti tablicu(tablica je ujedno i implementacija materijaliziranog pogleda u MySQL-u)
	# koja će pratititi izdanu količinu pojedinog artikla(izdavanje artikla se vrši kroz tablicu stavka_racun):
    
# POSTUPAK:
-- napraviti tablicu u koju ćemo spremat izdanu količinu
-- Uhvatiti momente kada se artikli izdaju -> unos u stavka_racun, update stavka_racun i brisanje stavka_racun

CREATE TABLE Izdana_kolicina_artikala(
	id_artikl INTEGER REFERENCES artikl,
    kolicina INTEGER
);

-- KREIRANJE PROCEDURE 
DELIMITER //
CREATE PROCEDURE azuriraj_kolicinu_artikala(IN p_id_artikl INTEGER, IN p_kolicina INTEGER )
BEGIN
	DECLARE l_art_postoji INTEGER;
	# ažuriraj u tablici izdana kolicina artikala kolicinu za id_artikl
    # 1. provjerit ako id_artikl postoji u tablici izdana kolicina artikala
    SELECT COUNT(*) INTO l_art_postoji
    FROM izdana_kolicina_artikala
    WHERE id_artikl = p_id_artikl;
    # 2. ako postoji, onda azuriraj kolicinu (UPDATE)
    IF l_art_postoji = 0 THEN
		INSERT INTO izdana_kolicina_artikala VALUES (p_id_artikl, p_kolicina);
	ELSE 
		UPDATE izdana_kolicina_artikala
			SET kolicina=kolicina+p_kolicina
            WHERE id_artikl=p_id_artikl;
    END IF;
    
    # 3. ako ne postoji, onda dodaj (INSERT)
    
    
    
END //
DELIMITER ;

-- 1 trigger

DELIMITER //
CREATE TRIGGER ai_stavka_racun
	AFTER INSERT ON stavka_racun
    FOR EACH ROW
BEGIN

	CALL azuriraj_kolicinu_artikla(new.id_artikl, new.kolicina);
    
 END //
DELIMITER ;

-- drugi trigger

DELIMITER //
CREATE TRIGGER ad_stavka_racun
	AFTER DELETE ON stavka_racun
    FOR EACH ROW
BEGIN

	CALL azuriraj_kolicinu_artikla(old.id_artikl, -old.kolicina);
  
    
 END //
DELIMITER ;

-- Priprema
INSERT INTO stavka_racun VALUES (46,33,21,1);
SELECT * FROM stavka_racun;
SELECT * FROM izdana_kolicina_artikala;

-- TEstiranje
UPDATE stavka_racun SET kolicina = 10, id_artikl=22 WHERE id = 46;

-- Ispis
SELECT * FROM stavka_racun;
SELECT * FROM izdana_kolicina_artikala;

DELETE FROM stavka_racun WHERE id=46;

-- ovakve procedure se zovu online

-- 

SELECT * FROM racun;