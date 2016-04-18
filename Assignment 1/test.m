load('source.mat');
load('target.mat');

pcd_b = source';
pcd_t = target';

[num_points, dimensions] = size(pcd_b);

[pcd_b, new_pcd_t, R, T] = own_ICP(pcd_b, pcd_t, num_points);