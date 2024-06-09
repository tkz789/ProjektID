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
  UNIQUE("id_czlonka", "id_spolecznosci"),
  primary key("id_czlonka", "id_spolecznosci", "id_roli")
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
  "miejsce" int not null,
  "podtytul" varchar,
  CHECK ("nr_edycji" > 0)
);

CREATE TABLE "sale" (
  "id_sali" serial PRIMARY KEY,
  "adres" int NOT NULL,
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
  "id_edycji" integer NOT NULL,
  unique("id_czlonka", "id_edycji")
);

CREATE TABLE "edycje_sale" (
  "id_edycji" integer NOT NULL,
  "id_sali" integer NOT NULL,
  unique("id_edycji", "id_sali")
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
  primary key("id_prelegenta", "id_prelekcji")
);

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

  primary key("id_czlonka", "id_edycji")
);

CREATE TABLE "organizatorzy" (
  "id_czlonka" integer NOT NULL,
  "id_edycji" integer NOT NULL,
  primary key("id_czlonka", "id_edycji")
);

CREATE TABLE "adresy" (
  "id_adresu" serial primary KEY,
  "adres" varchar(100) not null
);

CREATE TABLE "wolontariusze_prelekcje" (
  "id_czlonka" integer not null,
  "id_prelekcji" integer not null,
  primary key("id_czlonka", "id_prelekcji")
);

ALTER TABLE "wolontariusze_prelekcje" ADD FOREIGN KEY ("id_czlonka") REFERENCES "czlonkowie" ("id_czlonka");

ALTER TABLE "wolontariusze_prelekcje" ADD FOREIGN KEY ("id_prelekcji") REFERENCES "prelekcje" ("id_prelekcji");

ALTER TABLE "edycje" ADD FOREIGN KEY ("miejsce") REFERENCES "adresy" ("id_adresu");

ALTER TABLE "sale" ADD FOREIGN KEY ("adres") REFERENCES "adresy" ("id_adresu");

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

create or replace function get_user_id(username varchar(30)) returns integer as $$
declare user_id integer default -1;
begin
if(exists(select id_czlonka from czlonkowie where nazwa_uzytkownika = username)) then 
user_id = (select id_czlonka from czlonkowie where nazwa_uzytkownika = username);
end if;
if(user_id = -1) then
raise exception 'Nie znaleziono uzytkownika';
end if;
return user_id;
end;
$$ language plpgsql;

create or replace function register(username_ varchar(30), email_ varchar(100), name_ varchar(30), surname_ varchar(150), password_ char(162),
pronoun_id integer, newsletter boolean default true) returns boolean as $$
declare user_id integer;
begin
user_id = (select id_czlonka from czlonkowie where nazwa_uzytkownika = username_);
if(user_id is not null) then raise exception 'Podana nazwa uzytkownika jest juz zajeta'; end if;
user_id = (select id_czlonka from czlonkowie where nazwa_uzytkownika = email_);
if(user_id is not null) then raise exception 'Podany email jest juz zajety'; end if;
insert into czlonkowie(id_zaimka, nazwa_uzytkownika, email, imie, nazwisko, newsletter, data_dolaczenia, haslo_hash) values (pronoun_id, username_, email_, name_, surname_,
newsletter, NOW(), password_);
return true;
end;
$$ language plpgsql;

create or replace function make_post(parent_post_id integer, community_id integer, user_id integer, title varchar(100), content varchar(1000))
returns integer as $$
declare retId integer;
declare parentCommunity integer;
begin
if(not exists(select * from czlonkowie_spolecznosci where id_czlonka = user_id and id_spolecznosci = community_id)) then 
raise exception 'Czlonek nie nalezy do tej spolecznosci!';
end if;
if(parent_post_id is not null) then
parentCommunity = (select id_spolecznosci from posty where id_posta = parent_post_id);
if(parentCommunity is null or parentCommunity != community_id) then raise exception 'Post nie nalezy do wskazanej spolecznosci!';
end if;
end if;
insert into posty(id_posta_nad, id_spolecznosci, id_czlonka, data_dodania, tytul, tresc) values
(parent_post_id, community_id, user_id, now(), title, content) returning "id_posta" into retId;
return retId;
end $$ language plpgsql;


create or replace function get_posts(community_id integer ) returns table(id_posta integer,
id_posta_nad integer, id_spolecznosci integer, id_czlonka integer, data_dodania date, tytul varchar(100), tresc varchar(1000) )
as $$
begin

return query select * from posty p where p.id_posta_nad is null and p.id_spolecznosci = community_id order by data_dodania desc; 
end;
$$ language plpgsql;

create or replace function get_user_posts_with_names(user_id integer) 
returns table(id_posta integer, id_posta_nad integer, id_spolecznosci integer, nazwa varchar, id_czlonka integer, data_dodania date, tytul varchar(100), tresc varchar(1000)) as $$
begin
    return query 
    select p.id_posta, p.id_posta_nad, p.id_spolecznosci, sp.nazwa, p.id_czlonka, p.data_dodania, p.tytul, p.tresc 
    from posty p 
    join spolecznosci sp on p.id_spolecznosci = sp.id_spolecznosci 
    where p.id_posta_nad is null 
    and exists (
        select 1 
        from czlonkowie_spolecznosci cs 
        where cs.id_czlonka = user_id 
        and cs.id_spolecznosci = p.id_spolecznosci
    ) 
    order by p.data_dodania desc;
end;
$$ language plpgsql;

create or replace function get_communities_with_names(member_id int) 
returns table(id_spolecznosci integer, nazwa varchar) as $$
begin
    return query 
    select distinct s.id_spolecznosci, sp.nazwa 
    from czlonkowie_spolecznosci s 
    join spolecznosci sp on s.id_spolecznosci = sp.id_spolecznosci 
    where s.id_czlonka = member_id;
end;
$$ language plpgsql;

create or replace function get_replies(parent_post_id integer) returns table(id_posta integer,
id_posta_nad integer, id_spolecznosci integer, id_czlonka integer, data_dodania date, tytul varchar(100), tresc varchar(1000) )
as $$
begin
return query select * from posty p where p.id_posta_nad = parent_post_id;
end;
$$ language plpgsql;

create or replace function register_as_volonteer(member_id integer, edit integer) returns void as $$
declare
edycja boolean default true;
czlonek boolean default true;
begin
if(not exists(select * from czlonkowie where id_czlonka = member_id)) then czlonek = false; end if;
if(not exists(select * from edycje where id_edycji = edit)) then edycja = false; end if;
if(exists(select * from wolontariusze where id_czlonka = member_id and id_edycji = edit)) then
raise exception 'Podany czlonek zarejestrowal sie juz jako wolontariusz w tej edycji'; end if;
if(czlonek = false) then
raise exception 'Wprowadzono nieprawidlowe id czlonka'; end if;
if(edycja = false) then raise exception 'Wprowadzono nieprawidłowy numer edycji'; end if;
insert into wolontariusze values (member_id, edit);
end;
$$ language plpgsql;

create or replace function register_as_speaker(id_czlonka integer, imie varchar(30), nazwisko varchar(150)) returns void as $$
begin
insert into prelegenci(id_czlonka, imie, nazwisko) values (id_czlonka, imie, nazwisko);
end;
$$ language plpgsql;


create or replace view members as select id_czlonka, imie, nazwisko from czlonkowie;

create or replace function get_community_members(community_id int default null) returns table(id int, imie varchar(30), nazwisko varchar(150))
as $$
begin
return query
select c.id_czlonka, c.imie, c.nazwisko from czlonkowie c
where (community_id is null) or (community_id is not null and exists(select * from czlonkowie_spolecznosci cs where
cs.id_czlonka = c.id_czlonka and cs.id_spolecznosci = community_id));
end;
$$ language plpgsql;

create index users on czlonkowie(id_czlonka);
create index posts on posty(id_posta);
create index posts_archive on posty_archiwum(id_posta);
create index users_archive on czlonkowie_archiwum(id_czlonka);
create index talks on prelekcje(id_prelekcji);

create or replace function count_members(community_id int) returns int as $$
declare
result int;
begin
result = (select count(*) from czlonkowie_spolecznosci where id_spolecznosci = community_id);
return result;
end;
$$ language plpgsql;

create or replace function count_posts(community_id int, member_id int) returns int as $$
declare
result int;
begin
result = (select count(*) from posty where id_spolecznosci = community_id and id_czlonka = member_id);
return result;
end;
$$ language plpgsql;

create or replace function get_volonteers(edit_id integer) returns table (id_uzytkownika integer) as $$
begin
return query
select id_czlonka from wolontariusze where id_edycji = edit_id;
end;
$$ language plpgsql;

create or replace function get_communities(member_id int) returns table (id_spolecznosci integer) as $$
begin
return query
select distinct s.id_spolecznosci from czlonkowie_spolecznosci s where s.id_czlonka = member_id;
end; 
$$ language plpgsql;

create or replace function get_editions(member_id int) 
returns table (id_edycji integer, nazwa varchar, data_rozpoczecia date, data_zakonczenia date) as $$
begin
return query
select e.id_edycji, w.nazwa, e.data_rozpoczecia, e.data_zakonczenia 
from czlonkowie_edycje s 
join edycje e on s.id_edycji = e.id_edycji 
join wydarzenia w on e.id_wydarzenia = w.id_wydarzenia 
where s.id_czlonka = member_id;
end; 
$$ language plpgsql;

create or replace function get_participants (edit_id int) returns table (id_uzytkownika integer) as $$
begin
return query 
select id_czlonka from czlonkowie_edycje where id_edycji = edit_id;
end;
$$ language plpgsql;

create or replace function count_participants(edit_id int) returns int as $$
declare 
count int;
begin
count = (select count(*) from get_participants(edit_id));
return count;
end;
$$ language plpgsql;


create or replace function intersects(int1 timestamp, int2 timestamp, len1 interval, len2 interval) returns boolean as $$
begin
    return (int1 + '00:00:01'::interval, int1 + len1 - '00:00:01'::interval) overlaps (int2 + '00:00:01'::interval, int2+len2 - '00:00:01'::interval);
