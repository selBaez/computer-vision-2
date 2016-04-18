function [pcd_b, new_pcd_t, R, T] = own_ICP(pcd_b, pcd_t, sample_points)
%OWN_ICP Implements a basic ICP algorithm, given two point clouds on 3D and
%the number of sample points

if size(pcd_b) ~= size(pcd_t)
    error('Different number of points between PCDs!')
else
    %% Phase 0: Initialize
    threshold = 0.001;
    max_iterations = 30; 
    
    pcd_b = pcd_b(1:sample_points, :);
    pcd_t = pcd_t(1:sample_points, :);
    counter = 1;
    
    while 1
        %% Phase 1: Find closest points
        % Use given function to calculate distance among all points
        n2 = dist2(pcd_b, pcd_t);
        
        % For each point in base, get index of closest point in target
        [~, idx] = min(n2, [], 2);
        % Get actual matched points in target
        pcd_match = pcd_t(idx,:);
        
        
        %% Phase 2: Center point clouds
        % Bc: center of matched base cloud
        Bc = mean(pcd_b);
        % Tc: center of matched target cloud
        Tc = mean(pcd_match);
        
        % Subtract centroid from each point
        cen_pcd_b = pcd_b - repmat(Bc, sample_points, 1);
        cen_pcd_match = pcd_match - repmat(Tc, sample_points, 1);
        
        
        %% Phase 3: Apply singular value decomposition
        % Build A (covariance) matrix
        A = cen_pcd_b' * cen_pcd_match;
 
        [U,S,V] = svd(A,'econ');
        
        
        %% Phase 4: Find R and T
        % Find rotation matrix
        R = U * V';
        
        % Find translation matrix
        T = Bc - Tc * R;
        
        
        %% Phase 5: Calculate new averages distances using transformation matrices
        new_pcd_t = R * pcd_match' + repmat(T', 1, sample_points);
        new_pcd_t = new_pcd_t';
        
        dist_old = zeros(sample_points, 1);
        dist_new = zeros(sample_points, 1);
        for i = 1:sample_points
            dist_old(i) = dist2(pcd_b(i, :), pcd_t(i, :));
            dist_new(i) = dist2(pcd_b(i, :), new_pcd_t(i, :));
        end
        
        fprintf('Old: %i, New: %i, Improved? %i\n', mean(dist_old),...
            mean(dist_new), mean(dist_new) <= mean(dist_old))
        
        % Stop condition
        if (mean(dist_new) < threshold || counter >= max_iterations)
            break
        else
            counter = counter + 1;
            pcd_t = new_pcd_t;
        end
    end
    figure; hold on
    scatter3(pcd_b(:,1), pcd_b(:,2), pcd_b(:,3), 'b')
    scatter3(new_pcd_t(:,1), new_pcd_t(:,2), new_pcd_t(:,3), 'r')
    title('Rendering of base PC with new target PC')
    fprintf('Done!\nNumber of iterations: %i\n', counter)
end

end