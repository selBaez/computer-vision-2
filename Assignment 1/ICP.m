pcd0 = readPcd('/data/0000000001.pcd');
pcd1 = readPcd('/data/0000000001.pcd');
dim0 = size(pcd0);
dim1 = size(pcd1);
if dim0 ~= dim1
    disp('Different number of points between PCDs!')
end
R = eye(dim0(2),1);