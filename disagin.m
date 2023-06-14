% Load stereo images
i = 52
leftImage = imread(fullfile("Eldar_photos_seperated",sprintf('img_%d_L.png',i)));
rightImage = imread(fullfile("Eldar_photos_seperated",sprintf('img_%d_R.png',i)));
[m,n,~] = size(leftImage);
rightImage = rightImage(1:m,1:n,:);

figure;
subplot(1,2,1);imshow(leftImage);title("left")
subplot(1,2,2);imshow(rightImage);title("right")

corp_pixels = 25;
leftImage = leftImage(:,1:n-corp_pixels,:);
rightImage = rightImage(1:m,1+corp_pixels:n,:);

figure;
subplot(1,2,1);imshow(leftImage);title(" left corped")
subplot(1,2,2);imshow(rightImage);title(" right corped")

leftImage_gray = rgb2gray(leftImage);
rightImage_gray = rgb2gray(rightImage); 

%Detect features in both images.
ptsOriginal  =  detectSURFFeatures(leftImage_gray);
ptsDistorted =  detectSURFFeatures(rightImage_gray);

%Extract feature descriptors.
[featuresOriginal,validPtsOriginal] = extractFeatures(leftImage_gray,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(rightImage_gray,ptsDistorted);

%Match features by using their descriptors.
indexPairs = matchFeatures(featuresOriginal,featuresDistorted);


%Retrieve locations of corresponding points for each image.

matchedOriginal = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));
%Show putative point matches.

figure;
showMatchedFeatures(leftImage,rightImage,matchedOriginal,matchedDistorted);
title('Putatively matched points (including outliers)');

%% Step 4: Estimate Transformation

[tform, inlierIdx] = estgeotform2d(matchedDistorted,matchedOriginal,'affine');
inlierDistorted = matchedDistorted(inlierIdx,:);
inlierOriginal = matchedOriginal(inlierIdx,:);
%Display matching point pairs used in the computation of the transformation.

figure;
showMatchedFeatures(leftImage,rightImage,inlierOriginal,inlierDistorted);
title('Matching points (inliers only)');
legend('ptsOriginal','ptsDistorted');
%%  Step 5: Solve for Scale and Angle

invTform = invert(tform);
Ainv = invTform.A;

ss = Ainv(1,2);
sc = Ainv(1,1);
scaleRecovered = hypot(ss,sc);
disp(['Recovered scale: ', num2str(scaleRecovered)])

% Recover the rotation in which a positive value represents a rotation in
% the clockwise direction.
thetaRecovered = atan2d(-ss,sc);
disp(['Recovered theta: ', num2str(thetaRecovered)])

%disp(['Scale: ' num2str(invTform.Scale)])
%disp(['RotationAngle: ' num2str(invTform.RotationAngle)])

%% Step 6: Recover the Original Image

%ecover the original image by transforming the distorted image.

% outputView = imref2d(size(leftImage));
% recovered = imwarp(rightImage,tform,OutputView=outputView);
% %Compare recovered to original by looking at them side-by-side in a montage.
% 
% figure, imshowpair(leftImage,recovered,'montage')
% figure;
% imshow(recovered);
% 
% figure;
% imshow(leftImage);

% applay on the image Rotation 

recovered = imrotate(rightImage,thetaRecovered,'bilinear','crop');
figure, imshowpair(leftImage,recovered,'montage')
figure;
imshow(recovered); 
figure;
imshow(leftImage);



leftImage_gray = rgb2gray(leftImage);
recovered_gray = rgb2gray(recovered); 

%Detect features in both images.
ptsOriginal  =  detectSURFFeatures(leftImage_gray);
ptsDistorted =  detectSURFFeatures(recovered_gray);

%Extract feature descriptors.
[featuresOriginal,validPtsOriginal] = extractFeatures(leftImage_gray,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(recovered_gray,ptsDistorted);

%Match features by using their descriptors.
indexPairs = matchFeatures(featuresOriginal,featuresDistorted);

%Match features by using their descriptors.

indexPairs = matchFeatures(featuresOriginal,featuresDistorted);
%Retrieve locations of corresponding points for each image.

matchedOriginal = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));
%Show putative point matches.

figure;
showMatchedFeatures(leftImage,recovered,matchedOriginal,matchedDistorted);
title('Putatively matched points after rotation');


[tform, inlierIdx] = estgeotform2d(matchedDistorted,matchedOriginal,'affine');
inlierDistorted = matchedDistorted(inlierIdx,:);
inlierOriginal = matchedOriginal(inlierIdx,:);
%Display matching point pairs used in the computation of the transformation.

figure;
showMatchedFeatures(leftImage,recovered,inlierOriginal,inlierDistorted);
title('Matching points after rotation (inliers only)');
legend('ptsOriginal','ptsDistorted');


%% save new images 
sprintf('img_%d_L.png',i);
imwrite(leftImage,fullfile( "new data set",sprintf('img_%d_L.png',i)));
imwrite(recovered,fullfile( "new data set",sprintf('img_%d_R.png',i)));
