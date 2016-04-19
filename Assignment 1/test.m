load('source.mat');
load('target.mat');

pcd_b = source';
pcd_t = target';

num_points = min(size(pcd_b, 1), size(pcd_t, 1));

[pcd_b, new_pcd_t, R, T] = own_ICP(pcd_b, pcd_t, num_points);
% for i = 1:3
% R(:,i) = R(:,i)/norm(R(:,i));
% end
% T = T/norm(T);
for i = 1:3
R(i,i) = 1;
end

M = [R, T'; 0 0 0 1];
pcd_th = [pcd_t, ones(length(pcd_t), 1)];
pcd_bh = [pcd_t, ones(length(pcd_b), 1)];
match  = (M * pcd_bh')';
figure; hold on
scatter3(pcd_th(:, 1), pcd_th(:, 2), pcd_th(:, 3))
scatter3(match(:, 1), match(:, 2), match(:, 3))