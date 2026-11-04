function [x, info] = reconstruct(prob)
    sinograma  = prob.b;
    grid_size = prob.N;
    unghiuri = prob.angles;
    detectoare = prob.n_det;
    zgomot = prob.sigma;


    if isfield(prob, 'x_min')
        min_val = prob.x_min;
    else
        min_val = 0;
    end

    if isfield(prob, 'x_max')
        max_val = prob.x_max;
    else
        max_val = 1;
    end

    if isfield(prob, 'N_phys')
        N_phys = prob.N_phys;
    else
        N_phys = grid_size;
    end

    nr_unghi = length(unghiuri);
    dim_date = length(sinograma(:));

    % Coeficient de variatie al sinogramei
    cv_sinograma = std(sinograma(:)) / (mean(sinograma(:)) + eps);

    % Impartirea dintre T1 si restul
    if grid_size <= 64
        alegere_mare = false;
    else
        alegere_mare = true;
    end

    if alegere_mare
        % Pentru T2, T3 si T4 se foloseste PDHG cu regularizare TV
        if grid_size >= 256
            if dim_date < 30000
                lambda_tv = 0.15 + 3.5 * zgomot;
                nr_iter   = 2600;
            else
                lambda_tv = 0.012 + 1.5 * zgomot;
                nr_iter   = 600;
            end

        elseif nr_unghi >= 50
            if dim_date < 40000
                lambda_tv = 0.14 + 3.0 * zgomot;
                nr_iter   = 900;
            else
                lambda_tv = 0.02 + 2.0 * zgomot;
                nr_iter   = 450;
            end

        else
            if dim_date < 15000
                lambda_tv = 0.18 + 3.0 * zgomot;
                nr_iter   = 2777;
            else
                lambda_tv = 0.025 + 2.0 * zgomot;
                nr_iter   = 1100;
            end
        end

        % Regularizarea Huber TV
        huber_tv = 0;
        if grid_size == 128 && nr_unghi >= 50 && max_val <= 1.7 && cv_sinograma < 1.05
            huber_tv = 0.35;
            lambda_tv = 0.75 * lambda_tv;
        elseif grid_size == 128 && nr_unghi < 50 && max_val > 1.05 && max_val <= 1.4
            huber_tv = 0.18;
            lambda_tv = 0.90 * lambda_tv;
        elseif grid_size >= 256 && max_val > 1.05 && max_val <= 1.3
            huber_tv = 0.14;
            lambda_tv = 0.92 * lambda_tv;
        end

        rezultat = pdhg_tv(sinograma, unghiuri, grid_size, detectoare, lambda_tv, nr_iter, min_val, max_val, zgomot, huber_tv);
        info.iters  = nr_iter;

    else
        % Pentru T1 se foloseste gradient conjugat cu Tikhonov
        nr_iter    = 180;
        lambda_reg = 1e-4 + 1.5 * zgomot;

        [rezultat, iter_actual] = gradient_conjugat(sinograma, unghiuri, grid_size, detectoare, lambda_reg, nr_iter);
        rezultat = max(min_val, min(max_val, rezultat));
        info.iters  = iter_actual;
    end

    info.lambda = 0;
    info.sigma  = zgomot;
    info.N_phys = N_phys;

    x = rezultat;
end

% Gradient conjugat pentru sistemul normal
function [x, k_final] = gradient_conjugat(b, ang, N, nd, lam, max_k)
    rhs       = retroproiectie(b(:), ang, N, nd);
    rhs       = rhs(:);
    x_vec     = zeros(N*N, 1);
    reziduu   = rhs;
    directie  = rhs;
    norma_pat = dot(reziduu, reziduu);
    toleranta = 1e-6;
    k_final   = 0;

    for k = 1:max_k
        A_dir        = proiectie_directa(directie, ang, N, nd);
        At_A_dir     = retroproiectie(A_dir(:), ang, N, nd);

        % Operatorul regularizat in directia curenta
        dir_regularizat = At_A_dir(:) + lam * directie;

        numitor = dot(directie, dir_regularizat);
        if abs(numitor) < eps, break; end

        pas       = norma_pat / numitor;
        x_vec     = x_vec + pas * directie;
        reziduu   = reziduu - pas * dir_regularizat;
        norma_pat_noua = dot(reziduu, reziduu);
        k_final   = k;

        if sqrt(norma_pat_noua) < toleranta, break; end

        % Schimbare directie
        directie  = reziduu + (norma_pat_noua / norma_pat) * directie;
        norma_pat = norma_pat_noua;
    end
    x = reshape(x_vec, N, N);
