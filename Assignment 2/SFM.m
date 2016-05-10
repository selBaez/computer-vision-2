finalPC = [];
for i = 1:3:10
    shapePC = shapeMat(i, i+4);
    if isempty(finalPC)
        finalPC = shapePC;
    else
        new_points = length(shapePC);
        old_points = length(finalPC);
        N = min(new_points, old_points);
        if new_points < old_points
            sample = get_sample(old_points, N, finalPC);
            T = procrustes(sample, shapePC);
        else
            sample = get_sample(new_points, N, shapePC);
            T = procrustes(finalPC, sample);
        end
        finalPC = horzcat(finalPC, T\shapePC);
        scatter3(finalPC(1,:), finalPC(2,:), finalPC(3,:))
    end
end