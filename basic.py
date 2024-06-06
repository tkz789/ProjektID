from flask import Flask, render_template, request, redirect, url_for, abort, jsonify, flash
import psycopg2
from psycopg2.extras import RealDictCursor
import sys
import os
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from forms import RegistrationForm, LoginForm
from datetime import date, timedelta

app = Flask(__name__)

app.secret_key = "haszcze_W_kleszczach"

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

class User(UserMixin):
    def __init__(self, data) -> None:
        super().__init__()
        self.data = data
        self.id = data['id_czlonka']

    def __str__(self) -> str:
        return f"User({str(self.data)})"


@login_manager.user_loader
def load_user(user_id):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
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

# with app.app_context():
#     db.create_all()

def get_db_connection():
    conn = psycopg2.connect(
        database=os.getlogin(),
        user=os.getlogin()
    )
    return conn


@app.route('/')
def index():
    return redirect(url_for('home'))

# @app.route('/login')
# def login():
#     return render_template('html/login.html')

@app.route("/aboutus")
def aboutus():
    return render_template('html/aboutus.html', user = current_user)

@app.route("/home")
def home():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT nazwa from spolecznosci")
    spolecznosci = cur.fetchall()
    conn.commit()
    return render_template('html/index.html', spolecznosci=spolecznosci, user = current_user)

@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        try:
            username = form.username.data
            email = form.email.data
            imie = form.imie.data
            nazwisko = form.nazwisko.data
            password = generate_password_hash(form.password.data)
            pronoun_id = None  # Replace with actual pronoun_id if applicable
            newsletter = form.newsletter.data if 'newsletter' in form else True
            conn = get_db_connection()
            curr = conn.cursor()
            curr.execute('SELECT register(%s, %s, %s, %s, %s, %s, %s)', (username, email, imie, nazwisko, password, pronoun_id, newsletter))
            conn.commit()
            flash('Account created successfully!', 'success')

        except Exception as e:
            flash(str(e), 'danger')
            conn.rollback()
        # user = User(nazwa_uzytkownika=form.username.data, email=form.email.data,
        #             imie=form.imie.data, nazwisko=form.nazwisko.data,
        #             data_dolaczenia=date.today())
        # user.set_password(form.password.data)
        # db.session.add(user)
        # db.session.commit()
        return redirect(url_for('login'))
    return render_template('html/register.html', form=form, user = current_user)

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    print("przed formularzem", form.is_submitted(), form.validate(), file=sys.stderr)
    if form.is_submitted():
        print("Przed zapytaniem", file=sys.stderr)
        # user = User.query.filter_by(nazwa_uzytkownika=form.username.data).first()
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
        password = form.password.data
        username = form.username.data
        remember = form.remember.data
        user = None
        user_id = None
        try:
            cur.execute("select get_user_id(%s) as user_id", (username,))
            user_id = cur.fetchone()
            cur.execute("select * from czlonkowie where id_czlonka = %s", (user_id['user_id'],))
            user = User(cur.fetchone())
            conn.commit()
        except:
            conn.rollback()
        print("TEST", file=sys.stderr)
        print(user_id, user, file=sys.stderr)
        
        # flash('To działa' + str(user), 'success')
        if user and check_password_hash(user.data['haslo_hash'], password):
            # flash('To działa', 'danger')
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
    conn = get_db_connection()
    if conn is None:
        abort(500, description="Nieudane połączenie z bazą danych.")
    
    try:
        with conn.cursor() as cur:
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
    finally:
        conn.close()



