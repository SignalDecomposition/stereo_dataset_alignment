
%The Loop is creating a new dataset

for i = 0:128

    leftImage = imread(fullfile("Eldar_photos_seperated",sprintf('img_%d_L.png',i)));
    rightImage = imread(fullfile("Eldar_photos_seperated",sprintf('img_%d_R.png',i)));
    
    %Resize the right image to the size of the left image 
    [m,n,~] = size(leftImage);
    rightImage = rightImage(1:m,1:n,:);
    %Show_Features(leftImage,rightImage);

    corp_pixels = 25;
    [leftImage_out,rightImage_out] = aligenR2L(leftImage,rightImage,corp_pixels);
    %Show_Features(leftImage_out,leftImage_out); 

    %Saving
    imwrite(leftImage_out,fullfile( "new data set",sprintf('img_%d_L.png',i)));
    imwrite(rightImage_out,fullfile( "new data set",sprintf('img_%d_R.png',i)));

end