end;
$$ language plpgsql;

create or replace function register_talk(speaker_id integer, edit integer, room integer, talk_date timestamp, talk_length integer, subj varchar(100), descript varchar(1000))
returns void as $$
declare 
talk_id integer;
avaible boolean default true;
len1 interval;
len2 interval;
begin_date date;
end_date date;
k record;
begin
len1 = (select dlugosc from dlugosci where dlugosc_prelekcji = talk_length);
begin_date = (select data_rozpoczecia from edycje where id_edycji = edit);
end_date = (select data_zakonczenia from edycje where id_edycji = edit);
for k in select * from prelekcje loop
    len2 = (select dlugosc from dlugosci where dlugosc_prelekcji = k.dlugosc_prelekcji);
    if(intersects(k.data_prelekcji::timestamp, talk_date::timestamp, len2, len1)) then
        if(k.id_sali = room or exists(select * from prelekcje_prelegenci p where p.id_prelegenta = speaker_id and p.id_prelekcji = k.id_prelekcji)) then
            avaible = false;
        end if;
    end if;
end loop;
if(avaible = false) then
raise exception 'Nie mozna zarejestrowac prelekcji, gdyz inna odbywa sie w tym czasie';
end if;
if(talk_date < begin_date::timestamp or talk_date > end_date::timestamp) then
raise exception 'Nie mozna zarejestrowac prelekcji poza czasem trwania edycji';
end if;
insert into prelekcje(id_edycji, id_sali, data_prelekcji, dlugosc_prelekcji, temat, opis) values
(edit, room, talk_date, talk_length, subj, descript) returning "id_prelekcji" into talk_id;
insert into prelekcje_prelegenci values (speaker_id, talk_id); 

end;
$$ language plpgsql;

create or replace function add_to_talk(speaker_id int, talk_id int) returns void as $$
declare
avaible bool = true;
k record;
begin_date timestamp;
end_date timestamp;
len1 interval;
len2 interval;
begin
begin_date = (select data_prelekcji from prelekcje where id_prelekcji = talk_id);

len1 = (select dlugosc from dlugosci where dlugosc_prelekcji = (select p.dlugosc_prelekcji from prelekcje p where p.id_prelekcji = talk_id));
for k in select * from prelekcje
 loop

    if(exists(select * from prelekcje_prelegenci p where p.id_prelegenta = speaker_id and p.id_prelekcji = k.id_prelekcji)) then
        len2 = (select dlugosc from dlugosci where dlugosc_prelekcji = (select p.dlugosc_prelekcji from prelekcje p where p.id_prelekcji = k.id_prelekcji));
        if((k.data_prelekcji + '00:00:01'::interval, k.data_prelekcji + len1 -  '00:00:01'::interval) overlaps (begin_date + '00:00:01'::interval, begin_date + len2 - '00:00:01'::interval)) then
            avaible = false;
        end if;
    end if;
end loop;

if(avaible = false) then
raise exception 'Dany prelegent prowadzi w tym czasie inna prelekcje!';
end if;
insert into prelekcje_prelegenci values (speaker_id, talk_id); 
end;
$$ language plpgsql;

create or replace function get_timestable(edit_id integer, for_day date) returns table(data_rozpoczecia timestamp, data_zakonczenia timestamp,
temat varchar(100), opis varchar(1000), prowadzacy text[], sala int, wolontariusze text[]) as $$
begin
return query 
    select p.data_prelekcji, 
    p.data_prelekcji + (select d.dlugosc from dlugosci d where d.dlugosc_prelekcji = p.dlugosc_prelekcji), 
    p.temat, p.opis,
     (select array_agg(concat(q.imie, ' ', q.nazwisko)) from prelegenci q where exists(select * 
     from prelekcje_prelegenci r where r.id_prelegenta = q.id_prelegenta and r.id_prelekcji = p.id_prelekcji )), p.id_sali,
     (select array_agg(concat(m.imie, ' ', m.nazwisko)) from czlonkowie m where exists(
        select * from wolontariusze_prelekcje w where w.id_czlonka = m.id_czlonka and w.id_prelekcji = p.id_prelekcji
     ))
     from prelekcje p
    where p.id_edycji = edit_id and p.data_prelekcji::date = for_day and
    exists(select * from prelegenci q where exists(select * 
     from prelekcje_prelegenci r where r.id_prelegenta = q.id_prelegenta and r.id_prelekcji = p.id_prelekcji ))
     order by p.data_prelekcji, p.id_sali;
end;
$$ language plpgsql;

create or replace function generate_attendee_badges(edit_id int) returns table(imie varchar(30), nazwisko varchar(150), tekst varchar) as $$
declare 
begin
    return query
    select c.imie, c.nazwisko, 'uczestnik'::varchar
    from czlonkowie c right join czlonkowie_edycje ce on c.id_czlonka = ce.id_czlonka where ce.id_edycji = edit_id;
end;
$$ language plpgsql;



create or replace function generate_volonteer_badges(edit_id int) returns table(imie varchar(30), nazwisko varchar(150), tekst varchar) as $$
declare 
begin
    return query
    select c.imie, c.nazwisko, 'wolontariusz'::varchar
    from czlonkowie c right join wolontariusze ce on c.id_czlonka = ce.id_czlonka where ce.id_edycji = edit_id;
end;
$$ language plpgsql;

create or replace function generate_organiser_badges(edit_id int) returns table(imie varchar(30), nazwisko varchar(150), tekst varchar) as $$
declare 
begin
    return query
    select c.imie, c.nazwisko, 'organizator'::varchar
    from czlonkowie c right join organizatorzy ce on c.id_czlonka = ce.id_czlonka where ce.id_edycji = edit_id;
end;
$$ language plpgsql;


create or replace function generate_speaker_badges(edit_id int) returns table(imie varchar(30), nazwisko varchar(150), tekst varchar) as $$
begin
    return query
    select s.imie, s.nazwisko, 'prelegent'::varchar
    from prelegenci s join prelekcje p on (exists(select * from prelekcje_prelegenci r 
    where r.id_prelekcji = p.id_prelekcji and r.id_prelegenta = s.id_prelegenta)) where p.id_edycji = edit_id group by s.id_prelegenta;
    end;
$$ language plpgsql;


create or replace view full_edition_statistics as 
select e.id_edycji as "id edycji", (select w.nazwa from wydarzenia w where w.id_wydarzenia = e.id_wydarzenia) as "wydarzenie", e.nr_edycji as "numer edycji",
(select count(*) from generate_attendee_badges(e.id_edycji)) as "liczba uczestników", (select count(*) from generate_organiser_badges(e.id_edycji)) as "liczba organizatorów", 
(select count(*) from generate_speaker_badges(e.id_edycji)) as "liczba prelegentów", (select count(*) from generate_volonteer_badges(e.id_edycji)) as "liczba wolontariuszy", 
(select count(*) from prelekcje p where p.id_edycji = e.id_edycji) as "ilość prelekcji", (select count(*) from edycje_sale r where r.id_edycji = e.id_edycji) as "ilość sal"
from edycje e;

create or replace view full_communities_statistics as
select s.id_spolecznosci as "id społeczności", s.nazwa as "nazwa", (select count(distinct c.id_czlonka) from czlonkowie_spolecznosci c where c.id_spolecznosci = s.id_spolecznosci) as "ilość członków",
(select count(*) from wydarzenia_spolecznosci m where m.id_spolecznosci = s.id_spolecznosci) as "ilość współorganizowanych wydarzeń",
(select count(*) from posty where id_spolecznosci = s.id_spolecznosci) as "ilość postów", (select count(*) from posty where id_spolecznosci = s.id_spolecznosci
and id_posta_nad is null) as "ilość wątków"
from spolecznosci s;

create or replace function register_trigger() returns trigger as $$
begin
    select register(NEW.nazwa_uzytkownika, NEW.email, NEW.imie, NEW.nazwisko, 'password', NEW.id_zamika, NEW.newsletter);
    return old;
end;
$$ language plpgsql;

create or replace function post_trigger() returns trigger as $$
begin
    select make_post(NEW.id_posta_nad, NEW.id_spolecznosci, NEW.id_czlonka, NEW.tytul, NEW.tresc);
    return old;
end;
$$ language plpgsql;

create or replace function volo_trigger() returns trigger as $$
begin
    select register_as_volonteer(NEW.id_czlonka, NEW.id_edycji);
    return old;
end;
$$ language plpgsql;


create or replace function archive() returns void as $$
declare 
user_to_archive record;
post_to_archive record;
last_post date;
begin
for post_to_archive in select * from posty loop
    if(post_to_archive.data_dodania + '1 year'::interval < NOW()) then
        update posty p set id_posta_nad = post_to_archive.id_posta_nad where p.id_posta_nad = post_to_archive.id_posta;
        update posty p set id_posta_nad = null where p.id_posta_nad = post_to_archive.id_posta;

        insert into posty_archiwum values (post_to_archive.id_posta, post_to_archive.id_posta_nad,
        post_to_archive.id_spolecznosci, post_to_archive.id_czlonka, post_to_archive.data_dodania, 
        post_to_archive.tytul, post_to_archive.tresc);
        delete from posty p where p.id_posta = post_to_archive.id_posta;
    end if;
end loop;
for user_to_archive in select * from czlonkowie loop
    last_post = null;
    if(user_to_archive.data_dolaczenia + '1 year'::interval < NOW()) then 
        last_post = (select max(data_dodania) from posty where id_czlonka = user_to_archive.id_czlonka);
        if(last_post is null) then 
            delete from czlonkowie where id_czlonka = user_to_archive.id_czlonka;
        end if;
    end if;

end loop;
end;
$$ language plpgsql;

create or replace function prelegent_trigger() returns trigger as $$

begin
if(new.id_czlonka is not null) then 
new.imie = (select s.imie from czlonkowie s where s.id_czlonka = new.id_czlonka);
new.nazwisko = (select s.nazwisko from czlonkowie s where s.id_czlonka = new.id_czlonka);
end if;

