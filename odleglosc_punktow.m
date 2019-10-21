function [ d ] = odleglosc_punktow( x1, y1, x2, y2 )
%funkcja obliczajaca odleglosc pomiedzy dwoma punktami
d=sqrt((x2-x1).^2+(y2-y1).^2);
end

