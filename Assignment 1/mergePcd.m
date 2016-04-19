object_distance = 60;
pcd0 = readPcd('data/0000000000.pcd');
pcd1 = readPcd('data/0000000001.pcd');
% Discard points that are too close by
pcd0 = pcd0(pcd0(:,3) > object_distance, :);
pcd1 = pcd1(pcd1(:,3) > object_distance, :);
% Keep the first three colums (x, y, z coordinates)
pcd0 = pcd0(:, 1:3);
pcd1 = pcd1(:, 1:3);

[~, ~, R, T] = own_ICP(pcd0, pcd1, 1000);