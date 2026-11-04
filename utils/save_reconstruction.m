function save_reconstruction(x_recon, tier, output_dir)
% SAVE_RECONSTRUCTION  Save a reconstruction in submission format.
%
%   save_reconstruction(x_recon, 3, 'submissions/')
%   Saves to submissions/tier3_recon.mat
%
%   x_recon must be an N x N matrix.

    if nargin < 3, output_dir = 'submissions'; end
    if  ~exist(output_dir, 'dir'), mkdir(output_dir); end
    filename = fullfile(output_dir, sprintf('tier%d_recon.mat', tier));
    save(filename, 'x_recon', '-v7');
    fprintf('Saved reconstruction to %s (%d x %d)\n', filename, size(x_recon,1), size(x_recon,2));
end
