function ssim_val = compute_ssim(x_recon, x_true)
% COMPUTE_SSIM  Structural Similarity Index (simplified Wang et al. 2004).
%
%   ssim_val = compute_ssim(x_recon, x_true)
%
%   Self-contained implementation. Does not require Image Processing Toolbox.
%   Uses 11x11 Gaussian window with sigma=1.5 (standard parameters).
%   Both inputs are N x N.

    % Parameters
    K1 = 0.01;
    K2 = 0.03;
    L = max(x_true(:));  % dynamic range

    % Gaussian window
    [u,v] = meshgrid(-5:5, -5:5);
    sigma = 1.5;
    window = exp(-(u.^2 + v.^2)/(2*sigma^2));
    window = window / sum(window(:));

    % Compute means
    mu_x = conv2(x_recon, window, 'same');
    mu_y = conv2(x_true, window, 'same');

    % Compute variances and covariance
    sigma_x_sq = conv2(x_recon.^2, window, 'same') - mu_x.^2;
    sigma_y_sq = conv2(x_true.^2, window, 'same') - mu_y.^2;
    sigma_xy = conv2(x_recon.*x_true, window, 'same') - mu_x .* mu_y;

    C1 = (K1*L)^2;
    C2 = (K2*L)^2;

    ssim_map = (2*mu_x.*mu_y + C1) .* (2*sigma_xy + C2) ./ ((mu_x.^2 + mu_y.^2 + C1) .* (sigma_x_sq + sigma_y_sq + C2));
    ssim_val = mean(ssim_map(:));
end
