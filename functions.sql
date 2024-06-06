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
            delete from czlonkowie_edycje where id_czlonka = user_to_archive.id_czlonka;
            delete from czlonkowie_spolecznosci where id_czlonka = user_to_archive.id_czlonka;
            delete from wolontariusze where id_czlonka = user_to_archive.id_czlonka;
            delete from organizatorzy where id_czlonka = user_to_archive.id_czlonka;
            update prelegenci p set id_czlonka = null where p.id_czlonka = user_to_archive.id_czlonka;
            insert into czlonkowie_archiwum values (user_to_archive.id_czlonka, user_to_archive.id_zaimka, user_to_archive.nazwa_uzytkownika,
            user_to_archive.email, user_to_archive.imie, user_to_archive.nazwisko, user_to_archive.newsletter, user_to_archive.data_dolaczenia);
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

create trigger czlonkowie_check after update on czlonkowie for each row execute procedure czlonkowie_trigger();
create trigger prelegenci_check before insert or update on prelegenci for each row execute procedure prelegent_trigger();







