function [x_l, x_h, y_l, y_h] = getNDim(x,y,x_max,y_max,nsize)
    %Returns the point locations defining a point's neighborhood
    x_l = x - nsize;
	x_h = x + nsize;
	y_l = y - nsize;
	y_h = y + nsize;
        
    if x_l < 1
        x_l = 1;
    end
    if y_l < 1
        y_l = 1;
    end
    if x_h > x_max
        x_h = x_max;
    end
    if y_h > y_max
        y_h = y_max;
    end
end