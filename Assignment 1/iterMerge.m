% AUTHORS
% Selene Baez & Ildefonso Ferreira Pica
%
% DESCRIPTION
% Merge the PCDs iteratively, using an ICP algorithm.

num_frames = 99;
object_distance = 1.5;
data_path = 'data/00000000%02d.pcd';
next = 2;
performance = [];

figure; hold on
for f = 0:next:num_frames-next
    fprintf('Frame: %d\n', f);
    
    % Read cloud data
    cloud_path      = sprintf(data_path, f);
    cloud_next_path = sprintf(data_path, (f+next));
    
    if f == 0
        base = readPcd(cloud_path);
    end
    target = readPcd(cloud_next_path);
    
    % Discard background
    base = base(base(:,3) < object_distance, :);
    target = target(target(:,3) < object_distance, :);
    % Keep the first three colums (x, y, z coordinates)
    base = base(:, 1:3);
    target = target(:, 1:3);
    
    [~, ~, R, T, diff] = ICP(base, target, 10000, 10, 0.001);

    M = [R, T'; 0 0 0 1];
    disp(M)
    
    target_h = [target, ones(length(target), 1)];
    match  = (M * target_h')';
    scatter3(match(:, 1), match(:, 2), match(:, 3), '.')
    performance = vertcat(performance, diff(end));
    base = vertcat(base, match(:, 1:3));
end

% Plot the difference in distance between the two PCDs across iterations
figure; hold on
plot(performance,'+-')
xlabel('Iterative count')
ylabel('Improvement in Difference of Distance')
title('Improvement in each iterative step')