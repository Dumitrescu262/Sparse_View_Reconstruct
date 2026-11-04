function y = apply_ata(x, angles, N, n_det, lambda)
% APPLY_ATA  Compute (A'*A + lambda*I) * x using the operator functions.
%
%   y = apply_ata(x, angles, N, n_det, lambda)
%
%   This computes the matrix-vector product needed by CG and other iterative
%   methods for the Tikhonov-regularized normal equations, without ever
%   forming the matrix A'*A.
%
%   Inputs:
%     x       - Column vector of length N*N
%     angles  - Projection angles in radians
%     N       - Image grid size
%     n_det   - Detector bins per projection
%     lambda  - Tikhonov regularization parameter (scalar >= 0)
%
%   Output:
%     y       - Column vector of length N*N: A'*(A*x) + lambda*x

    Ax = forward_op(x, angles, N, n_det);
    y  = adjoint_op(Ax, angles, N, n_det) + lambda * x;
end
