function [G] = Gaussian(x, sigma)
G = exp((x^2)/(-2*sigma^2))/(sigma*sqrt(2*pi));
end
