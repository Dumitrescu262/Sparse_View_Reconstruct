function [score, psnr_val, ssim_val] = compute_score(x_recon, x_true)
% COMPUTE_SCORE  Competition composite score.
%
%   [score, psnr_val, ssim_val] = compute_score(x_recon, x_true)
%
%   score = 0.6 * PSNR + 0.4 * (100 * SSIM)
%
%   Clips x_recon to [0, Inf) before scoring.

    % Clip negative values to zero. This is intentional: physical CT images
    % cannot have negative attenuation, and it prevents negative outliers from
    % distorting PSNR/SSIM scores.
    x_recon = max(x_recon, 0);
    psnr_val = compute_psnr(x_recon, x_true);
    ssim_val = compute_ssim(x_recon, x_true);
    score = 0.6 * psnr_val + 0.4 * (100 * ssim_val);
end
