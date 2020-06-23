clear
clc

% the panorama of 5 images
for i = 1:5
    filename = ['IMG_', num2str(i), '.JPG'];
    if i==1
        result = imread(filename);
    else
        fprintf(['Solving the ',num2str(i), ' images...','\n']);
        img = imread(filename);
        result = panorama(img, result,i+1);
%         imwrite(result,['result_', num2str(i), '.png']); 
    end
end

figure;
imshow(result);