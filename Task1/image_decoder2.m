function image_decoder2(b, image_size)
% IMAGE_DECODER - Decodes a bit stream into an image with
% a given fixed size and display it.
%    image_decoder(b, image_size)
%    
%    Arguments:
%      b:          (vector) bit stream of length=8*height*width
%      image_size: (vector) [height, width] size of the image
% 
% Author(s): unknown
% Copyright (c) 2011 RWTH.


% Convert the bit stream "b" into an image and display it.
% The vector "image_size" of length 2 contains the dimensions 
% (in pixels) of the image (height x width)

% Add AWGN to signal
SNR=1;
b = awgn(b,SNR);

% (Re,Im) --> [-1,1]
% (x1,x2), x1=cos(theta)/|cos(theta)|, x2=sin(theta)/|sin(theta)|
% theta in (0,pi/2) --> 11
% theta in (pi/2,pi) --> -11
% theta in (pi,3/2pi) --> -1-1
% theta in (3/2pi,2pi) --> 1-1
b2 = [cos(angle(b))./abs(cos(angle(b))),sin(angle(b))./abs(sin(angle(b)))];

%[11,-11,-1-1,1-1] --> [11,01,00,10]
b3 = (b2+ones(length(b2),2))*0.5;

% error handling
if numel(b3) ~= 8 * prod(image_size)
  error('Input vector has wrong size.')
end

% convert to uint8
b4 = transpose(b3); 
b5 = reshape(b4,numel(b4),1);
b6= reshape(b5, 8, length(b5)/8).';
image = bi2de(b6);

% reshape into image format
image = reshape(image, image_size(2), image_size(1)).';

% displax image
imageview(image);

return
