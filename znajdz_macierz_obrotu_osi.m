function [ R, T ] = znajdz_macierz_obrotu_osi( xs,ys,zs )
%xs, ys, zs - wspolrzedne punktow osi obrotu

%obliczanie roznic pomiedzy wspolrzednymi koncowymi a poczatkowymi
dx=xs(1)-xs(end);
dy=ys(1)-ys(end);
dz=zs(1)-zs(end);

%obliczanie katow pochylenia
gamma=atan(dz./dy);
beta=atan(dx./dz);
alfa=atan(dx./dy);

%wyznaczanie macierzy obrotu wokol poszczegolnych osi
R_x=[1 0 0; 0 cos(gamma) -sin(gamma); 0 sin(gamma) cos(gamma)];
R_y=[cos(beta) 0 sin(beta); 0 1 0; -sin(beta) 0 cos(beta)];
R_z=[cos(alfa) -sin(alfa) 0; sin(alfa) cos(alfa) 0; 0 0 1];

%wyznaczanie koncowej macierzy obrotu
R=R_z*R_y*R_x;
%wyznaczenie wektora translacji
T=[xs(end),0,zs(end)];
end

