% Construct a point-view matrix
% The rows of the matrix represent images
% The columns of the matrix represent points

im_format = 'House/frame000000%02d.png';
nfirst = 1;
nim = 49;

im_indexes = nfirst:nim;

for im = im_indexes
    fprintf('Image: %i of %i\n', im, nim)
    
    impath1 = sprintf(im_format, im);
    impath2 = sprintf(im_format, im + 1);  
    
    im1 = imread(impath1);
    im2 = imread(impath2);

    if im == 1
        % INITIAL STEP
        pvMat = funMat(im1, im2, 2, 0, 0.5);
        % Remove duplicate points
        pvMat = unique(pvMat','rows')';
    else
        last_pv = pvMat(end-1:end,:)';
        pvMat = vertcat(pvMat, zeros(2,length(pvMat)));
        
        [row, col] = size(pvMat);
        points = funMat(im1, im2, 2, 0, 0.5);
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

scatter3(finalPC(1,:), finalPC(2,:), finalPC(3,:))