def get_posts(community_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT * FROM get_posts(%s)', (community_id,))
    posts = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return posts

def get_post(post_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT * FROM posty WHERE id_posta = %s', (post_id,))
    post = cur.fetchone()
    
    cur.close()
    conn.close()
    
    return post

def get_communities_with_names(member_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT * FROM get_communities_with_names(%s)', (member_id,))
    communities = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return communities

def get_user_posts_with_names(user_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT * FROM get_user_posts_with_names(%s) LIMIT 25', (user_id,))
    posts = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return posts

def get_replies(parent_post_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT * FROM get_replies(%s)', (parent_post_id,))
    replies = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return replies

@app.route('/feed')
@login_required
def feed():
    community_id = request.args.get('community_id')
    post_id = request.args.get('post_id')
    user_id = current_user.data['id_czlonka']

    if not community_id:
        communities = get_communities_with_names(user_id)
        posts = get_user_posts_with_names(user_id)
        return render_template('html/communities_feed.html', communities=communities, posts=posts, user = current_user)


    if post_id:
        post = get_post(post_id)
        replies = get_replies(post_id)
        return render_template('html/posty.html', post=post, replies=replies, community_id=community_id, user = current_user)
    else:
        posts = get_posts(community_id)
        return render_template('html/feed.html', posts=posts, community_id=community_id, user = current_user)



@app.route('/add_post', methods=['POST'])
@login_required
def add_post():
    community_id = request.form['community_id']
    parent_post_id = request.form.get('parent_post_id')
    title = request.form['title']
    content = request.form['content']
    user_id = current_user.data['id_czlonka']

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute('SELECT make_post(%s, %s, %s, %s, %s)', (parent_post_id, community_id, user_id, title, content))
        conn.commit()
        flash('Post created successfully!', 'success')
    except Exception as e:
        conn.rollback()
        flash(str(e), 'danger')

    cur.close()
    conn.close()

    if parent_post_id:
        return redirect(url_for('feed', community_id=community_id, post_id=parent_post_id))
    else:
        return redirect(url_for('feed', community_id=community_id))

@app.route('/register_talk', methods=['GET', 'POST'])
@login_required
def register_talk():
    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':
        speaker_id = request.form['speaker_id']
        edit = request.form['edit']
        room = request.form['room']
        talk_date = request.form['talk_date']
        talk_length = request.form['talk_length']
        subj = request.form['subj']
        descript = request.form['descript']

        cur.execute("""
            SELECT register_talk(%s, %s, %s, %s, %s, %s, %s);
        """, (speaker_id, edit, room, talk_date, talk_length, subj, descript))
        conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for('index'))

    cur.execute('SELECT id_sali, (select s.adres from adresy s where s.id_adresu = adres), nazwa FROM sale')
    rooms = cur.fetchall()
    
    cur.execute('SELECT id_prelegenta, imie, nazwisko FROM prelegenci')
    speakers = cur.fetchall()
    
    cur.execute('SELECT dlugosc_prelekcji, dlugosc FROM dlugosci')
    lengths = cur.fetchall()

    cur.close()
    conn.close()
    
    return render_template('html/register_talk.html', rooms=rooms, speakers=speakers, lengths=lengths, user = current_user)

@app.route('/add_speaker', methods=['GET', 'POST'])
@login_required
def add_speaker():
    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':
        speaker_id = request.form['speaker_id']
        talk_id = request.form['talk_id']

        cur.execute("""
            SELECT add_to_talk(%s, %s);
        """, (speaker_id, talk_id))
        conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for('index'))

    cur.execute('SELECT id_prelegenta, imie, nazwisko FROM prelegenci')
    speakers = cur.fetchall()
    
    cur.execute('SELECT id_prelekcji, temat FROM prelekcje')
    talks = cur.fetchall()

    cur.close()
    conn.close()
    
    return render_template('html/add_speaker.html', speakers=speakers, talks=talks, user = current_user)



@app.route('/admin_panel', methods=['GET', 'POST'])
@login_required
def admin_panel():
    if request.method == 'POST':
        edit_id = request.form['edit_id']
        badge_type = request.form['badge_type']
        badges = generate_badges(edit_id, badge_type)
        return render_template('html/badges.html', badges=badges)

    return render_template('html/admin_panel.html', user = current_user)

def generate_badges(edit_id, badge_type):
    conn = get_db_connection()
    cur = conn.cursor()

    if badge_type == 'attendees':
        cur.execute("SELECT * FROM generate_attendee_badges(%s)", (edit_id,))
    elif badge_type == 'volunteers':
        cur.execute("SELECT * FROM generate_volonteer_badges(%s)", (edit_id,))
    elif badge_type == 'organisers':
        cur.execute("SELECT * FROM generate_organiser_badges(%s)", (edit_id,))
    elif badge_type == 'speakers':
        cur.execute("SELECT * FROM generate_speaker_badges(%s)", (edit_id,))

    badges = cur.fetchall()
    cur.close()
    conn.close()

    return badges



def get_editions(member_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT * FROM get_editions(%s)', (member_id,))
    editions = cur.fetchall()
    

    cur.close()
    conn.close()
    
    return editions

def get_edition_details(edition_id):
    conn = get_db_connection()
    cur = conn.cursor()
    
    query = """
    SELECT e.nr_edycji, w.nazwa, e.data_rozpoczecia, e.data_zakonczenia 
    FROM edycje e 
    JOIN wydarzenia w ON w.id_wydarzenia = e.id_wydarzenia 
    WHERE e.id_edycji = %s
    """
    cur.execute(query, (edition_id,))
    edition_details = cur.fetchone()
    
    cur.close()
    conn.close()
    
    return edition_details

def get_timetable(edition_id, event_date):
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute('SELECT * FROM get_timestable(%s, %s)', (edition_id, event_date))
    timetable = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return timetable

@app.route('/events')
@login_required
def events():
    edition_id = request.args.get('edition_id')
    
    if edition_id:
        try:
            edition_id = int(edition_id)
        except ValueError:
            return "Invalid Edition ID", 400
        
        edition_details = get_edition_details(edition_id)
        if not edition_details:
            return "Edition not found", 404
        
        start_date, end_date = edition_details[2], edition_details[3]
        current_date = start_date
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT EXISTS(SELECT 1 FROM wolontariusze WHERE id_edycji = %s and id_czlonka = %s)", (edition_id, current_user.data["id_czlonka"]))
        is_volunteer = cur.fetchone()[0]

        timetable = {}
        while current_date <= end_date:
            timetable[current_date] = get_timetable(edition_id, current_date)
            current_date += timedelta(days=1)
        
        return render_template('html/edition.html', edition_details=edition_details, timetable=timetable, edition_id=edition_id, user = current_user, is_volunteer = is_volunteer)
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
    conn = get_db_connection()
    cur = conn.cursor()
    if request.method == 'POST':
        id_spolecznosci = request.form["community_id"]
        user_id = current_user.get_id()
        cur.execute("INSERT INTO czlonkowie_spolecznosci(id_czlonka, id_spolecznosci, id_roli) values (%s, %s, 1)", (user_id, id_spolecznosci) )
        conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for('dashboard'))
    
    
    cur.execute("""SELECT id_spolecznosci, nazwa from spolecznosci""")
    spolecznosci = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('html/join_community.html', user=current_user, spolecznosci=spolecznosci)
    
if __name__ == '__main__':
    app.run(debug=True)
