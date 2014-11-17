function audio = synthesize_audio( P, samps, samplerate, overlap, usewindow, interpolate, channels )
% given matrix P of parameter row vectors,
% and number of samples samps corresponding to each parameter vector,
% synthesize a row vector of audio

%the number of samples per vector is samps/overlap if !usewindow,
%or samps if usewindow (and windowing is used to blend overlap # of channels)

%simple fm without antialiasing

[frames, param_dim] = size(P);
hop = samps/overlap;

    function v = paramvec(P, i, n, mode)
        %turn column i of P into a row vector expanded by a factor of n
        [pdim, ~] = size(P);
        v = P(:,i)';
        if strcmp(mode, 'nearest') || length(v)<=1 || interpolate==0
            v = reshape(repmat(v, n, 1), 1, n*pdim);
        else
            param_samp_locs = ((0:pdim+1)-.5)*n;
            param_samps = [v(1) v v(pdim)];
            v = interp1(param_samp_locs, param_samps, (1:pdim*n)-.5, mode, 0);
            %v = interpn(1:pdim, v, (n:(pdim+1)*n-1)/n, mode, 0);
        end
    end

    function a = fm(params, samps)
        c = paramvec(params, 1, samps, 'linear');
        r = paramvec(params, 2, samps, 'linear');
        i = paramvec(params, 3, samps, 'linear');
        w = paramvec(params, 4, samps, 'linear');
        m = c.*r;
        m_phase = cumsum(2*pi*m/samplerate);
        c_phase = cumsum(2*pi*c/samplerate);
        modulating_signal = i./m.*sin(m_phase);%i./m.*sin(p.*m);
        a = w.*sin(modulating_signal+c_phase);%w.*sin(c.*p+modulating_signal);    
    end

    function a = multifm(params, samps, channels)
        [flen, plen] = size(params);
        np = 4;
        num = plen/np;
        pan = rand(channels, num)+eps;
        pan = pan./repmat(sum(pan, 1), channels, 1);
        a = zeros(channels, flen*samps);
        for idx = 0:num-1
            voice = fm(params(:, 1+idx*np:(idx+1)*np), samps);
            a = a + pan(:, idx+1)*voice; 
        end
    end

if usewindow %de-interleave parameter vectors, synthesize each channel, window and mix
    windowed = zeros(overlap, (frames/overlap+1)*samps);
    for tier = 1:overlap
        Pt = P(tier:overlap:frames,:);
        [framest, ~] = size(Pt);
        audiot = multifm(Pt, samps, channels);
        hann = 1-cos(framest*2*pi*(0:length(audiot)-1)/(length(audiot)-1));
        audiot = [zeros(1, (tier-1)*hop) hann.*audiot];
        windowed(tier, 1:length(audiot)) = audiot;
    end
    audio = sum(windowed, 1)/overlap;
else %just synthesize
    audio = multifm(P, samps/overlap, channels);
end
%v = interp(P(:,i)', samps, 1, 1/samps); %spline(1:frames, P(:,i)', (1:samps*frames)/samps);

% turn a column vector of parameters into a row vector repeated for each
% sample
% params = {amplitude, carrier, ratio, index}
%amp = paramvec(1);


%plot(audio);

end