return new;
end;
$$ language plpgsql;

create or replace function czlonkowie_trigger() returns trigger as $$
declare
k record;
begin
for k in (select * from prelegenci where id_czlonka = new.id_czlonka) loop
    update prelegenci p set id_czlonka = k.id_czlonka where p.id_czlonka = k.id_czlonka;
end loop;
return new;
end;
$$ language plpgsql;

create or replace function ce_trigger() returns trigger as $$
begin
if(
    exists(select * from czlonkowie_spolecznosci cs where cs.id_czlonka = NEW.id_czlonka 
and exists(select * from wydarzenia_spolecznosci ce
where ce.id_wydarzenia = (select e.id_wydarzenia from edycje e where e.id_edycji = NEW.id_edycji) and ce.id_spolecznosci = cs.id_spolecznosci))) then
return NEW;
end if;
return OLD;
end;
$$ language plpgsql;

create or replace function wp_trigger() returns trigger as $$
begin
if(exists(select * from wolontariusze where id_czlonka = NEW.id_czlonka and id_edycji = (select p.id_edycji from prelekcje p
where p.id_prelekcji = NEW.id_prelekcji))) then
return NEW;
end if;
return OLD;
end;
$$ language plpgsql;

create or replace function wolontariusze_trigger() returns trigger as $$
begin
if(exists(select * from czlonkowie_edycje where id_czlonka = NEW.id_czlonka and id_edycji = NEW.id_edycji)) then
return NEW;
end if;
return OLD;
end;
$$ language plpgsql;

create or replace function wolontariusze_delete_trigger() returns trigger as $$
declare 
k record;
begin
for k in (select * from prelekcje where id_edycji = OLD.id_edycji) loop
    delete from wolontariusze_prelekcje where id_czlonka = OLD.id_czlonka and id_prelekcji = k.id_prelekcji;
end loop;
return OLD;
end;
$$ language plpgsql;

create or replace function ce_delete_trigger() returns trigger as $$
begin
    delete from wolontariusze where id_czlonka = OLD.id_czlonka and id_edycji = OLD.id_edycji;
    return OLD;
end;
$$ language plpgsql;

create or replace function prelekcja_delete_trigger() returns trigger as $$
begin
    delete from prelekcje_prelegenci where id_prelekcji = OLD.id_prelekcji;
    return OLD;
end;
$$ language plpgsql;

create or replace function prelegent_delete_trigger() returns trigger as $$
begin
    delete from prelekcje_prelgenci where id_prelegenta = OLD.id_prelegenta;
    return OLD;
end;
$$ language plpgsql;

create or replace function czlonkowie_delete_trigger() returns trigger as $$
begin

if(OLD.id_czlonka = 1000420) then
return NEW;
end if;

update posty p set id_czlonka = 1000420 where id_czlonka = OLD.id_czlonka;

delete from czlonkowie_edycje where id_czlonka = OLD.id_czlonka;
delete from czlonkowie_spolecznosci where id_czlonka = OLD.id_czlonka;
delete from wolontariusze where id_czlonka = OLD.id_czlonka;
delete from organizatorzy where id_czlonka = OLD.id_czlonka;
update prelegenci p set id_czlonka = null where p.id_czlonka = OLD.id_czlonka;
insert into czlonkowie_archiwum values (OLD.id_czlonka, OLD.id_zaimka, OLD.nazwa_uzytkownika,
OLD.email, OLD.imie, OLD.nazwisko, OLD.newsletter, OLD.data_dolaczenia);
return OLD;
end;
$$ language plpgsql;

create trigger czlonkowie_check after update on czlonkowie for each row execute procedure czlonkowie_trigger();
create trigger prelegenci_check before insert or update on prelegenci for each row execute procedure prelegent_trigger();
create trigger czlonkowie_edycje_check before insert or update on czlonkowie_edycje for each row execute procedure ce_trigger();
create trigger wp_check before insert or update on wolontariusze_prelekcje for each row execute procedure wp_trigger();
create trigger wolontariusze_check before insert or update on wolontariusze for each row execute procedure wolontariusze_trigger();
create trigger ce_delete_check before delete on czlonkowie_edycje for each row execute procedure ce_delete_trigger();
create trigger wolo_delete_check before delete on wolontariusze for each row execute procedure wolontariusze_delete_trigger();
create trigger czlonkowie_trigger before delete on czlonkowie for each row execute procedure czlonkowie_delete_trigger();
create trigger prelegent_trigger before delete on prelegenci for each row execute procedure prelegent_delete_trigger();
create trigger prelekcja_trigger before delete on prelekcje for each row execute procedure prelekcja_delete_trigger();
INSERT INTO zaimki (id_zaimka, nazwa) VALUES 
(1, 'ona/jej'),
(2, 'on/jego'),
(3, 'ono/jego'),
(4, 'ono/jej'),
(5, 'ono/jejgo'),
(6, 'ono/jeno'),
(7, 'ono/jenu'),
(8, 'ono/ich');

INSERT INTO czlonkowie (id_zaimka, nazwa_uzytkownika, email, imie, nazwisko, newsletter, data_dolaczenia) VALUES 
(4, 'lnhqpivgjn', 'Grzegorz.Wiencek@mail.com','Grzegorz','Wiencek', '1', '2023-12-06'),
(2, 'dgiqoeaxaw', 'Szymon.Irzyk@mail.com','Szymon','Irzyk', '1', '2023-12-08'),
(4, 'pmnmrcgalc', 'Tomasz.Dub@mail.com','Tomasz','Dub', '1', '2024-03-01'),
(2, 'szfusboseh', 'Julian.Posłuszny@mail.com','Julian','Posłuszny', '0', '2023-01-25'),
(2, 'okjeoboyxn', 'Aniela.Mieszała@mail.com','Aniela','Mieszała', '1', '2023-11-17'),
(4, 'iatalizahq', 'Justyna.Woronko@mail.com','Justyna','Woronko', '1', '2024-01-22'),
(1, 'gqqfpuaktg', 'Eliza.Szumacher@mail.com','Eliza','Szumacher', '0', '2022-09-16'),
(3, 'wmqchahcxd', 'Damian.Juszczuk@mail.com','Damian','Juszczuk', '0', '2022-02-28'),
(2, 'pgfryiqeum', 'Franciszek.Rup@mail.com','Franciszek','Rup', '1', '2024-03-30'),
(3, 'ubhxhznzuy', 'Jeremi.Kołodziejak@mail.com','Jeremi','Kołodziejak', '1', '2023-08-23'),
(3, 'bvskftvwue', 'Arkadiusz.Chmara@mail.com','Arkadiusz','Chmara', '0', '2022-05-24'),
(4, 'scxnjvmnip', 'Tadeusz.Korzonek@mail.com','Tadeusz','Korzonek', '0', '2022-07-03'),
(3, 'wbokevtpqg', 'Kornelia.Golus@mail.com','Kornelia','Golus', '0', '2022-09-25'),
(4, 'iayugcraic', 'Jacek.Waszczyk@mail.com','Jacek','Waszczyk', '1', '2023-10-31'),
(2, 'exgglhtgjh', 'Bartek.Duży@mail.com','Bartek','Duży', '0', '2022-10-18'),
(3, 'pdmzyqslym', 'Julita.Pacholik@mail.com','Julita','Pacholik', '0', '2023-05-20'),
(1, 'swdmkrdalq', 'Malwina.Supeł@mail.com','Malwina','Supeł', '0', '2023-07-26'),
(2, 'guujphrmug', 'Tobiasz.Michalkiewicz@mail.com','Tobiasz','Michalkiewicz', '1', '2024-03-18'),
(2, 'iudfoyqvoz', 'Kamila.Olchawa@mail.com','Kamila','Olchawa', '1', '2022-08-03'),
(3, 'zjtdtbprzo', 'Filip.Banek@mail.com','Filip','Banek', '0', '2022-04-06'),
(1, 'ipqfuawpys', 'Kazimierz.Walo@mail.com','Kazimierz','Walo', '1', '2022-10-13'),
(2, 'vkirihsxnl', 'Sonia.Pacholczak@mail.com','Sonia','Pacholczak', '1', '2024-04-08'),
(2, 'grerjnzgpl', 'Kajetan.Juroszek@mail.com','Kajetan','Juroszek', '1', '2022-10-10'),
(1, 'kjhsnaoaal', 'Natasza.Owsianka@mail.com','Natasza','Owsianka', '1', '2022-04-01'),
(2, 'nemxzqivsq', 'Tola.Jachna@mail.com','Tola','Jachna', '1', '2022-09-11'),
(1, 'lnwzwnlcza', 'Albert.Wośko@mail.com','Albert','Wośko', '0', '2023-11-09'),
(1, 'grexueptjo', 'Daniel.Cyman@mail.com','Daniel','Cyman', '0', '2023-05-18'),
(4, 'lbjtchngyn', 'Maurycy.Walencik@mail.com','Maurycy','Walencik', '1', '2023-08-08'),
(1, 'yadisukhir', 'Kornel.Szczubełek@mail.com','Kornel','Szczubełek', '1', '2022-06-23'),
(1, 'xjnzbdccla', 'Mariusz.Stupak@mail.com','Mariusz','Stupak', '1', '2022-02-12'),
(1, 'leitglnrpi', 'Norbert.Żelasko@mail.com','Norbert','Żelasko', '1', '2023-09-30'),
(2, 'upktomptxz', 'Bruno.Wawrzyczek@mail.com','Bruno','Wawrzyczek', '0', '2022-07-01'),
(4, 'ysnquobgfq', 'Józef.Waluk@mail.com','Józef','Waluk', '1', '2023-05-04'),
(4, 'hbncyqxfgt', 'Eliza.Jagieło@mail.com','Eliza','Jagieło', '1', '2022-03-09'),
(3, 'dsejloccel', 'Stefan.Holc@mail.com','Stefan','Holc', '0', '2022-08-22'),
(4, 'uhxnittgtg', 'Julian.Bluszcz@mail.com','Julian','Bluszcz', '1', '2023-06-30'),
(1, 'eebhilhikk', 'Marek.Pacholik@mail.com','Marek','Pacholik', '1', '2023-03-11'),
(3, 'bjxfwqoxub', 'Apolonia.Kościuszko@mail.com','Apolonia','Kościuszko', '0', '2023-09-21'),
(1, 'blztznqntf', 'Krystyna.Sierota@mail.com','Krystyna','Sierota', '1', '2022-05-27'),
(2, 'cwtwopipqb', 'Daniel.Dybał@mail.com','Daniel','Dybał', '0', '2023-09-30'),
(2, 'xqtvwvltrv', 'Szymon.Miąsko@mail.com','Szymon','Miąsko', '1', '2022-03-24'),
(2, 'vqnxrzyjaz', 'Filip.Klemczak@mail.com','Filip','Klemczak', '0', '2022-05-22'),
(2, 'rmfxerlnkk', 'Błażej.Materek@mail.com','Błażej','Materek', '0', '2022-09-22'),
(1, 'ybtyporcym', 'Ryszard.Sularz@mail.com','Ryszard','Sularz', '1', '2023-10-14'),
(3, 'bvuuwxmaqn', 'Gustaw.Kacperczyk@mail.com','Gustaw','Kacperczyk', '1', '2022-09-28'),
(2, 'xbzlyjmhqd', 'Hubert.Jakiel@mail.com','Hubert','Jakiel', '1', '2023-04-06'),
(2, 'hdvknlqbtl', 'Dagmara.Nagórka@mail.com','Dagmara','Nagórka', '0', '2023-01-31'),
(3, 'mdirhttbmv', 'Igor.Borysiewicz@mail.com','Igor','Borysiewicz', '0', '2022-03-17'),
(2, 'cdozotuovk', 'Dawid.Miara@mail.com','Dawid','Miara', '0', '2023-03-16'),
(4, 'thfavuzxym', 'Dawid.Kolka@mail.com','Dawid','Kolka', '1', '2022-07-11');

