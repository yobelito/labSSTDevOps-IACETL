// vulnerable.js
// Funciones demo: una vulnerable y otra segura (comentada) para comparación.

function getUserByName_vulnerable(db, name) {
  // ¡VULNERABLE! construye la consulta concatenando sin sanitizar -> SQL Injection
  const sql = "SELECT id, name, role FROM users WHERE name = '" + name + "'";
  return new Promise((resolve, reject) => {
    db.all(sql, (err, rows) => {
      if (err) return reject(err);
      resolve(rows);
    });
  });
}

/*
function getUserByName_safe(db, name) {
  // SAFE: uso de parámetros para evitar inyección
  const sql = "SELECT id, name, role FROM users WHERE name = ?";
  return new Promise((resolve, reject) => {
    db.all(sql, [name], (err, rows) => {
      if (err) return reject(err);
      resolve(rows);
    });
  });
}
*/

module.exports = { getUserByName_vulnerable };
