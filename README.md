# Automated Vulnerability Discovery & Remediation Pipeline

DevSecOps lab: containerized WordPress, WPScan automation, patching, hardening, and registry publishing.

**Repository:** [https://github.com/iulianigas/DSO-lab](https://github.com/iulianigas/DSO-lab)  
**Docker Hub (hardened image):** [https://hub.docker.com/repository/docker/iulianigas/wordpress-hardened/general](https://hub.docker.com/repository/docker/iulianigas/wordpress-hardened/general)  
**GHCR:** `ghcr.io/iulianigas/wordpress-hardened:latest`

---

## What this project does (step by step)

### Phase 1 — Deploy the vulnerable baseline

1. `docker/docker-compose.yml` starts **MySQL 5.7** and **WordPress 5.8.3** (intentionally outdated).
2. Weak lab credentials and debug-friendly config simulate real misconfigurations.
3. Site listens on **http://localhost:8080** (first visit redirects to the install wizard — HTTP 302 is expected).

### Phase 2 — Discover vulnerabilities (WPScan)

1. **WPScan** scans version, users, plugins, and themes against its CVE database.
2. Results are saved under **`/scans/`** (`.txt` and `.json`).
3. **GitHub Actions** (`scan.yml`) repeats this on every push to `main`: spin up stack → wait for WordPress → scan → upload artifacts.

### Phase 3 — Analyze findings

Interpret scan output for risk and exploitation paths (documented in `docs/SECURITY_REPORT.md`):

- Outdated core (multiple CVEs)
- User enumeration (`admin`)
- Debug mode, weak DB passwords, missing security headers

### Phase 4 — Remediate (patch + harden)

1. **`dockerfiles/Dockerfile.hardened`** upgrades to WordPress **6.7.2**, PHP **8.2**, enables Apache `mod_headers`, applies PHP/WordPress hardening.
2. **`docker/docker-compose.hardened.yml`** uses MySQL **8.0** (not exposed on the host) and stronger passwords.

### Phase 5 — Build and publish the fixed image

1. Workflow **`build-push-rescan.yml`** builds the image and pushes to **GHCR** and **Docker Hub** (if secrets are set).
2. Image: `iulianigas/wordpress-hardened:latest`

### Phase 6 — Verify (rescan)

1. Same workflow pulls the hardened image, starts the stack, runs **WPScan** again.
2. Compare **`scans/before-remediation-*`** vs **`scans/after-remediation-*`** (and CI artifacts).

### Phase 7 — Document

1. Full write-up: **`docs/SECURITY_REPORT.md`**
2. Presentation PDF: **`docs/SECURITY_REPORT.pdf`** (`python3 scripts/generate-pdf.py`)

---

## Required deliverables (assignment checklist)

### A. GitHub Repository — [DSO-lab](https://github.com/iulianigas/DSO-lab)

| Requirement | Location | Status |
|-------------|----------|--------|
| Deployment definition | [`docker/docker-compose.yml`](docker/docker-compose.yml) | Included |
| Automated scanning workflow | [`.github/workflows/scan.yml`](.github/workflows/scan.yml) | Included |
| WPScan artifacts | [`scans/`](scans/) | Included (+ CI artifacts) |
| Fixed/hardened image build | [`dockerfiles/Dockerfile.hardened`](dockerfiles/Dockerfile.hardened), [`docker/docker-compose.hardened.yml`](docker/docker-compose.hardened.yml) | Included |
| Clear remediation commit history | [Commits](https://github.com/iulianigas/DSO-lab/commits/main) | Included |

### B. Docker Hub Repository

| Requirement | Location | Status |
|-------------|----------|--------|
| Final hardened WordPress image (required) | [iulianigas/wordpress-hardened](https://hub.docker.com/repository/docker/iulianigas/wordpress-hardened/general) | Published |
| Optional vulnerable baseline image | [`dockerfiles/Dockerfile.vulnerable`](dockerfiles/Dockerfile.vulnerable) | Dockerfile only (optional push) |

### C. PDF Report (presentation)

| Section | Document |
|---------|----------|
| 1. Environment Setup | `docs/SECURITY_REPORT.md` §1 |
| 2. Findings Overview | `docs/SECURITY_REPORT.md` §2 |
| 3. Remediation Steps | `docs/SECURITY_REPORT.md` §3 |
| 4. Fixed Image Build | `docs/SECURITY_REPORT.md` §4 |
| 5. Tooling Justification | `docs/SECURITY_REPORT.md` §5 |
| 6. DevSecOps Strategy (shift-left) | `docs/SECURITY_REPORT.md` §6 |

Generate PDF: `python3 scripts/generate-pdf.py` → `docs/SECURITY_REPORT.pdf`

---

## Tools used

| Tool | Purpose in this project |
|------|-------------------------|
| **Docker** | Run WordPress + MySQL consistently locally and in CI |
| **WordPress official image** | Realistic application target for scanning |
| **WPScan** | WordPress-specific vulnerability and enumeration scanner |
| **GitHub Actions** | Automate deploy → scan → build → push → rescan |
| **GitHub Container Registry (GHCR)** | Host hardened image `ghcr.io/iulianigas/wordpress-hardened` |
| **Docker Hub** | Public distribution of `iulianigas/wordpress-hardened` |

---

## Workflow summary (assignment steps 1–8)

1. **Deploy WordPress locally** — `docker compose -f docker/docker-compose.yml up -d`
2. **Run WPScan manually** — `./scripts/run-wpscan.sh http://localhost:8080 before-remediation`
3. **Build GitHub Actions workflow** — `scan.yml` (automated baseline scan)
4. **Analyze vulnerabilities** — see `docs/SECURITY_REPORT.md` §2
5. **Apply patches + hardening** — `dockerfiles/Dockerfile.hardened`
6. **Rebuild and push fixed image** — `build-push-rescan.yml` → GHCR + Docker Hub
7. **Trigger workflow to re-scan** — `build-push-rescan.yml` job `rescan-hardened`
8. **Document everything** — `docs/SECURITY_REPORT.md` / `.pdf`

---

## Repository layout

```
├── docker/docker-compose.yml          # Vulnerable baseline deployment
├── docker/docker-compose.hardened.yml # Hardened image deployment
├── dockerfiles/Dockerfile.hardened    # Patched + hardened image build
├── dockerfiles/Dockerfile.vulnerable  # Optional baseline image reference
├── .github/workflows/scan.yml         # Automated WPScan on push
├── .github/workflows/build-push-rescan.yml  # Build, GHCR/Docker Hub, rescan
├── scans/                             # WPScan CLI/JSON artifacts
├── scripts/                           # Local lab helpers
└── docs/SECURITY_REPORT.md            # Full report (export to PDF)
```

---

## Quick start

### 1. Deploy vulnerable WordPress

```bash
cd docker
docker compose -f docker-compose.yml up -d
# http://localhost:8080
```

### 2. Manual WPScan

```bash
gem install wpscan
./scripts/run-wpscan.sh http://localhost:8080 before-remediation
```

### 3. Build hardened image

```bash
./scripts/build-hardened.sh
HARDENED_IMAGE=wordpress-hardened:local docker compose -f docker/docker-compose.hardened.yml up -d
./scripts/run-wpscan.sh http://localhost:8080 after-remediation
```

### 4. GitHub Actions

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `scan.yml` | push / PR / manual | Spin up baseline stack, WPScan, upload artifacts |
| `build-push-rescan.yml` | push to `dockerfiles/**` / manual | Build hardened image → GHCR + Docker Hub → rescan |

**Secrets for Docker Hub:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`  
GHCR uses built-in `GITHUB_TOKEN`.

### 5. Pull published hardened image

```bash
docker pull iulianigas/wordpress-hardened:latest
# or
docker pull ghcr.io/iulianigas/wordpress-hardened:latest
```

---

## Remediation summary

| Area | Before | After |
|------|--------|-------|
| WordPress core | 5.8.3 | 6.7.2 |
| PHP | 8.0 | 8.2 |
| MySQL | 5.7 (exposed) | 8.0 (internal only) |
| Debug | ON | OFF |
| File editor | Allowed | DISALLOW_FILE_EDIT |
| Apache | Default tokens | ServerTokens Prod, port 8080 non-root |
| DB credentials | Weak defaults | Strong env-based passwords |

---

## PDF report

```bash
python3 scripts/generate-pdf.py
# → docs/SECURITY_REPORT.pdf
```

Detailed report: [`docs/SECURITY_REPORT.md`](docs/SECURITY_REPORT.md)
