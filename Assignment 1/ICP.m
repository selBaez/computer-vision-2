function [base, new_target, R, T, diff_list] = ICP(base, target, n_samples, n_iter, threshold)
% AUTHORS
% Selene Baez & Ildefonso Ferreira Pica
% 
% DESCRIPTION
% Implementation of a basic Iterative Closest Point (ICP) algorithm for
% point cloud matching.
% 
% INPUTS
% base      : array (Nx3) of the base point cloud.
% target    : array (Mx3) of the target point cloud.
% n_samples : max. number of points to be sampled for matching.
% n_iter    : max. number of iterations to be performed.
% threshold : desired accuracy to be reached.
% 
% OUTPUTS
% R         : rotation matrix (3x3):    R * target + T -> base.
% T         : translation vector (1x3): R * target + T -> base.
% diff_list : the difference in distance between the PCDs across
%             iterations.
% base      : array (Sx3) of the base point cloud.
% new_target: array (Sx3) of the transformed target point cloud.

if size(base) ~= size(target)
    error('Different number of points between PCDs!')
else
    %% Initialization
    diff_list = [];
    R = eye(3);
    T = zeros(1,3);
    n_points = min(size(base, 1), size(target, 1));
    if n_points < n_samples
        n_samples = n_points;
        fprintf('Number of points sampled: %i\n', n_samples)
    end
    % Randomly sample the PCDs
    base = base(randperm(n_samples), :);
    target = target(randperm(n_samples), :);
    counter = 1;
    
    % Center the base PCD
    Bc = mean(base);
    cen_base = base - repmat(Bc, n_samples, 1);
    while 1
        %% Phase 1: Find closest matching points
        % Center the target PCD
        Tc = mean(target);
        cen_target = target - repmat(Tc, n_samples, 1);
        
        % Calculate the distance between all points
        n2 = dist2(cen_base, cen_target);
        
        % For each point in the base PCD, get the index of the closest
        % point in the target PCD
        [~, idx] = min(n2, [], 2);
        
        % Compute the matched points in the target PCD
        cen_match = cen_target(idx, :);
        
        %% Phase 2: Apply the singular value decomposition (SVD)
        % Build covariance matrix A
        A = cen_base' * cen_match;
        [U, ~, V] = svd(A, 'econ');
        
        %% Phase 3: Compute the rotation matrix R, and translation vector T
        r = U * V';
        t = Bc - Tc * r; % Maybe replace with Tc
        
        %% Phase 4: Calculate the post-transformation average distances
        new_target = (r * target' + repmat(t', 1, n_samples))';
        dist_old = zeros(n_samples, 1);
        dist_new = zeros(n_samples, 1);
        for i = 1:n_samples
            dist_old(i) = dist2(base(i, :), target(i, :));
            dist_new(i) = dist2(base(i, :), new_target(i, :));
        end
        
        fprintf('I: %i, Old: %i, New: %i, Improved? %i\n',...
            counter, mean(dist_old), mean(dist_new),...
            mean(dist_new) < mean(dist_old))
        
        diff = mean(dist_old) - mean(dist_new);
        diff_list = vertcat(diff_list, diff);
        
        % Stop condition
        if mean(dist_new) < threshold || counter >= n_iter
            break
        else
            counter = counter + 1;
            target = new_target;
            R = r * R;
            T = T + t;
        end
    end
end
end