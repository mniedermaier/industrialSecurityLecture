/* ============================================================
   Industrial Security Labs — landing page interactivity.

   Everything in this file is vanilla DOM + fetch. No CDNs, no
   framework. Works offline so the lab stack on a student laptop
   has the same behaviour with or without an internet connection.
   ============================================================ */

(function () {
  "use strict";

  const $  = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));

  const STORAGE = {
    theme:    "isl-theme",       // "auto" | "light" | "dark"
    progress: "isl-progress",    // JSON: { "01": true, "04": true, ... }
  };

  // ----------------------------------------------------------------------
  // THEME — three states: auto / light / dark.
  // ----------------------------------------------------------------------
  (function theme() {
    const root = document.documentElement;
    const btn  = $("#theme-toggle");
    const mql  = window.matchMedia("(prefers-color-scheme: dark)");

    function resolve(theme) {
      return theme === "auto" ? (mql.matches ? "dark" : "light") : theme;
    }
    function apply(theme) {
      root.setAttribute("data-theme", theme);
      root.setAttribute("data-resolved", resolve(theme));
      try { localStorage.setItem(STORAGE.theme, theme); } catch (e) {}
      btn && btn.setAttribute("title",
        "Theme: " + theme + " — click to cycle (auto → light → dark)");
    }
    function current() {
      try { return localStorage.getItem(STORAGE.theme) || "auto"; } catch (e) { return "auto"; }
    }

    // The pre-paint script in <head> set the initial attribute. Keep them
    // in sync with localStorage in case the user has multiple tabs open.
    apply(current());

    btn && btn.addEventListener("click", () => {
      const order = ["auto", "light", "dark"];
      const next = order[(order.indexOf(current()) + 1) % order.length];
      apply(next);
    });

    // React to OS-level changes when in auto mode.
    mql.addEventListener && mql.addEventListener("change", () => {
      if (current() === "auto") apply("auto");
    });
  })();

  // ----------------------------------------------------------------------
  // SCROLL PROGRESS — thin gradient bar at the very top.
  // ----------------------------------------------------------------------
  (function scrollProgress() {
    const bar = $(".scroll-progress-bar");
    if (!bar) return;
    function update() {
      const h = document.documentElement;
      const max = h.scrollHeight - h.clientHeight;
      const pct = max > 0 ? (h.scrollTop / max) * 100 : 0;
      bar.style.width = pct.toFixed(1) + "%";
    }
    document.addEventListener("scroll", update, { passive: true });
    update();
  })();

  // ----------------------------------------------------------------------
  // COPY BUTTONS — added to every <pre>. Uses Clipboard API + fallback.
  // ----------------------------------------------------------------------
  (function copyButtons() {
    $$("pre").forEach((pre) => {
      const btn = document.createElement("button");
      btn.className = "copy-btn";
      btn.type = "button";
      btn.setAttribute("aria-label", "Copy code to clipboard");
      btn.innerHTML = '<svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true"><path fill="currentColor" d="M10 1H4a1 1 0 0 0-1 1v8h2V3h5V1zm2 3H7a1 1 0 0 0-1 1v9a1 1 0 0 0 1 1h5a1 1 0 0 0 1-1V5a1 1 0 0 0-1-1zm0 10H7V5h5v9z"/></svg>';
      pre.appendChild(btn);
      btn.addEventListener("click", async () => {
        const code = pre.querySelector("code");
        const text = (code ? code : pre).innerText;
        try {
          await navigator.clipboard.writeText(text);
        } catch (e) {
          // Fallback for older browsers / non-HTTPS contexts.
          const ta = document.createElement("textarea");
          ta.value = text;
          ta.style.position = "fixed"; ta.style.left = "-9999px";
          document.body.appendChild(ta);
          ta.select();
          try { document.execCommand("copy"); } catch (_) {}
          document.body.removeChild(ta);
        }
        btn.classList.add("is-copied");
        btn.innerHTML = '<svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true"><path fill="currentColor" d="M6 11.5 2.5 8l1.4-1.4 2.1 2.1 5.6-5.6L13 4.5l-7 7z"/></svg>';
        setTimeout(() => {
          btn.classList.remove("is-copied");
          btn.innerHTML = '<svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true"><path fill="currentColor" d="M10 1H4a1 1 0 0 0-1 1v8h2V3h5V1zm2 3H7a1 1 0 0 0-1 1v9a1 1 0 0 0 1 1h5a1 1 0 0 0 1-1V5a1 1 0 0 0-1-1zm0 10H7V5h5v9z"/></svg>';
        }, 1400);
      });
    });
  })();

  // ----------------------------------------------------------------------
  // PROGRESS TRACKING — checkbox per lab card; persists to localStorage.
  // ----------------------------------------------------------------------
  const progress = (function () {
    function read() {
      try { return JSON.parse(localStorage.getItem(STORAGE.progress) || "{}"); }
      catch (e) { return {}; }
    }
    function write(p) {
      try { localStorage.setItem(STORAGE.progress, JSON.stringify(p)); } catch (e) {}
    }
    const state = read();

    function paint() {
      let done = 0;
      $$(".lab-card").forEach((card) => {
        const lab = card.dataset.lab;
        const isDone = !!state[lab];
        card.classList.toggle("is-done", isDone);
        const btn = card.querySelector(".lab-done");
        if (btn) btn.setAttribute("aria-pressed", String(isDone));
        if (isDone) done++;
      });
      const pill = $("#progress-pill");
      const count = $("#progress-count");
      if (count) count.textContent = String(done);
      if (pill)  pill.classList.toggle("is-complete", done >= 10);
    }

    $$(".lab-done").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const lab = btn.dataset.lab;
        if (state[lab]) delete state[lab]; else state[lab] = true;
        write(state);
        paint();
      });
    });

    paint();
    return { read: () => state, paint };
  })();

  // ----------------------------------------------------------------------
  // PDF MODAL — opens any .pdf inline via <iframe>. Works offline
  // because the browser handles the PDF natively from a local URL.
  // Focus is trapped; Esc closes; backdrop click closes.
  // ----------------------------------------------------------------------
  const pdfModal = (function () {
    const modal = $("#pdf-modal");
    if (!modal) return { open: () => {}, close: () => {} };

    const frame    = $("#pdf-modal-frame");
    const title    = $("#pdf-modal-title");
    const openLnk  = $("#pdf-modal-open");
    const dlLnk    = $("#pdf-modal-download");
    const closeBn  = $("#pdf-modal-close");
    const fallback = $("#pdf-modal-fallback");
    const fbUrl    = $("#pdf-modal-url-text");

    let lastFocus = null;

    function trapFocusKeydown(e) {
      if (e.key === "Escape") { close(); return; }
      if (e.key !== "Tab") return;
      const focusables = $$("a, button, [tabindex]:not([tabindex=\"-1\"])", modal)
        .filter((el) => !el.hasAttribute("hidden") && el.offsetParent !== null);
      if (focusables.length === 0) return;
      const first = focusables[0], last = focusables[focusables.length - 1];
      if (e.shiftKey && document.activeElement === first) { last.focus(); e.preventDefault(); }
      else if (!e.shiftKey && document.activeElement === last) { first.focus(); e.preventDefault(); }
    }

    function open(pdfUrl, niceTitle) {
      if (!pdfUrl) return;
      lastFocus = document.activeElement;
      title.textContent = niceTitle || "Lab PDF";
      // Hide fallback up front; show iframe.
      if (fallback) fallback.hidden = true;
      if (fbUrl) fbUrl.textContent = pdfUrl;
      // #toolbar=1 is honored by Chromium's PDF viewer; harmless elsewhere.
      frame.src = pdfUrl + "#toolbar=1&navpanes=0";
      openLnk.href = pdfUrl;
      dlLnk.href   = pdfUrl;
      dlLnk.setAttribute("download", "");
      modal.hidden = false;
      document.body.classList.add("modal-open");
      document.addEventListener("keydown", trapFocusKeydown);
      // Focus the close button so Esc/Tab work immediately.
      setTimeout(() => closeBn.focus(), 30);
    }
    function close() {
      modal.hidden = true;
      frame.src = "about:blank";
      if (fallback) fallback.hidden = true;
      document.body.classList.remove("modal-open");
      document.removeEventListener("keydown", trapFocusKeydown);
      if (lastFocus && typeof lastFocus.focus === "function") lastFocus.focus();
    }

    // Show the fallback panel only when the iframe genuinely errors out.
    // Cross-process PDF rendering is too opaque to detect reliably from JS;
    // the action buttons in the header are the primary recovery path.
    frame.addEventListener("error", () => {
      if (fallback) fallback.hidden = false;
    });

    // Wire up every element with data-pdf
    $$("[data-pdf]").forEach((el) => {
      el.addEventListener("click", (e) => {
        e.preventDefault();
        open(el.dataset.pdf, el.dataset.title || el.textContent.trim());
      });
    });

    // Backdrop & close button (anything with data-close)
    $$("[data-close]", modal).forEach((el) => el.addEventListener("click", close));

    return { open, close };
  })();

  // ----------------------------------------------------------------------
  // SEARCH — filters labs + scripts + quick-ref + stack + troubleshooting.
  // ----------------------------------------------------------------------
  (function search() {
    const input = $("#search");
    const status = $("#filter-status");
    if (!input) return;

    const targets = $$(".lab-card, .service-card, .script-card, .ref-card, .trouble-card");
    function apply() {
      const q = input.value.trim().toLowerCase();
      let visible = 0, hidden = 0;
      targets.forEach((el) => {
        if (!q) { el.classList.remove("is-hidden"); visible++; return; }
        const hay = (el.dataset.keywords || "") + " " + el.textContent.toLowerCase();
        const match = hay.toLowerCase().includes(q);
        el.classList.toggle("is-hidden", !match);
        if (match) visible++; else hidden++;
      });
      if (status) {
        if (q) {
          status.hidden = false;
          status.textContent = visible + " result" + (visible === 1 ? "" : "s") + " for “" + input.value + "”";
        } else {
          status.hidden = true;
        }
      }
    }
    input.addEventListener("input", apply);

    // Esc clears search
    input.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && input.value) { input.value = ""; apply(); e.preventDefault(); }
    });
  })();

  // ----------------------------------------------------------------------
  // STACK HEALTH — pings landing + OpenPLC UI every 10s.
  //
  // We can't speak Modbus / OPC UA / MQTT from JS, but the two HTTP
  // services (landing on :8000 and OpenPLC web UI on :8080) tell us
  // whether the stack is up. Image-ping via favicon avoids CORS.
  // ----------------------------------------------------------------------
  (function health() {
    const pill = $("#health-pill");
    if (!pill) return;
    const dot  = pill.querySelector(".health-dot");
    const text = pill.querySelector(".health-text");

    function ping(url, timeoutMs) {
      return new Promise((resolve) => {
        const img = new Image();
        const t = setTimeout(() => { img.src = ""; resolve(false); }, timeoutMs || 2500);
        img.onload  = () => { clearTimeout(t); resolve(true);  };
        // 404 still means the host answered → it's up.
        img.onerror = () => { clearTimeout(t); resolve(true);  };
        // The landing nginx serves favicon; OpenPLC serves /static/openplc_logo.gif.
        img.src = url + (url.indexOf("?") === -1 ? "?" : "&") + "_=" + Date.now();
      });
    }

    async function check() {
      // Run both pings in parallel.
      const [landingUp, openplcUp] = await Promise.all([
        ping("/favicon.svg", 1500),
        ping("http://127.0.0.1:8080/static/openplc_logo.gif", 2500),
      ]);
      let state, label;
      if (landingUp && openplcUp)      { state = "up";      label = "stack up"; }
      else if (landingUp || openplcUp) { state = "partial"; label = "partial";  }
      else                             { state = "down";    label = "stack down"; }
      dot.dataset.state = state;
      text.textContent = label;
      pill.setAttribute("title",
        "Stack health (10s poll): landing=" + (landingUp ? "up" : "down") +
        ", openplc=" + (openplcUp ? "up" : "down"));
    }
    check();
    setInterval(check, 10000);
  })();

  // ----------------------------------------------------------------------
  // KEYBOARD SHORTCUTS
  //   /           focus the search box
  //   T           cycle theme
  //   1..9, 0     open lab N (0 = Lab 10)
  //   Esc         close modal / clear search (handled in their handlers)
  // ----------------------------------------------------------------------
  (function shortcuts() {
    document.addEventListener("keydown", (e) => {
      // Skip when typing in an input / textarea / contenteditable
      const t = e.target;
      if (t && (t.tagName === "INPUT" || t.tagName === "TEXTAREA" || t.isContentEditable)) {
        return;
      }
      if (e.metaKey || e.ctrlKey || e.altKey) return;

      if (e.key === "/") {
        const s = $("#search");
        if (s) { s.focus(); s.select(); e.preventDefault(); }
        return;
      }
      if (e.key === "t" || e.key === "T") {
        const b = $("#theme-toggle");
        if (b) { b.click(); e.preventDefault(); }
        return;
      }
      if (/^[0-9]$/.test(e.key)) {
        const num = e.key === "0" ? "10" : ("0" + e.key);
        const card = document.querySelector('.lab-card[data-lab="' + num + '"]');
        if (!card) return;
        const link = card.querySelector(".lab-title-link");
        if (link) { link.click(); e.preventDefault(); }
      }
    });
  })();
})();