INSERT INTO czlonkowie (id_zaimka, nazwa_uzytkownika, email, imie, nazwisko, newsletter, data_dolaczenia, haslo_hash) VALUES 
(null, 'admin1', 'admin1@mail.com', 'Gall', 'Anonim', '0', '2024-06-07', 'scrypt:32768:8:1$oIC4qvovUEGqNJY8$6b677839bff548cab9f764cf51bf8420271d83a26e75e26031b7b3749806397df2ca1a47c7e6d38b1a6621ae8c0ac50044806f89a2a91310bafc349657b8ded5');
INSERT INTO czlonkowie values
(1000420, 2, 'Deleted', 'Deleted', 'Deleted', 'Deleted', '0', '1999-01-01');
INSERT INTO spolecznosci(id_spolecznosci, nazwa) VALUES
(1, 'Społeczność Matematyków'),
(2, 'Społeczność Programistów'),
(3, 'Kącik Szydełkowania');

INSERT INTO posty (id_spolecznosci, id_czlonka, data_dodania, tytul, tresc) VALUES
(3, 21, '2024-04-27', 'Minima ipsam unde beatae.', 'Consequuntur et temporibus. Fugiat mollitia quo doloremque non nobis. Doloremque. Nisi enim modi animi dolorem. Ipsum voluptatum quo beatae deserunt.'),
(2, 38, '2024-04-21', 'Sapiente autem saepe aliquid.', 'Odio et. Id. Ut doloremque numquam dicta omnis eos. Enim. Ex. Aut. Eos molestias quisquam quam quasi. Quas. Dolorem placeat accusamus et dolor qui.'),
(3, 40, '2024-04-24', 'Ab deleniti placeat amet.', 'Voluptas eum aliquid quia itaque quia. Quasi. Aut dolore. Rerum maxime aut. Vel inventore similique enim ut. Ipsa autem velit mollitia.'),
(3, 45, '2024-04-27', 'Ut ea voluptatem vel necessitatibus.', 'Aperiam. Temporibus consequatur ut modi. Eos. Esse ut laboriosam accusantium nihil. Aspernatur velit qui. Est consequuntur.'),
(2, 41, '2024-04-24', 'Voluptatibus pariatur.', 'Qui. Dolor quisquam aut itaque qui. At. Sed repellendus sunt ad. Nulla vitae dolor suscipit. Sint. Quo animi nobis qui quo rem. Quia alias maiores. Autem consequatur.'),
(2, 29, '2024-04-26', 'Et velit molestias ipsum.', 'Est. Ut. Blanditiis dolor libero ipsum. Animi consequatur minus sapiente quidem perspiciatis. Fuga rem labore. Necessitatibus veritatis eum voluptas culpa facilis.'),
(1, 19, '2024-04-22', 'Aut quam porro et ad laborum.', 'Illum vel et nam et. Sed. Molestiae expedita ut officiis necessitatibus soluta. Est iste voluptatem. Libero consequatur.'),
(3, 27, '2024-04-26', 'Quidem voluptate ratione.', 'Excepturi quisquam suscipit. Rerum vel doloribus illo laudantium. Ut vel in ex ut ipsa. Rerum dolorem et voluptatem. Ut quos fuga blanditiis sit aut.'),
(1, 17, '2024-04-28', 'Ducimus recusandae exercitationem.', 'Consequatur quibusdam harum debitis dolor. Totam et distinctio voluptatem sint qui. Rerum dolores. Illum vitae explicabo at. Neque dolores quam.'),
(3, 43, '2024-04-23', 'Consectetur ut numquam.', 'Ex. Tempore fugiat est expedita omnis. Ex. Vitae dolores eos non deserunt nulla. Dolor eligendi. Veniam praesentium sit dolor aut. In sapiente illum ut quis labore. Et qui magni.'),
(2, 18, '2024-04-26', 'Ipsa ut et fuga accusamus.', 'Vero. Enim. Qui et consectetur enim tempore. Aut. Et rem tempore et. Ipsa. Ipsam eum aut nostrum dolores. Blanditiis doloribus necessitatibus sint et.'),
(1, 20, '2024-04-23', 'Eaque distinctio ex pariatur.', 'Et qui unde fuga ullam. Quia doloribus velit consequatur sint sunt. Quia esse. Ut provident delectus commodi qui est. Nesciunt.'),
(2, 11, '2024-04-22', 'Necessitatibus dolores.', 'Iusto unde. Similique. Saepe cupiditate omnis quia aut. Omnis. Et quia omnis eum unde. Soluta sed modi. Et quis quas autem ipsa. Quia consequatur doloribus.'),
(2, 18, '2024-04-21', 'Eos itaque ratione laboriosam.', 'Ut maxime. Optio consequuntur magnam occaecati ea. Ut iste ab. Officia qui sed vero. Molestias. Nostrum iste id qui. Optio facere blanditiis quidem illum. Consequatur reprehenderit.'),
(1, 42, '2024-04-27', 'Ea aut ipsa velit non expedita.', 'Inventore maiores quisquam et est. Impedit. Est quia quasi laudantium. Accusantium. Eius dolor cumque ratione error. Magni architecto non in. Laudantium ratione aperiam quos sint est.'),
(3, 25, '2024-04-26', 'Tempora ipsa labore est.', 'Sequi temporibus aliquid voluptatem distinctio. In est accusantium aut aut tempore. Laudantium voluptas.'),
(1, 42, '2024-04-25', 'Delectus harum doloribus.', 'Atque. Enim vero officia nam error. Perferendis quo corrupti facilis. Est quaerat. Deleniti. Animi accusamus beatae.'),
(1, 33, '2024-04-27', 'Nisi voluptatibus architecto.', 'Labore voluptatem. Blanditiis quia voluptatem fugit. Necessitatibus. Rem omnis velit. Est. Nulla quasi commodi.'),
(1, 28, '2024-04-22', 'Minus earum tempore eos.', 'Blanditiis quo nobis necessitatibus est voluptas. Et quaerat. Dolorem. Esse cupiditate non est id. Sed.'),
(2, 6, '2024-04-22', 'Dignissimos molestias.', 'Dolorum. Est laboriosam aperiam. Eum praesentium eius aut. Voluptatem aut. Nihil. Unde et. Vitae rerum. Velit veniam illo. Vero quae omnis.'),
(2, 6, '2024-04-25', 'Tempore voluptas nam neque.', 'Iusto hic illum nisi ut omnis. Et earum rem. Asperiores totam aliquid. Sed et. Ex. Odit voluptatem vel in id aut.'),
(3, 48, '2024-04-23', 'Qui est et quod qui ut placeat.', 'Quia iure. Occaecati voluptates labore. Excepturi. Sit consequatur cum sed sit. Tenetur. Aliquid molestiae qui nihil vel earum. Sunt ut ipsa eligendi culpa.'),
(2, 13, '2024-04-25', 'Dolorem architecto dolores.', 'Quo consectetur. Minima labore. Recusandae qui eum. Quidem et voluptatum natus. Ab odio. Harum quasi a cupiditate aspernatur explicabo. Molestiae unde libero neque.'),
(3, 35, '2024-04-28', 'Qui porro rem nemo enim voluptatem.', 'Quae perferendis distinctio corporis error. Non. In. Odio. Consequatur labore hic voluptates molestias nemo.'),
(1, 2, '2024-04-28', 'Excepturi rerum voluptatem.', 'Modi numquam. Nulla quis voluptate id. Cupiditate tempora hic reiciendis et. Tempore iure labore laudantium. Voluptas unde repudiandae voluptates fugit.'),
(1, 30, '2024-04-27', 'Maxime eaque repellendus.', 'Et voluptas repudiandae cum animi et. Laborum exercitationem placeat officia. Error labore et quas. Quia quos.'),
(3, 35, '2024-04-28', 'Ipsa ea voluptatem saepe.', 'Tenetur. In sed ipsum dolores sed veritatis. Eius et iusto aut esse. Voluptatum quidem quia. Voluptate. Saepe alias.'),
(1, 19, '2024-04-21', 'Perspiciatis enim quod.', 'Atque qui. Vel quia quod eum reprehenderit. Perspiciatis quaerat dolorem iure neque quas. Sint quam fugiat. Ducimus quia voluptatibus at quia.'),
(2, 50, '2024-04-25', 'Dolores tempora harum nihil.', 'Fugiat. Aut quaerat nostrum et totam. Eligendi tempora eaque qui maxime. Perspiciatis qui similique. Dignissimos.'),
(3, 47, '2024-04-25', 'Numquam eum fugit incidunt.', 'Recusandae sed. At excepturi. Quod ea fuga qui architecto laborum. Aliquam minima odio. Beatae alias animi qui sed vero.'),
(1, 2, '2024-04-24', 'Consequatur ipsam ut quia.', 'Sunt et. Placeat similique omnis incidunt. Sit omnis vel ut magni. Possimus ullam tempora minima ipsam.'),
(3, 25, '2024-04-24', 'Assumenda et accusantium.', 'Est est ipsa. Dignissimos sed. Perspiciatis sed. Quaerat et. Sunt quod accusamus velit. Maiores. Qui sint unde.'),
(2, 26, '2024-04-22', 'Officiis voluptas rem vitae.', 'Tenetur omnis architecto ab quia maxime. Atque accusamus expedita. Et similique tempora repudiandae totam et.'),
(2, 41, '2024-04-23', 'Earum autem repellat nesciunt.', 'Velit perspiciatis harum id est. Magni in vel eius veritatis. Eos accusamus aliquam natus omnis. Omnis nihil. Sed vero aperiam fugiat.'),
(2, 31, '2024-04-21', 'Itaque sed optio debitis.', 'Ut deserunt assumenda. Consequuntur aut minima soluta omnis quo. Id a libero id neque. Illum modi. Saepe sequi. Consectetur consequatur ut debitis vel.'),
(3, 36, '2024-04-26', 'Eos occaecati quas est reprehenderit.', 'Vitae aut blanditiis sit voluptatibus. Voluptatem. Harum possimus optio et non. Magni tempore et esse et assumenda. Dolores rerum libero et.'),
(1, 42, '2024-04-25', 'Nobis error et qui rem enim.', 'At dolore nihil totam. Nisi quisquam ullam. Et ipsam ex iste sint quisquam. Dolorem illo. Sunt et rerum et.'),
(2, 13, '2024-04-28', 'Dolorum optio in repudiandae.', 'Ut deserunt unde voluptatum quia veniam. Repudiandae. Autem sit quia rem suscipit harum. Quaerat dolore veritatis enim et.'),
(2, 31, '2024-04-27', 'Deserunt quas sed doloremque.', 'Iure quo commodi. Sed. Molestias dolorem. Consectetur doloribus. Molestiae consequatur nihil dignissimos. Hic et dicta quos.'),
(2, 7, '2024-04-22', 'Dolorem sed illo voluptates.', 'Quas quia quae quia vel. Sed molestiae sunt nisi praesentium sit. Illum voluptatem ex. Id et enim. Et consequatur exercitationem error nihil odio. Eum animi cumque praesentium.'),
(3, 39, '2024-04-27', 'Expedita quis sapiente.', 'Dolores adipisci. Eum sit iure voluptatem. Aut laboriosam asperiores nihil eligendi pariatur. Repellendus earum. Quod itaque enim nisi hic est.'),
(3, 25, '2024-04-23', 'Repudiandae aut eum dolores.', 'Tempora nesciunt. Sit illum. Nihil deserunt quibusdam et. Qui aut aut nesciunt beatae. Architecto saepe quisquam eveniet est.'),
(1, 17, '2024-04-27', 'Autem voluptas veniam amet.', 'Sunt quia vitae. Quidem unde perferendis eveniet qui. Veniam alias qui enim animi. Asperiores repellat nobis. Voluptate.'),
(3, 34, '2024-04-28', 'Doloremque magni illo sit.', 'Repudiandae odio neque in enim consectetur. Commodi. Ducimus quis et accusamus tenetur tempore. Voluptas omnis quisquam neque voluptas molestias. Optio ipsam eos eos eaque quos.'),
(1, 17, '2024-04-22', 'Dolores doloremque itaque.', 'Inventore vel soluta delectus voluptatem labore. Officia iure vel nobis. Mollitia voluptatem sed rerum occaecati cupiditate.'),
(2, 41, '2024-04-28', 'Quas voluptatem sequi deserunt.', 'Et eum ipsa ea quo. Sit qui eos praesentium. Porro amet asperiores. Quos et aliquid placeat. Velit. Placeat pariatur.'),
(3, 45, '2024-04-27', 'Alias nobis quae voluptas.', 'Delectus quisquam aperiam sunt quia quis. Corrupti et quia pariatur accusantium inventore. Voluptatem qui rem harum.'),
(3, 39, '2024-04-24', 'Repellendus eaque dicta.', 'Mollitia earum deserunt maxime. Sunt quidem numquam et vel. Tempore. Voluptatem quia enim totam. Provident aut adipisci. Quas voluptas recusandae voluptatem ab.'),
(1, 10, '2024-04-22', 'Ut nihil quas qui sunt et.', 'Sint eius. Possimus commodi maxime dolor. Dolor. Quia ut facilis. Perspiciatis suscipit velit consequatur vero.'),
(1, 16, '2024-04-28', 'Esse in reiciendis nihil.', 'Pariatur odit ut. Nihil consequuntur. Quaerat. Aut voluptatem optio. Optio. Dolores. Expedita voluptas distinctio.'),
(2, 1, '2024-04-27', 'Eum qui tempore fugit sit.', 'Numquam dolores fugit delectus autem. Blanditiis quia. Quia. Rerum impedit similique veniam est. Doloremque quod.'),
(3, 48, '2024-04-28', 'Ipsum impedit nemo expedita.', 'Repellendus fugit nisi. Inventore illum. Omnis. Ut sed blanditiis dolor. Laborum. Dolorem. Consequatur quas nesciunt numquam similique.'),
(2, 3, '2024-04-27', 'Qui voluptatem eum totam.', 'Id perspiciatis. Impedit ipsum qui est qui similique. Ut debitis nobis. Expedita. Non. Et qui quae. Et sequi at.'),
(1, 49, '2024-04-28', 'Repellendus nemo odit adipisci.', 'Provident. Quae id magni sequi autem. Quis eos neque sit. Nemo. Voluptatem ut. Illo id reprehenderit. Et inventore iste repudiandae deserunt consectetur.'),
(2, 23, '2024-04-21', 'Expedita qui placeat deserunt.', 'Laboriosam. Ut dicta perferendis aut. Et. Dicta sint. Qui ratione quibusdam qui molestiae quibusdam. In.'),
(3, 27, '2024-04-25', 'Nobis omnis dicta quam molestiae.', 'Sed aut. Quaerat qui. Esse maiores vero. Quo aliquid et explicabo. Dignissimos est ut qui ipsa voluptatibus. Maxime facere labore nostrum neque ducimus.'),
(2, 13, '2024-04-24', 'Commodi est inventore aspernatur.', 'Quis nostrum magnam vitae libero. Voluptatem. Blanditiis inventore quidem. Itaque dicta non placeat dicta facere.'),
(1, 33, '2024-04-24', 'Et rerum doloribus ab fugiat.', 'Et. Quisquam. Ducimus quasi. Repellendus. Aut et voluptatem excepturi voluptatem. Impedit animi. Minima et hic quo repellat expedita. Et reprehenderit quasi soluta. Tempora vitae ullam molestiae autem occaecati.'),
(2, 18, '2024-04-22', 'Dolor fugit doloribus et.', 'Vel non consequatur delectus distinctio. Inventore quis quaerat fugit consequatur voluptatum. Eveniet eaque eum. Vitae veritatis. Recusandae aut veniam beatae modi aspernatur.'),
(1, 10, '2024-04-22', 'Quas quia itaque veritatis.', 'Laboriosam. Ut. Autem illo assumenda. Modi ut aut velit facilis vel. Eos voluptatibus. Vel doloremque.'),
(2, 50, '2024-04-28', 'Velit dolorem possimus.', 'Eaque. Necessitatibus. Inventore. Excepturi eos sunt aut. Voluptatum dolores consequatur atque nemo rerum.'),
(2, 18, '2024-04-21', 'Repellat architecto voluptatibus.', 'Itaque est quo reiciendis suscipit ipsum. Autem sequi laborum blanditiis. Ad officiis aliquid. Sit ut suscipit sit sed quaerat. Qui nesciunt similique assumenda id.'),
(3, 34, '2024-04-28', 'Ipsa in at sint et rerum ea.', 'Deleniti amet aliquam quaerat sit fuga. Similique nesciunt rerum. Rerum corrupti pariatur. Deserunt provident laborum ab deleniti.'),
(2, 7, '2024-04-24', 'Quibusdam aut cupiditate.', 'Non libero. Voluptates tempora. Facere sed maxime sunt tempora recusandae. Voluptate quasi et commodi iusto.'),
(2, 1, '2024-04-25', 'Enim architecto ut id dolorem.', 'Omnis ut sunt nobis iusto labore. Deleniti. Unde unde sit sit. Molestiae non. Ut culpa temporibus debitis omnis.'),
(3, 39, '2024-04-24', 'Facere voluptas atque omnis.', 'Laboriosam quidem vero. Qui quis non eveniet officiis. Aut repellendus. Dicta cumque saepe officiis. Ipsam nihil nesciunt sed sed. Sint aperiam.'),
(1, 30, '2024-04-24', 'Quod temporibus amet magnam.', 'Nihil et. Est. Et sint. Sapiente recusandae. Illum officiis labore. Dolorem. Aut nostrum occaecati. Ut rerum veniam. Nisi iure et nisi.'),
(3, 47, '2024-04-27', 'Consequatur itaque non.', 'Dolorem voluptas. Iure facilis. Libero voluptatem dolorum ex dicta rem. Excepturi quam voluptas. Non quo qui eos eveniet. Nihil corrupti accusamus qui.'),
(3, 4, '2024-04-24', 'Possimus ut quidem autem.', 'Voluptatibus. Officia debitis libero ut. Cupiditate ut ad rerum reprehenderit. Eum in consequatur omnis repudiandae et. Iste maxime minima optio error ut. Adipisci provident voluptatum.'),
(2, 18, '2024-04-23', 'Qui ab aut laudantium ut.', 'Sequi necessitatibus vitae magni. Itaque magni nihil. Nemo atque reiciendis. Nulla est et. Adipisci. Nobis dignissimos nostrum nobis.'),
(3, 47, '2024-04-23', 'Corrupti dolorem sit quis.', 'Eligendi consequatur eveniet quidem. Nisi voluptatem saepe omnis. Quibusdam ipsum autem veritatis repudiandae natus. Dolorem. Voluptatum.'),
(2, 11, '2024-04-28', 'Necessitatibus quia minus.', 'Omnis dolores sed. Dolores aut qui blanditiis tempore. Cum enim. Autem repellendus dolorem non quam quos. Ea facere.'),
(3, 39, '2024-04-22', 'Molestiae consequatur.', 'Est. Earum. Et. Dolorum architecto minus tempore eveniet est. Totam est ratione. Et et. Quos corporis occaecati asperiores. Sit. Dolorem in qui.'),
(3, 34, '2024-04-25', 'Deleniti laborum velit.', 'Reiciendis ut ab minima. Voluptates nesciunt non. Necessitatibus illo minima officiis. Quam officia sit et. Quasi suscipit rerum cum repudiandae quis.'),
(3, 36, '2024-04-22', 'Iste culpa debitis est dolorum.', 'Inventore. Consequatur ut officia sequi perspiciatis vel. Non. Perspiciatis et molestiae atque consequuntur.'),
(1, 8, '2024-04-21', 'Totam quo blanditiis illum.', 'Asperiores quis veniam est. Ut totam distinctio qui sed. Qui nihil veniam eos. Necessitatibus minus debitis est. Omnis laborum quia voluptates molestias fugit.'),
(3, 34, '2024-04-28', 'Totam quasi quia est quos.', 'Sit assumenda ipsa qui mollitia. Voluptatem laudantium. Maxime facere. Deleniti. Voluptas nisi ea atque nesciunt.'),
(2, 5, '2024-04-22', 'Doloribus deleniti earum.', 'Debitis. Nam ut eum. Ut laboriosam maxime id quos. Voluptatem impedit commodi. Aliquid consequuntur quis dicta pariatur. Omnis velit totam est aut. In optio praesentium qui.'),
(3, 43, '2024-04-27', 'Illum est odio ratione voluptas.', 'Iusto consequatur. Vel atque ut ut recusandae nemo. Sit quis voluptate illo maiores tempora. Enim ut sunt perspiciatis facilis corrupti. Aut. Est illum aut natus iste assumenda.'),
(1, 33, '2024-04-23', 'Qui quia provident alias.', 'Quae. Delectus in. Et. Non optio aut ad aliquam sint. Iusto. Repellat. Fuga culpa. Odio. Aut. Et velit.'),
(2, 6, '2024-04-21', 'Sit reiciendis tenetur.', 'Praesentium rem. Autem qui nemo magnam non voluptates. Ad accusamus similique. Quia tenetur quisquam reprehenderit aut consequatur. Qui possimus ducimus natus odit. Est voluptatum et exercitationem perferendis.'),
(3, 27, '2024-04-23', 'Deleniti rem ipsam ipsum.', 'Impedit molestiae ipsa velit autem. Molestiae occaecati. At. Necessitatibus ut. Optio. Perferendis est voluptatem sit optio. Similique non fugit.'),
(2, 31, '2024-04-25', 'Nostrum at nostrum eius.', 'Quia nostrum. Qui dolor voluptates. Totam. Aliquam illum quo dignissimos soluta. Praesentium omnis debitis.'),
(3, 39, '2024-04-24', 'Dignissimos est ratione.', 'Voluptatibus consequatur. Asperiores reiciendis delectus dolorum vero. Sunt modi tenetur sunt eos. Maiores ut ullam blanditiis qui. Sit quibusdam. Ullam corrupti vero nihil dolorem dignissimos.'),
(3, 37, '2024-04-21', 'Ex quia accusantium magnam.', 'Exercitationem atque. Est. Laudantium quia. Tempore enim. Sit expedita placeat. Vel quaerat aliquid. Inventore. Quaerat non enim commodi sit dolor. Error itaque.'),
(3, 40, '2024-04-22', 'Eum rem odit et distinctio.', 'In labore voluptatem. Consequatur modi quibusdam voluptate eos in. Voluptatibus eaque veritatis quae molestiae neque. In ut facere. Voluptas.'),
(1, 20, '2024-04-27', 'Est repellat enim nemo velit.', 'Temporibus fugiat facilis omnis atque neque. Illo cum. Qui vero. Et sint rerum. Et accusantium autem et vitae tempore. Praesentium sed et nemo natus. Ex.'),
(1, 16, '2024-04-26', 'Distinctio ea aut voluptas.', 'Veniam at sint totam nihil excepturi. Placeat deserunt optio ab. Ipsum omnis quasi. Rerum. Velit asperiores corrupti. Corporis quod consequatur non suscipit.'),
(1, 8, '2024-04-26', 'Dolore incidunt enim omnis.', 'Aut velit quae voluptatem hic. Qui veritatis vero. Quo a. Pariatur est. Voluptas et voluptate ex est. Perferendis omnis. Cumque quis.'),
(3, 34, '2024-04-23', 'Quia at qui enim ullam non.', 'Ut. Earum aliquid necessitatibus. Amet quos natus aut aut. Aperiam. Enim quo. Reprehenderit necessitatibus porro laborum.'),
(2, 26, '2024-04-23', 'Iusto expedita odio quia.', 'Ut et id et ex. Quisquam. Nobis nesciunt fugiat laborum rerum consequuntur. Et velit quas autem aliquid eum. Enim et.'),
(3, 4, '2024-04-27', 'Est ut dolor accusantium.', 'Magni qui voluptas. Ipsam et nisi. Delectus minima. Natus officia cupiditate aut eum et. Rerum autem. Aut atque ratione ut minus. Dolorem ut autem nisi.'),
(3, 48, '2024-04-23', 'Qui adipisci quas incidunt.', 'Quibusdam deserunt ducimus aperiam omnis quam. Aperiam. Et aut animi reiciendis commodi. Sequi. Ipsa sed.'),
(2, 23, '2024-04-21', 'Nihil quaerat cupiditate.', 'Nihil quo aut. Voluptas nihil ut. Quam ratione est quos. Modi libero nulla et ducimus nemo. Expedita velit tempore quisquam. A ut ut.'),
(3, 25, '2024-04-24', 'Placeat cum voluptatem.', 'Quas impedit. Est cum architecto aliquam architecto voluptatem. Sunt. Quibusdam aut non neque sint. Et dolores. Quasi quisquam.'),
(3, 37, '2024-04-22', 'Provident sapiente laudantium.', 'Ea fugiat illum quod voluptas. Temporibus laborum quis necessitatibus. Quod nulla consequatur et ad. Adipisci temporibus suscipit quisquam. Necessitatibus commodi id dolor.'),
(3, 39, '2024-04-21', 'Eum enim autem officia in.', 'Magni. Nam reprehenderit fugiat excepturi sit eos. Et autem incidunt vero. Et modi occaecati doloremque omnis.'),
(3, 40, '2024-04-26', 'Est esse recusandae et ipsam.', 'Alias sed maiores. Odio eligendi explicabo recusandae facere beatae. Ex. Cumque ratione corporis temporibus cum hic. Fuga sed doloremque.'),
(1, 30, '2024-04-28', 'Aut occaecati quos et consequatur.', 'Explicabo harum quasi. Tempore. Et sit. Mollitia. Omnis adipisci molestiae ut dignissimos. Laudantium voluptatem enim autem. Ut ex repellendus explicabo. Culpa rerum ut voluptates expedita.'),
(2, 32, '2024-04-28', 'Magnam deleniti debitis.', 'Voluptatem similique in dolorem atque. Sint. Blanditiis et suscipit et. Consequatur aliquid. Animi laborum veniam at.'),
(3, 39, '2024-04-27', 'Iure tempore aspernatur.', 'Et ipsa voluptas. Magni veniam dignissimos. Quos. Libero natus recusandae. Voluptas. Corporis vitae hic.'),
(1, 9, '2024-04-21', 'Non sunt nisi sequi ea natus.', 'Voluptate ipsum pariatur sunt eum. Est quidem id. Dolor explicabo dolore et unde totam. Dolores. Libero nostrum modi at eum.'),
(2, 7, '2024-04-26', 'Est dolorem quam illo quia.', 'Nihil iure sint. Possimus et quo. Laboriosam non fuga sequi ipsam eveniet. Et officia voluptatibus vel officiis.'),
(3, 15, '2024-04-23', 'Eaque natus architecto.', 'Inventore quas accusantium architecto quia iste. Quasi voluptas ipsa nostrum. Provident. Repellat sequi omnis. Doloremque. Eaque a sunt quis est officiis.'),
(2, 18, '2024-04-25', 'Autem id accusantium consequatur.', 'Velit odio vitae. Et molestiae rerum recusandae esse rerum. Sit hic quia aperiam dolor nisi. Alias possimus quod quidem non sunt.'),
(2, 24, '2024-04-25', 'Ut laudantium delectus.', 'Quae cupiditate. Dolorem nisi omnis animi in. Harum. Sint sunt impedit rerum. Molestiae consequatur ut molestiae.'),
(2, 26, '2024-04-24', 'Dolores saepe molestiae.', 'Quia debitis dolores. Reiciendis. Voluptas quia unde ut voluptas aut. Velit. Sed eius dolore. Deserunt doloribus sed. Velit eveniet aut voluptatibus.'),
(1, 19, '2024-04-27', 'Beatae cum est quisquam.', 'Blanditiis consectetur eaque architecto consectetur aut. Eveniet animi. Atque dignissimos ut porro veritatis.'),
(3, 21, '2024-04-26', 'Deserunt dignissimos ut.', 'Distinctio alias. Cupiditate. Dolore. Dolorem dolores alias ab tempora esse. Adipisci quae nulla. Neque. At ipsum minus cupiditate.'),
(2, 38, '2024-04-26', 'Alias consectetur dolorem.', 'Optio atque quae distinctio. Cumque laborum. Deserunt dolores repellendus. Necessitatibus vel dicta quos tempora.'),
(3, 48, '2024-04-22', 'Fuga et quod commodi veniam.', 'Aut voluptatem in expedita. Voluptatem omnis. Iusto. Ut enim voluptate. Quos. Blanditiis. Qui. Reiciendis sunt qui.'),
(2, 26, '2024-04-28', 'Et dicta exercitationem.', 'Nisi odio impedit. Sed et magni. Distinctio eum. Doloribus commodi atque dolores modi. Omnis tempore unde earum. Excepturi adipisci quia incidunt error. Earum corrupti ducimus.'),
(3, 15, '2024-04-23', 'Laudantium perferendis.', 'Sunt. Quae minima et. Laudantium ut est repellat. Aut autem ut et. Ipsum. Ut. Cum placeat doloribus. Sapiente occaecati nihil. Quia voluptatum laboriosam unde.'),
(1, 42, '2024-04-25', 'Consequatur consequatur.', 'Repellat consequuntur et. Blanditiis. Molestiae modi autem molestias dignissimos. Quia rerum et magnam impedit. Accusantium molestiae adipisci sequi nisi. Et odio aut modi dolores.'),
(3, 45, '2024-04-28', 'Laborum et beatae eum nemo.', 'Voluptatem excepturi. Quidem. Repellat repudiandae impedit voluptatum. Repudiandae ea veniam. Harum sapiente facilis porro est. Quibusdam ipsam illum deleniti.'),
(3, 21, '2024-04-23', 'Est magni et dignissimos.', 'Et consequatur quod. Rem est dolorem amet praesentium. Neque in ipsa harum ipsam dolorem. Reprehenderit perspiciatis. Voluptatem suscipit qui sapiente recusandae.'),
(2, 18, '2024-04-28', 'Et at animi consequuntur.', 'Qui atque numquam rerum. Reiciendis doloremque. Dolor rerum. Itaque dignissimos totam. Reprehenderit. Assumenda et velit distinctio harum. Nulla autem aut dolores accusantium. Vel.'),
(3, 21, '2024-04-28', 'Temporibus sit hic voluptatem.', 'Ut libero quas libero mollitia. Dolor occaecati rerum necessitatibus. Voluptatibus delectus qui molestias. Iste.'),
(2, 1, '2024-04-22', 'Nihil sunt quia quia iusto.', 'Iure sint quis at voluptas qui. Fuga sit autem fugiat ea est. Sit repudiandae dolore optio autem. Quibusdam rerum autem.'),
(3, 34, '2024-04-22', 'Molestias repudiandae.', 'Odit voluptas laboriosam illum. Autem velit. Occaecati sit. Illo non molestias tempora. Sint iste eaque.'),
(2, 50, '2024-04-24', 'Aut ducimus quae ut recusandae.', 'Ea dolor itaque quidem nam est. Facilis et. Vitae architecto ea qui quod sit. Impedit amet. Fugiat magni quasi ab velit laudantium. Accusantium et repellat.'),
(1, 17, '2024-04-22', 'Magnam sint quibusdam impedit.', 'Aut voluptas voluptatum ab id. Totam vel qui. Dolorem fuga. Saepe veniam repudiandae voluptatibus corporis. Assumenda.'),
(1, 49, '2024-04-27', 'Quisquam deleniti earum.', 'Quia voluptate impedit molestiae qui odit. Culpa quis cupiditate. Non. Ut. Ex voluptate deserunt sed animi. Quia dolores est aut impedit.'),
(3, 4, '2024-04-22', 'Corrupti sed cum reprehenderit.', 'Officia dolor accusantium laudantium nemo iusto. Corporis quibusdam consequatur qui animi ab. Sit eaque voluptas impedit sunt. Voluptas quae harum doloremque in non.'),
(1, 8, '2024-04-23', 'Eos consequatur tempore.', 'Sed iste quo atque. Vel aut ducimus rem nulla. Quibusdam facere. Qui sapiente occaecati quis qui accusantium. Et laudantium labore magni et optio.'),
(1, 10, '2024-04-22', 'Beatae aspernatur aut voluptatem.', 'Nemo. Molestiae consequatur. Illum. Sit cumque earum. Veniam corrupti id aperiam saepe numquam. Voluptatem maxime. Nobis dolorem quis quam. Id corrupti iste est possimus.'),
(3, 4, '2024-04-23', 'Illum ipsa pariatur veniam.', 'Aut. Optio. Consequatur. Minima voluptatum. Omnis. Sunt repellendus cupiditate qui pariatur perferendis.'),
(2, 23, '2024-04-27', 'Nihil ut similique eos dolorum.', 'Ut aspernatur est. Repellat a blanditiis. Laborum voluptate. Quidem non. Molestiae placeat quo iusto. Ex tenetur iure ea.'),
(2, 32, '2024-04-26', 'Error voluptas qui quis.', 'Voluptatum eos. Nostrum magnam temporibus et qui. Qui voluptas voluptatum eum. Porro corporis repellat.'),
(3, 35, '2024-04-23', 'Magnam omnis asperiores.', 'Doloribus numquam autem quas. Ipsam. Ut consectetur asperiores. Aliquid aliquam et numquam quasi et. Doloremque et eum fugiat laboriosam.'),
(1, 10, '2024-04-25', 'In exercitationem est praesentium.', 'Omnis amet omnis. Qui magni quo consequatur reiciendis. At soluta. Eos. Illum. Nulla autem inventore laboriosam. Nemo quas ullam hic. Mollitia sapiente dolores quas inventore culpa.'),
(3, 35, '2024-04-24', 'Laborum accusantium porro.', 'Excepturi tempore quibusdam et. Magni. Veritatis ab suscipit tenetur quia. Quo ea est necessitatibus blanditiis. Rerum aut enim.'),
(1, 33, '2024-04-22', 'Dolores vero aliquam ut.', 'Magni et doloremque. Quia veritatis iure quis. Voluptatum. Assumenda assumenda sed maxime voluptas nihil.'),
(2, 12, '2024-04-22', 'Voluptas accusamus inventore.', 'Earum nulla tempora placeat temporibus. Sint quaerat doloremque et facere rem. Nihil. Voluptas repellat veniam vel et.'),
(2, 32, '2024-04-22', 'Odio eveniet qui incidunt.', 'Molestiae adipisci omnis maiores vitae. Voluptatem id veritatis eaque tempore. Aliquid soluta debitis similique debitis esse. Ea non earum est consectetur repellat. Minima neque ut.'),
(2, 6, '2024-04-28', 'Voluptatem ex et ea non voluptatem.', 'Alias id voluptates quam. Non dicta. Eius voluptate similique. Maxime mollitia expedita impedit qui maxime. Illo.'),
(3, 47, '2024-04-28', 'Amet eos velit ut qui sit.', 'Rerum. Molestias neque ut dolore voluptatem. Ex animi nihil earum qui. Ea in et facilis accusamus. Rerum officiis aspernatur et nihil. Facilis necessitatibus ipsam autem eaque labore.'),
(1, 19, '2024-04-25', 'Aspernatur id voluptate.', 'Quia delectus ut. Sunt. Dolor. Sit assumenda id tempora culpa molestias. Beatae. Optio nam commodi officia.'),
(3, 21, '2024-04-21', 'Laborum vitae ipsum veritatis.', 'Iure expedita non quia sed consequatur. Perspiciatis aut nulla. Voluptatem enim illo. Porro reiciendis omnis. Repellendus neque possimus numquam ipsum.'),
(1, 9, '2024-04-27', 'Enim cupiditate nulla ullam.', 'Maxime dolore nam beatae. Delectus. Corporis aut. Voluptate ipsa tenetur. Id aut eos. Ipsam id atque sed molestiae.'),
(2, 46, '2024-04-25', 'Molestiae voluptatibus.', 'Quod minus at quasi repellat distinctio. Ad est maiores quia voluptatem magnam. Consectetur pariatur nulla numquam placeat. Numquam a fuga natus.'),
(1, 2, '2024-04-21', 'Aut autem harum esse autem.', 'Qui quos. Error ea ipsa eligendi. Perferendis sint ut esse. Et totam qui ea. Quasi non ipsum. Voluptas dolore laboriosam.'),
(2, 41, '2024-04-24', 'Incidunt error facilis.', 'Ut. Repellendus nemo omnis voluptates facere. Voluptate sed. Quos facere. Vitae. Sequi esse dolores qui qui in. Nobis vitae. Dolorem ad et.'),
(3, 4, '2024-04-23', 'Perspiciatis assumenda.', 'Quibusdam. Suscipit dolorem voluptatem mollitia dolor. Sunt omnis incidunt. Perspiciatis officia et aut. Aut quo qui. Excepturi.'),
(1, 8, '2024-04-25', 'Blanditiis ab ipsum aspernatur.', 'Veniam. Possimus ab voluptatem quas. Vero eos id aut totam atque. Nihil quisquam. Quam nulla ad nihil distinctio voluptatum. Incidunt.'),
(2, 29, '2024-04-24', 'Porro accusamus enim ea.', 'Provident sit nam ipsam quisquam. Quis est. Doloremque ad tempora non aspernatur. Maxime. Ea ut officia. Magnam perspiciatis beatae doloremque.'),
(2, 29, '2024-04-26', 'Commodi perspiciatis amet.', 'Ex. Nobis delectus consequatur aut dolore fugiat. Doloribus unde quaerat. Sed voluptas quam temporibus unde. Consequatur harum reiciendis culpa dolor. Distinctio officia ad.'),
(3, 34, '2024-04-25', 'Ipsam natus molestiae eum.', 'Rem totam aut quia. Corporis atque sit officiis. Deserunt nam aut quos. Eveniet est enim ut ratione. Ut deserunt ab at. Odio.'),
(2, 1, '2024-04-24', 'Aperiam est consequatur.', 'Est nemo. Non nulla. Itaque illum ex consequatur. Suscipit. Dolorem voluptate sit. Facilis et enim voluptate sequi quam. Cumque.'),
(1, 28, '2024-04-25', 'Est sit nemo enim nobis totam.', 'Tempora consequatur consectetur vitae. Rerum quas. Sed aut consequatur sunt. Veritatis esse quaerat porro. Tempore quidem.');

