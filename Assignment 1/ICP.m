pcd_base   = readPcd('data/0000000001.pcd');
pcd_target = readPcd('data/0000000001.pcd');

if size(pcd_base) ~= size(pcd_target)
    error('Different number of points between PCDs!')
else
    %% Phase 0: Initialize matrices
    % m = num_points and n = dimensions
    [num_points, dimensions] = size(pcd_base);
    
    % Rotation matrix initialized as identity
    R = eye(dimensions, dimensions);
    % Tranlation matrix initializes as 0
    T = zeros(1,dimensions);
    
    %% Phase 1: Find closest points
    %n2 = zeros(num_points, num_points);
    sample_points = 100;
    
    % Use given function to calculate distance by brute force
    n2 = dist2(pcd_base(1:sample_points, :), pcd_target(1:sample_points, :)); 
    % currently throwing an "out of memory" error when using whole point cloud
    
    % For each row (point in base), get column index with lowest value 
    % (closest point in target)
    [dist idx] = min(n2, [], 2);
    
    % Get actual matched points in target
    pcd_matched = pcd_target(idx,:);

    %% Phase 2: finding the geometric centroid 
    % Bc: center of matched base cloud
    Bc = mean(pcd_base(1:sample_points, :));
    % Tc: center of matched target cloud 
    Tc = mean(pcd_matched);
    
    % Subtract centroid from each point (row)
    new_pcd_base   = zeros(sample_points, dimensions);
    for i = 1:sample_points
        new_pcd_base(i,:) = pcd_base(i, :) - Bc;
    end
    
    new_pcd_matched   = zeros(sample_points, dimensions);
    for i = 1:sample_points
        new_pcd_matched(i,:) = pcd_matched(i, :) - Tc;
    end
    
    %% Phase 3: Apply singular value decomposition
    % Build A matrix
    A = zeros(sample_points, dimensions);
    for i=1:sample_points
        A(i, :) = new_pcd_base(i) * new_pcd_matched(i);
    end
    
    [U,S,V] =svd(A,'econ');
    
    %% Phase 4: Find R and T
    % Find rotation matrix
    R = U * V';
    
    % Find translation matrix
    T = Bc - Tc * R;
    
    %% Phase 5: Calculate new averages


end




