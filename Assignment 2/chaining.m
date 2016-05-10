% Construct a point-view matrix
% The rows of the matrix represent images
% The columns of the matrix represent points
for im = 1:40-1
    if im == 1
        % INITIAL STEP
        pvMat = funMat(im, im+1, 2, 0);
    else
        pvMat = vertcat(zeros(2,length(pvMat)));
        [row, col] = size(pvMat);
        points = funMat(im, im+1, 2, 0);
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