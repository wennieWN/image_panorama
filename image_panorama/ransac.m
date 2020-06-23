function homography = ransac(xy_left, xy_right, ransac_iter)

    fprintf('ransac is Running\n');
    
    points_num = size(xy_left,1);
    number_threshold = 0;
    dist_threshold = 0.3;

    for i = 1:ransac_iter
        % randomly select 4 points
        ind = randperm(points_num); 
        ind_subset = ind(1:4);
        ind_out = ind(5:end);
        
        left_subset = xy_left(ind_subset,:);
        right_subset = xy_right(ind_subset,:);
        left_out = xy_left(ind_out,:);
        right_out = xy_right(ind_out,:);
        
        % calcu homography
        cur_homography = fit(left_subset,right_subset);
        
        % estimate right_out
        right_out_transform = cur_homography * cat(1, left_out', ones(1, size(left_out, 1)));
        right_out_estimate(:,1) = (right_out_transform(1,:) ./ right_out_transform(3,:))';
        right_out_estimate(:,2) = (right_out_transform(2,:) ./right_out_transform(3,:))';
        
        % calcu distance
        distance = sum((right_out - right_out_estimate).^2,2);
        
        % judge inlier_number
        inlier_number = size(find(distance < dist_threshold),1);    
        if inlier_number > number_threshold
            homography = cur_homography;
            number_threshold = inlier_number;
        end
    end
end

function homography = fit(xy_left, xy_right)
    matrix = [];
    points_num = size(xy_left,1);
    for i = 1:points_num
        one_xy_left = xy_left(i,:);
        one_xy_left_shape = [one_xy_left';1];
        one_x_right = xy_right(i,1);
        one_y_right = xy_right(i,2);
        matrix = cat(1,matrix,cat(2,zeros(1,3),one_xy_left_shape',-one_y_right*one_xy_left_shape'));
        matrix = cat(1,matrix,cat(2,one_xy_left_shape',zeros(1,3),-one_x_right*one_xy_left_shape'));
    end
    [~,~,V] = svd(matrix); 
    homography = V(:,end);
    homography = reshape(homography,[3 3])';
end


