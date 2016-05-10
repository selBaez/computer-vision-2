% Construct a point-view matrix
% The rows of the matrix represent images
% The columns of the matrix represent points
for im = 1:40-1
    if im == 1
        % INITIAL STEP
        pvMat = funMat(im, im+1, 2, 0);
    else
        [row, col] = size(pvMat);
        points = funMat(im, im+1, 2, 0);
        last_pv = pvMat(end-1:end)';
        this_pv = points(1:2)';
        
        for n = 1:length(points)
            % Find column index
            idx = find(last_pv(ismember(last_pv,this_pv(n,:),'rows'),1));
            if ~isempty(idx)
                % Add the new points, to the right column
                pvMat(row+1:row+2, idx) = points(3:4,n);
            else
                pvMat()
            end
        end
    end
end