% load('source.mat');
% load('target.mat');

% pcd_b = source';
% pcd_t = target';

object_distance = 1.5;

pcd_b = readPcd('data/0000000000.pcd');
pcd_t = readPcd('data/0000000001.pcd');

figure; hold on
scatter3(pcd_b(:, 1), pcd_b(:, 2), pcd_b(:, 3), 'fill')
scatter3(pcd_t(:, 1), pcd_t(:, 2), pcd_t(:, 3), 'fill')

pcd_b = pcd_b(pcd_b(:,3) < object_distance, :);
pcd_t = pcd_t(pcd_t(:,3) < object_distance, :);
% Keep the first three colums (x, y, z coordinates)
pcd_b = pcd_b(:, 1:3);
pcd_t = pcd_t(:, 1:3);

figure; hold on
scatter3(pcd_b(:, 1), pcd_b(:, 2), pcd_b(:, 3), '.')
scatter3(pcd_t(:, 1), pcd_t(:, 2), pcd_t(:, 3), '.')

% num_points = min(size(pcd_b, 1), size(pcd_t, 1));
num_points = 10000;
[pcd_b, new_pcd_t, r, R, T] = own_ICP(pcd_b, pcd_t, num_points);

M = [r, T'; 0 0 0 1];
M = inv(M);
% m = [r, T'; 0 0 0 1];
pcd_th = [pcd_t, ones(length(pcd_t), 1)];
pcd_bh = [pcd_b, ones(length(pcd_b), 1)];
match  = (M * pcd_bh')';
% nmatch = (m * pcd_th')';
figure; hold on
scatter3(pcd_bh(:, 1), pcd_bh(:, 2), pcd_bh(:, 3), '.')
scatter3(match(:, 1), match(:, 2), match(:, 3), '.')
% scatter3(match(:, 1), match(:, 2), match(:, 3)) % normalized