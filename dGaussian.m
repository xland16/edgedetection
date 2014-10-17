function [Gx] = dGaussian(x, sigma)
Gx = x*Gaussian(x,sigma)/(-1*sigma^2);
end