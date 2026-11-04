function show_reconstruction(x_recon, prob, title_str)
% SHOW_RECONSTRUCTION  Display reconstruction alongside sinogram and (if available) ground truth.
%
%   show_reconstruction(x_recon, prob)
%   show_reconstruction(x_recon, prob, 'My Method')
%
%   prob is the struct returned by load_problem.

    if nargin < 3, title_str = 'Reconstruction'; end
    N = prob.N;
    sino = reshape(prob.b, [], prob.n_det);   % reshape sinogram for display

    if  ~isempty(prob.x_true)
        % 3-panel: ground truth | reconstruction | sinogram
        subplot(1,3,1);
        imagesc(prob.x_true); axis image; colorbar;
        title('Ground Truth');

        subplot(1,3,2);
        imagesc(reshape(x_recon, N, N)); axis image; colorbar;
        [sc, p, s] = compute_score(reshape(x_recon, N, N), prob.x_true);
        title(sprintf('%s\nPSNR=%.1f SSIM=%.3f Score=%.1f', title_str, p, s, sc));

        subplot(1,3,3);
        imagesc(sino); axis image; colorbar;
        title('Sinogram');
    else
        % 2-panel: reconstruction | sinogram
        subplot(1,2,1);
        imagesc(reshape(x_recon, N, N)); axis image; colorbar;
        title(title_str);

        subplot(1,2,2);
        imagesc(sino); axis image; colorbar;
        title('Sinogram');
    end
    colormap('gray');
end
