# Updates Tracker

This project tracks software updates over time, including:

- Current version
- Release date
- Download source
- Upgrade method and path
- Historical versions

The system is intentionally simple and static.

## Design Principles

- `updates.json` is the single source of truth
- Git commit history acts as the audit trail
- No server-side writes
- Read-only frontend via GitHub Pages

## Hosting

Currently hosted at:

https://jasrasr.github.io/updates/

## Future Enhancements (Planned)

- Detailed history view per update
- Security / CVE annotations
- Export to CSV
- PowerShell integration for version compliance checks
