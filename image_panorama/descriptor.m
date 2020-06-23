% feature descriptor
function sift_descriptors = descriptor(im, blobs, coefficient)
    fprintf('descriptor is Running\n');
    
    im_height = size(im,1);
    im_width = size(im,2);
    blobs_num = size(blobs,1);

    % 8 directions
    directions_num = 8;
    directions = 0:2*pi/8:2*pi;
    directions = directions(1:directions_num);
    
    % orientation image
    orientation = zeros(im_height, im_width, directions_num);

    % 16 samples per window
    region_size = 4;
    region_num = region_size * region_size;
    sift_descriptors = zeros(blobs_num, region_num * directions_num);
    
    % grids
    grid_space = [-0.75,-0.25,0.25,0.75];
    [grid_x, grid_y] = meshgrid(grid_space, grid_space);
    grid_x = reshape(grid_x, [1,region_num]);
    grid_y = reshape(grid_y, [1,region_num]);

    % Gaussion
    Gau = normpdf(-4:4,0,1);
    Gau = Gau' * Gau;
    [Gau_x,Gau_y] = gradient(Gau); 
    Gau_x = Gau_x * 2 ./ sum(sum(abs(Gau_x)));
    Gau_y = Gau_y * 2 ./ sum(sum(abs(Gau_y)));

    % gradient magnitude
    im_dx = filter2(Gau_x, im, 'same'); 
    im_dy = filter2(Gau_y, im, 'same');   
    grad_mag = sqrt(im_dx.^2 + im_dy.^2);
    
    im_theta = atan2(im_dy,im_dx);
    im_theta(isnan(im_theta)) = 0; 

    % calcu orientation
    for dir_index = 1:directions_num    
        dir_val = cos(im_theta - directions(dir_index)).^9;
        dir_val = dir_val .* (dir_val > 0);
        dir_val = dir_val .* grad_mag;  
        orientation(:,:,dir_index) = dir_val;
    end

    % iterations for all blobs
    for blob_index = 1:blobs_num
        blob_x = blobs(blob_index,1);
        blob_y = blobs(blob_index,2);
        blob_scale = blobs(blob_index,3);
        blob_r = blob_scale * coefficient;

        % blob's coordinates
        grid_x_blob = grid_x * blob_r + blob_x;
        grid_y_blob = grid_y * blob_r + blob_y;
        grid_res = grid_y_blob(2) - grid_y_blob(1);
    
        % find this descriptor's windows
        win_xmin = floor(max(blob_x - blob_r - grid_res/2, 1));
        win_xmax = ceil(min(blob_x + blob_r + grid_res/2, im_width));
        win_ymin = floor(max(blob_y - blob_r - grid_res/2, 1));
        win_ymax = ceil(min(blob_y + blob_r + grid_res/2, im_height));
    
        [win_pixel_x, win_pixel_y] = meshgrid(win_xmin:win_xmax,win_ymin:win_ymax);
        win_pixel_x = reshape(win_pixel_x, [numel(win_pixel_x),1]);
        win_pixel_y = reshape(win_pixel_y, [numel(win_pixel_x),1]);
        
        % calcu the  distance between pixel and grid
        dist_pixel_x = abs(repmat(win_pixel_x, [1 region_num]) - repmat(grid_x_blob, [numel(win_pixel_x),1])); 
        dist_pixel_y = abs(repmat(win_pixel_y, [1 region_num]) - repmat(grid_y_blob, [numel(win_pixel_x),1])); 
    
        % calcu weight
        weights_x = dist_pixel_x/grid_res;
        weights_x = (1 - weights_x) .* (weights_x <= 1);
        weights_y = dist_pixel_y/grid_res;
        weights_y = (1 - weights_y) .* (weights_y <= 1);
        weights = weights_x .* weights_y;
        
        % get sift descriptor
        blob_sift = zeros(directions_num, region_num);
        for dir_index = 1:directions_num
            dir_val = reshape(orientation(win_ymin:win_ymax, win_xmin:win_xmax, dir_index),[numel(win_pixel_x),1]);        
            dir_val = repmat(dir_val, [1,region_num]);
            dir_val = sum(dir_val .* weights);
            blob_sift(dir_index,:) = dir_val;
        end    
        sift_descriptors(blob_index,:) = reshape(blob_sift, [1 region_num * directions_num]);    
    end

    % normalize SIFT descriptor
    threshold = 0.2;
    
    sift_descriptors_dim = size(sift_descriptors,2); % 128
    sift_descriptors_square = sqrt(sum(sift_descriptors.^2, 2));
    normalize_index = find(sift_descriptors_square > 1);
    
    sift_descriptors_square_filter = sift_descriptors_square(normalize_index,:);
    sift_descriptors_norm = sift_descriptors(normalize_index,:);
    sift_descriptors_norm = sift_descriptors_norm ./ repmat(sift_descriptors_square_filter, [1, sift_descriptors_dim]);

    % truncation > 0.2
    truncation_index = find(sift_descriptors_norm > threshold);
    sift_descriptors_norm(truncation_index) = 0.2;

    % renormalize
    sift_descriptors_square = sqrt(sum(sift_descriptors_norm.^2, 2));
    sift_descriptors_norm = sift_descriptors_norm ./ repmat(sift_descriptors_square, [1, sift_descriptors_dim]);

    sift_descriptors(normalize_index,:) = sift_descriptors_norm;
end