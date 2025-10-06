// app.js
const express = require('express');
const { createDatabase } = require('./db');
const { getUserByName_vulnerable } = require('./vulnerable');

const app = express();
app.use(express.json());

let dbInstance = null;
createDatabase((db) => { dbInstance = db; });

// Endpoint demo: /user?name=...
app.get('/user', async (req, res) => {
  const name = req.query.name || '';
  try {
    const rows = await getUserByName_vulnerable(dbInstance, name);
    res.json({ rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// sólo si se ejecuta directamente
if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`Listening on ${port}`));
}

module.exports = app;
