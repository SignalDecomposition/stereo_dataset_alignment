function [leftImage_out,rightImage_out] = aligenR2L(leftImage,rightImage)

%Resize the right image to the size of the left image 
[m,n,~] = size(leftImage);

%Clear the edges of the sensor noise 
corp_pixels = 20;
leftImage = leftImage(:,1:n-corp_pixels,:);
rightImage = rightImage(1:m,1+corp_pixels:n,:);

%convert to gray
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

%Match features by using their descriptors.

indexPairs = matchFeatures(featuresOriginal,featuresDistorted);
%Retrieve locations of corresponding points for each image.

matchedOriginal = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

%Step 4: Estimate Transformation
[tform, inlierIdx] = estgeotform2d(matchedDistorted,matchedOriginal,'similarity');
inlierDistorted = matchedDistorted(inlierIdx,:);
inlierOriginal = matchedOriginal(inlierIdx,:);

% Step 5: Solve for Scale and Angle

invTform = invert(tform);
Ainv = invTform.A;

ss = Ainv(1,2);
sc = Ainv(1,1);
scaleRecovered = hypot(ss,sc);

% Recover the rotation in which a positive value represents a rotation in
% the clockwise direction.
thetaRecovered = atan2d(-ss,sc);

% Step 6: Recover the Original Image
recovered = imrotate(rightImage,invTform.RotationAngle,'bilinear','crop');

leftImage_out = leftImage;
rightImage_out = recovered;

end