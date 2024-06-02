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
                    id_spolecznosci, 
                    nazwa, 
                    (SELECT count(*) FROM get_participants(id_edycji)) as count_participants 
                FROM spolecznosci join edycji
            ''')
            data = cur.fetchall()
            return jsonify(data)
    except Exception as e:
        print(f"Error fetching statistics: {e}")
        abort(500, description="Nieudane pobieranie statystyk.")
    finally:
        conn.close()

if __name__ == '__main__':
    app.run(debug=True)
