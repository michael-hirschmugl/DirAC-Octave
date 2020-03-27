clear
close all
clc

matlab_version = 1;

% open in matlab
files = dir('*.json');
for nsub = 1 : size(files,1)
    
    text = fileread([files(nsub).name]);
    data = jsondecode(text);
    
    for scene = 1 : 4
        Klang(1:7,scene,nsub) = data.Results.Parts(1).Trials(scene).Ratings([1:7]);
        Raum(1:7,scene,nsub) = data.Results.Parts(2).Trials(scene).Ratings([1:7]);
    end
end

% open in octave
%Raum = load("dirac_room_quality_no_header.txt");
%Klang = load("dirac_sound_quality_no_header.txt");
%Raum = Raum(:, 1:7)';
%Klang = Klang(:, 1:7)';


figure
[Med1, Low, Hi] = CI2(Klang(:,:)'/100);
errorbar([1:7]-0.1,Med1,[Low-Med1],[Hi-Med1],'o','color',0*[1 1 1],'markerfacecolor',0*[1 1 1])
hold on
[Med2, Low, Hi] = CI2(Raum(:,:)'/100);
errorbar([1:7]+0.1,Med2,[Low-Med2],[Hi-Med2],'s','color',0.5*[1 1 1],'markerfacecolor',0.4*[1 1 1])

set(gca,'xtick',1:7,'xticklabel',{'LSDecorr','LSFDN','TdesFDN','TdesWid','Harpex','COMPASS','FOA'})

xlim([0.5 7.5])
ylim([-0.05 1.05])
grid on

return

for dl = 1 : 3
    for N = 0 : 5
        data = squeeze(Noise((pos-1)*3+dl,:,:))'/100;
        [~,p] = ttest(ones(nsub,1), data(:,N+1));
        %             p = signrank(ones(nsub,1), data(:,N+1));
        p = signrank(data(:,N+1),1);
        if p > 0.05/(N+1)
            N_min_noise(pos,dl) = N;
            break
        end
    end
end


N_min_noise


for pos = 1 : 3
    figure
    [Med, Low, Hi] = CI2(squeeze(Speech((pos-1)*3+1,:,:))'/100);
    errorbar([1:6]-0.15,Med,[Low-Med],[Hi-Med],'o-','color',0*[1 1 1],'markerfacecolor',0*[1 1 1])
    hold on
    [Med, Low, Hi] = CI2(squeeze(Speech((pos-1)*3+2,:,:))'/100);
    errorbar([1:6],Med,[Low-Med],[Hi-Med],'o--','color',0.4*[1 1 1],'markerfacecolor',0.4*[1 1 1])
    [Med, Low, Hi] = CI2(squeeze(Speech((pos-1)*3+3,:,:))'/100);
    errorbar([1:6]+0.15,Med,[Low-Med],[Hi-Med],'o:','color',0.7*[1 1 1],'markerfacecolor',0.7*[1 1 1])
    set(gca,'xtick',1:6,'xticklabel',0:5,'xdir','reverse')
    xlabel('truncation order')
    ylabel('similarity to reference directivity')
    xlim([0.5 6.5])
    ylim([-0.05 1.05])
    grid on
    legend('   0 dB direct sound','-10 dB direct sound','-20 dB direct sound','location','sw')
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 11 7])
    print('-depsc2',['../latex/figures/speech_' num2str(pos) '.eps'])
    title(['Speech Position ' num2str(pos)])
    
    for dl = 1 :3
        for N = 0 : 5
            data = squeeze(Speech((pos-1)*3+dl,:,:))'/100;
            [~,p] = ttest(ones(nsub,1), data(:,N+1));
            %             p = signrank(ones(nsub,1), data(:,N+1));
            p = signrank(data(:,N+1),1);
            if p > 0.05/(N+1)
                N_min_speech(pos,dl) = N;
                break
            end
        end
    end
end

N_min_speech
