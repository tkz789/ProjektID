from functools import reduce
from gc import get_debug
from uu import Error
from flask import Flask, render_template, request, redirect, url_for, abort, jsonify, flash
import psycopg2
from psycopg2.extras import RealDictCursor
import sys
import os
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import date, timedelta

app = Flask(__name__)

app.secret_key = "haszcze_W_kleszczach"

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login' # type: ignore

class User(UserMixin):
    def __init__(self, data) -> None:
        super().__init__()
        self.data = data
        self.id = data['id_czlonka']
        with get_db_connection() as conn, conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) > 0 from czlonkowie_spolecznosci where id_czlonka = %s and id_roli = 1", (self.id,)) 
            self.is_admin = cur.fetchone()[0] # type: ignore

    def __str__(self) -> str:
        return f"User({str(self.data)})"


@login_manager.user_loader
def load_user(user_id):
    with get_db_connection() as conn, conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor) as cur: # type: ignore
        user = None
        try:
            cur.execute("SELECT * from czlonkowie where id_czlonka = %s", (user_id,))
            user = cur.fetchone()
            conn.commit()
            if user is not None:
                return User(user)
        except:
            conn.rollback()
    return None

def get_db_connection():
    return psycopg2.connect(
        database=os.getlogin(),
        user=os.getlogin()
    )

def get_pronouns():
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute("SELECT * from zaimki")
        return cur.fetchall()

from forms import RegistrationForm, LoginForm

@app.route('/')
def index():
    return redirect(url_for('home'))


@app.route("/aboutus")
def aboutus():
    return render_template('html/aboutus.html', user = current_user)

@app.route("/home")
def home():
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute("SELECT nazwa from spolecznosci")
        spolecznosci = cur.fetchall()
    return render_template('html/index.html', spolecznosci=spolecznosci, user = current_user)