INSERT INTO rodzaje_wydarzen(typ_wydarzenia, nazwa) VALUES
(1, 'konferencja'),
(2, 'spotkanie'),
(3, 'speed-dating'),
(4, 'integracja'),
(5, 'zawody');

INSERT INTO wydarzenia(id_wydarzenia, typ_wydarzenia, nazwa) VALUES 
(1, 1, 'Wielka Konferencja Młodych Matematyków i Informatyków'),
(2, 3, 'Serwisowy Speed-Dating'),
(3, 2, 'Spotkanie Majsterkowiczów'),
(4, 5, 'Zawody w Programowaniu Zespołowym');

INSERT INTO wydarzenia_spolecznosci (id_wydarzenia, id_spolecznosci) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 2),
(2, 3),
(3, 3),
(4, 2);

INSERT INTO role(id_roli, nazwa) VALUES
(1, 'admin'),
(2, 'czlonek'),
(3, 'aktywny-czlonek'),
(4, 'moderator');

INSERT INTO adresy values 
(1, 'Collegium Maximum UJ, Kraków'),
(2, 'Forum Kraków'),
(3, 'Wydział Matematyki i Informatyki UJ, Kraków');


INSERT INTO edycje(id_edycji, nr_edycji, id_wydarzenia, data_rozpoczecia, data_zakonczenia, miejsce, podtytul) VALUES
(1, 1, 1, '2023-10-13', '2023-10-16', 1, 'Pierwsza edycja Wielkiej Konferencji Matematyków i Informatyków'),
(2, 2, 1, '2024-10-13', '2024-10-16', 1, 'Druga edycja Wielkiej Konferencji Matematyków i Informatyków'),
(3, 1, 2, '2024-02-14', '2024-02-14', 2, 'Pierwsza edycja ogólno-serwisowego speed-datingu'),
(4, 1, 3, '2024-06-22', '2024-02-23', 3, 'Pierwsza edycja Zawodów w Programowaniu Zespołowym');


