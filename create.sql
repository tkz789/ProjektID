CREATE TABLE "spolecznosci" (
  "id_spolecznosci" serial PRIMARY KEY,
  "nazwa" varchar NOT NULL
);

CREATE TABLE "wydarzenia_spolecznosci" (
  "id_wydarzenia" integer NOT NULL,
  "id_spolecznosci" integer NOT NULL,
  UNIQUE("id_wydarzenia", "id_spolecznosci")
);

CREATE TABLE "rodzaje_wydarzen" (
  "typ_wydarzenia" serial PRIMARY KEY,
  "nazwa" varchar NOT NULL
);

CREATE TABLE "wydarzenia" (
  "id_wydarzenia" serial PRIMARY KEY,
  "typ_wydarzenia" integer NOT NULL,
  "nazwa" varchar NOT NULL
);

CREATE TABLE "czlonkowie_spolecznosci" (
  "id_czlonka" integer NOT NULL,
  "id_spolecznosci" integer NOT NULL,
  "id_roli" integer NOT NULL,
  UNIQUE("id_czlonka", "id_spolecznosci")
);

CREATE TABLE "role" (
  "id_roli" integer PRIMARY KEY,
  "nazwa" varchar NOT NULL
);

CREATE TABLE "edycje" (
  "id_edycji" serial PRIMARY KEY,
  "nr_edycji" integer NOT NULL,
  "id_wydarzenia" integer NOT NULL,
  "data_rozpoczecia" date NOT NULL,
  "data_zakonczenia" date NOT NULL,
  "miejsce" varchar NOT NULL,
  "podtytul" varchar,
  CHECK ("nr_edycji" > 0)
);

CREATE TABLE "sale" (
  "id_sali" serial PRIMARY KEY,
  "adres" varchar(100) NOT NULL,
  "nazwa" varchar(20) NOT NULL,
  "pojemnosc" integer NOT NULL,
  CHECK ("pojemnosc" > 0)
);

CREATE TABLE "zaimki" (
  "id_zaimka" serial PRIMARY KEY,
  "nazwa" varchar(16) UNIQUE NOT NULL
);

CREATE TABLE "czlonkowie" (
  "id_czlonka" serial PRIMARY KEY,
  "id_zaimka" integer,
  "nazwa_uzytkownika" varchar(30) UNIQUE NOT NULL,
  "email" varchar(100) UNIQUE NOT NULL,
  "imie" varchar(30) NOT NULL,
  "nazwisko" varchar(150) NOT NULL,
  "newsletter" bool,
  "data_dolaczenia" date NOT NULL,
  "haslo_hash" char(162)
);

CREATE TABLE "czlonkowie_archiwum" (
  "id_czlonka" serial PRIMARY KEY,
  "id_zaimka" integer,
  "nazwa_uzytkownika" varchar(30) NOT NULL,
  "email" varchar(100) UNIQUE NOT NULL,
  "imie" varchar(30) NOT NULL,
  "nazwisko" varchar(150) NOT NULL,
  "newsletter" bool,
  "data_dolaczenia" date NOT NULL
);

CREATE TABLE "czlonkowie_edycje" (
  "id_czlonka" integer NOT NULL,
  "id_edycji" integer NOT NULL
);

CREATE TABLE "edycje_sale" (
  "id_edycji" integer NOT NULL,
  "id_sali" integer NOT NULL
);

CREATE TABLE "prelekcje" (
  "id_prelekcji" serial PRIMARY KEY,
  "id_edycji" integer NOT NULL,
  "id_sali" integer,
  "data_prelekcji" timestamp,
  "dlugosc_prelekcji" integer NOT NULL,
  "temat" varchar(100) NOT NULL,
  "opis" varchar(1000)
);

CREATE TABLE "dlugosci" (
  "dlugosc_prelekcji" serial PRIMARY KEY,
  "dlugosc" interval NOT NULL,
  CHECK ("dlugosc" > '0 mins')
);

CREATE TABLE "prelegenci" (
  "id_prelegenta" serial PRIMARY KEY,
  "id_czlonka" integer UNIQUE,
  "imie" varchar(30) NOT NULL,
  "nazwisko" varchar(150) NOT NULL
);

CREATE TABLE "prelekcje_prelegenci" (
  "id_prelegenta" integer NOT NULL,
  "id_prelekcji" integer NOT NULL,
  UNIQUE("id_prelegenta", "id_prelekcji")
);

