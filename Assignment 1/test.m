load('source.mat');
load('target.mat');

pcd_b = source';
pcd_t = target';

num_points = min(size(pcd_b, 1), size(pcd_t, 1));

[pcd_b, new_pcd_t, r, R, T] = own_ICP(pcd_b, pcd_t, num_points);

M = [R, T'; 0 0 0 1];
m = [r, T'; 0 0 0 1];
pcd_th = [pcd_t, ones(length(pcd_t), 1)];
pcd_bh = [pcd_b, ones(length(pcd_b), 1)];
match  = (M * pcd_th')';
nmatch = (m * pcd_th')';
figure; hold on
scatter3(pcd_bh(:, 1), pcd_bh(:, 2), pcd_bh(:, 3))
scatter3(match(:, 1), match(:, 2), match(:, 3)) % normalized
scatter3(nmatch(:, 1), nmatch(:, 2), nmatch(:, 3))