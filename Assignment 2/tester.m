% run('vlfeat-0.9.20/toolbox/vl_setup.m');
im1_path = 'House/frame00000001.png';
im2_path = 'House/frame00000002.png';

im1 = imread(im1_path);
im2 = imread(im2_path);

[points, F] = funMat(im1, im2, 2, 0, 0.5);

scatter3(finalPC(1,:), finalPC(2,:), finalPC(3,:))