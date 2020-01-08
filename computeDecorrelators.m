function [decorFilt, decorDelay] = computeDecorrelators(nOutChan, fs)
% calls function that designs FIR filters for decorrelation
%decorFilt = compute_delay_decorrelation_response(fs,nOutChan);
decorDelay = 1500;

%This script creates decorrelation filters that have randomly
% delayed impulses at different frequency bands.
order = 3000;       %order of the bandpass filters
len = 1024*8;       %length of the decorrelation filters
maxdel = 80;        %maximum delay of the filters
mindel = 3;         %minimum delay of the filters
minmaxlocal = 30;   %above 1500Hz the value for delay upper limit
maxminlocal = 20;   %below 1500Hz the value for delay upper limit
mincycles = 10;     %mininum amount of delay in cycles
maxcycles = 40;     %maximum amount of delay in cycles

%compute the values in samples
maxdelN = round(maxdel/1000*fs);
mindelN = round(mindel/1000*fs);
minmaxlocalN = round(minmaxlocal/1000*fs);
maxminlocalN = round(maxminlocal/1000*fs);
if maxdelN > len-(order+1)
    maxdelN = len-(order+1);
end
if minmaxlocalN > maxdelN
    minmaxlocalN = maxdelN;
end
% Compute frequency band
[fpart, npart] = makepart_constcut(200, 2, nOutChan);
cutoff_f = fpart;
cutoff = cutoff_f/fs*2;
cycleN = fs./cutoff_f;
%compute the bandpass filters
h = zeros(order+1,npart,nOutChan);
for j = 1:nOutChan
    h(:,1,j) = fir1(order, cutoff(1,j),'low');
    for i = 2:npart
        h(:,i,j) = fir1(order, [cutoff(i-1,j) cutoff(i,j)], 'bandpass');
    end
end
% Compute the maximum and minimum delays
curveon = ones(npart,1);
mindellocalN = zeros(npart,1);
maxdellocalN = zeros(npart,1);
for i = 1:npart
    maxdellocalN(i) = round(maxcycles*(1/cutoff_f(i))*fs);
    mindellocalN(i) = round(mincycles*(1/cutoff_f(i))*fs);
    if maxdellocalN(i) > maxdelN
        maxdellocalN(i) = maxdelN;
    end
    if maxdellocalN(i) < minmaxlocalN
        maxdellocalN(i) = minmaxlocalN;
        curveon(i) = 0;
    end
    if mindellocalN(i) < mindelN
        mindellocalN(i) = mindelN;
    end
    if mindellocalN(i) > maxminlocalN
        mindellocalN(i) = maxminlocalN;
    end
end
%convert to samples
maxdellocal = maxdellocalN/fs*1000;
mindellocal = mindellocalN/fs*1000;
delvariation = maxdellocal - mindellocal;
cycleT = cycleN/fs*1000;
%randomize the delays of the first band
decorFilt = zeros(len,nOutChan);
delayinit = (maxdelN-mindellocalN(1))*rand(1,nOutChan)+mindellocalN(1);
delay(1,:) = round(delayinit);
% Compute the frequency-dependent delay curve for each loudspeaker channel.
% A heuristic approach is used to form the curve, which limits how
% the delay varies between adjacent frequency channels.
for m = 1:nOutChan
    for i = 2:npart
        cycles = 0.5*i*i+1;
        if curveon(i) == 0
            delchange = cycleN(i-1,m)*(round(rand(1,1)*cycles*2-cycles));
        else
            delchange = cycleN(i-1,m)*(round(rand(1,1)*cycles*2-1.3*cycles));
        end
        delay(i,m) = delay(i-1,m) + delchange;
        if delay(i,m) < mindellocalN(i)
            k = 0;
            while delay(i,m) < mindellocalN(i)
                delay(i,m) = delay(i,m) + cycleN(i-1,m);
                k = k+1;
            end
            if curveon(i) == 0
                delay(i,m) = delay(i,m) + round(k/2)*cycleN(i-1,m);
            end
            while delay(i,m) > maxdellocalN(i)
                delay(i,m) = delay(i,m) - cycleN(i-1,m);
            end
        elseif delay(i,m) > maxdellocalN(i)
            k = 0;
            while delay(i,m) > maxdellocalN(i)
                delay(i,m) = delay(i,m) - cycleN(i-1,m);
                k = k+1;
            end
            if curveon(i) == 0
                delay(i,m) = delay(i,m) - round(k/2)*cycleN(i-1,m);
            end
            while delay(i,m) < mindellocalN(i)
                delay(i,m) = delay(i,m) + cycleN(i-1,m);
            end
        end
        delay(i,m) = round(delay(i,m));
    end
    
    % Summing up the response from band-pass impulse responses
    hdelayed = zeros(len,npart);
    for i = 1:npart
        hdelayed(delay(i,m)+1:delay(i,m)+order+1,i) = h(:,i,m);
    end
    for i = 1:npart
        decorFilt(:,m) = decorFilt(:,m) + hdelayed(:,i);
    end
end
end