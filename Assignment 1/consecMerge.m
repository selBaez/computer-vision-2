% AUTHORS
% Selene Baez & Ildefonso Ferreira Pica
%
% DESCRIPTION
% Merge the PCDs consecutively, using an ICP algorithm.

% num_frames = 99;
num_frames = 8;
object_distance = 1.5;
data_path = 'data/00000000%02d.pcd';
next = 4;
diff_list = [];

figure; hold on
for f = 0:next:num_frames-next
    fprintf('Frame: %d\n', f);
    
    % Read cloud
    cloud_path      = sprintf(data_path, f);
    cloud_next_path = sprintf(data_path, (f+next));
    
    base = readPcd(cloud_path);
    target = readPcd(cloud_next_path);
    
    % Discard background
    base = base(base(:,3) < object_distance, :);
    target = target(target(:,3) < object_distance, :);
    % Keep the first three colums (x, y, z coordinates)
    base = base(:, 1:3);
    target = target(:, 1:3);
    
    [~, ~, R, T, ~] = ICP(base, target, 10000, 20, 0.001);

    M = [R, T'; 0 0 0 1];
    target_h = [target, ones(length(target), 1)];
    match  = (M * target_h')';
    scatter3(match(:, 1), match(:, 2), match(:, 3), '.')
end