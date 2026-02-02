<!--
  File: README.md
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.0
  Change Log:
    - 1.0 Initial project structure, schema, and documentation
-->

# Updates Tracker

A lightweight, static system for tracking **software updates over time**, including:

- Current version
- Release date
- Download source
- Installation and upgrade method
- Historical version tracking

The goal is not inventory management, but **change awareness**.

---

## 📌 Design Principles

- `updates.json` is the **single source of truth**
- All changes are **append-only** (history is never deleted)
- Git commit history serves as the **audit trail**
- The frontend is **read-only by design**
- No server-side writes
- No databases
- No frameworks

If it can’t be versioned, it doesn’t belong here.

---

## 📁 File Overview

### `updates.json`
- Canonical data store
- Tracks current version and full update history
- Designed to be:
  - Human-readable
  - Machine-readable
  - Git-diff friendly

### `index.html`
- Static frontend
- Displays tracked updates in table form
- No business logic
- No data mutation

### `app.js`
- Loads and renders `updates.json`
- Calculates “days since release”
- Applies basic status coloring

### `README.md`
- Documents intent, structure, and rules
- Defines how updates are added and maintained

---

## ✍️ How Updates Are Added

Updates are added by **editing `updates.json` directly**.

For a new software item:
- Create a new entry under the `updates` array
- Add an initial history record

For a new version of existing software:
1. Update the `current` version and release date
2. Append a new entry to the top of the `history` array
3. Commit the change

History is never overwritten.

---

## 🧠 Naming and Structure Rules

- The project tracks **updates**, not installs
- “Tools” and “software” are descriptive labels only
- `release_date` = vendor-published date
- `noted_on` = date you recorded the update
- Newest history entries appear first

Consistency beats cleverness.

---

## 🌐 Hosting

Currently hosted via GitHub Pages:

https://jasrasr.github.io/updates/

GitHub Pages provides:
- Static hosting
- Automatic updates on commit
- Zero backend attack surface

---

## 🔮 Planned Enhancements (Non-breaking)

- Expandable per-update history view
- Filters (stale updates, vendor, category)
- CSV export
- PowerShell helper for safe JSON updates
- Optional PHP write support on hosted platforms (Hostinger)

All future enhancements must preserve:
- JSON schema compatibility
- Git-based auditability

---

## ⚠️ Non-Goals

- Asset management
- Endpoint inventory
- User tracking
- Auto-updating without review

This is a **curated system**, not an autopilot.

---

## 🧾 Revision Policy (Important)

Every file in this project must include:
- File name
- Author
- Created date
- Modified date
- Revision number
- Change log

If a file doesn’t have a header, it’s incomplete.