@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        imie = form.imie.data
        nazwisko = form.nazwisko.data
        password = generate_password_hash(form.password.data)
        pronoun_id: int | None = int(form.pronouns.data[0])
        if pronoun_id == 0:
            pronoun_id = None
        newsletter = form.newsletter.data if 'newsletter' in form else True
        with get_db_connection() as conn, conn.cursor() as cur:
            try:
                cur.execute('SELECT register(%s, %s, %s, %s, %s, %s, %s)', (username, email, imie, nazwisko, password, pronoun_id, newsletter))
                conn.commit()
                flash('Account created successfully!', 'success')
            except Exception as e:
                flash(str(e), 'danger')
                conn.rollback()
            return redirect(url_for('login'))
    return render_template('html/register.html', form=form, user = current_user)

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.is_submitted():
        with get_db_connection() as conn, conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor) as cur: # type: ignore
            password = form.password.data
            username = form.username.data
            remember = form.remember.data
            user = None
            user_id = None
            try:
                cur.execute("select get_user_id(%s) as user_id", (username,))
                user_id = cur.fetchone()
                cur.execute("select * from czlonkowie where id_czlonka = %s", (user_id['user_id'],)) # type: ignore
                user = User(cur.fetchone())
                conn.commit()
            except:
                conn.rollback()

        if user and check_password_hash(user.data['haslo_hash'], password): # type: ignore
            login_user(user, remember=remember)
            return redirect(url_for('dashboard'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'success')
    return render_template('html/login.html', form=form , user = current_user)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('html/dashboard.html', username = current_user.data['nazwa_uzytkownika'] , user = current_user)


@app.route('/get_statistics', methods=['GET'])
@login_required
def get_statistics():
    with get_db_connection() as conn, conn.cursor() as cur:
        try:
            cur.execute('''
                SELECT 
                    *
                FROM full_edition_statistics;
            ''')
            stats = cur.fetchall()
            cur.execute('''
                SELECT 
                    *
                FROM full_communities_statistics;
            ''')
            stats2 = cur.fetchall()
            return render_template('html/statistics.html', stats=stats, stats2=stats2)
        except Exception as e:
            print(f"Error fetching statistics: {e}")
            abort(500, description="Nieudane pobieranie statystyk.")


def get_posts(community_id):
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT r.id_posta, r.id_posta_nad, r.id_spolecznosci, (select p.nazwa_uzytkownika from czlonkowie p where p.id_czlonka = r.id_czlonka), r.data_dodania, r.tytul, r.tresc FROM get_posts(%s) r', (community_id,))
        return cur.fetchall()

def get_post(post_id):
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT r.id_posta, r.id_posta_nad, r.id_spolecznosci, (select p.nazwa_uzytkownika from czlonkowie p where p.id_czlonka = r.id_czlonka), r.data_dodania, r.tytul, r.tresc FROM posty r WHERE r.id_posta = %s', (post_id,))
        return cur.fetchone()

def get_communities_with_names(member_id):
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT * FROM get_communities_with_names(%s)', (member_id,))
        return cur.fetchall()

def get_user_posts_with_names(user_id):
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT * FROM get_user_posts_with_names(%s) LIMIT 25', (user_id,))
        return cur.fetchall()

def get_replies(parent_post_id):
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT r.id_posta, r.id_posta_nad, r.id_spolecznosci, (select p.nazwa_uzytkownika from czlonkowie p where p.id_czlonka = r.id_czlonka), r.data_dodania, r.tytul, r.tresc FROM get_replies(%s) r', (parent_post_id,))
        return cur.fetchall()


@app.route('/feed')
@login_required
def feed():

    with get_db_connection() as conn, conn.cursor() as cur:
        community_id = request.args.get('community_id')
        post_id = request.args.get('post_id')
        user_id = current_user.data['id_czlonka']

        if not community_id:
            communities = get_communities_with_names(user_id)
            posts = get_user_posts_with_names(user_id)
            return render_template('html/communities_feed.html', communities=communities, posts=posts, user = current_user)

        cur.execute('SELECT nazwa FROM spolecznosci WHERE id_spolecznosci = %s', (community_id))
        community_name = cur.fetchone()[0]

        if post_id:
            post = get_post(post_id)
            replies = get_replies(post_id)
            return render_template('html/posty.html', post=post, replies=replies, community_id=community_id, cname = community_name, user = current_user)
        else:
            posts = get_posts(community_id)
            return render_template('html/feed.html', posts=posts, community_id=community_id, cname = community_name, user = current_user)



@app.route('/add_post', methods=['POST'])
@login_required
def add_post():
    community_id = request.form['community_id']
    parent_post_id = request.form.get('parent_post_id')
    title = request.form['title']
    content = request.form['content']
    user_id = current_user.data['id_czlonka']

    with get_db_connection() as conn, conn.cursor() as cur:
        try:
            cur.execute('SELECT make_post(%s, %s, %s, %s, %s)', (parent_post_id, community_id, user_id, title, content))
            conn.commit()
            flash('Udało się utworzyć post!')
        except Exception as e:
            conn.rollback()
            flash(str(e), 'error')


    if parent_post_id:
        return redirect(url_for('feed', community_id=community_id, post_id=parent_post_id))
    else:
        return redirect(url_for('feed', community_id=community_id))

@app.route('/register_talk', methods=['GET', 'POST'])
@login_required
def register_talk():
    with get_db_connection() as conn, conn.cursor() as cur:
        if request.method == 'POST':
            speaker_id = request.form['speaker_id']
            edit = request.form['edit']
            room = request.form['room']
            talk_date = request.form['talk_date']
            talk_length = request.form['talk_length']
            subj = request.form['subj']
            descript = request.form['descript']
            try:
                cur.execute("""
                    SELECT register_talk(%s, %s, %s, %s, %s, %s, %s);
                """, (speaker_id, edit, room, talk_date, talk_length, subj, descript))
                conn.commit()
                flash("Dodałeś właśnie nową rozmowę")
            except Exception as e:
                conn.rollback()
                flash(str(e), "error")
                
            return redirect(url_for('dashboard'))

        cur.execute('SELECT r.id_sali, (select s.adres from adresy s where s.id_adresu = r.adres), nazwa FROM sale r')
        rooms = cur.fetchall()

        cur.execute('SELECT id_prelegenta, imie, nazwisko FROM prelegenci')
        speakers = cur.fetchall()

        cur.execute('SELECT dlugosc_prelekcji, dlugosc FROM dlugosci')
        lengths = cur.fetchall()

        cur.execute('SELECT * FROM full_edition_statistics')
        editions = cur.fetchall()

        return render_template('html/register_talk.html', rooms=rooms, speakers=speakers, lengths=lengths, user = current_user, editions = editions)

@app.route('/add_speaker', methods=['GET', 'POST'])
@login_required
def add_speaker():
    with get_db_connection() as conn, conn.cursor() as cur:
        if request.method == 'POST':
            speaker_id = request.form['speaker_id']
            talk_id = request.form['talk_id']
            try:
                cur.execute("""
                    SELECT add_to_talk(%s, %s);
                """, (speaker_id, talk_id))
                conn.commit()
                flash("Udało się dodać mówcę!")
            except Exception as e:
                conn.rollback()
                flash(str(e), 'error')
            return redirect(url_for('dashboard'))

        cur.execute('SELECT id_prelegenta, imie, nazwisko FROM prelegenci')
        speakers = cur.fetchall()

        cur.execute('SELECT id_prelekcji, temat FROM prelekcje')
        talks = cur.fetchall()

    return render_template('html/add_speaker.html', speakers=speakers, talks=talks, user = current_user)

@app.route('/add_volonteer', methods=['GET', 'POST'])
@login_required
def add_volonteer():
    if not current_user.is_admin:
        flash("Nie masz dostępu do funkcji admina!")
        return redirect(url_for("dashboard"))

    with get_db_connection() as conn, conn.cursor() as cur:
        if request.method == 'POST':
            edit_id = request.form['edit_id']
            member_id = request.form['member_id']
            try:
                cur.execute("""
                    INSERT INTO wolontariusze VALUES (%s, %s);
                """, (member_id, edit_id))
                conn.commit()
                flash("Udało się dodać wolontariusza!")
            except Exception as e:
                conn.rollback()
                flash(str(e), 'error')
            return redirect(url_for('dashboard'))

        cur.execute('SELECT id_czlonka, imie, nazwisko FROM czlonkowie')
        members = cur.fetchall()

        cur.execute('SELECT e.id_edycji, (select w.nazwa from wydarzenia w where w.id_wydarzenia = e.id_wydarzenia), e.nr_edycji FROM edycje e')
        editions = cur.fetchall()

    return render_template('html/add_volonteer.html', members = members, editions = editions, user = current_user)


@app.route('/admin_panel', methods=['GET', 'POST'])
@login_required
def admin_panel():
    if not current_user.is_admin:
        flash("Nie masz dostępu do funkcji admina!")
        return redirect(url_for("dashboard"))
    if request.method == 'POST':
        edit_id = request.form['edit_id']
        badge_type = request.form['badge_type']
        badges = generate_badges(edit_id, badge_type)
        return render_template('html/badges.html', badges=badges)

    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT * FROM full_edition_statistics')
        editions = cur.fetchall()


    return render_template('html/admin_panel.html', user = current_user, editions = editions)

def generate_badges(edit_id, badge_type):
    with get_db_connection() as conn, conn.cursor() as cur:
        if badge_type == 'attendees':
            cur.execute("SELECT * FROM generate_attendee_badges(%s)", (edit_id,))
        elif badge_type == 'volunteers':
            cur.execute("SELECT * FROM generate_volonteer_badges(%s)", (edit_id,))
        elif badge_type == 'organisers':
            cur.execute("SELECT * FROM generate_organiser_badges(%s)", (edit_id,))
        elif badge_type == 'speakers':
            cur.execute("SELECT * FROM generate_speaker_badges(%s)", (edit_id,))

        return cur.fetchall()



def get_editions(member_id):
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT * FROM get_editions(%s)', (member_id,))
        return cur.fetchall()

def get_edition_details(edition_id):
    with get_db_connection() as conn, conn.cursor() as cur:
        query = """
        SELECT e.nr_edycji, w.nazwa, e.data_rozpoczecia, e.data_zakonczenia
        FROM edycje e
        JOIN wydarzenia w ON w.id_wydarzenia = e.id_wydarzenia
        WHERE e.id_edycji = %s
        """
        cur.execute(query, (edition_id,))
        return cur.fetchone()

def get_timetable(edition_id, event_date):
    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT r.data_rozpoczecia, r.data_zakonczenia, r.temat, r.opis, r.prowadzacy, (select s.nazwa from sale s where s.id_sali = r.sala), r.wolontariusze FROM get_timestable(%s, %s) as r', (edition_id, event_date))
        return cur.fetchall()

@app.route('/events', methods=['GET', 'POST'])
@login_required
def events():
    edition_id = request.args.get('edition_id')
    if request.method == 'POST':
        user_id = current_user.get_id()   
            
        if request.form['action'] == 'update':
            talk_id = request.form['join_id']
            with get_db_connection() as conn, conn.cursor() as cur:
                cur.execute("insert into wolontariusze_prelekcje values (%s, %s)", (user_id, talk_id))
                conn.commit()

        if request.form['action'] == 'delete':
            leave_talk_id = request.form['leave_id']
            with get_db_connection() as conn, conn.cursor() as cur:
                cur.execute("delete from wolontariusze_prelekcje where id_czlonka = %s and id_prelekcji = %s", (user_id, leave_talk_id))
                conn.commit()
            
    if edition_id:
        try:
            edition_id = int(edition_id)
        except ValueError:
            flash("Nie należy patrzeć do miejsc, które nie istnieją!")
            return redirect(url_for('dashboard'))
        
        with get_db_connection() as conn, conn.cursor() as cur:
                cur.execute("SELECT count(*) > 0 from czlonkowie_edycje where id_czlonka = %s and id_edycji = %s", (current_user.id, edition_id))
                if cur.fetchone()[0] == False: # type: ignore
                    flash("Nie masz dostępu do tej edycji!")
                    return redirect(url_for('dashboard'))

        edition_details = get_edition_details(edition_id)
        if not edition_details:
            flash("Nie należy patrzeć do miejsc, które nie istnieją!")
            return redirect(url_for('dashboard')) 
        
        start_date, end_date = edition_details[2], edition_details[3]
        current_date = start_date

        with get_db_connection() as conn, conn.cursor() as cur:
            cur.execute("SELECT EXISTS(SELECT 1 FROM wolontariusze WHERE id_edycji = %s and id_czlonka = %s)", (edition_id, current_user.data["id_czlonka"]))
            is_volunteer = cur.fetchone()[0] # type: ignore
            cur.execute("SELECT p.id_prelekcji, p.data_prelekcji, p.temat from prelekcje p where p.id_edycji = %s and not exists(select * from wolontariusze_prelekcje q where q.id_prelekcji = p.id_prelekcji and q.id_czlonka = %s)", (edition_id, current_user.data["id_czlonka"]))
            avaible_prelections = cur.fetchall()
            cur.execute("SELECT p.id_prelekcji, p.data_prelekcji, p.temat from prelekcje p where p.id_edycji = %s and exists(select * from wolontariusze_prelekcje q where q.id_prelekcji = p.id_prelekcji and q.id_czlonka = %s)", (edition_id, current_user.data["id_czlonka"]))
            occupied_prelections = cur.fetchall()        
            timetable = {}
            while current_date <= end_date:
                timetable[current_date] = get_timetable(edition_id, current_date)
                current_date += timedelta(days=1)

        return render_template('html/edition.html', edition_details=edition_details, timetable=timetable, edition_id=edition_id, user = current_user, is_volunteer = is_volunteer, present = occupied_prelections, absent = avaible_prelections)
    else:
        user_id = current_user.data['id_czlonka']
        editions = get_editions(user_id)
        current_date = date.today()
        current_future_editions = [edition for edition in editions if edition[2] >= current_date]
        past_editions = [edition for edition in editions if edition[2] < current_date]

    
    return render_template('html/events.html', current_future_editions=current_future_editions, past_editions=past_editions, user = current_user)
        
@app.route('/join_community', methods=['GET', 'POST'])
@login_required
def join_community():
    with get_db_connection() as conn, conn.cursor() as cur:
        if request.method == 'POST':
            id_spolecznosci = request.form["community_id"]
            user_id = current_user.get_id()
            try:
                cur.execute("INSERT INTO czlonkowie_spolecznosci(id_czlonka, id_spolecznosci, id_roli) values (%s, %s, 3)", (user_id, id_spolecznosci) )
                conn.commit()
                flash("Dołączyłeś do społeczności!")
            except Exception:
                conn.rollback()
                flash("Z jakiegoś powodu nie możesz dołączyć do tej społeczności", 'error')
            return redirect(url_for('dashboard'))


        cur.execute("""SELECT id_spolecznosci, nazwa from spolecznosci""")
        spolecznosci = cur.fetchall()
    return render_template('html/join_community.html', user=current_user, spolecznosci=spolecznosci)

@app.route('/join_event', methods=['GET','POST'])
@login_required
def join_event():
    if request.method == "POST":
        id_edycji = request.form["edition_id"]
        with get_db_connection() as conn, conn.cursor() as cur:
            try:
                cur.execute("insert into czlonkowie_edycje(id_czlonka, id_edycji) values (%s, %s)", (current_user.id, id_edycji))
                conn.commit()
                flash("Dołączono do wydarzenia!")
            except:
                conn.rollback()
                flash("Nie można dołączyć do wybranej edycji!")
        return redirect(url_for('dashboard'))

    with get_db_connection() as conn, conn.cursor() as cur:
        cur.execute("""SELECT id_edycji, nazwa, podtytul from edycje join wydarzenia using (id_wydarzenia)
                    join wydarzenia_spolecznosci using (id_wydarzenia)
                    join czlonkowie_spolecznosci using (id_spolecznosci)
                    where id_czlonka = %s and current_date <= data_zakonczenia and id_edycji != ALL(SELECT id_edycji from czlonkowie_edycje where id_czlonka = %s)""", (current_user.id, current_user.id))
        events = cur.fetchall()

    return render_template('html/join_event.html', user=current_user, events=events)

if __name__ == '__main__':
    app.run(debug=True)
