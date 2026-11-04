
function b = forward_op(x, angles, N, n_det)
% FORWARD_OP  Vectorized forward projection (sinogram) of an image.
%
%   b = forward_op(x, angles, N, n_det)
%
%   Inputs:
%     x       - Column vector of length N*N (image flattened in column-major order)
%     angles  - Column vector of projection angles in radians
%     N       - Scalar, image grid size (N x N)
%     n_det   - Scalar, number of detector bins per projection
%
%   Output:
%     b       - Column vector of length n_angles * n_det (sinogram, flattened)

    image = reshape(x, N, N);
    n_angles = length(angles);
    b = zeros(n_angles * n_det, 1);
    
    % Create pixel center coordinates
    [X, Y] = meshgrid(linspace(-N/2 + 0.5, N/2 - 0.5, N), ...
                      linspace(-N/2 + 0.5, N/2 - 0.5, N));
    X = X(:); 
    Y = Y(:);
    vals = x;

    % Detector range
    s_min = -N * sqrt(2) / 2;
    s_max = N * sqrt(2) / 2;
    bin_width = (s_max - s_min) / n_det;

    for a = 1:n_angles
        theta = angles(a);
        % Project coordinates onto the detector line for this angle
        % s = x*cos(theta) + y*sin(theta)
        s = X * cos(theta) + Y * sin(theta);
        
        % Map projection values to bin indices [1, n_det]
        idx = round((s - s_min) / bin_width) + 1;
        
        % Filter indices to stay within detector bounds
        valid = (idx >= 1) & (idx <= n_det);
        
        % Use accumarray to sum pixel values into bins
        % b_angle = accumarray(idx(valid), vals(valid), [n_det, 1]);
        % Since accumarray might be slower than needed or not available in all Octave versions,
        % we can use a simple loop for the accumulation if needed, but accumarray is standard.
        b_angle = accumarray(idx(valid), vals(valid), [n_det, 1]);
        
        b((a-1)*n_det + (1:n_det)) = b_angle;
    end
end
