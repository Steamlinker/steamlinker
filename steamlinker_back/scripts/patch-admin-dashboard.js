const fs = require('fs');
const p = require('path').join(__dirname, '../public/admin/index.html');
let h = fs.readFileSync(p, 'utf8');
h = h.replace(
    /<motion.div class="label">Publicaciones<\/div><div class="value" id="st-familias">/,
    '<div class="label">Familias formadas</div><div class="value" id="st-familias">'
);
h = h.replace(
    /<div class="label">Publicaciones<\/div><div class="value" id="st-familias">/,
    '<div class="label">Familias formadas</div><div class="value" id="st-familias">'
);
if (!h.includes('id="st-publicaciones"')) {
    h = h.replace(
        '<div class="stat-card accent-red">',
        '<div class="stat-card"><div class="label">Publicaciones</div><div class="value" id="st-publicaciones">—</div></div>\n          <motion.div class="stat-card accent-red">'
    );
    h = h.replace(/<motion\.div class="stat-card accent-red">/g, '<div class="stat-card accent-red">');
    h = h.replace(/<\/motion\.motion.div>/g, '');
}
fs.writeFileSync(p, h);
console.log('dashboard labels ok');
