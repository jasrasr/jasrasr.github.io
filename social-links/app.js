/*
File: app.js
Author: Jason Lamb (generated with ChatGPT)
Created: 2026-02-27
Modified: 2026-02-27
Revision: 2.0

Changelog:
2.0 - Loads tiles from links.json, renders grid, tracks clicks, posts to log_click.php
*/

(function () {
  const JSON_PATH = "./links.json";
  const LOG_ENDPOINT = "./log_click.php";

  const elTitle = document.getElementById("pageTitle");
  const elSubtitle = document.getElementById("pageSubtitle");
  const elGrid = document.getElementById("grid");
  const elFooterText = document.getElementById("footerText");
  const elFooterRev = document.getElementById("footerRev");

  function safeText(value) {
    return (value ?? "").toString();
  }

  async function loadConfig() {
    const res = await fetch(JSON_PATH, { cache: "no-store" });
    if (!res.ok) throw new Error(`Failed to load ${JSON_PATH} : ${res.status}`);
    return await res.json();
  }

  function makeCard(tile) {
    const a = document.createElement("a");
    a.className = "card";
    a.href = tile.url;
    a.target = "_blank";
    a.rel = "noopener noreferrer";
    a.setAttribute("data-id", tile.id);

    // Background image
    a.style.backgroundImage = `url('${tile.image}')`;

    // Badge (optional)
    if (tile.badge) {
      const badge = document.createElement("div");
      badge.className = "badge";
      badge.textContent = safeText(tile.badge);
      a.appendChild(badge);
    }

    const label = document.createElement("div");
    label.className = "label";

    const name = document.createElement("span");
    name.className = "name";
    name.textContent = safeText(tile.name);

    const hint = document.createElement("span");
    hint.className = "hint";
    hint.textContent = safeText(tile.hint);

    label.appendChild(name);
    label.appendChild(hint);
    a.appendChild(label);

    // Track click (fire-and-forget)
    a.addEventListener("click", () => {
      trackClick(tile);
    });

    return a;
  }

  function trackClick(tile) {
    // Client-side log (useful even if PHP logging fails)
    const key = "social_clicks_v1";
    const now = new Date().toISOString();
    const record = {
      ts: now,
      id: tile.id,
      name: tile.name,
      url: tile.url,
      ref: document.referrer || "",
      ua: navigator.userAgent || ""
    };

    try {
      const existing = JSON.parse(localStorage.getItem(key) || "[]");
      existing.unshift(record);
      localStorage.setItem(key, JSON.stringify(existing.slice(0, 250)));
    } catch (_) {
      // Ignore localStorage failures (private mode etc.)
    }

    // Server-side log (POST JSON)
    // keepalive lets it try to finish even during navigation
    try {
      fetch(LOG_ENDPOINT, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(record),
        keepalive: true
      }).catch(() => {});
    } catch (_) {}
  }

  function render(config) {
    const page = config.page || {};
    const meta = config._meta || {};
    const tiles = Array.isArray(config.tiles) ? config.tiles : [];

    elTitle.textContent = safeText(page.title) || "Social";
    elSubtitle.textContent = safeText(page.subtitle);

    elFooterText.textContent = safeText(page.footerText) || "";
    elFooterRev.textContent = `Rev ${safeText(meta.revision)} • Updated ${safeText(meta.modified_date)}`;

    elGrid.innerHTML = "";
    for (const tile of tiles) {
      // basic validation
      if (!tile || !tile.url || !tile.image) continue;
      elGrid.appendChild(makeCard(tile));
    }
  }

  (async function init() {
    try {
      const config = await loadConfig();
      render(config);
    } catch (err) {
      elTitle.textContent = "Social Links";
      elSubtitle.textContent = "Config failed to load. The grid is empty because the JSON is missing or broken.";
      elGrid.innerHTML = "";
      elFooterText.textContent = "";
      elFooterRev.textContent = "";
      console.error(err);
    }
  })();
})();