-- CREATE TABLE "hasla" (
--   "id_czlonka" integer NOT NULL,
--   "data_od" date NOT NULL,
--   "haslo" varchar(162) NOT NULL
-- );

-- CREATE TABLE "hasla_archiwum" (
--   "id_czlonka" integer NOT NULL,
--   "data_od" date NOT NULL,
--   "haslo" varchar(162) NOT NULL
-- );

CREATE TABLE "posty" (
  "id_posta" serial PRIMARY KEY,
  "id_posta_nad" integer,
  "id_spolecznosci" integer NOT NULL,
  "id_czlonka" integer NOT NULL,
  "data_dodania" date NOT NULL,
  "tytul" varchar(100) NOT NULL,
  "tresc" varchar(1000) NOT NULL
);

CREATE TABLE "posty_archiwum" (
  "id_posta" serial PRIMARY KEY,
  "id_posta_nad" integer,
  "id_spolecznosci" integer NOT NULL,
  "id_czlonka" integer NOT NULL,
  "data_dodania" date NOT NULL,
  "tytul" varchar(100) NOT NULL,
  "tresc" varchar(1000) NOT NULL
);

CREATE TABLE "wolontariusze" (
  "id_czlonka" integer NOT NULL,
  "id_edycji" integer NOT NULL,

  UNIQUE("id_czlonka", "id_edycji")
);

CREATE TABLE "organizatorzy" (
  "id_czlonka" integer NOT NULL,
  "id_edycji" integer NOT NULL,
  UNIQUE("id_czlonka", "id_edycji")
);

ALTER TABLE "organizatorzy" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "organizatorzy" ADD FOREIGN KEY ("id_edycji") REFERENCES "edycje" ("id_edycji");

ALTER TABLE "czlonkowie_spolecznosci" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "czlonkowie_spolecznosci" ADD FOREIGN KEY ("id_spolecznosci") REFERENCES "spolecznosci" ("id_spolecznosci");

ALTER TABLE "prelegenci" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "wydarzenia_spolecznosci" ADD FOREIGN KEY ("id_wydarzenia") REFERENCES "wydarzenia" ("id_wydarzenia");

ALTER TABLE "wydarzenia_spolecznosci" ADD FOREIGN KEY ("id_spolecznosci") REFERENCES "spolecznosci" ("id_spolecznosci");

ALTER TABLE "prelekcje_prelegenci" ADD FOREIGN KEY ("id_prelegenta") REFERENCES "prelegenci" ("id_prelegenta");

ALTER TABLE "prelekcje_prelegenci" ADD FOREIGN KEY ("id_prelekcji") REFERENCES "prelekcje" ("id_prelekcji");

ALTER TABLE "posty" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "czlonkowie_spolecznosci" ADD FOREIGN KEY ("id_roli") REFERENCES "role" ("id_roli");

ALTER TABLE "posty" ADD FOREIGN KEY ("id_spolecznosci") REFERENCES "spolecznosci" ("id_spolecznosci");

ALTER TABLE "prelekcje" ADD FOREIGN KEY ("id_sali") REFERENCES "sale" ("id_sali");

ALTER TABLE "edycje" ADD FOREIGN KEY ("id_wydarzenia") REFERENCES "wydarzenia" ("id_wydarzenia");

ALTER TABLE "edycje_sale" ADD FOREIGN KEY ("id_edycji") REFERENCES "edycje" ("id_edycji");

ALTER TABLE "edycje_sale" ADD FOREIGN KEY ("id_sali") REFERENCES "sale" ("id_sali");

ALTER TABLE "czlonkowie_edycje" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "czlonkowie_edycje" ADD FOREIGN KEY ("id_edycji") REFERENCES "edycje" ("id_edycji");

ALTER TABLE "prelekcje" ADD FOREIGN KEY ("dlugosc_prelekcji") REFERENCES "dlugosci" ("dlugosc_prelekcji");

ALTER TABLE "posty" ADD FOREIGN KEY ("id_posta_nad") REFERENCES "posty" ("id_posta");

ALTER TABLE "wydarzenia" ADD FOREIGN KEY ("typ_wydarzenia") REFERENCES "rodzaje_wydarzen" ("typ_wydarzenia");

ALTER TABLE "czlonkowie" ADD FOREIGN KEY ("id_zaimka") REFERENCES "zaimki" ("id_zaimka");

ALTER TABLE "wolontariusze" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "wolontariusze" ADD FOREIGN KEY ("id_edycji") REFERENCES "edycje" ("id_edycji");

ALTER TABLE "hasla" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");
