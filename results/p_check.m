%pkg load statistics

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

%[h_1, p_1] = ttest(Klang(:,1), Raum(:,1))

for i = [1:7]
    [h(i), p(i)] = ttest(Klang(:,i), Raum(:,i));
    R = corrcoef(Klang(:,i), Raum(:,i));
    r(i) = R(1, 2);
end

figure
plot(1:length(p), p, 'o', 1:length(r), r, 'x')
set(gca,'xtick',1:7,'xticklabel',{'LSDecorr','LSFDN','TdesFDN','TdesWid','HARPEX','COMPASS','FOA'})
legend('p-Wert', 'Korrelationskoeffizient')

xlim([0.5 7.5])
ylim([-0.05 1.05])
