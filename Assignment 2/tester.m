% run('vlfeat-0.9.20/toolbox/vl_setup.m');
im1_path = '/House/frame00000001.png';
im2_path = '/House/frame00000002.png';

im1 = imread(im1_path);
im2 = imread(im2_path);

[T1, T2] = funMat(im1, im2, 0);