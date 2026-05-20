# Automated Vulnerability Discovery & Remediation Pipeline

DevSecOps lab: containerized WordPress, WPScan automation, patching, hardening, and registry publishing.

## Repository layout

```
├── docker/docker-compose.yml          # Vulnerable baseline deployment
├── docker/docker-compose.hardened.yml # Hardened image deployment
├── dockerfiles/Dockerfile.hardened    # Patched + hardened image build
├── .github/workflows/scan.yml         # Automated WPScan on push
├── .github/workflows/build-push-rescan.yml  # Build, GHCR/Docker Hub, rescan
├── scans/                             # WPScan CLI/JSON artifacts
├── scripts/                           # Local lab helpers
└── docs/SECURITY_REPORT.md            # Full report (export to PDF)
```

## Quick start

### 1. Deploy vulnerable WordPress

```bash
cd docker
docker compose -f docker-compose.yml up -d
# http://localhost:8080
```

### 2. Manual WPScan

```bash
gem install wpscan   # or use Docker: wpscanteam/wpscan
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

**Secrets for Docker Hub** (repository settings):

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

GHCR push uses `GITHUB_TOKEN` (packages: write).

### 5. Publish images

```bash
docker tag wordpress-hardened:local YOUR_USER/wordpress-hardened:latest
docker login
docker push YOUR_USER/wordpress-hardened:latest
```

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

## PDF report

```bash
# Option A: pandoc
pandoc docs/SECURITY_REPORT.md -o docs/SECURITY_REPORT.pdf

# Option B: Python (see scripts/generate-pdf.py)
python3 scripts/generate-pdf.py
```

## Links (update after publish)

- **GitHub repo:** `https://github.com/YOUR_ORG/DSO`
- **Docker Hub:** `https://hub.docker.com/r/YOUR_USER/wordpress-hardened`
- **GHCR:** `ghcr.io/YOUR_ORG/wordpress-hardened`
