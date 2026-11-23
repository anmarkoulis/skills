---
name: sk-tier
description: Extends anmarkoulis:tier for the anmarkoulis/skills repo with minimum tiers for the contracts, plugin manifest and workflows, and the release files as sensitive. Not for direct use; anmarkoulis:ship applies it through the sk layer.
---
| Point | This layer |
|---|---|
| confirmation | default |
| sensitive areas | extend: `.github/workflows/release.yml`, `.releaserc.json` (release App credential and version bumps, #18) |
| minimum tier per path or change type | extend: T1 for `contracts/**` (every step relies on it), `.claude-plugin/**` (install id and skills list), `.github/workflows/**` |
