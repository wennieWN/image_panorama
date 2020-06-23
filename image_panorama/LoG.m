% LoG Function
function [blobs]= LoG(im_gray, sigma_arr, blob_top_num)

fprintf('LoG is Running\n');

height = size(im_gray,1);
width = size(im_gray,2);
sigma_num = size(sigma_arr,2);

% LoG in different sigma
LoG_result = ones(height,width,sigma_num); 
for i = 1:sigma_num
    sigma = sigma_arr(i);
    one_layer = sigma*sigma*imfilter(im_gray,fspecial('log',floor(6*sigma+1),sigma),'replicate');
    LoG_result(:,:,i) = one_layer;
end

% Blob detection
% 1. local extremum in 3*3*3 
LoG_result_max = imdilate(LoG_result, ones(3,3,3));
blob_index = find(LoG_result_max==LoG_result); % index
blob_num = size(blob_index,1); % number
[x,y,z] = ind2sub([height,width,sigma_num],blob_index); % 3-d cor
scale = reshape(sigma_arr(z),[blob_num,1]); % scale
r = 1.414 * scale; % radius
blobs = [x,y,r,scale];

% 2. select top-90 blobs
blob_top_num = min(blob_num,blob_top_num); % top number
[blob_value_sorted,sort_index] = sort(LoG_result(blob_index), 'descend'); % sort blobs
blobs = blobs(sort_index(1:blob_top_num),:);

end