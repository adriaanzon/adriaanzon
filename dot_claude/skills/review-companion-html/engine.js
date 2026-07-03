/* Review Companion engine — plain vanilla JS, zero dependencies.
 *
 * Headless: ships no styling and imposes no layout. The authored page opts in
 * with data attributes; the engine flips STATE attributes (data-rc-done,
 * data-rc-active, data-rc-collapsed, data-rc-capped, …) that the page's own
 * CSS styles. render.py inlines this file via <!--rc:engine--> so the JS never
 * passes through the authoring session's context.
 *
 * Wiring (authored)              what the engine does
 *   [data-rc-root]               data-rc-key = localStorage scope,
 *                                data-rc-source recorded in the handoff JSON
 *   [data-rc-unit="id"]          a unit; name from data-rc-name or [data-rc-title]
 *   [data-rc-mark]               checkbox inside a unit — toggles done
 *   [data-rc-toggle]             header inside a unit — click toggles done
 *                                (clicks on links/controls and text selections ignored)
 *   [data-rc-nav="id"]           click scrolls to the unit; mirrors active/done state
 *   [data-rc-count] [data-rc-total]  meter text (done / registered units)
 *   [data-rc-bar]                style.width set to the done percentage
 *   [data-rc-band="id"]          collapsible section; data-rc-start-collapsed
 *                                seeds it collapsed on first visit
 *   [data-rc-band-toggle="id"]   click collapses/expands the band
 *   [data-handoff="key"]         field inside a unit (or wrapper of a radio/checkbox
 *                                group) — persisted and included in the handoff
 *   [data-rc-copy]               copies the handoff JSON; label flashes "Copied N units"
 *   pre[data-rc-fence]           gets data-rc-lines; >24 lines gets data-rc-capped,
 *                                click toggles data-rc-expanded
 *   [data-rc-markdown]           hidden markdown source; rendered with marked.js
 *                                if loaded, else shown as pre-wrap text
 */
