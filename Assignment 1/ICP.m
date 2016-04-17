pcd_b = readPcd('data/0000000001.pcd');
pcd_t = readPcd('data/0000000002.pcd');
% Store only the first three columns (spatial data)
pcd_b = pcd_b(:, 1:3);
pcd_t = pcd_t(:, 1:3);
if size(pcd_b) ~= size(pcd_t)
    error('Different number of points between PCDs!')
else
    %% Phase 0: Initialize matrices
    % m = num_points and n = dimensions
    [num_points, dimensions] = size(pcd_b);
    
%     % Rotation matrix initialized as identity
%     R = eye(dimensions, dimensions);
%     % Tranlation matrix initializes as 0
%     T = zeros(1,dimensions);
    
    %% Phase 1: Find closest points
    %n2 = zeros(num_points, num_points);
    sample_points = 100;
    pcd_b = pcd_b(1:sample_points, :);
    pcd_t = pcd_t(1:sample_points, :);
    % Use given function to calculate distance by brute force
    n2 = dist2(pcd_b, pcd_t); 
    % currently throwing an "out of memory" error when using whole point cloud
    
    % For each row (point in base), get column index with lowest value 
    % (closest point in target)
    [dist, idx] = min(n2, [], 2);
    
    % Get actual matched points in target
    pcd_match = pcd_t(idx,:);

    %% Phase 2: finding the geometric centroid 
    % Bc: center of matched base cloud
    Bc = mean(pcd_b);
    % Tc: center of matched target cloud 
    Tc = mean(pcd_match);
    
    % Subtract centroid from each point (row)
    cen_pcd_b     = zeros(sample_points, dimensions);
    cen_pcd_match = zeros(sample_points, dimensions);
    for i = 1:sample_points
        cen_pcd_b(i,:)     = pcd_b(i, :) - Bc;
        cen_pcd_match(i,:) = pcd_match(i, :) - Tc;
    end
    
    %% Phase 3: Apply singular value decomposition
    % Build A matrix
%     A = (cen_pcd_b/size(cen_pcd_b,2)) * ...
%         (cen_pcd_match/size(cen_pcd_match,2))';
    A = cen_pcd_b' * cen_pcd_match;
    
    [U,S,V] =svd(A,'econ');
    
    %% Phase 4: Find R and T
    % Find rotation matrix
    R = U * V';
    
    % Find translation matrix
    T = Bc - Tc * R;
    
    %% Phase 5: Calculate new averages
    new_pcd_t = R * pcd_match';
    new_pcd_t = new_pcd_t';
    for i = 1:sample_points
        new_pcd_t(i,:) = new_pcd_t(i,:) + T;
    end
    dist_old = zeros(sample_points, 1);
    dist_new = zeros(sample_points, 1);
    for i = 1:sample_points
        dist_old(i) = dist2(cen_pcd_b(i, :), cen_pcd_match(i, :));
        dist_new(i) = dist2(cen_pcd_b(i, :), new_pcd_t(i, :));
    end
    fprintf('Old: %i, New: %i, Improved? %i\n',mean(dist_old),...
        mean(dist_new),mean(dist_new) <= mean(dist_old))
    
    figure; hold on
    scatter3(cen_pcd_b(:,1), cen_pcd_b(:,2), cen_pcd_b(:,3), 'b')
    scatter3(cen_pcd_match(:,1), cen_pcd_match(:,2), cen_pcd_match(:,3), 'r')
    title('Rendering of base PC with original target PC')
    
    figure; hold on
    scatter3(cen_pcd_b(:,1), cen_pcd_b(:,2), cen_pcd_b(:,3), 'b')
    scatter3(new_pcd_t(:,1), new_pcd_t(:,2), new_pcd_t(:,3), 'r')
    title('Rendering of base PC with new target PC')

end




