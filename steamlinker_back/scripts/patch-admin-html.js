const fs = require('fs');
const path = require('path');

const file = path.join(__dirname, '../public/admin/index.html');
let html = fs.readFileSync(file, 'utf8');

html = html.replace(
    /<div class="label">Publicaciones<\/motion.div><div class="value" id="st-familias">[^<]*<\/div><div class="change" id="st-familias-c"><\/motion.div><\/motion.div>/,
    '<div class="label">Familias formadas</div><motion.div class="value" id="st-familias">—</div></div><div class="stat-card"><div class="label">Publicaciones</div><div class="value" id="st-publicaciones">—</div></div>'
);

// Fix if file has wrong chars for em dash
html = html.replace(
    /<div class="label">Publicaciones<\/div><div class="value" id="st-familias">[^<]*<\/motion.div><div class="change" id="st-familias-c"><\/div><\/div>/,
    '<div class="label">Familias formadas</div><div class="value" id="st-familias">—</div></div>\n          <div class="stat-card"><div class="label">Publicaciones</div><div class="value" id="st-publicaciones">—</div></div>'
);

html = html.replace(
    'const ENDPOINTS = {\n  login:         () => `${BASE_URL}/auth/login`,\n  stats:         () => `${BASE_URL}${ROUTE_PREFIX}/estadisticas`,\n  usuarios:      () => `${BASE_URL}${ROUTE_PREFIX}/usuarios`,\n  familias:      () => `${BASE_URL}${ROUTE_PREFIX}/familias`,\n  solicitudes:   () => `${BASE_URL}${ROUTE_PREFIX}/solicitudes`,\n  reportes:      () => `${BASE_URL}${ROUTE_PREFIX}/reportes`,\n  contenido:     () => `${BASE_URL}${ROUTE_PREFIX}/contenido`,\n};',
    `const ENDPOINTS = {
  login:         () => \`\${BASE_URL}/auth/login\`,
  stats:         () => \`\${BASE_URL}\${ROUTE_PREFIX}/estadisticas\`,
  usuarios:      () => \`\${BASE_URL}\${ROUTE_PREFIX}/usuarios\`,
  usuario:       (id) => \`\${BASE_URL}\${ROUTE_PREFIX}/usuarios/\${id}\`,
  banUsuario:    (id) => \`\${BASE_URL}\${ROUTE_PREFIX}/usuarios/\${id}/ban\`,
  unbanUsuario:  (id) => \`\${BASE_URL}\${ROUTE_PREFIX}/usuarios/\${id}/unban\`,
  familias:      () => \`\${BASE_URL}\${ROUTE_PREFIX}/familias\`,
  solicitudes:   () => \`\${BASE_URL}\${ROUTE_PREFIX}/solicitudes\`,
  reportes:      () => \`\${BASE_URL}\${ROUTE_PREFIX}/reportes\`,
  reporte:       (id) => \`\${BASE_URL}\${ROUTE_PREFIX}/reportes/\${id}\`,
  contenido:     () => \`\${BASE_URL}\${ROUTE_PREFIX}/contenido\`,
  contenidoItem:(id) => \`\${BASE_URL}\${ROUTE_PREFIX}/contenido/\${id}\`,
};`
);

html = html.replace(
    '<th>Usuario</th><th>Email</th><th>País</th><th>Tipo</th><th>Registro</th><th>Rol</th>',
    '<th>Usuario</th><th>Email</th><th>Nivel</th><th>Familias</th><th>Estado</th><th>Tipo</th><th>Registro</th><th>Acciones</th>'
);

html = html.replace(
    '<option value="admin">Admin</option>\n              </select>',
    `<option value="admin">Admin</option>
                <option value="baneado">Baneados</option>
                <option value="activo">Activos</option>
              </select>`
);

html = html.replace(
    '<th>Reportado</th><th>Reportador</th><th>Motivo</th><th>Estado</th><th>Fecha</th><th>#</th>',
    '<th>Reportado</th><th>Reportador</th><th>Motivo</th><th>Estado</th><th>Fecha</th><th>Acciones</th>'
);

html = html.replace(
    '<th># Match</th><th>Estado</th><th>Fecha</th>',
    '<th>#</th><th>Solicitante</th><th>Receptor</th><th>Estado</th><th>Fecha</th>'
);

html = html.replace(
    '<th>Tipo</th><th>Autor</th><th>Título</th><th>Estado</th><th>Fecha</th><th>#</th>',
    '<th>Tipo</th><th>Autor</th><th>Título</th><th>Estado</th><th>Fecha</th><th>Acciones</th>'
);

if (!html.includes('admin-panel.js')) {
    html = html.replace('</body>', '  <script src="admin-panel.js"></script>\n</body>');
}

fs.writeFileSync(file, html, 'utf8');
console.log('Patched', file);
