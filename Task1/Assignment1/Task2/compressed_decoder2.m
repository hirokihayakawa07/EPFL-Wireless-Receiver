function compressed_decoder2(b,image_size)

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

% % convert to uint8
% b1 = reshape(b, 8, length(b)/8).';
% image = bi2de(b1);

% convert to uint8
b4 = transpose(b3); 
b5 = reshape(b4,numel(b4),1);
b6= reshape(b5, 8, length(b5)/8).';
image = bi2de(b6);
size(image);

% reshape into image format
image = reshape(image, image_size(2), image_size(1)).';
size(image);

% pad the image to multiples of 8
height  = ceil(image_size(1)/8)*8;
width   = ceil(image_size(2)/8)*8;
padded = zeros(height,width);
size(padded);
padded(1:image_size(1),1:image_size(2)) = image;

factor = 0.7;

% segment image into tiles
data = zeros(8*8,(width*height)/(8*8));
k = 1;

for rr=1:8:width % go through rows 
    for cc=1:8:height % go through columns
        patch       = padded(cc:cc+7,rr:rr+7);
        vector      = reshape(patch,8*8,1);
        data(:,k)   = vector;
        k = k + 1;
    end
end

% decompose 
[U S V]         = svd(data.',0);

% filter weak singular values 
fullsv              = diag(S);
compressedsv        = zeros(size(fullsv));
mask = cumsum(fullsv) < (factor*sum(fullsv));
compressedsv(mask)  = fullsv(mask);

SC = diag(compressedsv);

% compose
newdata = U*SC*V';
size(newdata);
newpadded = zeros(height,width);
k = 1;

% assemble full image from patches
for cc=1:8:width % go through rows
    for rr=1:8:height % go through columns
        patch = newdata(k,:);
        newpadded(rr:rr+7,cc:cc+7) = reshape(patch,8,8);
        k=k+1;
    end
end

% shrink to original size
newimage = newpadded(1:image_size(1),1:image_size(2));

imageview(newimage);
end