(() => {
'use strict';

const boot = () => {
  const $ = (sel, el = document) => Array.from(el.querySelectorAll(sel));
  const root = document.querySelector('[data-rc-root]') || document.body;
  const KEY = root.getAttribute('data-rc-key') || 'rc-' + location.pathname;
  const SOURCE = root.getAttribute('data-rc-source') || KEY;

  // ---- persisted state: { units: {id: {done, fields}}, bands: {id: bool} } ----
  let state = { units: {}, bands: {} };
  try {
    const saved = JSON.parse(localStorage.getItem(KEY));
    if (saved && typeof saved === 'object') {
      state = { units: saved.units || {}, bands: saved.bands || {} };
    }
  } catch (e) {}
  const save = () => { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} };
  const entry = id => state.units[id] || (state.units[id] = { done: false, fields: {} });

  // ---- markdown blocks (first, so their fences get highlighted/capped below) ----
  $('[data-rc-markdown]').forEach(el => {
    if (window.marked) el.innerHTML = marked.parse(el.textContent);
    else el.style.whiteSpace = 'pre-wrap'; // offline fallback: readable raw text
    el.removeAttribute('hidden');
  });

  // ---- syntax highlighting (optional, if highlight.js is loaded) ----
  if (window.hljs) {
    $('pre code').forEach(c => { try { hljs.highlightElement(c); } catch (e) {} });
  }

  // ---- long-fence capping ----
  $('pre[data-rc-fence], [data-rc-markdown] pre').forEach(pre => {
    const code = pre.querySelector('code') || pre;
    const lines = code.textContent.replace(/\n+$/, '').split('\n').length;
    pre.setAttribute('data-rc-lines', lines);
    if (lines <= 24) return;
    pre.setAttribute('data-rc-capped', '');
    pre.addEventListener('click', () => {
      if (!getSelection().isCollapsed) return; // click-drag text selection shouldn't toggle
      pre.toggleAttribute('data-rc-expanded');
    });
  });

  // ---- units ----
  const unitEls = $('[data-rc-unit]');
  const units = unitEls.map(el => {
    const id = el.getAttribute('data-rc-unit');
    const titleEl = el.querySelector('[data-rc-title]');
    const name = (el.getAttribute('data-rc-name') || (titleEl && titleEl.textContent) || id).trim();
    entry(id);
    return { el, id, name };
  });
  let active = null;

  const setAttr = (el, attr, on) => on ? el.setAttribute(attr, '') : el.removeAttribute(attr);

  const render = () => {
    let count = 0;
    for (const u of units) {
      const done = !!entry(u.id).done;
      if (done) count++;
      setAttr(u.el, 'data-rc-done', done);
      $('[data-rc-mark]', u.el).forEach(box => { box.checked = done; });
    }
    $('[data-rc-nav]').forEach(a => {
      const id = a.getAttribute('data-rc-nav');
      setAttr(a, 'data-rc-done', !!(state.units[id] || {}).done);
      setAttr(a, 'data-rc-active', id === active);
    });
    $('[data-rc-count]').forEach(el => { el.textContent = count; });
    $('[data-rc-total]').forEach(el => { el.textContent = units.length; });
    const pct = units.length ? Math.round(100 * count / units.length) : 0;
    $('[data-rc-bar]').forEach(el => { el.style.width = pct + '%'; });
    $('[data-rc-band]').forEach(b =>
      setAttr(b, 'data-rc-collapsed', !!state.bands[b.getAttribute('data-rc-band')]));
    $('[data-rc-band-toggle]').forEach(t =>
      setAttr(t, 'data-rc-collapsed', !!state.bands[t.getAttribute('data-rc-band-toggle')]));
  };

  const setDone = (id, v) => { entry(id).done = !!v; save(); render(); };

  $('[data-rc-mark]').forEach(box => box.addEventListener('change', () => {
    const u = box.closest('[data-rc-unit]');
    if (u) setDone(u.getAttribute('data-rc-unit'), box.checked);
  }));

  $('[data-rc-toggle]').forEach(h => h.addEventListener('click', e => {
    if (e.target.closest('a,button,input,textarea,select,label,summary,details')) return;
    if (!getSelection().isCollapsed) return;
    const u = h.closest('[data-rc-unit]');
    if (!u) return;
    const id = u.getAttribute('data-rc-unit');
    setDone(id, !entry(id).done);
  }));

  // ---- bands ----
  $('[data-rc-band]').forEach(b => {
    const id = b.getAttribute('data-rc-band');
    if (!(id in state.bands)) state.bands[id] = b.hasAttribute('data-rc-start-collapsed');
  });
  $('[data-rc-band-toggle]').forEach(t => t.addEventListener('click', () => {
    const id = t.getAttribute('data-rc-band-toggle');
    state.bands[id] = !state.bands[id];
    save(); render();
  }));

  // ---- nav + scroll-spy ----
  $('[data-rc-nav]').forEach(a => a.addEventListener('click', e => {
    e.preventDefault();
    const u = units.find(u => u.id === a.getAttribute('data-rc-nav'));
    if (u) u.el.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }));
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver(entries => {
      for (const en of entries) {
        if (en.isIntersecting) active = en.target.getAttribute('data-rc-unit');
      }
      render();
    }, { rootMargin: '-10% 0px -80% 0px' });
    unitEls.forEach(el => io.observe(el));
  }

  // ---- handoff fields: one generic reader/writer for any standard control ----
  const isSet = v => Array.isArray(v) ? v.length > 0 : (v !== '' && v != null && v !== false);
  const controls = el =>
    el.matches('input,textarea,select') ? [el] : $('input,textarea,select', el);

  const getField = el => {
    const els = controls(el);
    if (!els.length) return '';
    const radios = els.filter(c => c.type === 'radio');
    if (radios.length) { const c = radios.find(r => r.checked); return c ? c.value : ''; }
    const boxes = els.filter(c => c.type === 'checkbox');
    if (boxes.length > 1) return boxes.filter(b => b.checked).map(b => b.value);
    const c = els[0];
    if (c.type === 'checkbox') return c.checked;
    if (c.matches('select[multiple]')) return Array.from(c.selectedOptions, o => o.value);
    if (c.type === 'number' || c.type === 'range') return c.value === '' ? '' : Number(c.value);
    return c.value;
  };
  const setField = (el, v) => {
    const els = controls(el);
    if (!els.length) return;
    const radios = els.filter(c => c.type === 'radio');
    if (radios.length) { radios.forEach(r => { r.checked = r.value === v; }); return; }
    const boxes = els.filter(c => c.type === 'checkbox');
    if (boxes.length > 1) {
      boxes.forEach(b => { b.checked = Array.isArray(v) && v.includes(b.value); });
      return;
    }
    const c = els[0];
    if (c.type === 'checkbox') c.checked = !!v;
    else if (c.matches('select[multiple]')) {
      Array.from(c.options).forEach(o => { o.selected = Array.isArray(v) && v.includes(o.value); });
    } else c.value = v == null ? '' : v;
  };

  // restore saved field values
  for (const u of units) {
    const fields = entry(u.id).fields || {};
    $('[data-handoff]', u.el).forEach(el => {
      const key = el.getAttribute('data-handoff');
      if (key in fields) setField(el, fields[key]);
    });
  }

  // capture on input/change (delegated; data-rc-mark lives outside handoff wrappers)
  const capture = e => {
    const h = e.target.closest && e.target.closest('[data-handoff]');
    if (!h) return;
    const u = h.closest('[data-rc-unit]');
    if (!u) return;
    entry(u.getAttribute('data-rc-unit')).fields[h.getAttribute('data-handoff')] = getField(h);
    save();
  };
  document.addEventListener('input', capture);
  document.addEventListener('change', capture);

  // ---- copy for handoff: touched = done or any field set ----
  $('[data-rc-copy]').forEach(btn => {
    const resting = btn.textContent;
    btn.addEventListener('click', async () => {
      const touched = units
        .map(u => ({ id: u.id, name: u.name, done: !!entry(u.id).done, fields: entry(u.id).fields || {} }))
        .filter(u => u.done || Object.values(u.fields).some(isSet));
      const payload = JSON.stringify({ source: SOURCE, units: touched }, null, 2);
      try { await navigator.clipboard.writeText(payload); } catch (e) { console.log(payload); }
      btn.textContent = 'Copied ' + touched.length + ' unit' + (touched.length === 1 ? '' : 's');
      setTimeout(() => { btn.textContent = resting; }, 1600);
    });
  });

  render();
};

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
else boot();
})();
