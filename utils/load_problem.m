function prob = load_problem(filepath)
% LOAD_PROBLEM  Load a competition problem from a .mat file.
%
%   prob = load_problem('data/competition/tier3.mat')
%
%   Returns a struct with fields:
%     prob.b       - Sinogram vector (column, length m = n_angles * n_det)
%     prob.angles  - Projection angles in radians (column vector)
%     prob.N       - Image grid size (image is N x N)
%     prob.n_det   - Number of detector bins per angle
%     prob.sigma   - Noise standard deviation
%     prob.x_min   - Minimum intensity of true image
%     prob.x_max   - Maximum intensity of true image
%     prob.x_true  - Ground truth image (N x N), ONLY in practice files
%                    (empty [] for competition files)

    data = load(filepath);
    
    % Handle different variable naming schemes (b vs b_prac/b_comp)
    if isfield(data, 'b')
        prob.b = data.b(:);
        prob.angles = data.angles(:);
        prob.N = data.N;
        prob.n_det = data.n_det;
        prob.sigma = data.sigma;
        prob.x_min = data.x_min;
        prob.x_max = data.x_max;
    elseif isfield(data, 'b_prac')
        prob.b = data.b_prac(:);
        prob.angles = data.angles_prac(:);
        prob.N = data.N_prac;
        prob.n_det = data.n_det_prac;
        prob.sigma = data.sigma_prac;
        prob.x_min = data.x_min_prac;
        prob.x_max = data.x_max_prac;
    elseif isfield(data, 'b_comp')
        prob.b = data.b_comp(:);
        prob.angles = data.angles_comp(:);
        prob.N = data.N_comp;
        prob.n_det = data.n_det_comp;
        prob.sigma = data.sigma_comp;
        prob.x_min = data.x_min_comp;
        prob.x_max = data.x_max_comp;
    else
        error('Unsupported .mat file format: no sinogram found (b, b_prac, or b_comp)');
    end

    if isfield(data, 'x_true')
        prob.x_true = data.x_true;
    elseif isfield(data, 'x_true_prac')
        prob.x_true = data.x_true_prac;
    else
        prob.x_true = [];
    end
end
