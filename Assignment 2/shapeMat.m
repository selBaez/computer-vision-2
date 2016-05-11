function shapePC = shapeMat(imStart, imEnd)
% Construct a point-view matrix
% The rows of the matrix represent images
% The columns of the matrix represent points

im_format = 'House/frame000000%02d.png';
im_indexes = imStart:imEnd;

for im = im_indexes
    fprintf('Image: %i of %i\n', im, imEnd)
    
    impath1 = sprintf(im_format, im);
    impath2 = sprintf(im_format, im+1);  
    
    im1 = imread(impath1);
    im2 = imread(impath2);

    if im == imStart
        % INITIAL STEP
        pvMat = funMat(im1, im2, 2, 0, .1);
        % Remove duplicate points
        pvMat = unique(pvMat','rows')';
    else
        last_pv = pvMat(end-1:end,:)';
        pvMat = vertcat(pvMat, zeros(2,length(pvMat)));
        
        [row, col] = size(pvMat);
        points = funMat(im1, im2, 2, 0, .1);
        
        this_pv = points(1:2,:)';
        
        for n = 1:length(points)
            % Find column index
            idx = find(ismember(last_pv,this_pv(n,:),'rows'),1);
%             fprintf('Match index: %i, point: %i of %i\n', idx, n, length(points))
            
            if ~isempty(idx)
                % Add the new view, to the corresponding point-column
                pvMat(row-1:row, idx) = points(3:4,n);
            else
                % Add the new point to a new column
                pvMat(row-1:row, col+1) = points(3:4,n);
                
                % Update the column count
                col = col + 1;
            end
        end
    end
end
spy(pvMat)

% 2. Select a dense block from the point-view matrix and construct the 2MxN
% measurement matrix D.
Dmat = [];
for i = 1:length(pvMat)
    if nnz(pvMat(:,i)) == length(pvMat(:,i))
        if isempty(Dmat)
            Dmat = pvMat(:,i);
        end
        Dmat = horzcat(Dmat, pvMat(:,i));
    end
end
% size(Dmat)
% 3. Apply SVD to the 2MxN
[U,S,V] = svd(Dmat);
%size(S)
%size(V)
U = U(:,1:3);
W = S(1:3,1:3);
V = V(:,1:3);
%motionMat = U * sqrtm(W);
shapePC  = sqrtm(W) * V';

%scatter3(shapePC(1,:), shapePC(2,:), shapePC(3,:))
end