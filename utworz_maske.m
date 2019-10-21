function maska_prog=utworz_maske( obraz_obiekt,prog)
%prog - wartosc graniczna procesu progowania obrazu

for k = 1 : length(obraz_obiekt)
	obraz  = obraz_obiekt{k};
    
	%pobierz wymiary pojedynczego obrazu
	rozmiar = size(obraz);
    
	%jesli obraz posiada wiecej niz jeden kolor wybierz tylko zielony
	if rozmiar(3) > 1
		obraz = obraz(:, :, 2); 
    end
	%pobierz pierwszy oobraz
	if k == 1
		wszystkie_obrazy = obraz;
	end

	%Nakladanie obrazow jako kolejne warstwy
	wszystkie_obrazy = cat(3, wszystkie_obrazy, obraz);
end
% obliczanie wariancji ze wszystkich obrazow wzdluz 3 wymiaru
maska = var(double(wszystkie_obrazy), 0, 3);

%progowanie otrzymanego obrazu
maska_prog=zeros(rozmiar(1),rozmiar(2),'uint8');
for iy = 1:rozmiar(1)
    for ix = 1:rozmiar(2)
        if ( maska(iy, ix)>prog) 
            maska_prog(iy, ix) = 1;
        end
    end
end

end

