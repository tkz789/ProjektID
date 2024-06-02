from flask import Flask, render_template, request, redirect, url_for, abort, jsonify, flash
# from flask_sqlalchemy import SQLAlchemy
import psycopg2
from psycopg2.extras import RealDictCursor
import sys
import os
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from forms import RegistrationForm, LoginForm
from datetime import date

app = Flask(__name__)

app.secret_key = "haszcze_W_kleszczach"
# app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql+psycopg2:///{os.getlogin()}?host=/var/run/postgresql'
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# db = SQLAlchemy(app)
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
# class User(UserMixin, db.Model):
#     __tablename__ = 'czlonkowie'
#     id = db.Column('id_czlonka', db.Integer, primary_key=True)
#     id_zaimka = db.Column(db.Integer)
#     nazwa_uzytkownika = db.Column(db.String(30), unique=True, nullable=False)
#     email = db.Column(db.String(100), unique=True, nullable=False)
#     imie = db.Column(db.String(30), nullable=False)
#     nazwisko = db.Column(db.String(150), nullable=False)
#     newsletter = db.Column(db.Boolean)
#     data_dolaczenia = db.Column(db.Date, nullable=False)
#     password_hash = db.Column(db.String(128), nullable=False)
    

#     def set_password(self, password):
#         self.password_hash = generate_password_hash(password)

#     def check_password(self, password):
#         return check_password_hash(self.password_hash, password)

@login_manager.user_loader
def load_user(user_id):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
    user = None
    try:
        cur.execute("SELECT * from czlonkowie where id_czlonka = %s", (user_id,))
        user = cur.fetchone()
        conn.commit()
    except:
        conn.rollback()
    
    return user

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
    return render_template('html/aboutus.html')

@app.route("/home")
def home():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT nazwa from spolecznosci")
    spolecznosci = cur.fetchall()
    conn.commit()
    return render_template('html/index.html', spolecznosci=spolecznosci)

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
    return render_template('html/register.html', form=form)

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
        if user and check_password_hash(user.data['haslo_hash'], form.password.data):
            # flash('To działa', 'danger')
            login_user(user, remember=form.remember.data)
            return redirect(url_for('dashboard'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'success')
    return render_template('html/login.html', form=form)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    return f'Hello, {current_user.nazwa_uzytkownika}!'


@app.route('/get_statistics', methods=['GET'])
def get_statistics():
    conn = get_db_connection()
    if conn is None:
        abort(500, description="Nieudane połączenie z bazą danych.")
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute('''
                SELECT 
                    e.nr_edycji, 
                    w.nazwa, 
                    count_participants(e.id_edycji) as count_participants 
                FROM edycje e join wydarzenia w on e.id_wydarzenia = w.id_wydarzenia;
            ''')
            data = cur.fetchall()
            return jsonify(data)
    except Exception as e:
        print(f"Error fetching statistics: {e}")
        abort(500, description="Nieudane pobieranie statystyk.")
    finally:
        conn.close()

@app.route('/register_talk', methods=['GET', 'POST'])
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

    cur.execute('SELECT id_sali, adres, nazwa FROM sale')
    rooms = cur.fetchall()
    
    cur.execute('SELECT id_prelegenta, imie, nazwisko FROM prelegenci')
    speakers = cur.fetchall()
    
    cur.execute('SELECT dlugosc_prelekcji, dlugosc FROM dlugosci')
    lengths = cur.fetchall()

    cur.close()
    conn.close()
    
    return render_template('html/register_talk.html', rooms=rooms, speakers=speakers, lengths=lengths)

@app.route('/add_speaker', methods=['GET', 'POST'])
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
    
    return render_template('html/add_speaker.html', speakers=speakers, talks=talks)



@app.route('/admin_panel', methods=['GET', 'POST'])
def admin_panel():
    if request.method == 'POST':
        edit_id = request.form['edit_id']
        badge_type = request.form['badge_type']
        badges = generate_badges(edit_id, badge_type)
        return render_template('html/badges.html', badges=badges)

    return render_template('html/admin_panel.html')

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
    
if __name__ == '__main__':
    app.run(debug=True)
