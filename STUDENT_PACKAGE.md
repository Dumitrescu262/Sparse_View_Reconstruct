# CT Reconstruction - Student Package

This is the package for the Sparse-View CT Reconstruction project.

## Standalone Nature
This package is designed to be a standalone unit. You have everything you need to implement and test your solution here. You should not rely on, or have knowledge of, any other packages in the project repository.

## What You Have

- `reconstruct.m` - **The ONLY file you modify** (your entire solution goes here)
- `run_tier.m` - Driver script to test your reconstruction on different tiers
- `operators/` - Forward projection operators (forward_op, adjoint_op, apply_ata)
- `evaluation/` - Scoring metrics (PSNR, SSIM)
- `utils/` - Utility functions (load_problem, save/show reconstruction)
- `data/practice/` - Practice data (with ground truth for scoring)

## Quick Start

1. Implement `reconstruct.m` using the provided operators.
2. **Build your image**: Since this project uses a "Black Box" execution model, any changes you make to the code must be baked into a Docker image before they can be run.
   ```bash
   make build
   ```
3. **Test your solution on practice data** (start here):
   ```bash
   make p1    # Run Tier 1 practice
   make p2    # Run Tier 2 practice
   make p3    # Run Tier 3 practice
   make p4    # Run Tier 4 practice
   ```
   Start with `make p1` to get a working implementation, then move to higher tiers to improve your algorithm.
4. **Test on competition data** (requires competition dataset):
   ```bash
   make t1    # Run Tier 1 competition
   make t2    # Run Tier 2 competition
   make t3    # Run Tier 3 competition
   make t4    # Run Tier 4 competition
   ```
   The competition dataset will be gradually revealed as the competition progresses. Competition data does not include ground truth, so scores can only be verified via official submission.

## Docker Support & "Black Box" Execution

To ensure the grading environment is identical to your testing environment, this project uses **static image execution**. 

**Crucial**: You cannot simply edit a file and run `make t1`. You must rebuild the image for your changes to take effect. The `Makefile` handles this automatically by making `build` a prerequisite for all run commands, but be aware that the `docker build` step is what captures your current code.

### Common Commands
- `make build`: Build the `ct-student` Docker image.
- `make t1` to `make t4`: Run the specified tier.
- `make dev`: Start an interactive shell inside your built image.
- `make submit`: Create the `submission.zip` for grading.
- `make check-submit`: Verify your zip contents inside the container.

## Practice Data Structure

Practice data is stored in `data/practice/`:
- `tierX_practice.mat`: Standard practice problem.
- `tierX_extraY.mat`: Additional practice problems.

Each practice file contains the sinogram `b`, projection `angles`, image size `N`, detector count `n_det`, noise level `sigma`, and the ground truth `x_true`.
