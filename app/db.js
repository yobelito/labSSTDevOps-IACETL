// db.js
const sqlite3 = require('sqlite3');

function createDatabase(callback) {
  const db = new sqlite3.Database(':memory:');
  db.serialize(() => {
    db.run(`CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      role TEXT
    )`);
    const stmt = db.prepare("INSERT INTO users (name, role) VALUES (?, ?)");
    stmt.run("alice", "user");
    stmt.run("bob", "user");
    stmt.run("admin", "admin");
    stmt.finalize(() => callback(db));
  });
}

module.exports = { createDatabase };
