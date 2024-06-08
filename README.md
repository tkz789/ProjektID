# Instalacja

Do uruchomienia aplikacji jest wymagany Python, prawdopodobnie w wersji >= 3.8 (używaliśmy 3.12, ale powinien działać na starszych).

W celu utworzenia środowiska wirtualnagego oraz instalacji wymaganych bibliotek proszę, będąc w folderze, gdzie rozpakowano projekt, wykonać komendy:

```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Następnie w celu uruchomienia, będąc wciąż w tym samym folderze:

```
flask --app "basic" run
```
Uruchomi to serwer, do którego link pokaże się w konsoli. Po otwarciu linku w przeglądarce powinno nastąpić przekierowanie do strony głównej aplikacji