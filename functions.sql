-- create or replace function login(username varchar(30), g_password varchar(162)) returns integer as $$
-- declare user_id integer;
-- user_password varchar(50);
-- begin
-- user_id = (select id_czlonka from czlonkowie where nazwa_uzytkownika = username);
-- if(user_id is null) then raise exception 'Niepoprawna nazwa uzytkownika'; end if;
-- user_password = (select haslo from hasla where id_czlonka = user_id 
-- and data_od = (select max(h.data_od) from hasla h where h.id_czlonka = user_id));
-- if(user_password is null or g_password != user_password) then raise exception 'Wprowadzone haslo jest nieprawidlowe'; end if;
-- return user_id;
-- end;
-- $$ language plpgsql;

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

return query select * from posty p where p.id_posta_nad is null and p.id_spolecznosci = community_id; 
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
k record;
begin
len1 = (select dlugosc from dlugosci where dlugosc_prelekcji = talk_length);
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
temat varchar(100), opis varchar(1000), prowadzacy text[], sala int) as $$
begin
return query 
    select p.data_prelekcji, 
    p.data_prelekcji + (select d.dlugosc from dlugosci d where d.dlugosc_prelekcji = p.dlugosc_prelekcji), 
    p.temat, p.opis,
     (select array_agg(concat(q.imie, ' ', q.nazwisko)) from prelegenci q where exists(select * 
     from prelekcje_prelegenci r where r.id_prelegenta = q.id_prelegenta and r.id_prelekcji = p.id_prelekcji )), p.id_sali
     from prelekcje p
    where p.id_edycji = edit_id and p.data_prelekcji::date = for_day and
    exists(select * from prelegenci q where exists(select * 
     from prelekcje_prelegenci r where r.id_prelegenta = q.id_prelegenta and r.id_prelekcji = p.id_prelekcji ))
     order by p.data_prelekcji, p.id_sali;
end;
$$ language plpgsql;