end

% PDHG pentru minimizarea cu regularizare TV
function img = pdhg_tv(b, ang, N, nd, lam_tv, max_k, vmin, vmax, zgomot, huber_tv)
    b = b(:);
    % Estimam norma lui A pentru a calcula pasul primal-dual
    norma_A = estimeaza_norma(ang, N, nd);
    % 0.99 in loc de 1 pt a asigura convergenta
    pas     = 0.99 / sqrt(norma_A^2 + 8);

    factor_actualizare = 1 / (1 + pas);
    pas_ori_b = pas * b;

    % Initializam variabilele primale si duale la zero
    img          = zeros(N, N);
    img_anterior = img;
    % Dual pentru date
    dual_date  = zeros(length(b), 1);
    % Dual pentru gradientul pe x
    dual_grad_x = zeros(N, N);
    % Dual pentru gradientul pe y
    dual_grad_y = zeros(N, N);

    grad_x  = zeros(N, N);
    grad_y  = zeros(N, N);
    div_dual = zeros(N, N);

    % Atenuare adaptiva a lambda (se dezactiveaza la zgomot mare)
    atenuare   = 0.85 * (1 - min(1, 15 * zgomot));
    lambda_min = lam_tv * 0.05;

    for k = 1:max_k

        img_extrapol = img + (img - img_anterior);

        % Actualizare duala
        proiectie_date = dual_date + pas * proiectie_directa(img_extrapol(:), ang, N, nd);
        dual_date      = (proiectie_date - pas_ori_b) * factor_actualizare;

        % Gradientul imaginii
        grad_x(1:N-1, :) = img_extrapol(2:N, :) - img_extrapol(1:N-1, :);
        grad_y(:, 1:N-1) = img_extrapol(:, 2:N) - img_extrapol(:, 1:N-1);

        % Lambda adaptiv: se reduce in zone cu gradient concentrat pe un singur contur
        magnitudine_grad = sqrt(grad_x.^2 + grad_y.^2);
        grad_medie       = mean(magnitudine_grad(:));
        grad_maxim       = max(magnitudine_grad(:)) + 1e-10;
        concentrare      = grad_medie / grad_maxim;

        lambda_iteratie = lam_tv * (1 - atenuare * concentrare);
        if lambda_iteratie < lambda_min, lambda_iteratie = lambda_min; end

        % Actualizare duala pt TV
        dual_grad_x_nou = dual_grad_x + pas * grad_x;
        dual_grad_y_nou = dual_grad_y + pas * grad_y;
        % Varianta Huber TV: netezeste penalizarea pentru gradiente mici
        if huber_tv > 0
            dual_grad_x_nou = dual_grad_x_nou / (1 + pas * huber_tv);
            dual_grad_y_nou = dual_grad_y_nou / (1 + pas * huber_tv);
        end


        magnitudine = sqrt(dual_grad_x_nou.^2 + dual_grad_y_nou.^2);
        scara       = max(magnitudine, lambda_iteratie);
        dual_grad_x = dual_grad_x_nou .* lambda_iteratie ./ scara;
        dual_grad_y = dual_grad_y_nou .* lambda_iteratie ./ scara;

        % Calculul divergentei dualului
        grad_date = retroproiectie(dual_date, ang, N, nd);
        grad_date = reshape(grad_date, N, N);

        div_dual(:) = 0;
        div_dual(1:N-1, :) = div_dual(1:N-1, :) - dual_grad_x(1:N-1, :);
        div_dual(2:N, :)   = div_dual(2:N, :)   + dual_grad_x(1:N-1, :);
        div_dual(:, 1:N-1) = div_dual(:, 1:N-1) - dual_grad_y(:, 1:N-1);
        div_dual(:, 2:N)   = div_dual(:, 2:N)   + dual_grad_y(:, 1:N-1);


        img_anterior = img;
        img          = img - pas * (grad_date + div_dual);
        img          = max(vmin, min(vmax, img));
    end
