function [] = edge(file, sigma, T_h, T_l)

%Read image, convert to grayscale and then to double matrix
img = imread(file);
gray = rgb2gray(img);
d = im2double(gray);

%Get dimensions of image
[row col] = size(d);

%Create the filter size based on sigma, make sure its size is odd
fsize = round(sigma*6);
if mod(fsize, 2) == 0
    fsize = fsize + 1;
  
half = floor(fsize / 2);    

%Centralize the Gaussian filter so point 0,0 is at center of filter
for x = -1*half:half
    for y = -1*half:half
        Gy(x+half+1,y+half+1) = dGaussian(x,sigma)*Gaussian(y,sigma);
        Gx(x+half+1,y+half+1) = dGaussian(y,sigma)*Gaussian(x,sigma);
    end
end

%Perform convolution
Fx = conv2(d,Gx,'same');
Fy = conv2(d,Gy,'same');

%Find gradient magnitude
for x = 1:row
    for y = 1:col
        F(x,y) = sqrt(Fx(x,y)^2 + Fy(x,y)^2);
    end
end

Ithin = zeros(row,col);

%Nonmaximum surpression
for x = 1:row
    for y = 1:col
        %Find the edge orientation at each pixel and round to nearest
        %amount
        dir = atan(Fy(x,y)/Fx(x,y))*180/pi;
        dir = round(dir/45.0)*45 + 90;
        if dir == 180
            dir = 0;
        end
        
        %Create variables to easily access the adjacent pixels in the same
        %direction as the edge orientation of the current pixel
        if dir == 0
            x_i = 1;
            y_i = 0;
        elseif dir == 45
            x_i = 1;
            y_i = -1;
        elseif dir == 90
            x_i = 0;
            y_i = 1;
        else
            x_i = 1;
            y_i = 1;
        end
        
        %If edge pixel, ignore
        if x == 1 || y == 1 || x == row || y == col
            I(x,y) = 0;
        %If the edge strength at this pixel is smaller than one of its 
        %neighbors along its edge orientation, ignore
        elseif abs(F(x,y)) < abs(F(x+x_i, y+y_i)) ||  abs(F(x,y)) < abs(F(x-x_i, y-y_i))
            I(x,y) = 0;
        %Else, store value of edge strength in a new matrix 
        else
            I(x,y) = F(x,y);
        end
        
        D(x,y) = dir;
    end
end

E = zeros(row,col);
csize = 0;

%Find the most important edge pixels
for x = 1:row
    for y = 1:col
        %If the given pixel has an edge strength higher than a treshold,
        %add to a list to be chained
        if abs(I(x,y)) > T_h
            csize = csize + 1;
            toChainX(csize) = x;
            toChainY(csize) = y;
        end
    end
end

%For every pixel to be chained
for i = 1:csize
    x = toChainX(i);
    y = toChainY(i);
    
    %If the pixel was unvisited and is greater than a threshold...
    if E(x,y) == 0 && abs(I(x,y)) > T_l
        %Mark it as visited
        E(x,y) = 255;
        dir = D(x,y);
        
        if dir == 0
            x_i = 1;
            y_i = 0;
        elseif dir == 45
            x_i = -1;
            y_i = 1;
        elseif dir == 90
            x_i = 0;
            y_i = 1;
        else
            x_i = 1;
            y_i = 1;
        end
        
        %And add neighboring pixels in the direction of the edge
        %orientation to possibly be chained
        if x-x_i >= 1 && y-y_i >= 1 && x-x_i <= row && x-x_i <= col
            csize = csize + 1;
            toChainX(csize) = x-x_i;
            toChainY(csize) = y-y_i;
        end
        
        if x+x_i >= 1 && y+y_i >= 1 && x+x_i <= row && x+x_i <= col
            csize = csize + 1;
            toChainX(csize) = x+x_i;
            toChainY(csize) = y+y_i;
        end      
    end
end

%Convert matrices to images
GradX = mat2gray(abs(Fx));
GradY = mat2gray(abs(Fy));
GradM = mat2gray(F);
NonMax = mat2gray(I);
Hyst = mat2gray(E);

%Save images of the different steps
params = ['-edge-' num2str(sigma) '-' num2str(T_h) '-' num2str(T_l) '-'];
nfile = strrep(file, '.jpg', '');
imwrite(GradX,[nfile params 'fgx.jpg']);
imwrite(GradY,[nfile params 'fgy.jpg']);
imwrite(GradM,[nfile params 'fgm.jpg']);
imwrite(NonMax,[nfile params 'nms.jpg']);
imwrite(Hyst,[nfile params 'hyst.jpg']);
imshow(Hyst)
end