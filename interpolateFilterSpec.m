function intFilterspec = interpolateFilterSpec(filterspec)

    nChan = size(filterspec,2);
    hopsize = size(filterspec,1)-1;
    winsize = hopsize*2;
    % IFFT to time domain
    filterimp = ifft([filterspec; conj(filterspec(end-1:-1:2,:))]); 
    % circular shift
    filterimp = [filterimp(hopsize+1:end, :); filterimp(1:hopsize, :)]; 
    % zero-pad to 2*winsize
    filterimp = [filterimp; zeros(winsize, nChan)]; 
    intFilterspec = fft(filterimp); % back to FFT
    % save only positive frequency bins
    intFilterspec = intFilterspec(1:winsize+1, :); 
end