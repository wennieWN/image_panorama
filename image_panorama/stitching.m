function result = stitching(img_left, img_right, homography)

    fprintf('stitching is Running\n');
    
    [~, xdata, ydata] = imtransform(img_left,maketform('projective',homography'),'XYScale',1);
%     imshow(test)

    xdata_out=[min(1,xdata(1)) max(size(img_right,2), xdata(2))];
    ydata_out=[min(1,ydata(1)) max(size(img_right,1), ydata(2))];

    result_left = imtransform(img_left, maketform('projective',homography'),...
        'XData',xdata_out,'YData',ydata_out,'XYScale',1);
    result_right = imtransform(img_right, maketform('affine',eye(3)),...
        'XData',xdata_out,'YData',ydata_out,'XYScale',1);
    
    result = result_left + result_right;

    % slove overlap
    overlap = (result_left > 0.0) & (result_right > 0.0);
    result_avg = (result_left/2 + result_right/2);    
    result(overlap) = result_avg(overlap);
end