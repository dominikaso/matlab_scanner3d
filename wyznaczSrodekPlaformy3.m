function [x_srodka,y_srodka, z_srodka] = wyznaczSrodekPlaformy3( wspol_rz, N, wym_szach)
%oblicza wspolrzedne srodka obrotowej podstawy na podstawie polozenia
%plansz kalibracyjnych (N - liczba zdjec)

%liczba pol branych pod uwage w procesie kalibracji
liczba_pol=(wym_szach(1)-1).*(wym_szach(2)-1); 
%obliczanie roznicy pomiedzy sasiadujacymi polami w pionie
d_pola=liczba_pol-(wym_szach(1)-1);
%liczba pol w pionie 
pola_pion=wym_szach(1)-1;

%tworzenie pustych wektorow wspolrzednych srodka podstawy
x_srodka=[];
z_srodka=[];
y_srodka=[];

%zamienanie kolejnosci punktow kalibracyjncyh w zaleznosci od ulozenia
%planszy kalirbacyjnej
for i=1:N
    if(wspol_rz(1,1,i)>wspol_rz(end,1,i))
        wspol_rz(:,:,i)=flipud(wspol_rz(:,:,i));
        wspol_rz(:,:,i)=[wspol_rz(26:30,:,i); wspol_rz(21:25,:,i);
        wspol_rz(16:20,:,i); wspol_rz(11:15,:,i); wspol_rz(6:10,:,i); 
        wspol_rz(1:5,:,i)];
    end 
end


for n=1:pola_pion
    
x_srodka1=0;
z_srodka1=0;
y_srodka1=0;

    for i=1:N-1;
    %wyznaczanie macierzy potrzebnych do znalezienia wspolrzednych srodka
    W=[ 2.*(wspol_rz(n,1,i+1)-wspol_rz(n,1,i)), 2.*(wspol_rz(n,3,i+1)-wspol_rz(n,3,i));
        2.*(wspol_rz(n+d_pola,1,i+1)-wspol_rz(n+d_pola,1,i)), 2.*(wspol_rz(n+d_pola,3,i+1)-wspol_rz(n+d_pola,3,i))];

    Wx=[ wspol_rz(n,1,i+1).^2-wspol_rz(n,1,i).^2+wspol_rz(n,3,i+1).^2-wspol_rz(n,3,i).^2, 2.*(wspol_rz(n,3,i+1)-wspol_rz(n,3,i));
         wspol_rz(n+d_pola,1,i+1).^2-wspol_rz(n+d_pola,1,i).^2+wspol_rz(n+d_pola,3,i+1).^2-wspol_rz(n+d_pola,3,i).^2, 2.*(wspol_rz(n+d_pola,3,i+1)-wspol_rz(n+d_pola,3,i))];

    Wz=[ 2.*(wspol_rz(n,1,i+1)-wspol_rz(n,1,i)), wspol_rz(n,1,i+1).^2-wspol_rz(n,1,i).^2+wspol_rz(n,3,i+1).^2-wspol_rz(n,3,i).^2;
         2.*(wspol_rz(n+d_pola,1,i+1)-wspol_rz(n+d_pola,1,i)), wspol_rz(n+d_pola,1,i+1).^2-wspol_rz(n+d_pola,1,i).^2+wspol_rz(n+d_pola,3,i+1).^2-wspol_rz(n+d_pola,3,i).^2];

    %oblicanie wyznacznikow macierzy
    W=det(W);
    Wx=det(Wx);
    Wz=det(Wz);
    
    %obliczanie sumy poszczegolnych wspolrzednych
    x_srodka1=x_srodka1+(Wx./W);
    z_srodka1=z_srodka1+(Wz./W);
    y_srodka1=y_srodka1+((wspol_rz(n,2,i)+wspol_rz(n,2,i+1)+wspol_rz(n+d_pola,2,i)+wspol_rz(n+d_pola,2,i+1))./4);
    end
   
%tworzenie wektorow ze srednimi wartosciami wspolrzednych srodka
x_srodka=[x_srodka; x_srodka1./(N-1)];
z_srodka=[z_srodka; z_srodka1./(N-1)];
y_srodka=[y_srodka; y_srodka1./(N-1)];
end

end

