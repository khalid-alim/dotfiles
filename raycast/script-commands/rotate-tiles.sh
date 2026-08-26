#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rotate Tiles
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Window
# @raycast.icon 🔄
# @raycast.description Flip the half-screen windows on this display: side-by-side <-> stacked

# Finds every window in a half of the display holding the focused window and
# flips it (left<->top, right<->bottom). Rectangle does the placement via its
# URL scheme, so frames match its own hotkeys. Pass --dry-run to only report.
/usr/bin/osascript -l JavaScript - "$@" <<'JXA'
ObjC.import('Cocoa');
function run(argv) {
  const dry = argv.indexOf('--dry-run') >= 0;
  const app = Application.currentApplication(); app.includeStandardAdditions = true;
  const se = Application('System Events');
  const T = 40, T2 = 70, ROT = { left: 'top', right: 'bottom', top: 'left', bottom: 'right' };
  const overlap = (a, b) => Math.max(0, Math.min(a.x + a.w, b.x + b.w) - Math.max(a.x, b.x)) * Math.max(0, Math.min(a.y + a.h, b.y + b.h) - Math.max(a.y, b.y));
  function classify(f, s) {
    const wHalf = Math.abs(f.w - s.w / 2) <= T2, hHalf = Math.abs(f.h - s.h / 2) <= T2;
    const fullH = f.h >= s.h * 0.8, fullW = f.w >= s.w * 0.8;
    if (fullH && wHalf && Math.abs(f.x - s.x) <= T) return 'left';
    if (fullH && wHalf && Math.abs(f.x + f.w - (s.x + s.w)) <= T) return 'right';
    if (fullW && hHalf && Math.abs(f.y - s.y) <= T + 40) return 'top';
    if (fullW && hHalf && Math.abs(f.y + f.h - (s.y + s.h)) <= T) return 'bottom';
    return null;
  }
  const nss = $.NSScreen.screens, primaryH = nss.objectAtIndex(0).frame.size.height, screens = [];
  for (let i = 0; i < nss.count; i++) { const f = nss.objectAtIndex(i).frame;
    screens.push({ x: f.origin.x, y: primaryH - (f.origin.y + f.size.height), w: f.size.width, h: f.size.height }); }
  const front = se.processes.whose({ frontmost: true })()[0];
  let ff; try { const p = front.windows[0].position(), s = front.windows[0].size(); ff = { x: p[0], y: p[1], w: s[0], h: s[1] }; } catch (e) { return 'No focused window'; }
  let screen = null, best = 0; for (const s of screens) { const a = overlap(ff, s); if (a > best) { best = a; screen = s; } }
  if (!screen) return 'No screen';
  const plan = [];
  for (const p of se.processes.whose({ backgroundOnly: false })()) {
    let pos, sz, sub, pname; try { pname = p.name(); pos = p.windows.position(); sz = p.windows.size(); sub = p.windows.subrole(); } catch (e) { continue; }
    for (let j = 0; j < pos.length; j++) {
      if (sub[j] !== 'AXStandardWindow') continue;
      const f = { x: pos[j][0], y: pos[j][1], w: sz[j][0], h: sz[j][1] };
      if (overlap(f, screen) <= f.w * f.h * 0.5) continue;
      const half = classify(f, screen); if (!half) continue;
      let minimized = false; try { minimized = p.windows[j].attributes.byName('AXMinimized').value(); } catch (e) {}
      if (minimized) continue;
      const isFront = pname === front.name() && Math.abs(f.x - ff.x) < 2 && Math.abs(f.y - ff.y) < 2 && Math.abs(f.w - ff.w) < 2 && Math.abs(f.h - ff.h) < 2;
      plan.push({ p, pname, f, half, isFront });
    }
  }
  if (!plan.length) return 'No half-screen windows on this display';
  plan.sort((a, b) => (a.isFront ? 1 : 0) - (b.isFront ? 1 : 0));
  const summary = plan.map(e => `${e.pname}: ${e.half}→${ROT[e.half]}`).join(', ');
  if (dry) return 'Would rotate ' + plan.length + ': ' + summary;
  let done = 0;
  for (const e of plan) {
    const pos = e.p.windows.position(), sz = e.p.windows.size();
    const j = pos.findIndex((q, k) => Math.abs(q[0] - e.f.x) < 2 && Math.abs(q[1] - e.f.y) < 2 && Math.abs(sz[k][0] - e.f.w) < 2 && Math.abs(sz[k][1] - e.f.h) < 2);
    if (j < 0) continue;
    try { e.p.windows[j].actions.byName('AXRaise').perform(); } catch (err) {}
    e.p.frontmost = true; delay(0.25);
    app.openLocation('rectangle://execute-action?name=' + ROT[e.half] + '-half'); delay(0.45); done++;
  }
  try { front.frontmost = true; } catch (e) {}
  return 'Rotated ' + done + ': ' + summary;
}
JXA
