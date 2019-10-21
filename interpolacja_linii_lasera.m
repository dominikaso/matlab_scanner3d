 function [ x_l_kal, y_l_kal, z_l_kal , a] = interpolacja_linii_lasera( wspolrzedne_rz, wsp_las_3d)
%funckja do interpolacji linii lasera 
%x_l_kal, y_l_kal, z_l_kal - wspolrzedne linii lasera
%a - wspolczynniki rownania prostej
%wspolrzedne_rz - wspolrzedne rzeczywste punktow kalibracyjnych
%wsp_las_3d - wspolrzedne rzeczywiste linii lasera

rozmiar=size(wspolrzedne_rz); %pobieranie rozmiaru planszy i liczby zdjec

z_l_kal=[0:max(max(wspolrzedne_rz(:,3,:)))]'; %tworzenie wektora wspol. Z lasera
x_l_kal=zeros(length(z_l_kal),1); % pusty wektor X o wym. wektora Z

for j=1:length(wsp_las_3d(:,:,1))
    %pobieranie wspolrzednych X i Z uzywanych do interpolacji
    for i=1:rozmiar(3)
        x_apro(i,j)=wsp_las_3d(j,1,i);
        z_apro(i,j)=wsp_las_3d(j,3,i);
    end
    
%interpolacja liniowa punktow lasera   
a=polyfit(z_apro(:,j),x_apro(:,j),1);
    %obliczanie interpolowanych wspolrzednych X
    for i=1:length(z_l_kal)
        x_l_kal(i,1)=x_l_kal(i,1)+a(1).*z_l_kal(i)+a(2);
    end
end
x_l_kal=x_l_kal./length(wsp_las_3d(:,:,1));

%zamiana kolejnosci punktow kalibracyjnych w zaleznosci od polozenia
%plansz kalibracyjnych
for i=1:rozmiar(3)
    if(wspolrzedne_rz(1,1,i)>wspolrzedne_rz(end,1,i))
        wspolrzedne_rz(:,:,i)=flipud(wspolrzedne_rz(:,:,i));
    end
end

%obliczanie sredniej wartosci Y dla wszystkich zdjec
for i=1:5
    y_l_kal(i)=mean(wspolrzedne_rz(i,2,:));
end

end

