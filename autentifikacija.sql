## AUTENTIFIKACIJA I AUTORIZACIJA

# Kreiraj novog korisnika pod nazivom 'novi korisnik' i lozinkom 'novi korisnik'

## REATE USER novi_korisnik IDENTIFIED BY 'novi_korisnik';

# dodijeli ovlasti korisniku 'novi_korisnik' za čitanje, ažuriranje i brisanje nad tablicom račun:alter
# Prijavi se sa korisnikom 'novi_korisnik' i isprobaj CRUD operacija
GRANT  SELECT, UPDATE ON trgovina.racun TO novi_korisnik;

# Prikaz svih ovlasti korisnika

SHOW GRANTS FOR novi_korisnik;
SHOW GRANTS FOR CURRENT_USER();

## OPOZIV OVLASTI

REVOKE UPDATE ON trgovina.racun FROM novi_korisnik;

## dodijeli ovlast čitanja tablice tako da novi korisnik može dati istu ovlast korisnicima koje je on kreirao:

GRANT SELECT ON trgovina.artikl TO novi_korisnik WITH GRANT OPTION;
