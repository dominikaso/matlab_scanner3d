%% Kalibracja uk?adu
%close all, clear all

%dane poczatkowe
wym_pola=15; %wymiar w mm
wysokosc_planszy_nad_podstawka=30;
%parametry podstawki
przelozenie_podstawki=100./15; %przelozenie
liczbaKrokowPodst=200.*przelozenie_podstawki; %liczba krokow 

%deklaracja kamery
%kamera=webcam('Logitech HD Pro Webcam C920');

%deklaracja mikrokontrolera
%arduino=arduino('COM4','Nano');
%{
%wykonywanie zdjec potrzebnych do kalibracji
for i=1:17
        obrot_silnika(arduino,0.000001, 640)
        pause(0.1);
        obraz_kalib_pocz{i}=snapshot(kamera);    
end
%}
%Wybranie zdjec na ktorych jest widoczna szachownica
n=1;
for i=1:17
    %Detekcja punktów kalibracyjnych - wspolrzedne obrazu (2D)
    [punkty_kalib_pom, wym_szach] = detectCheckerboardPoints(obraz_kalib_pocz{i});
    if wym_szach(1)==6 && wym_szach(2)==7
        obraz_kalib_szach{n}=obraz_kalib_pocz{i};
        punkty_kalib(:,:,n)=punkty_kalib_pom;
        n=n+1;
    end
end
liczbaZdjec_szach=n-1;

%Znajdywanie wspolrzednych lasera 
[wsp_las_szach,wsp_las_ob_szach]=znajdz_laser_kalib(obraz_kalib_szach, punkty_kalib, liczbaZdjec_szach, wym_pola);

%Generowanie wzorcowych wspolrzednych wierzcholkow szachownicy 
wspol_szach=generateCheckerboardPoints([6,7], wym_pola);

%Wyznaczenie podstawowych parametrów kamery
parametry_kamery = estimateCameraParameters(punkty_kalib,wspol_szach);

%Obliczanie wspolrzednych rzeczywistych punktow kalirbacyjnych (3D)
for j=1:liczbaZdjec_szach 
    for i=1:length(wspol_szach)
    wspolrzedne_rz(i,:,j)=[wspol_szach(i,:) 0]*parametry_kamery.RotationMatrices(:,:,j)+parametry_kamery.TranslationVectors(j,:);
    end
end

%Wyznaczenie srodka platformy obrotowej
[xs,ys,zs]=wyznaczSrodekPlaformy3(wspolrzedne_rz, liczbaZdjec_szach, [6,7]);

%Wyznaczanie macierzy obrotu i wektora transalcji pomiedzy ukl. C a P
[ R, T ] = znajdz_macierz_obrotu_osi( xs,ys,zs );

%Wyznaczanie wspolrzednych rzeczywistych lasera
m=1;
for i=1:liczbaZdjec_szach
   if length(find(wsp_las_szach(:,:,i))~=0)>0
        for j=1:length(wsp_las_szach(:,:,1))
        wsp_las_3d(j,:,m)=[wsp_las_szach(j,:,i) 0]*parametry_kamery.RotationMatrices(:,:,i)+parametry_kamery.TranslationVectors(i,:);
        obraz_kalib_las{m}=obraz_kalib_szach{i};
        wspolrzedne_rz_las(:,:,m)=wspolrzedne_rz(:,:,i);
        wspol_las_ob(:,:,m)=wsp_las_ob_szach(:,:,i);
        end
   m=m+1;
   end
end
liczbaZdjec_las=m-1;

%Aproksymacja linii lasera 
[ x_l_kal, y_l_kal, z_l_kal, a ] = interpolacja_linii_lasera( wspolrzedne_rz_las, wsp_las_3d);

%Obliczanie parametrów kalibracyjnych
L=x_l_kal(1); %odleglosc laser-kamera
B=-a(2)./a(1); %odleglosc punktu przeciecia osi optycznej kamery i lasera

%Obliczanie rozmiarow piksela w kierunku horyznotalnym i wertykalnym
wym_pola_ob_y=odleglosc_punktow(punkty_kalib(30,1,1), punkty_kalib(30,2,1),punkty_kalib(29,1,1), punkty_kalib(29,2,1));
wspol_skal_y=wym_pola./wym_pola_ob_y; % wspolczynnik skalowania obrazu wzledem rzeczywistosci

wym_pola_ob_x=odleglosc_punktow(punkty_kalib(30,1,1), punkty_kalib(30,2,1),punkty_kalib(25,1,1), punkty_kalib(25,2,1));
wspol_skal_x=wym_pola./wym_pola_ob_x;

poziom_podstawki=-ys(end)-wym_pola-wysokosc_planszy_nad_podstawka;

%Tworzenie struktury zawierajacej parametry kalibracyjne
kalib=struct('f',parametry_kamery.FocalLength,'oxy',parametry_kamery.PrincipalPoint,...
    'R',R,'T',T,'B',B,'L',L,'sx',wspol_skal_x,'sy', wspol_skal_y, 'poz_podst', poziom_podstawki);


%% Wizualizacja danych kalibracyjnych

%Wyswietlanie zdjec kalibracyjny
figure(1)
%obliczanie wielkosci do prezentacji wykresow
pom=round(sqrt(liczbaZdjec_szach));
if pom^2<liczbaZdjec_szach
    sub1=pom;
    sub2=pom+1;
else
    sub1=pom;
    sub2=pom;
end
for i=1:liczbaZdjec_szach
subplot(sub1,sub2,i, polaraxes)
obraz_kalib3=obraz_kalib_szach{i};
imshow(obraz_kalib3);
end

%Wyswietlanie zdjec kalibracyjnych z laserem
figure(2)
%obliczanie wielkosci do prezentacji wykresow
pom=round(sqrt(liczbaZdjec_las));
if pom^2<liczbaZdjec_las
    sub1=pom;
    sub2=pom+1;
else
    sub1=pom;
    sub2=pom;
end
%prezentacja wykresow
for i=1:liczbaZdjec_las
subplot(sub1,sub2,i)
obraz_kalib3=obraz_kalib_las{i};
imshow(obraz_kalib3);
hold on
line(wspol_las_ob(:,1,i), wspol_las_ob(:,2,i), 'LineWidth',3,'Color','green')
hold off
end

%Tworzenie wizualizacji sceny
figure(3)
showExtrinsics(parametry_kamery);
title('Wizualizacja sceny');
tab_kolorow = im2double(label2rgb(1:liczbaZdjec_las, 'lines','c','shuffle'));
hold on

for n=1:liczbaZdjec_las
kolor = squeeze(tab_kolorow(1, n, :))';
for i=1:length(wspolrzedne_rz_las(:,:,1))
plot3(wspolrzedne_rz_las(1,1,n),wspolrzedne_rz_las(1,3,n),wspolrzedne_rz_las(1,2,n),'LineStyle','none','Marker','+','Color',kolor);    
end
end

plot3(xs,zs,ys,'LineWidth', 2, 'Color', 'green', 'Marker', '*');

for n=1:liczbaZdjec_las
plot3(wsp_las_3d(:,1,n),wsp_las_3d(:,3,n),wsp_las_3d(:,2,n),'LineStyle','-','Color','red','LineWidth', 3);    
end

patch([x_l_kal(1),x_l_kal(1), x_l_kal(end), x_l_kal(end)],[z_l_kal(1),z_l_kal(1), z_l_kal(end), z_l_kal(end)], ...
    [ y_l_kal(end);y_l_kal(1);y_l_kal(1);y_l_kal(end)] ,'red','FaceColor','red','FaceAlpha',0.4,'EdgeColor','red');

hold off
