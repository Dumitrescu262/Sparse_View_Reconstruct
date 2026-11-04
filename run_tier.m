
function run_tier()
    % RUN_TIER  Driver script to test reconstruction on a specific tier.
    % This script handles data loading, reconstruction, evaluation, and visualization.

    % --- Configuration ---
    try tier = evalin('base', 'tier'); catch, tier = 1; end
    try use_practice = evalin('base', 'use_practice'); catch, use_practice = true; end
    version = 1;
    
    % --- Path Setup ---
    % Ensure operators and utils are in path
    addpath(genpath('operators'));
    addpath(genpath('evaluation'));
    addpath(genpath('utils'));

    % --- Data Loading ---
    if use_practice
        data_path = sprintf('data/practice/tier%d_practice.mat', tier);
    else
        data_path = sprintf('data/competition/tier%d_v%d.mat', tier, version);
    end
    
    if ~exist(data_path, 'file')
        error('Data file not found: %s', data_path);
    end
    
    fprintf('Loading problem: %s...\n', data_path);
    prob = load_problem(data_path);
    
    % --- Reconstruction ---
    fprintf('Running reconstruction...\n');
    tic;
    [x, info] = reconstruct(prob);
    elapsed = toc;
    
    % --- Evaluation ---
    x_2d = reshape(x, prob.N, prob.N);
    
    % Only compute score if ground truth is available (practice data)
    if ~isempty(prob.x_true)
        [score, psnr_val, ssim_val] = compute_score(x_2d, prob.x_true);
        fprintf('Result: PSNR = %.2f dB, SSIM = %.4f, Score = %.2f\n', psnr_val, ssim_val, score);
    else
        fprintf('Competition data: Ground truth hidden. Results can only be verified via official submission.\n');
        psnr_val = NaN; ssim_val = NaN;
    end
    
    fprintf('Time elapsed: %.3f s\n', elapsed);
    if isfield(info, 'iters')
        fprintf('Iterations: %d\n', info.iters);
    end

    % --- Visualization and Saving ---
    % Create results directory
    results_dir = 'results';
    if ~exist(results_dir, 'dir'), mkdir(results_dir); end
    
    % Filename for this run
    if use_practice
        fname = sprintf('tier%d_practice', tier);
    else
        fname = sprintf('tier%d_v%d', tier, version);
    end
    
    % 1. Save the reconstructed image as PNG
    % Normalize to [0, 1] for visualization
    img_norm = (x_2d - min(x_2d(:))) / (max(x_2d(:)) - min(x_2d(:)) + 1e-10);
    imwrite(img_norm, fullfile(results_dir, [fname, '_recon.png']));
    
    % 2. Save a simple text report
    fid = fopen(fullfile(results_dir, [fname, '_report.txt']), 'w');
    fprintf(fid, 'Problem: %s\n', data_path);
    fprintf(fid, 'Runtime: %.3f s\n', elapsed);
    if ~isnan(psnr_val)
        fprintf(fid, 'PSNR: %.2f dB\n', psnr_val);
        fprintf(fid, 'SSIM: %.4f\n', ssim_val);
    end
    if isfield(info, 'iters')
        fprintf(fid, 'Iterations: %d\n', info.iters);
    end
    fclose(fid);
    
    fprintf('Results saved to %s/\n', results_dir);
end
