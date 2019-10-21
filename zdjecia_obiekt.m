%% Skanowanie obiektu 
%{
%wykonywanie zdjec obiektu co 1.08 stopnia
for i=1:333
        obrot_silnika(arduino,0.000002, 32)
        pause(0.1);
        obraz_obiekt{i}=snapshot(kamera);    
end
%}
%tworzenie pliku w ktorym zapisywane beda wspolrzedne chmury punktow
nazwa_pliku = 'dzbanek_ostatni_polegly'; % nazwa pliku
nazwa_pliku_roz=sprintf('%s.asc', nazwa_pliku); %nazwa pliku z rozszerzeniem
fileID=fopen(nazwa_pliku_roz,'w'); %otwarcie pliku, w ktorym zapisywane beda dane

%tworzenie maski tla
maska=utworz_maske(obraz_obiekt,700);

figure(5)
hold on
xlabel('x')
ylabel('y')
zlabel('z')

for n=1:333
    %zerowanie zmiennych
    X=[];
    Y=[];
    Z=[];
    punkty_podst=[];
    punkty_podst2=[];
    punkty_podst3=[];
    wart_usun=[];
    wart_usun2=[];
    wart_usun3=[];
    
    %pobieranie jednego zdjecia
    obraz=obraz_obiekt{n};
    
    %obliczanie wspolrzednych obiektu w ukladzie kamery
    [ X, Y, Z ] = znajdz_wspol_obiektu(obraz, maska, kalib);
    
    %przeliczanie na wspolrzedne podstawki
    for i=1:length(X)
    punkty_podst2(:,i)=R*([X(i); Y(i); Z(i)]-T');
    punkty_podst2(:,i)=[1 0 0; 0 cos(-pi./2) -sin(-pi./2); 0 sin(-pi./2) cos(-pi./2)]*punkty_podst2(:,i);
    end
    
    %usuwanie wartosci poza powierzchnia podstawki
    wart_usun=find(punkty_podst2(2,:)>160);
    punkty_podst2(:,[wart_usun])=[;;];
    
    wart_usun2=find(punkty_podst2(2,:)<-160);
    punkty_podst2(:,[wart_usun2])=[;;];
    
    %usuwanie wartosc ponizej poziomu podstawki
    wart_usun3=find(punkty_podst2(3,:)<kalib.poz_podst+5);
    punkty_podst2(:,[wart_usun3])=[;;];
    

    
    teta=(1.08.*n./180).*pi;
    %uzaleznienie od aktualnego kata obrotu
    for m=1:length(punkty_podst2)
        punkty_podst3(:,m)=[cos(teta) -sin(teta) 0; sin(teta) cos(teta) 0; 0 0 1]*punkty_podst2(:,m);
    end
    punkty_podst=punkty_podst3';
    
    for u=1:length(punkty_podst)
    fprintf(fileID, '%.4f,%.4f,%.4f\n', punkty_podst(u,:));
    end
    
    plot3(punkty_podst(:,1),punkty_podst(:,2),punkty_podst(:,3), '.b','MarkerSize',5);
        
end

fclose(fileID);
%}