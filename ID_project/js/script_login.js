const { Pool } = require('pg');

const pool = new Pool({
  user: 'your_username',
  host: 'your_host',
  database: 'your_database',
  password: 'your_password',
  port: 5432,
});
const functionName = 'login';

const form = document.getElementById('login-form');
const errorMessage = document.getElementById('error-message');

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;

  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
  if (!passwordRegex.test(password)) {
    errorMessage.textContent = 'Password must be at least 8 characters long, contain at least one lowercase letter, one uppercase letter, one digit, and one special character';
    return;
  }

  try {
    const result = await pool.query('SELECT * FROM login($1, $2)', [username, password]);
    if (result.rows.length === 0) {
      errorMessage.textContent = 'Invalid username or password';
    } else {
      window.location.href = "/html/mainweb.html";
    }
  } catch (err) {
    console.error(err);
    errorMessage.textContent = err;
  }
});