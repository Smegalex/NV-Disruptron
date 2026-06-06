# Deploy

Portable replication bundle for NV-Disruptron on another DGX Spark (or similar aarch64 + CUDA host).

| Path | Purpose |
|------|---------|
| [replicate/README.md](replicate/README.md) | **Start here** — step-by-step clone to a new device |
| [replicate/manifest.yaml](replicate/manifest.yaml) | Machine-readable stack definition (ports, models, paths) |
| [replicate/CHECKLIST.md](replicate/CHECKLIST.md) | Printable replication checklist |
| [replicate/FILE-MAP.md](replicate/FILE-MAP.md) | Source device → target device path mapping |
| [replicate/docs/OPERATIONS.md](replicate/docs/OPERATIONS.md) | Full operations snapshot (self-contained copy) |
| [replicate/scripts/bootstrap-device.sh](replicate/scripts/bootstrap-device.sh) | Automated bootstrap on fresh clone |
| [replicate/scripts/verify-device.sh](replicate/scripts/verify-device.sh) | Post-install health verification |

Copy the whole repo (or at minimum `deploy/replicate/` + source tree) to the target machine, then follow `replicate/README.md`.
