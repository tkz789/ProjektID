from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired, Length, Email, EqualTo

class RegistrationForm(FlaskForm):
    username = StringField('Login', validators=[DataRequired(), Length(min=2, max=30)])
    email = StringField('Email', validators=[DataRequired(), Email()])
    imie = StringField('Imię', validators=[DataRequired()])
    nazwisko = StringField('Nazwisko', validators=[DataRequired()])
    password = PasswordField('Hasło', validators=[DataRequired()])
    confirm_password = PasswordField('Potwierdź hasło', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Zarejestruj się!')

class LoginForm(FlaskForm):
    username = StringField('Login', validators=[DataRequired(), Length(min=6, max=30)])
    password = PasswordField('Hasło', validators=[DataRequired()])
    remember = BooleanField('Pamiętaj mnie! :3')
    submit = SubmitField('Zaloguj')