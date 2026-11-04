function show_convergence(residuals, errors, delta)
% SHOW_CONVERGENCE  Plot convergence history of an iterative method.
%
%   show_convergence(residuals)           - plot residual norm vs iteration
%   show_convergence(residuals, errors)   - also plot true error (practice only)
%   show_convergence(residuals, [], delta)- also plot noise floor
%
%   residuals - vector of ||Ax_k - b|| at each iteration k
%   errors    - vector of ||x_k - x_true|| at each iteration (optional, [] to skip)
%   delta     - noise floor sqrt(m)*sigma (optional, plotted as horizontal line)

    iterations = 1:length(residuals);
    figure;
    semilogy(iterations, residuals, 'b-', 'LineWidth', 2);
    hold on;
    if nargin >= 2 && ~isempty(errors)
        semilogy(iterations, errors, 'r--', 'LineWidth', 2);
        legend('Residual ||Ax-b||', 'Error ||x-x_true||');
    end
    if nargin >= 3 && ~isempty(delta)
        yline(delta, 'k--', 'LineWidth', 1.5, 'Label', 'Noise floor');
    end
    xlabel('Iteration');
    ylabel('Norm (log scale)');
    grid on;
    hold off;
end