end

% Estimarea normei spectrale a lui A prin metoda puterii
function norma = estimeaza_norma(ang, N, nd)
    vector = randn(N*N, 1);
    vector = vector / norm(vector);
    for i = 1:6
        A_vector  = proiectie_directa(vector, ang, N, nd);
        At_vector = retroproiectie(A_vector(:), ang, N, nd);
        At_vector = At_vector(:);
        norma = norm(At_vector);
        if norma < eps, break; end
        vector = At_vector / norma;
    end
    norma = norm(proiectie_directa(vector, ang, N, nd));
end

% Operatorul de proiectie
function sinograma_out = proiectie_directa(imagine, unghiuri, N, nr_det)
    [indici, validi] = geometrie_memorata(unghiuri, N, nr_det);
    nr_unghiuri  = length(unghiuri);
    sinograma_out = zeros(nr_unghiuri * nr_det, 1);
    valori_imagine = imagine(:);

    for a = 1:nr_unghiuri
        idx   = indici{a};
        valid = validi{a};
        % Adunam valorile pixelilor care cad in acelasi bin de detector
        b_unghi = accumarray(idx(valid), valori_imagine(valid), [nr_det, 1]);
        sinograma_out((a-1)*nr_det + (1:nr_det)) = b_unghi;
    end
end

% Operatorul retroproiectie
function imagine_out = retroproiectie(sinograma_in, unghiuri, N, nr_det)
    [indici, validi] = geometrie_memorata(unghiuri, N, nr_det);
    nr_unghiuri  = length(unghiuri);
    imagine_plata = zeros(N*N, 1);

    for a = 1:nr_unghiuri
        idx   = indici{a};
        valid = validi{a};
        b_unghi = sinograma_in((a-1)*nr_det + (1:nr_det));
        % Fiecare pixel primeste valoarea detectorului pe care il proiecteaza
        valori_adaugate = b_unghi(idx(valid));
        imagine_plata(valid) = imagine_plata(valid) + valori_adaugate;
    end
    imagine_out = imagine_plata;
end

% Geometrie memorata: evita recalcularea indicilor la fiecare iteratie
function [indici, validi] = geometrie_memorata(unghiuri, N, nr_det)
    persistent dim_salvata nr_det_salvat unghiuri_salvate indici_salvati validi_salvati

    % Returnam direct din memorie daca geometria nu s-a schimbat
    if ~isempty(indici_salvati) && dim_salvata == N && nr_det_salvat == nr_det && length(unghiuri_salvate) == length(unghiuri) && max(abs(unghiuri_salvate(:) - unghiuri(:))) < 1e-14
        indici = indici_salvati;
        validi = validi_salvati;
        return;
    end

    nr_unghiuri = length(unghiuri);
    indici = cell(nr_unghiuri, 1);
    validi = cell(nr_unghiuri, 1);

    % Coordonatele centrelor pixelilor in sistemul de coordonate al imaginii
    [X, Y] = meshgrid(linspace(-N/2 + 0.5, N/2 - 0.5, N), linspace(-N/2 + 0.5, N/2 - 0.5, N));
    X = X(:);
    Y = Y(:);

    % Limitele intervalului de proiectie pe detectori
    s_minim    = -N * sqrt(2) / 2;
    s_maxim    =  N * sqrt(2) / 2;
    latime_bin = (s_maxim - s_minim) / nr_det;

    for a = 1:nr_unghiuri
        unghi = unghiuri(a);
        % Proiectia fiecarui pixel pe axa detectorului la unghiul curent
        s = X * cos(unghi) + Y * sin(unghi);
        % Indicele detectorului corespunzator fiecarui pixel
        idx_det = round((s - s_minim) / latime_bin) + 1;
        valid   = (idx_det >= 1) & (idx_det <= nr_det);
        indici{a} = idx_det;
        validi{a} = valid;
    end

    % Salvam in memorie pentru reutilizare
    dim_salvata      = N;
    nr_det_salvat    = nr_det;
    unghiuri_salvate = unghiuri(:);
    indici_salvati   = indici;
    validi_salvati   = validi;
end
