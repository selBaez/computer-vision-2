load('source.mat');
load('target.mat');

pcd_b = source';
pcd_t = target';

num_points = min(size(pcd_b, 1), size(pcd_t, 1));

[pcd_b, new_pcd_t, R, T] = own_ICP(pcd_b, pcd_t, num_points);