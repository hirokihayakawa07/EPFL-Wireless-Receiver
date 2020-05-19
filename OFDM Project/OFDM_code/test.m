RGB = imread('freddy.png');
I = rgb2gray(RGB);
imwrite(I,'image.png');