INSERT INTO dlugosci(dlugosc_prelekcji, dlugosc) VALUES
(1, '00000000 00:30:00'),
(2, '00000000 01:00:00'),
(3, '00000000 01:30:00'),
(4, '00000000 02:00:00');

INSERT INTO sale(id_sali, adres, nazwa, pojemnosc) VALUES 
(1, 3, 'Sala 0016', 25),
(2, 3, 'Sala 0017', 25),
(3, 3, 'Sala 0018', 25),
(4, 3, 'Sala 0019', 25),
(5, 3, 'Sala 0020', 25),
(6, 2, 'Sala Bankietowa', 200),
(7, 1, 'Aula mała A0', 60),
(8, 1, 'Aula średnia A1', 100),
(9, 1, 'Aula duża A2', 150);

INSERT INTO edycje_sale(id_edycji, id_sali) VALUES 
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(4, 5),
(1, 8),
(1, 9),
(2, 7),
(2, 8),
(2, 9),
(3, 6);

INSERT INTO prelegenci (id_prelegenta, imie, nazwisko) VALUES 
(1, 'Andrzej', 'Dragan'),
(2, 'Gynvael', 'Coldwind'),
(3, 'Łukasz', 'Michalik'),
(4, 'Marcin', 'Bawor'),
(5, 'Tomasz', 'Stopa'),
(6, 'Tomasz', 'Markiewicz'),
(7, 'Dorota', 'Łąka'),
(8, 'Anna', 'Czura'),
(9, 'Anna', 'Bawołek');
INSERT INTO prelegenci (id_prelegenta, id_czlonka, imie, nazwisko) VALUES
(10, 1, 'Cyprian', 'Szoka');

