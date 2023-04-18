-- PROCEDURE SQL

# DEFINIRANJE procedure: Napiši proceduru koja će pri pozivu povećati cijenu 
# svih artikala za vrijednost parametra *postotak*

DELIMITER //

CREATE PROCEDURE povecaj_cijene(postotak DECIMAL(4,2))
BEGIN
	UPDATE artikl 
		SET cijena= cijena* (1+ postotak/100 );
END //
DELIMITER ;

# poziv procedure

CALL povecaj_cijene(50);

SELECT * FROM artikl;


# IN/OUT parametri: Napiši proceduru koja će u varijablu *rezultat* spremiti zbroj vrijednosti *a* i *b*:

DELIMITER // 
CREATE PROCEDURE suma(IN a INTEGER, IN b INTEGER, OUT rez INTEGER)
BEGIN
	SET rez = a + b;

END //
DELIMITER ;

CALL suma (2,3, @sesijska_varijabla );


SELECT @sesijska_varijala;

#INOUT parametar: Napiši neku procedutru koja će povećati vrijednost parametra za 1

DELIMITER //
CREATE PROCEDURE povecaj_br(INOUT br INTEGER)
BEGIN
	SET br= br+1;

END //
DELIMITER ;
SET @brojac=5;

CALL povecaj_br(@brojac);
SELECT @brojac;

#  Napiši proceduru koja će dohvatiti min i max cijenu artikala i spremiti ih u varijbale min_cije na i max_cijena
# IMPLICITNI KURSOR pokazivač na određeni set rezultata

DELIMITER //
CREATE PROCEDURE min_max_artikla(OUT min_cijena DECIMAL(10,2), OUT max_cijena DECIMAL(10,2))
BEGIN
	SELECT MIN(cijena), MAX(cijena) INTO min_cijena, max_cijena
		FROM artikl;
END //
DELIMITER ;

CALL min_max_artikla(@min,@max);
SELECT @min, @max;

## Eksplicitni cursor
# Napiši proceduru gornju korištenjem eksplicitnog kursora

DELIMITER //
CREATE PROCEDURE eksplicitni_kursor(OUT min_cijena DECIMAL(10,2), OUT max_cijena DECIMAL(10,2))

BEGIN
	DECLARE cur CURSOR FOR
		SELECT cijena, cijena
			FROM artikl;
            
	OPEN cur;
		FETCH cur INTO min_cijena, max_cijena;
    FETCH cur INTO min_cijena, max_cijena;
    FETCH cur INTO min_cijena, max_cijena;
    CLOSE cur;

END //
DELIMITER ;

CALL eksplicitni_kursor(@mini,@maxi);
SELECT @mini,@maxi;

# LOOP PETLJA: Napiši proceduru koja besmisleno iterira od 1 do 10

DELIMITER //
CREATE PROCEDURE demo_loop(OUT p_x INTEGER )
BEGIN
SET p_x=0;
 naziv_petlje: LOOP
 SET p_x= p_x+1;
 IF p_x = 10 
 THEN LEAVE naziv_petlje;
 END IF;
 
 END LOOP naziv_petlje:

END //
DELIMITER ;

CALL demo_loop(@rez);
SELECT @rez;

# ITERATE kao continue u c++








