# CT Reconstruction - Docker Guide

This document provides the necessary commands to set up and run the reconstruction environment.

## Quick Start

Execute these commands from the `homework/student-package` directory:

```bash
# Build the environment
make build

# Run tests for Tiers 1-4
make t1
make t2
make t3
make t4

# Run a specific tier
make run-tier TIER=3

# Enter development shell for live code updates
make dev
```

## Docker CLI Reference

For users preferring direct Docker commands over the provided Makefile:

| Action | Command |
| :--- | :--- |
| Build Image | `docker build -t ct-student .` |
| Run Tier N | `docker run --rm ct-student octave --eval "tier=N; run_tier"` |

## Implementation Constraints

Submissions must adhere to the following technical requirements to be valid:

- **Banned Functions:** Use of `pcg`, `bicgstab`, `gmres`, `lsqr`, `svd`, `eig`, `radon`, `iradon`, `mldivide` (`\`), `inv`, or `pinv` is prohibited.
- **Toolboxes:** The use of external toolboxes (e.g., Image Processing, Optimization) is prohibited.
- **Time Limit:** Each reconstruction must complete within 120 seconds.
- **Non-negativity:** Results must be clipped to non-negative values: `x = max(x, 0)`.
- **Scope:** Only `reconstruct.m` should be modified. Use the provided `forward_op` and `adjoint_op`.

## Troubleshooting

- **Docker command not found:** Ensure Docker Desktop is installed and the daemon is running.
- **Permission denied (Linux):** Run `sudo usermod -aG docker $USER` and restart your session.
- **File not found:** Verify that the current working directory is `homework/student-package`.
- **Code updates:** If not using `make dev`, you must run `make build` after every change to `reconstruct.m` to update the image.