INSERT INTO prelekcje (id_edycji, id_sali, data_prelekcji, dlugosc_prelekcji, temat) VALUES
(1, 9, '2023-10-13 12:00:00', 4, 'Rozpoczęcie'),
(1, 9, '2023-10-13 14:00:00', 4, 'Sztuczna inteliencja - cele i niebezpieczeństwa'),
(1, 8, '2023-10-13 16:00:00', 4, 'Quantum Computing in modern physics'),
(1, 8, '2023-10-13 18:00:00', 4, 'Navier-Stokes equation - solving it together!'),
(1, 9, '2023-10-14 12:00:00', 4, 'In-game development'),
(1, 9, '2023-10-14 14:00:00', 4, 'Zasada superpozycji a programowanie kwantowe'),
(1, 8, '2023-10-14 16:00:00', 4, 'How to build a game engine'),
(1, 8, '2023-10-14 18:00:00', 4, 'Jak rozwijać swoją markę w IT?'),
(1, 9, '2023-10-15 12:00:00', 4, 'Komputery Kwantowe - co nas czeka w przyszłości?'),
(1, 9, '2023-10-15 14:00:00', 4, 'How to hack a polish train'),
(1, 8, '2023-10-15 16:00:00', 4, 'Hackers 101'),
(1, 8, '2023-10-15 18:00:00', 4, 'Competitive Programming - how to start?'),
(1, 9, '2023-10-13 12:00:00', 4, 'Jak powstały wirusy komputerowe?'),
(1, 9, '2023-10-13 14:00:00', 4, 'Zakończenie'),

