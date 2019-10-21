function [ wspol_las, wspol_las_ob] = znajdz_laser_kalib( obraz_kalib, punkty_kalib, N, wym_pola)
%N - liczba zdjec kaliibracyjnych
 
y_lasera=[];
x_lasera=[];
n=1;
    
for m=1:N
    obraz=obraz_kalib{m};       %pobieranie jednego zdjecia kalibracyjnego
    obraz_szary=obraz(:,:,2);   %zamiana na skale szarosci (skladowa G)
    rozmiar=size(obraz_szary);  %pobieranie danych o rozmiarze obrazu

    %wykrywanie lini lasera
    obraz_prog=zeros(rozmiar,'uint8');
    
    for iy = 1:rozmiar(1)
        %pobranie intensywnosci obrazu wzdluz linii
        c=improfile(obraz_szary, [0 rozmiar(2)],[iy iy]); 
        %progorwanie obrazu
        for ix = 1:rozmiar(2)
            if ( obraz_szary(iy, ix)==max(c)) 
                obraz_prog(iy, ix) = 1;
            end
        end
    end

    %tworzenie maski o wielkosci planszy kalibracyjnej
    maska_tlo=zeros(rozmiar,'uint8');
    wspol_maski=[ punkty_kalib(1, :, m)  punkty_kalib(5, :, m)  punkty_kalib(30, :, m)  punkty_kalib(26, :, m)];
    maska=insertShape(maska_tlo,'FilledPolygon',wspol_maski ,'Color','white','Opacity',1);
    maska=rgb2gray(maska);

    %maskowanie obrazu
    obraz_mask=obraz_prog.*maska;

    %obliczanie wysokosci maski
    wysokosc_maski=punkty_kalib(5,2,m)-punkty_kalib(1,2,m);
    
    %jesli znalezionno wiazke lasera na planszy kalibracyjnej
    if length(find(obraz_mask(:,:))==255)>0.5*wysokosc_maski
   
        %usrednianie linii lasera - zapisywanie jak wspolrzedne punktow
        punkty_laser=[,];
        for y = 1:rozmiar(1)
           laserx= round(mean(find(obraz_mask(y,:)==255))); 
                if isnan(laserx) ==0 
                    punkty_laser = [punkty_laser; laserx,y];
                end     
        end

        %wykluczanie punktow obarczonych duzym bledem
        for i=1:length(punkty_laser)-1
            if punkty_laser(i+1,1)>punkty_laser(i,1)+0.01*rozmiar(2) || punkty_laser(i+1,1)<punkty_laser(i,1)-0.01*rozmiar(2) 
                punkty_laser(i+1,1)= punkty_laser(i,1);
            end
        end

        %aproksymacja liniowa punktow lasera
        a=polyfit(punkty_laser(:,2),punkty_laser(:,1), 1);
        y_l1=min(punkty_laser(:,2));
        y_l2=max(punkty_laser(:,2));
        x_l1=a(1).*y_l1+a(2);
        x_l2=a(1).*y_l2+a(2);

        %tworzenie wektora wspolrzednych pionowych lasera
        y_las=[0:wym_pola:4.*wym_pola];

        %obliczanie rozmiaru pola na obrazie
        wym_pola_ob=odleglosc_punktow(punkty_kalib(30,1,m), punkty_kalib(30,2,m),punkty_kalib(25,1,m), punkty_kalib(25,2,m));
        %obliczanie wsolczynnika skalowania (rozmiar piksela obrazu w mm)
        wspol_skal=wym_pola./wym_pola_ob;

        %obliczanie wspolrzednych poziomych lasera w zaleznosci od polozenia
        %punktow kalibracyjnych
        if(punkty_kalib(1,1,m)<punkty_kalib(end,1,m))
            d1=odleglosc_punktow(x_l1, y_l1, punkty_kalib(1,1,m), punkty_kalib(1,2,m));
            d2=odleglosc_punktow(x_l2, y_l2, punkty_kalib(5,1,m), punkty_kalib(5,2,m));

            d=(d1+d2)./2;

            d_rz=d.*wspol_skal;
            x_las(1:length(y_las))=d_rz;
        else
            d1=odleglosc_punktow(x_l1, y_l1, punkty_kalib(30,1,m), punkty_kalib(30,2,m));
            d2=odleglosc_punktow(x_l2, y_l2, punkty_kalib(26,1,m), punkty_kalib(26,2,m));

            d=(d1+d2)./2;

            d_rz=d.*wspol_skal;
            x_las(1:length(y_las))=5.*21-d_rz;
        end

        %tworzenie macierzy ze wspolrzednymi lasera
        wspol_las(:,:,m)=[x_las; y_las]';
        %tworzenie macierzy ze wspolrzednymi lasera wzgledem obrazu
        wspol_las_ob(:,:,m)=[x_l1 x_l2; y_l1 y_l2]';
        
    %jesli nie wykryto wiazki lasera na planszy zwroc wektor zerowy    
    else
        wspol_las(:,:,m)=zeros(5,2);
        wspol_las_ob(:,:,m)=zeros(2,2);
    end
end

end

