pcd_base   = readPcd('data/0000000001.pcd');
pcd_target = readPcd('data/0000000001.pcd');

if size(pcd_base) ~= size(pcd_target)
    error('Different number of points between PCDs!')
else
    %% Phase 0: Initialize matrices
    % Rotation matrix initialized as identity
    R = eye(3,3);
    % Tranlation matrix initializes as 0
    T = zeros(1,3);
    
    %% Phase 1: Find closest points
    num_points = 100;
    
    %n2 = zeros(num_points, num_points);
    n2 = dist2(pcd_base(1:num_points, :), pcd_target(1:num_points, :)); % currently throwing an "out of
    % memory" error when using whole point cloud
    
    % For each row in n2 (each point in base), get column with lowest value
    % (closest point in target)
    [dist idx] = min(n2, [], 2);
    
    pcd_matched = pcd_target(idx,:);

    %% Phase 2: finding the geometric centroid 
    % Bc: center of base cloud
    Bc = mean(pcd_base(1:num_points, :));
    % Tc: center of target cloud 
    Tc = mean(pcd_matched);
    
    % Subtract centroid %TODO Revise this part
    new_pcd_base   = pcd_base - Bc;
    new_pcd_target = pcd_target - Tc;
    
    %% Phase 3: Apply singular value decomposition
    % FOR ALL matched point pair AS i:
    % A += (#i point in base cloud - Bc)*(#i point in
    % target cloud - Tc)
    
    % A matrix for decomposition
    
    %% Phase 4: Find R and T
    % Find rotation matrix
    % R = UV'
    
    % Find translation matrix
    % T = Bc - Tc * R
    
    %% Phase 5: Calculate new averages


end




