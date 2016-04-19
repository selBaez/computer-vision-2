num_frames = 99;
object_distance = 60;
data_path = 'data/00000000%02d.pcd';
next = 2;

figure; hold on
for f = 0:6
    fprintf('Frame: %d\n', f);
    
    % Read cloud
    cloud_path      = sprintf(data_path, f);
    cloud_next_path = sprintf(data_path, (f+next));
    
    pcd0 = readPcd(cloud_path);
    pcd1 = readPcd(cloud_next_path);
    
    % Discard points that are too close by
    pcd0 = pcd0(pcd0(:,3) > object_distance, :);
    pcd1 = pcd1(pcd1(:,3) > object_distance, :);
    % Keep the first three colums (x, y, z coordinates)
    pcd0 = pcd0(:, 1:3);
    pcd1 = pcd1(:, 1:3);
    
    [~, ~, r, R, T] = own_ICP(pcd0, pcd1, 1000);

    M = [R, T'; 0 0 0 1];
    M = inv(M);
    pcd1h = [pcd1, ones(length(pcd1), 1)];
    pcd0h = [pcd0, ones(length(pcd0), 1)];
    match  = (M * pcd1h')';
    scatter3(match(:, 1), match(:, 2), match(:, 3),'filled')
end

% figure; hold on
% scatter3(pcd0(:, 1), pcd0(:, 2), pcd0(:, 3), 'filled')
% scatter3(pcd1(:, 1), pcd1(:, 2), pcd1(:, 3), 'filled')