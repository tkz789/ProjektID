using Random
using Impostor
using Faker
using Dates
ilosc_czlonkow = 50
ilosc_spolecznosci = 3
ilosc_postow = 150
role = 2:3
edycje = 1:4
czlonkowie_spolecznosci_arr = Vector()
function czlonkowie()
  println("INSERT INTO czlonkowie (id_zaimka, nazwa_uzytkownika, email, imie, nazwisko, newsletter, data_dolaczenia) VALUES ")
  for i in 1:ilosc_czlonkow
    imie = Impostor.firstname(locale=["pl_PL"])
    nazwisko = Impostor.surname(locale=["pl_PL"])
    username = Random.randstring('a':'z', 10)
    data = rand(Date(2022, 1, 1):Day(1):Date(2024, 4, 21))
    println("($(abs(Random.rand(1:4))), '$(username)', '$(imie*"."*nazwisko*"@"*"mail.com")','$imie','$nazwisko', '$(rand(0:1))', '$data')" * ((i == ilosc_czlonkow) ? ";" : ","))
  end
end

function czlonkowie_spolecznosci()
  println("INSERT INTO czlonkowie_spolecznosci (id_czlonka, id_spolecznosci, id_roli) VALUES ")
  for i in 1:ilosc_czlonkow
    spolecznosc = rand(1:ilosc_spolecznosci)
    push!(czlonkowie_spolecznosci_arr, (i, spolecznosc))
    println("($i, $(spolecznosc) ,$(rand(role)))" * ((i == ilosc_czlonkow) ? ";" : ","))
  end
end

function czlonkowie_edycje()
  println("INSERT INTO czlonkowie_edycje (id_czlonka, id_edycji) VALUES")
  for i in 1:ilosc_czlonkow
    if (rand() < 0.7 || i == ilosc_czlonkow)
      println("($i, $(rand(edycje)))" * ((i == ilosc_czlonkow) ? ";" : ","))
    end
  end
end
function czlonkowie_edycje()
  println("INSERT INTO wolontariusze (id_czlonka, id_edycji) VALUES")
  for i in 1:ilosc_czlonkow
    if (rand() < 0.2 || i == ilosc_czlonkow)
      println("($i, $(rand(edycje)))" * ((i == ilosc_czlonkow) ? ";" : ","))
    end
  end
end

function posty()
  println("INSERT INTO posty (id_spolecznosci, id_czlonka, data_dodania, tytul, tresc) VALUES")
  for i in 1:ilosc_postow
    czl_sp = rand(czlonkowie_spolecznosci_arr)
    println("($(czl_sp[2]), $(czl_sp[1]), '$(rand(Date(2024, 4, 21):Day(1):Date(2024, 4, 28)))', '$(Faker.text(number_chars=20))', '$(Faker.text(number_chars=100))')" * ((i == ilosc_postow) ? ";" : ","))
  end

end

czlonkowie()
czlonkowie_spolecznosci()
czlonkowie_edycje()
posty()
