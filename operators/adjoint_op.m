
function y = adjoint_op(b, angles, N, n_det)
% ADJOINT_OP  Vectorized backprojection (adjoint of forward projection).
%
%   y = adjoint_op(b, angles, N, n_det)
%
%   Inputs:
%     b       - Column vector of length n_angles * n_det (sinogram, flattened)
%     angles  - Column vector of projection angles in radians
%     N       - Scalar, image grid size
%     n_det   - Scalar, number of detector bins per projection
%
%   Output:
%     y       - Column vector of length N*N (backprojected image, flattened)

    image = zeros(N, N);
    n_angles = length(angles);
    
    % Create pixel center coordinates
    [X, Y] = meshgrid(linspace(-N/2 + 0.5, N/2 - 0.5, N), ...
                      linspace(-N/2 + 0.5, N/2 - 0.5, N));
    X = X(:); 
    Y = Y(:);

    % Detector range
    s_min = -N * sqrt(2) / 2;
    s_max = N * sqrt(2) / 2;
    bin_width = (s_max - s_min) / n_det;

    for a = 1:n_angles
        theta = angles(a);
        % Project coordinates to find which bin each pixel belongs to
        s = X * cos(theta) + Y * sin(theta);
        idx = round((s - s_min) / bin_width) + 1;
        
        % Valid indices for this angle
        valid = (idx >= 1) & (idx <= n_det);
        
        % Get the sinogram values for the valid bins
        b_angle = b((a-1)*n_det + (1:n_det));
        vals = b_angle(idx(valid));
        
        % Add these values back to the corresponding pixels in the image
        % We use linear indexing for the image to be fast
        img_flat = image(:);
        img_flat(valid) = img_flat(valid) + vals;
        image = reshape(img_flat, N, N);
    end
    y = image(:);
end
