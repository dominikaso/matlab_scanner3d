function [ X, Y, Z ] = znajdz_wspol_obiektu( obraz, maska, kalib)

%pobranie jednej skladowej obrazu
obraz_szary=obraz(:,:,2);
%pobranie rozmiaru obrazu
rozmiar=size(obraz_szary);

%maskowanie obrazu
obraz_szary=obraz_szary.*maska;

%wykrywanie lini lasera
obraz_prog=zeros(rozmiar(1),rozmiar(2),'uint8');
for iy = 1:rozmiar(1)
c=improfile(obraz_szary, [0 rozmiar(2)],[iy iy]);
    for ix = 1:rozmiar(2)
        if ( obraz_szary(iy, ix)==max(c) && obraz_szary(iy, ix)>10) 
            obraz_prog(iy, ix) = 255;
        end
    end
end

%znajdywanie wspolrzednych lini lasera
punkty_laser=[,];
for y = 1:rozmiar(1)
   laserx= round(mean(find(obraz_prog(y,:)==255))); 
        if isnan(laserx) ==0 
            punkty_laser = [ punkty_laser; laserx,y];
        end     
end
%{
%wykluczanie punktow obarczonych duzym bledem
for i=1:length(punkty_laser)-1
    if punkty_laser(i+1,1)>punkty_laser(i,1)+0.02*rozmiar(2) || punkty_laser(i+1,1)<punkty_laser(i,1)-0.02*rozmiar(2) 
        punkty_laser(i+1,1)= punkty_laser(i,1);
    end
end
%}
%przeliczanie wspolrzednych obrazu na wspolrzedne rzeczywiste
for i=1:length(punkty_laser)
    dx=punkty_laser(i,1)-kalib.oxy(1);
    X(i,1)=kalib.B/((kalib.B/kalib.L)+(kalib.f(1)/dx));
    Z(i,1)=X(i,1)*(kalib.f(1)/dx);
    Y(i,1)=(punkty_laser(i,2)-kalib.oxy(2)).*kalib.sy;
end

end

