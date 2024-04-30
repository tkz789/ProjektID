INSERT INTO spolecznosci(id_spolecznosci, nazwa) VALUES
(1, 'Społeczność Matematyków'),
(2, 'Społeczność Programistów'),
(3, 'Kącik Szydełkowania');

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

INSERT INTO zaimki (id_zaimka, nazwa) VALUES 
(1, 'ona/jej'),
(2, 'on/jego'),
(3, 'ono/jego'),
(4, 'ono/jej'),
(5, 'ono/jejgo'),
(6, 'ono/jeno'),
(7, 'ono/jenu'),
(8, 'ono/ich');

INSERT INTO edycje(id_edycji, nr_edycji, id_wydarzenia, data_rozpoczecia, data_zakonczenia, miejsce, podtytul) VALUES
(1, 1, 1, '2023-10-13', '2023-10-16', 'Collegium Maximum UJ, Kraków', 'Pierwsza edycja Wielkiej Konferencji Matematyków i Informatyków'),
(2, 2, 1, '2024-10-13', '2024-10-16', 'Collegium Maximum UJ, Kraków', 'Druga edycja Wielkiej Konferencji Matematyków i Informatyków'),
(3, 1, 2, '2024-02-14', '2024-02-14', 'Forum Kraków', 'Pierwsza edycja ogólno-serwisowego speed-datingu'),
(4, 1, 3, '2024-06-22', '2024-02-23', 'Wydział Matematyki i Informatyki UJ, Kraków', 'Pierwsza edycja Zawodów w Programowaniu Zespołowym');
