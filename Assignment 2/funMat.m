% OUTLINE
% 1. Detect interest points in the image
% 2. Characterize the local appearance of the regions around interest points. 
% 3. Get a set of supposed matches between region descriptors in each image.
% 4. Estimate the fundamental matrix for the given two images.
% Note: Eliminating detected interest points on background can help <- HOW?

function [out1, out2] = funMat(im1, im2, show)
if show
    [~, f1, f2] = show_keypointmatches(im1, im2, 10);
else
    [~, f1, f2] = keypoint_matches(im1, im2);
end
x1 = f1(:,1); x2 = f2(:,1);
y1 = f1(:,2); y2 = f2(:,2);
os = ones(size(x1));

% 1.1 EIGHT-POINT ALGORITHM
% Construct the matrix A by pointwise multiplying the keypoint-coordinate
% arrays (x1, y1, x2, y2).
A = [x1.*x2, x1.*y2, x1, y1.*x2, y1.*y2, y1, x2, y2, os];
% The entries of F are the components of the column of V 
% corresponding to the smallest singular value; the diagonal values
% lie on the diagonal of S.
[~, S, V] = svd(A);
[~, idx] = sort(diag(S));
% Select the columns corresponding to the 3 smallest singular values.
% How should the columns of F be ordered?
F = V(:, idx(1:3));
fprintf('rank(F) = %i\n', rank(F))
% An important property of fundamental matrix is that it is singular,
% in fact of rank two. The estimated fundamental matrix F will not in 
% general have rank two.
% Find the SVD of F
[Uf, Sf, Vf] = svd(F);
% Set the smallest singular value in the diagonal matrix Df
% to zero in order to obtain the corrected matrix D'f.
[~, idx] = min(Sf); Sf(idx) = 0;
% Recompute F: F = Uf * Sf * Vf'
F = Uf * Sf * Vf';
fprintf('rank(F'') = %i\n', rank(F))
% 1.2 NORMALIZED EIGHT-POINT ALGORITHM
% We want to apply a similarity transformation to the set of points {pi}
% so that their mean is 0 and the average distance to the mean is sqrt(2).
mx1 = mean(x1); mx2 = mean(x2);
my1 = mean(y1); my2 = mean(y2);
d1 = mean(sqrt((x1-mx1).^2 + (y1-my1).^2));
d2 = mean(sqrt((x2-mx2).^2 + (y2-my2).^2));
T1 = [sqrt(2)/d1, 0, -mx1*sqrt(2)/d1;
      0, sqrt(2)/d1, -my1*sqrt(2)/d1;
      0, 0, 1];
T2 = [sqrt(2)/d2, 0, -mx1*sqrt(2)/d2;
      0, sqrt(2)/d2, -my1*sqrt(2)/d2;
      0, 0, 1];
out1 = T1;
out2 = T2;
end

function [matches, f1, f2, desc1, desc2] = keypoint_matches(im1, im2)
% f1 & f2 : feature frames containing the keypoints
if size(im1, 3) == 3
    im1 = single(rgb2gray(im1));
else
    im1 = single(im1);
end
if size(im2, 3) ==3
    im2 = single(rgb2gray(im2));
else
    im2 = single(im1);
end
[f1, desc1] = vl_sift(im1);
[f2, desc2] = vl_sift(im2);
matches = vl_ubcmatch(desc1, desc2);
end

function  [matches, f1, f2] = show_keypointmatches(im1, im2, k)
% as in vl_feat demo: https://github.com/vlfeat/vlfeat/blob/master/toolbox/demo/vl_demo_sift_match.m
% but for a random sample of matches
[matches, f1, f2] = keypoint_matches(im1, im2);
keypoints = datasample(matches, k, 2);

x1 = f1(1,keypoints(1,:)) ;
x2 = f2(1,keypoints(2,:)) + size(im1,2);
y1 = f1(2,keypoints(1,:)) ;
y2 = f2(2,keypoints(2,:)) ;

figure(1); clf; hold on ; imshow([im1,im2]);
h = line([x1 ; x2], [y1 ; y2]) ;
set(h,'linewidth', 1, 'color', 'b') ;
vl_plotframe(f1(:,keypoints(1,:))) ;
f2(1,:) = f2(1,:) + size(im1,2) ;
vl_plotframe(f2(:,keypoints(2,:))) ;
axis image off ;
end