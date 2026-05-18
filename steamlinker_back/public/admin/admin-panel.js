// Extensiones del panel admin conectadas al backend Steamlinker

(function patchAdminPanel() {
  const origLoadDashboard = window.loadDashboard;
  const origFilterUsuarios = window.filterUsuarios;
  const origRenderUsuarios = window.renderUsuarios;
  const origRenderReportes = window.renderReportes;
  const origRenderSolicitudes = window.renderSolicitudes;
  const origRenderContenido = window.renderContenido;
  const origDoLogin = window.doLogin;

  window.loadDashboard = async function loadDashboardPatched() {
    try {
      const stats = await api('GET', ENDPOINTS.stats());
      if (stats) {
        const s = stats.data || stats;
        const set = (id, v) => {
          const el = document.getElementById(id);
          if (el) el.textContent = v != null ? Number(v).toLocaleString('es-CO') : '—';
        };
        set('st-usuarios', s.totalUsuarios);
        set('st-familias', s.familiasFormadas);
        set('st-solicitudes', s.solicitudesPendientes);
        set('st-reportes', s.reportesPendientes);
        set('st-publicaciones', s.totalPublicaciones);
      }
    } catch (e) {
      /* stats opcionales */
    }

    try {
      const res = await api('GET', ENDPOINTS.usuarios());
      const lista = (Array.isArray(res) ? res : []).slice(0, 5);
      const el = document.getElementById('dash-usuarios-list');
      if (!lista.length) {
        el.innerHTML = '<div class="empty"><p>Sin usuarios</p></div>';
        return;
      }
      el.innerHTML = `<table><thead><tr><th>Usuario</th><th>Email</th><th>Nivel</th><th>Estado</th></tr></thead><tbody>${lista
        .map((u) => {
          const name = u.username_usu || '—';
          const email = u.email_usu || '—';
          const nivel = u.repu_usu != null ? `★ ${Number(u.repu_usu).toFixed(1)}` : '—';
          const estado = u.baneado_usu ? 'baneado' : 'activo';
          return `<tr>
            <td>${name}</td>
            <td class="mono">${email}</td>
            <td>${nivel}</td>
            <td>${statusBadge(estado)}</td>
          </tr>`;
        })
        .join('')}</tbody></table>`;
    } catch (e) {
      document.getElementById('dash-usuarios-list').innerHTML =
        `<div class="empty"><p>No se pudo cargar usuarios. ${e.message}</p></div>`;
    }

    document.getElementById('dash-activity').innerHTML = `
      <div class="activity-item"><div class="activity-dot blue"></div><div class="activity-text">Panel conectado a <span>${BASE_URL}</span></div><div class="activity-time">ahora</div></div>
      <div class="activity-item"><div class="activity-dot green"></div><div class="activity-text">Rutas admin bajo <span>${ROUTE_PREFIX}</span></div><div class="activity-time">ahora</div></div>
    `;
  };

  window.filterUsuarios = function filterUsuariosPatched() {
    const q = (document.getElementById('usuarios-search')?.value || '').toLowerCase();
    const st = document.getElementById('usuarios-status')?.value || '';
    filtered.usuarios = data.usuarios.filter((u) => {
      const name = (u.username_usu || '').toLowerCase();
      const email = (u.email_usu || '').toLowerCase();
      const steam = (u.steam_id || '').toLowerCase();
      const pais = (u.pais_usu || '').toLowerCase();
      const matchQ = !q || name.includes(q) || email.includes(q) || steam.includes(q) || pais.includes(q);
      const tipo = (u.tipo_usu || 'usuario').toLowerCase();
      const baneado = u.baneado_usu === true;
      let matchSt = true;
      if (st === 'admin' || st === 'usuario') matchSt = tipo === st;
      if (st === 'baneado') matchSt = baneado;
      if (st === 'activo') matchSt = !baneado;
      return matchQ && matchSt;
    });
    pages.usuarios = 1;
    renderUsuarios();
  };

  window.renderUsuarios = function renderUsuariosPatched() {
    const items = renderPagination('usuarios', 'usuarios', renderUsuarios);
    if (!items.length) {
      document.getElementById('usuarios-tbody').innerHTML =
        '<tr><td colspan="8"><div class="empty"><p>No se encontraron usuarios</p></div></td></tr>';
      return;
    }
    document.getElementById('usuarios-tbody').innerHTML = items
      .map((u) => {
        const id = u.id_usu;
        const name = u.username_usu || '—';
        const email = u.email_usu || '—';
        const nivel = u.repu_usu != null ? Number(u.repu_usu).toFixed(1) : '0';
        const familias = u.familias_aceptadas ?? 0;
        const tipo = (u.tipo_usu || 'usuario').toLowerCase();
        const fecha = u.creadoen_usu;
        const baneado = u.baneado_usu === true;
        const esAdmin = tipo === 'admin';
        const estado = baneado ? 'baneado' : 'activo';
        const acciones = esAdmin
          ? '<span class="mono" style="color:var(--t3)">admin</span>'
          : baneado
            ? `<button class="btn btn-green btn-sm" onclick="accionUsuario('unban',${id},'${name.replace(/'/g, "\\'")}')">Desbanear</button>`
            : `<button class="btn btn-yellow btn-sm" onclick="accionUsuario('ban',${id},'${name.replace(/'/g, "\\'")}')">Banear</button>`;
        return `<tr>
          <td><div class="user-cell"><div class="avatar-txt">${initials(name)}</div><div><div>${name}</div><div class="mono" style="font-size:10px;">#${id}${u.steam_id ? ' · Steam' : ''}</div></div></div></td>
          <td class="mono">${email}</td>
          <td>★ ${nivel} <span class="mono" style="color:var(--t3)">(${u.totalrating_usu || 0})</span></td>
          <td>${familias}</td>
          <td>${statusBadge(estado)}</td>
          <td>${statusBadge(tipo)}</td>
          <td class="mono">${fmtDate(fecha)}</td>
          <td>${acciones}</td>
        </tr>`;
      })
      .join('');
  };

  window.renderReportes = function renderReportesPatched() {
    const items = renderPagination('reportes', 'reportes', renderReportes);
    if (!items.length) {
      document.getElementById('reportes-tbody').innerHTML =
        '<tr><td colspan="6"><div class="empty"><p>No se encontraron reportes</p></div></td></tr>';
      return;
    }
    document.getElementById('reportes-tbody').innerHTML = items
      .map((r) => {
        const id = r.id_repor;
        const rep = r.reportado || '—';
        const by = r.reportador || '—';
        const motivo = r.motivo_repor || '—';
        const estado = r.estado_repor || '—';
        const fecha = r.creadoen_repor;
        const pendiente = String(estado).toLowerCase() === 'pendiente' || String(estado).toLowerCase() === 'abierto';
        const acciones = pendiente
          ? `<button class="btn btn-green btn-sm" onclick="accionReporte('resuelto',${id})">Resolver</button>
             <button class="btn btn-ghost btn-sm" onclick="accionReporte('descartado',${id})">Descartar</button>`
          : '<span class="mono" style="color:var(--t3)">—</span>';
        return `<tr>
          <td><div class="user-cell"><div class="avatar-txt">${initials(rep)}</div>${rep}</div></td>
          <td>${by}</td>
          <td style="max-width:200px;">${truncate(motivo, 50)}</td>
          <td>${statusBadge(estado)}</td>
          <td class="mono">${fmtDateTime(fecha)}</td>
          <td><div style="display:flex;gap:6px;flex-wrap:wrap;">${acciones}</div></td>
        </tr>`;
      })
      .join('');
  };

  window.renderSolicitudes = function renderSolicitudesPatched() {
    const items = renderPagination('solicitudes', 'solicitudes', renderSolicitudes);
    if (!items.length) {
      document.getElementById('solicitudes-tbody').innerHTML =
        '<tr><td colspan="5"><div class="empty"><p>No hay solicitudes pendientes</p></div></td></tr>';
      return;
    }
    document.getElementById('solicitudes-tbody').innerHTML = items
      .map((s) => {
        const id = s.id_match || '?';
        const sol = s.solicitante || '—';
        const rec = s.receptor || '—';
        const estado = s.estado_match || '—';
        const fecha = s.creadoen_match;
        return `<tr>
          <td><span class="mono">#${id}</span></td>
          <td>${sol}</td>
          <td>${rec}</td>
          <td>${statusBadge(estado)}</td>
          <td class="mono">${fmtDate(fecha)}</td>
        </tr>`;
      })
      .join('');
  };

  window.renderContenido = function renderContenidoPatched() {
    const items = renderPagination('contenido', 'contenido', renderContenido);
    if (!items.length) {
      document.getElementById('contenido-tbody').innerHTML =
        '<tr><td colspan="6"><div class="empty"><p>No hay contenido</p></div></td></tr>';
      return;
    }
    document.getElementById('contenido-tbody').innerHTML = items
      .map((c) => {
        const id = c.id_publi;
        const titulo = c.titulo_publi || '—';
        const tipo = c.tipo_publi || '—';
        const activa = c.estado_publi === true || c.estado_publi === 'true';
        const estadoLabel = activa ? 'activa' : 'cerrada';
        const autor = c.username_usu || '—';
        const fecha = c.creadoen_publi;
        const acciones = activa
          ? `<button class="btn btn-red btn-sm" onclick="accionContenido('cerrar',${id})">Cerrar</button>`
          : `<button class="btn btn-green btn-sm" onclick="accionContenido('reabrir',${id})">Reabrir</button>`;
        return `<tr>
          <td>${statusBadge(tipo)}</td>
          <td>${autor}</td>
          <td style="max-width:220px;">${truncate(titulo, 60)}</td>
          <td>${statusBadge(estadoLabel)}</td>
          <td class="mono">${fmtDate(fecha)}</td>
          <td>${acciones}</td>
        </tr>`;
      })
      .join('');
  };

  const origAccionContenido = window.accionContenido;
  window.accionContenido = async function accionContenidoPatched(estado, id) {
    if (estado === 'cerrar' || estado === 'reabrir') {
      try {
        await api('PUT', ENDPOINTS.contenidoItem(id), {
          estado_publi: estado === 'reabrir',
        });
        toast(estado === 'cerrar' ? 'Publicación cerrada' : 'Publicación reabierta', 'ok');
        loadContenido();
      } catch (e) {
        toast(e.message, 'err');
      }
      return;
    }
    if (origAccionContenido) return origAccionContenido(estado, id);
  };

  window.doLogin = async function doLoginPatched() {
    const email = document.getElementById('login-email').value.trim();
    const pass = document.getElementById('login-pass').value;
    const url = document.getElementById('login-url').value.trim();
    const errEl = document.getElementById('login-error');
    const btn = document.getElementById('login-btn');

    if (!email || !pass) {
      errEl.textContent = 'Completa todos los campos.';
      return;
    }

    if (url) {
      BASE_URL = url;
      localStorage.setItem('sl_base_url', url);
    }

    btn.disabled = true;
    btn.textContent = 'Iniciando sesión…';
    errEl.textContent = '';

    try {
      const res = await fetch(ENDPOINTS.login(), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password: pass }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.message || json.error || 'Credenciales incorrectas');

      token = json.token || json.access_token;
      if (!token) throw new Error('No se recibió token.');

      adminUser = json.usuario || json.user || {};
      const tipo = String(adminUser.tipo || adminUser.tipo_usu || '').toLowerCase();
      if (tipo !== 'admin') {
        throw new Error('Esta cuenta no tiene permisos de administrador.');
      }

      localStorage.setItem('sl_token', token);
      localStorage.setItem('sl_admin', JSON.stringify(adminUser));

      document.getElementById('login-screen').style.display = 'none';
      document.getElementById('app').classList.add('visible');

      const name = adminUser.username || adminUser.email || 'Admin';
      document.getElementById('s-name').textContent = name;
      document.getElementById('s-avatar').textContent = name[0].toUpperCase();

      nav('dashboard');
    } catch (e) {
      errEl.textContent = e.message;
    } finally {
      btn.disabled = false;
      btn.textContent = 'Iniciar sesión';
    }
  };

  window.filterReportes = function filterReportesPatched() {
    const q = (document.getElementById('reportes-search')?.value || '').toLowerCase();
    const st = document.getElementById('reportes-status')?.value || '';
    filtered.reportes = data.reportes.filter((r) => {
      const rep = (r.reportado || '').toLowerCase();
      const repor = (r.reportador || '').toLowerCase();
      const mot = (r.motivo_repor || '').toLowerCase();
      const estado = (r.estado_repor || '').toLowerCase();
      const matchQ = !q || rep.includes(q) || repor.includes(q) || mot.includes(q);
      let matchSt = true;
      if (st === 'abierto') matchSt = estado === 'pendiente' || estado === 'abierto';
      else if (st) matchSt = estado === st;
      return matchQ && matchSt;
    });
    pages.reportes = 1;
    renderReportes();
  };

  console.info('[Steamlinker Admin] Panel conectado al backend.');
})();
