CREATE TABLE "spolecznosci" (
  "id_spolecznosci" integer PRIMARY KEY,
  "nazwa" varchar NOT NULL
);

CREATE TABLE "konferencje_spolecznosci" (
  "id_konferencji" integer NOT NULL,
  "id_spolecznosci" integer NOT NULL
);

CREATE TABLE "konferencje" (
  "id_konferencji" integer PRIMARY KEY,
  "title" varchar
);

CREATE TABLE "czlonkowie_spolecznosci" (
  "id_czlonka" integer NOT NULL,
  "id_spolecznosci" integer NOT NULL,
  "id_roli" integer NOT NULL
);

CREATE TABLE "role" (
  "id_roli" integer PRIMARY KEY,
  "nazwa" varchar NOT NULL
);

CREATE TABLE "edycje" (
  "id_edycji" integer PRIMARY KEY,
  "nr_edycji" integer NOT NULL,
  "id_konferencji" integer NOT NULL,
  "data_rozpoczecia" date,
  "data_zakonczenia" date,
  "miejsce" varchar,
  "podtytul" varchar
);

CREATE TABLE "sale" (
  "id_sali" integer PRIMARY KEY,
  "adres" varchar[100] NOT NULL,
  "nazwa" varchar[20] NOT NULL,
  "pojemnosc" integer NOT NULL
);

CREATE TABLE "czlonkowie" (
  "id_czlonka" integer PRIMARY KEY,
  "nazwa_uzytkownika" varchar[30] NOT NULL,
  "email" varchar[100] NOT NULL,
  "imie" varchar[30],
  "nazwisko" varchar[150],
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
  "id_prelekcji" integer PRIMARY KEY,
  "id_edycji" integer NOT NULL,
  "id_sali" integer,
  "data_prelekcji" timestamp,
  "dlugosc_prelekcji" integer NOT NULL,
  "temat" varchar[100],
  "opis" varchar[1000]
);

CREATE TABLE "dlugosci" (
  "dlugosc_prelekcji" integer PRIMARY KEY,
  "dlugosc" timestamp NOT NULL
);

CREATE TABLE "prelegenci" (
  "id_prelegenta" integer PRIMARY KEY,
  "id_czlonka" integer UNIQUE,
  "imie" varchar[30] NOT NULL,
  "nazwisko" varchar[150] NOT NULL
);

CREATE TABLE "prelekcje_prelegenci" (
  "id_prelegenta" integer NOT NULL,
  "id_prelekcji" integer NOT NULL
);

CREATE TABLE "posty" (
  "id_posta" integer PRIMARY KEY,
  "id_posta_nad" integer,
  "id_spolecznosci" integer NOT NULL,
  "id_czlonka" integer NOT NULL,
  "data_dodania" date NOT NULL,
  "tytul" varchar[100] NOT NULL,
  "tresc" varchar[1000] NOT NULL
);

CREATE TABLE "organizatorzy" (
  "id_czlonka" integer NOT NULL,
  "id_edycji" integer NOT NULL
);

ALTER TABLE "organizatorzy" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "organizatorzy" ADD FOREIGN KEY ("id_edycji") REFERENCES "edycje" ("id_edycji");

ALTER TABLE "czlonkowie_spolecznosci" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "czlonkowie_spolecznosci" ADD FOREIGN KEY ("id_spolecznosci") REFERENCES "spolecznosci" ("id_spolecznosci");

ALTER TABLE "prelegenci" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "konferencje_spolecznosci" ADD FOREIGN KEY ("id_konferencji") REFERENCES "konferencje" ("id_konferencji");

ALTER TABLE "konferencje_spolecznosci" ADD FOREIGN KEY ("id_spolecznosci") REFERENCES "spolecznosci" ("id_spolecznosci");

ALTER TABLE "prelekcje_prelegenci" ADD FOREIGN KEY ("id_prelegenta") REFERENCES "prelegenci" ("id_prelegenta");

ALTER TABLE "prelekcje_prelegenci" ADD FOREIGN KEY ("id_prelekcji") REFERENCES "prelekcje" ("id_prelekcji");

ALTER TABLE "posty" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "czlonkowie_spolecznosci" ADD FOREIGN KEY ("id_roli") REFERENCES "role" ("id_roli");

ALTER TABLE "posty" ADD FOREIGN KEY ("id_spolecznosci") REFERENCES "spolecznosci" ("id_spolecznosci");

ALTER TABLE "prelekcje" ADD FOREIGN KEY ("id_sali") REFERENCES "sale" ("id_sali");

ALTER TABLE "edycje" ADD FOREIGN KEY ("id_konferencji") REFERENCES "konferencje" ("id_konferencji");

ALTER TABLE "edycje_sale" ADD FOREIGN KEY ("id_edycji") REFERENCES "edycje" ("id_edycji");

ALTER TABLE "edycje_sale" ADD FOREIGN KEY ("id_sali") REFERENCES "sale" ("id_sali");

ALTER TABLE "czlonkowie_edycje" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "czlonkowie_edycje" ADD FOREIGN KEY ("id_edycji") REFERENCES "edycje" ("id_edycji");

ALTER TABLE "prelekcje" ADD FOREIGN KEY ("dlugosc_prelekcji") REFERENCES "dlugosci" ("dlugosc_prelekcji");

ALTER TABLE "posty" ADD FOREIGN KEY ("id_posta_nad") REFERENCES "posty" ("id_posta");
