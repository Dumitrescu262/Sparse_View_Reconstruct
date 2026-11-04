function psnr_val = compute_psnr(x_recon, x_true)
% COMPUTE_PSNR  Peak Signal-to-Noise Ratio in decibels.
%
%   psnr_val = compute_psnr(x_recon, x_true)
%
%   Both inputs are N x N matrices (2D images).
%   PSNR = 10 * log10(max(x_true(:))^2 / MSE)

    peak = max(x_true(:));
    mse  = mean((x_recon(:) - x_true(:)).^2);
    if mse < 1e-16
        psnr_val = Inf;
    else
        psnr_val = 10 * log10(peak^2 / mse);
    end
end
