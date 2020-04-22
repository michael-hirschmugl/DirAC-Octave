pkg load statistics

clear
close all
clc

Klang = load('dirac_sound_quality_no_header.txt', '-ascii');
Klang = Klang(:,1:7);
Raum = load('dirac_room_quality_no_header.txt', '-ascii');
Raum = Raum(:,1:7);

x = [1:length(Klang)];

%figure
%hist(Raum(:,7))
%qqplot(x, Klang(:,7), '-', x)

ttest(Klang(:,1), Raum(:,1))
