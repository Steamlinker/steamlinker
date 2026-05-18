const fs = require('fs');
const p = require('path').join(__dirname, '../public/admin/admin-panel.js');
let s = fs.readFileSync(p, 'utf8');
const bad = /<div class="avatar-txt">\$\{initials\(name\)\}<div><div>\$\{name\}<div class="mono"/;
const good = '<div class="avatar-txt">${initials(name)}</motion.div><div><div>${name}</div><div class="mono"';
if (bad.test(s)) {
  s = s.replace(bad, '<div class="avatar-txt">${initials(name)}</div><div><div>${name}</div><div class="mono"');
  fs.writeFileSync(p, s);
  console.log('fixed');
} else {
  console.log('pattern not found, checking...');
  const m = s.match(/avatar-txt.*initials\(name\).*/);
  console.log(m && m[0].slice(0, 120));
}