(2, 9, '2024-10-13 12:00:00', 4, 'Rozpoczęcie'),
(2, 9, '2024-10-13 14:00:00', 4, 'Sztuczna inteliencja - cele i niebezpieczeństwa'),
(2, 8, '2024-10-13 16:00:00', 4, 'Quantum Computing in modern physics'),
(2, 8, '2024-10-13 18:00:00', 4, 'Navier-Stokes equation - solving it together!'),
(2, 9, '2024-10-14 12:00:00', 4, 'In-game development'),
(2, 9, '2024-10-14 14:00:00', 4, 'Zasada superpozycji a programowanie kwantowe'),
(2, 8, '2024-10-14 16:00:00', 4, 'How to build a game engine'),
(2, 8, '2024-10-14 18:00:00', 4, 'Jak rozwijać swoją markę w IT?'),
(2, 9, '2024-10-15 12:00:00', 4, 'Komputery Kwantowe - co nas czeka w przyszłości?'),
(2, 9, '2024-10-15 14:00:00', 4, 'How to hack a polish train'),
(2, 8, '2024-10-15 16:00:00', 4, 'Hackers 101'),
(2, 8, '2024-10-15 18:00:00', 4, 'Competitive Programming - how to start?'),
(2, 9, '2024-10-13 12:00:00', 4, 'Jak powstały wirusy komputerowe?'),
(2, 9, '2024-10-13 14:00:00', 4, 'Zakończenie');

INSERT INTO prelekcje_prelegenci(id_prelegenta, id_prelekcji) VALUES
(10, 1),
(1, 2),
(1, 3),
(9, 4),
(5, 5),
(4, 6),
(6, 7),
(8, 8),
(7, 9),
(3, 10),
(4, 11),
(2, 12),
(3, 13),
(10, 14),
(10, 15),
(1, 16),
(1, 17),
(9, 18),
(5, 19),
(4, 20),
(6, 21),
(8, 22),
(7, 23),
(3, 24),
(4, 25),
(2, 26),
(3, 27),
(10, 28);

INSERT INTO organizatorzy(id_czlonka, id_edycji) VALUES
(1, 1),
(1, 2);

INSERT INTO czlonkowie_spolecznosci (id_czlonka, id_spolecznosci, id_roli) VALUES 
(1, 2 ,3),
(2, 1 ,3),
(3, 2 ,3),
(4, 3 ,2),
(5, 2 ,3),
(6, 2 ,2),
(7, 2 ,2),
(8, 1 ,2),
(9, 1 ,2),
(10, 1 ,3),
(11, 2 ,2),
(12, 2 ,3),
(13, 2 ,3),
(14, 2 ,2),
(15, 3 ,2),
(16, 1 ,2),
(17, 1 ,3),
(18, 2 ,2),
(19, 1 ,3),
(20, 1 ,2),
(21, 3 ,3),
(22, 1 ,3),
(23, 2 ,3),
(24, 2 ,2),
(25, 3 ,3),
(26, 2 ,2),
(27, 3 ,3),
(28, 1 ,2),
(29, 2 ,3),
(30, 1 ,3),
(31, 2 ,3),
(32, 2 ,3),
(33, 1 ,2),
(34, 3 ,2),
(35, 3 ,3),
(36, 3 ,2),
(37, 3 ,2),
(38, 2 ,3),
(39, 3 ,2),
(40, 3 ,2),
(41, 2 ,2),
(42, 1 ,3),
(43, 3 ,3),
(44, 1 ,3),
(45, 3 ,3),
(46, 2 ,3),
(47, 3 ,2),
(48, 3 ,2),
(49, 1 ,2),
(50, 2 ,2),
(51, 1, 1);



INSERT INTO czlonkowie_edycje (id_czlonka, id_edycji) VALUES
(1, 4),
(2, 1),
(9, 4),
(31, 1),
(34, 1),
(37, 3),
(38, 3),
(44, 2),
(50, 2);

INSERT INTO wolontariusze (id_czlonka, id_edycji) VALUES
(1, 4),
(2, 1),
(9, 4),
(31, 1),
(34, 1),
(37, 3),
(38, 3),
(44, 2),
(50, 2);
