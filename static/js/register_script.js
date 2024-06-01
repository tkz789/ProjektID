
const { Pool } = require('pg');
//pronoum jako wybór z listy
const pool = new Pool({
  user: 'your_username',
  host: 'your_host',
  database: 'your_database',
  password: 'your_password',
  port: 5432,
});
const form = document.getElementById('register-form');
      const username = document.getElementById('username');
      const email = document.getElementById('email');
      const name = document.getElementById('name');
      const surname = document.getElementById('surname');
      const password = document.getElementById('password');
      const pronoun = document.getElementById('pronoun');
      const error = document.getElementById('error');

      form.addEventListener('submit', async (e) => {
        e.preventDefault();

        error.textContent = '';

        const result = await register(
          username.value,
          email.value,
          name.value,
          surname.value,
          password.value,
          pronoun.value
        );

        if (result) {
          console.log('Registration successful');
          form.reset();
        } else {
          error.textContent = 'Registration failed. Please try again.';
        }
      });

      async function register(username, email, name, surname, password, pronoun_id) {
        try {
          const result = await pool.query(
            'SELECT register($1, $2, $3, $4, $5, $6, $7)',
            [username, email, name, surname, password, pronoun_id, true]
          );

          if (result.rows[0].register) {
            return true;
          } else {
            return false;
          }
        } catch (err) {
          console.error(err.message);
          error.textContent = err.message;
          return false;
        }
      }

    