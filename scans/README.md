# WPScan artifacts

Scan outputs from manual runs and GitHub Actions are stored here.

| File pattern | Description |
|--------------|-------------|
| `before-remediation-*` | Baseline scan (WordPress 5.8.3, debug on) |
| `after-remediation-*` | Post-patch hardened image scan |
| `latest-*.txt` | Symlink/copy of most recent run per label |

Generate locally:

```bash
./scripts/setup-lab.sh          # starts stack + before scan
./scripts/build-hardened.sh
./scripts/run-wpscan.sh http://localhost:8080 after-remediation
```
