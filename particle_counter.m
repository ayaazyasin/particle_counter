% Particle Counter
% Ayaaz Yasin & Will Cullen - May 21, 2024
clear; clc; close all;

%%% Load and pre-process image
files = {'0514_Case 1-20', '0514_Case 2-20', '0514_Case 3-20'};    % <---- % input image filename

for idx  = 1:length(files)
filename = files{idx};
img = imread(strcat(filename,'.jpg'));
img = double(rgb2gray(img));               % pick color from RGB, 1-red, 2-green, 3-blue

%%% Thresholding 
[m,n] = size(img);                      % size of image
imgT = img;                             % intialize threshold image
T = 0.11*255; % <----                   % thresholding value
for i = 1:m                             % thresholding loop
    for j = 1:n
        if img(i,j) < T
            imgT(i,j) = 0;
        else
            imgT(i,j) = 255;
        end
    end
end
imgT = imgaussfilt(imgT,5);             % gaussian filter to clean edges    <---- comment out to remove edge sharpening
img = img/255;                          % normalize original image
imgT = logical(imgT/255);               % normalize thresholded image


%%% Compute bounding boxes
areaCutoff = 7500; % <-----            % minimum acceptable area of box
s = regionprops(imgT,'BoundingBox');    % find b-boxes using regionprops
boxes = cat(1,s.BoundingBox);           % extract b-box data
area = boxes(:,3).*boxes(:,4);          % calculate area of boxes
boxes = boxes(find(area>areaCutoff),:); % find boxes with area above areaCutoff
area = area(find(area>areaCutoff));     % find area above areaCutoff
count = length(area);                   % number of accepted boxes

%%% Visualization
imshow(imgT); hold on;                  % show thresholded image
for r = 1:count                         % loop and plot boxes
    rectangle('Position', boxes(r,:), ...
        'EdgeColor','r', 'LineWidth', 2); hold on; 
end
hold off

%%% Output
fprintf('idx = %i\nthreshold = %0.2f\nbox count = %i\n\n', idx,T/255, count);
exportgraphics(gca, strcat(filename,'_boxes.jpg'), 'ContentType','image')
end