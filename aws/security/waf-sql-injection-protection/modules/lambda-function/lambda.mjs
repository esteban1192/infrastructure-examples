import sqlite3 from 'sqlite3';

const initializeDatabase = () => 
  new sqlite3.Database(':memory:', (err) => {
    if (err) console.error("Error opening database:", err.message);
  });

const setupDatabase = (db) => 
  new Promise((resolve, reject) => {
    db.serialize(() => {
      db.run("CREATE TABLE IF NOT EXISTS users (id INT PRIMARY KEY, name TEXT)");
      db.run(`CREATE TABLE IF NOT EXISTS sensitive_data (
        user_id INT,
        ssn TEXT,
        account_balance REAL,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )`);

      const users = Array.from({ length: 20 }, (_, i) => [i + 1, String.fromCharCode(65 + i)]);
      const stmtUsers = db.prepare("INSERT INTO users VALUES (?, ?)");
      users.forEach(user => stmtUsers.run(user));
      stmtUsers.finalize();

      const stmtSensitive = db.prepare("INSERT INTO sensitive_data VALUES (?, ?, ?)");
      users.forEach(user => stmtSensitive.run(user[0], `${user[0]}-SSN`, user[0] * 100));
      stmtSensitive.finalize(err => (err ? reject(err) : resolve()));
    });
  });

const getUser = (db, id) => 
  new Promise((resolve, reject) => {
    db.all(`SELECT * FROM users WHERE id = ${id}`, (err, row) => {
      err ? reject({ error: 'SQL Error' }) : resolve(row.length ? { user: row } : { error: 'User not found' });
    });
  });

export const handler = async (event) => {
  console.log(JSON.stringify(event))
  const db = initializeDatabase();
  try {
    await setupDatabase(db);
    const { id } = JSON.parse(event.body);
    const response = await getUser(db, id);
    return { statusCode: 200, body: JSON.stringify(response) };
  } catch (error) {
    console.error(error);
    return { statusCode: 500, body: JSON.stringify({ error: 'Failed to process the request' }) };
  } finally {
    db.close();
  }
};
