/*
  File: app.js
  Project: Updates Tracker
  Author: Jason Lamb
  Created: 2026-02-02
  Revision: 1.0
  Description:
  Loads updates.json and renders a table with basic age/status logic.
*/

fetch('updates.json')
  .then(response => {
    if (!response.ok) {
      throw new Error('Failed to load updates.json');
    }
    return response.json();
  })
  .then(data => {
    renderTable(data.updates);
  })
  .catch(error => {
    console.error(error);
  });

function renderTable(updates) {
  const tbody = document.querySelector('#updatesTable tbody');
  const today = new Date();

  updates.forEach(update => {
    const releaseDate = new Date(update.current.release_date);
    const daysOld = Math.floor((today - releaseDate) / (1000 * 60 * 60 * 24));

    let statusClass = 'status-green';
    if (daysOld > 180) statusClass = 'status-red';
    else if (daysOld > 90) statusClass = 'status-yellow';

    const row = document.createElement('tr');

    row.innerHTML = `
      <td>
        <strong>${update.name}</strong><br>
        <span class="small">${update.vendor}</span>
      </td>
      <td>${update.current.version}</td>
      <td>${update.current.release_date}</td>
      <td class="${statusClass}">${daysOld}</td>
      <td>
        ${update.upgrade.method}<br>
        <span class="small">${update.upgrade.path}</span>
      </td>
      <td>
        <a href="${update.source.url}" target="_blank">
          ${update.source.type}
        </a>
      </td>
    `;

    tbody.appendChild(row);
  });
}
