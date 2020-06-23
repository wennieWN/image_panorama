function result = panorama(img_left, img_right, iter)
    gray_left = im2double(rgb2gray(img_left));
    gray_right = im2double(rgb2gray(img_right));

    % feature blobs
    sigma_arr = 3:18;
    blob_num = 300;
    blobs_left = LoG(gray_left, sigma_arr, blob_num);
    blobs_left = sortrows(blobs_left,2);
    blobs_right = LoG(gray_right, sigma_arr, blob_num);
    blobs_right = sortrows(blobs_right,2);
    
    x_left = blobs_left(:,2);
    y_left = blobs_left(:,1);
    scale_left = blobs_left(:,4);
    
    x_right = blobs_right(:,2);
    y_right = blobs_right(:,1);
    scale_right = blobs_right(:,4);
    
    if iter == 5
       index_right = (x_right > size(img_right,2)/3);
       x_right = x_right(index_right);
       y_right = y_right(index_right);
       scale_right = scale_right(index_right);
    end

    % feature descriptors
    descriptors_left = descriptor(gray_left,[x_left,y_left,scale_left],10);
    descriptors_right = descriptor(gray_right,[x_right,y_right,scale_right],10);
    
    % feature matching
    matching_num = 200;
    [matches_left,matches_right] = matching(descriptors_left,descriptors_right,matching_num);
    matching_xy_left = [x_left(matches_left),y_left(matches_left)];
    matching_xy_right = [x_right(matches_right),y_right(matches_right)];
    
    % show matching
    height_left = size(img_left,1);
    width_left = size(img_left,2);
    
    height_right = size(img_right,1);
    width_right = size(img_right,2);
    
    height_I3 = max(height_left,height_right);
    width_I3 = width_left + width_right;
    I3 = zeros(height_I3,width_I3,3);
    I3(1:height_left,1:width_left,:) = img_left;
    I3(1:height_right,width_left+1:width_I3,:) = img_right;
    I3 = I3/255.;
    imshow(I3);
    axis off;
    hold on;
    
    for i=1:size(matching_xy_left,1)
        x_left = matching_xy_left(i,1);
        y_left = matching_xy_left(i,2);
        rectangle('Position',[x_left-1,y_left-1,2,2],'Curvature',[1,1],'EdgeColor','r','LineWidth',1.5);
        
        x_right = matching_xy_right(i,1);
        y_right = matching_xy_right(i,2);
        rectangle('Position',[width_left + x_right-1,y_right-1,2,2],'Curvature',[1,1],'EdgeColor','r','LineWidth',1.5);
        
        line([x_left,width_left + x_right],[y_left,y_right]);
    end
    
    % Ransac
    ransac_iter = 5000;
    homography = ransac(matching_xy_left,matching_xy_right,ransac_iter);
    
    % stitching
    result = stitching(img_left, img_right, homography);

end