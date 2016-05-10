% OUTLINE
% 1. Detect interest points in the image
% 2. Characterize the local appearance of the regions around interest points. 
% 3. Get a set of supposed matches between region descriptors in each image.
% 4. Estimate the fundamental matrix for the given two images.
% Note: Eliminating detected interest points on background can help <- HOW?

function [points, F] = funMat(im1, im2, method, show, threshold)
if show
    [matches, f1, f2] = show_keypointmatches(im1, im2, 10);
else
    [matches, f1, f2] = keypoint_matches(im1, im2);
end

x1 = f1(1,:)'; y1 = f1(2,:)';
x2 = f2(1,:)'; y2 = f2(2,:)';

os1 = ones(size(x1));
os2 = ones(size(x2));

%% Normalized Eight-point Algorithm with RANSAC
% Pick 8 point correspondences randomly from phat1 <-> phat2
% Calculate a fundamental matrix F
% Count the number of inliers
% Repeat this process many times, pick the largest set of inliers

% RANSAC PARAMETERS
points = 8; max_iter = 30;
nrof_matches = length(matches);
nr_inliers = 0; nr_iter = 0;

% Calculate normalized p1, p2 for RANSAC
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

p1hat = T1 * [x1, y1, os1]';
p2hat = T2 * [x2, y2, os2]';

while nr_iter < max_iter
    nr_iter = nr_iter + 1;
    sample = get_sample(nrof_matches, points, matches);
    
    if method == 1
        % EIGHT-POINT ALGORITHM
        % Construct the matrix A by pointwise multiplying the keypoint-coordinate
        % arrays (x1, y1, x2, y2).
        A = [x1.*x2, x1.*y2, x1, y1.*x2, y1.*y2, y1, x2, y2, os];

        % The entries of F are the components of the column of V 
        % corresponding to the smallest singular value; the diagonal values
        % lie on the diagonal of S.
        [~, S, V] = svd(A);
        [~, idx] = sort(diag(S));

        % Select the columns corresponding to the smallest singular values.
        F = V(:, idx(1)); F = reshape(F,3,3);

        % Find the SVD of F
        [Uf, Sf, Vf] = svd(F);

        % Set the smallest singular value in the diagonal matrix Df
        % to zero in order to obtain the corrected matrix D'f.
        [~, idx] = min(Sf); Sf(idx) = 0;

        % Recompute F: F = Uf * Sf * Vf'
        F = Uf * Sf * Vf';  % Return the fundamental matrix
    
    elseif method == 2
        % NORMALIZED EIGHT-POINT ALGORITHM
        x1hat = p1hat(1,sample(1,:))'; y1hat = p1hat(2,sample(1,:))';
        x2hat = p2hat(1,sample(2,:))'; y2hat = p2hat(2,sample(2,:))';
        oshat = ones(size(x1hat));

        A = [x1hat.*x2hat, x1hat.*y2hat, x1hat, y1hat.*x2hat,...
             y1hat.*y2hat, y1hat, x2hat, y2hat, oshat];

        % Compute the fundamental matrix F
        [~, ~, V] = svd(A);

        % Get Fhat from the last column of V in the SVD of A.
        Fhat = V(:,end); Fhat = reshape(Fhat,3,3);

        % Find the SVD of Fhat.
        [Ufhat, Sfhat, Vfhat] = svd(Fhat);
        Sfhat(end) = 0;

        % Recompute F: F = Uf * Sf * Vf'
        Fhat = Ufhat * Sfhat * Vfhat';

        % 1.2.3 Denormalization
        F = T2' * Fhat * T1;
    end

    % Check whether the matches pi <-> pi' agree with F, using Sampson
    % distance
    m1 = matches(1,:); m2 = matches(2,:);
    p1 = [x1(m1), y1(m1), os1(m1)]'; p2 = [x2(m2), y2(m2), os2(m2)]';
    Fp = F*p1; FTp = F'*p2;

    % Calculate the Sampson distances
    denominator = diag(p2' * Fp)'.^2;
    numerator = Fp(1,:).^2  + Fp(2,:).^2 + FTp(1,:).^2 + FTp(2,:).^2;
    dists = denominator./numerator;

    inliers = dists < threshold;
    nr_inliers_ = sum(inliers);
%     fprintf('#iterations: %i, \t#inliers: %i\n', nr_iter, nr_inliers_)
    if nr_inliers_ > nr_inliers
        nr_inliers = nr_inliers_;
        inlier_matches = matches([inliers; inliers]==1);
        inlier_matches = reshape(inlier_matches,2,[]);
    end
end
% Apply fundamental matrix estimation to the set of all inliers
f1_matches = inlier_matches(1,:); f2_matches = inlier_matches(2,:);
x1 = f1(1, f1_matches)'; y1 = f1(2, f1_matches)';
x2 = f2(1, f2_matches)'; y2 = f2(2, f2_matches)';

points = [x1'; y1'; x2'; y2'];  % Return the inliers
end

%% Matching functions
function [matches, f1, f2, desc1, desc2] = keypoint_matches(im1, im2)
% f1 & f2 : feature frames containing the keypoints
if size(im1, 3) == 3
    im1 = single(rgb2gray(im1));
    im2 = single(rgb2gray(im2));
else
    im1 = single(im1);
    im2 = single(im2);
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
f2pl = f2; f2pl(1,:) = f2(1,:) + size(im1,2) ;
vl_plotframe(f2pl(:,keypoints(2,:))) ;
axis image off ;
end