% AUTHORS
% Selene Baez & Ildefonso Ferreira Pica
% 
% DESCRIPTION
% Test script to validate our implementation of the ICP algorithm.

load('source.mat');
load('target.mat');

base = source';
target = target';

% Plot PCDs prior to ICP
figure; hold on
scatter3(base(:, 1), base(:, 2), base(:, 3))
scatter3(target(:, 1), target(:, 2), target(:, 3))
title('Initial PCD.')

n_samples = min(size(base, 1), size(target, 1));
% Perform the ICP
[~, ~, R, T, diff_list] = ICP(base, target, n_samples, 30, 0.001);
% Compose the transformation matrix (4x4)
M = [R, T'; 0 0 0 1];
% Modify the target PCD matrix, to allow for multiplication with M
target_h = [target, ones(length(target), 1)];
% Apply the transformation matrix on the target PCD matrix
match  = (M * target_h')';

% Plot the results
figure; hold on
scatter3(base(:, 1), base(:, 2), base(:, 3))
scatter3(match(:, 1), match(:, 2), match(:, 3))
title('PCD after alignment with ICP algorithm.')

% Plot the difference in distance between the two PCDs across iterations
figure; hold on
plot(diff_list,'+-')
xlabel('Iterative count')
ylabel('Improvement in Difference of Distance')
title('Improvement in each iterative step')