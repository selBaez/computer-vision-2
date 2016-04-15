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
    
    % n2 = dist2(pcd_base, pcd_target); %currently throwing an "out of
    % memory" error

    %% Phase 2: finding the geometric centroid 
    % Bc: center of base cloud
    % Tc: center of target cloud 
    
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




