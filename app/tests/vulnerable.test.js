// tests/vulnerable.test.js
const request = require('supertest');
const app = require('../app');
const { createDatabase } = require('../db');
const { getUserByName_vulnerable } = require('../vulnerable');

let db;

beforeAll((done) => {
  createDatabase((d) => {
    db = d;
    done();
  });
});

afterAll((done) => {
  db.close(done);
});

test('getUserByName_vulnerable returns exact user for normal name', async () => {
  const rows = await getUserByName_vulnerable(db, "alice");
  expect(Array.isArray(rows)).toBe(true);
  expect(rows.length).toBe(1);
  expect(rows[0].name).toBe('alice');
});

test('getUserByName_vulnerable is vulnerable to SQL injection (demo exploit)', async () => {
  // payload que fuerza la cláusula OR para devolver múltiples filas (incl. admin)
  const injection = "x' OR '1'='1";
  const rows = await getUserByName_vulnerable(db, injection);

  // Esperamos que la vulnerabilidad permita devolver más de 0 filas.
  // En un sistema seguro, la consulta debería devolver 0 filas para 'x\' OR ...'
  expect(rows.length).toBeGreaterThan(1);
  // Comprobamos que uno de los roles es admin — demuestra impacto.
  const roles = rows.map(r => r.role);
  expect(roles).toContain('admin');
});

test('Optional: endpoint /user responds and demonstrates same behavior', async () => {
  const res = await request(app).get('/user').query({ name: "x' OR '1'='1" }).expect(200);
  expect(res.body.rows.length).toBeGreaterThan(1);
});
