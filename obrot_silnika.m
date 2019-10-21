function obrot_silnika(a,t,N)
%funkcja odpowiadajaca za obrot silnika 
%a-mikrokontroler, t-czas trwania stanu wysokiego i niskiego
%N-liczba powtorzen, 1 potworzenie=1/8 kroku

writeDigitalPin(a, 'D6', 0); %kierunek obrotow ('0'-lewo, '1'-prawo)
for i=1:N
        writeDigitalPin(a, 'D5', 1);
        pause(t);
        writeDigitalPin(a, 'D5', 0);
        pause(t);
end
end

