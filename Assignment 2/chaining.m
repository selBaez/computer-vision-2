% Construct a point-view matrix
% The rows of the matrix represent images
% The columns of the matrix represent points

im_format = 'House/frame000000%02d.png';
nfirst = 0;
nim = 49;

im_indexes = nfirst+1:nim;

for im = im_indexes
    impath1 = sprintf(im_format, im - 1);
    impath2 = sprintf(im_format, im);  
    
    im1 = imread(im1_path);
    im2 = imread(im2_path);

    if im == 1
        % INITIAL STEP
        pvMat = funMat(im1, im2, 2, 0);
    else
        fprintf('HI')
        pvMat = vertcat(zeros(2,length(pvMat)));
        [row, col] = size(pvMat);
        points = funMat(im1, im2, 2, 0);
        last_pv = pvMat(end-1:end)';
        this_pv = points(1:2)';
        
        for n = 1:length(points)
            % Find column index
            idx = find(last_pv(ismember(last_pv,this_pv(n,:),'rows'),1));
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