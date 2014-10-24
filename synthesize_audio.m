function audio = synthesize_audio( P, samps, samplerate, overlap )
% given matrix P of parameter row vectors,
% and number of samples samps corresponding to each parameter vector,
% synthesize a row vector of audio

%simple fm without antialiasing

% smooths parameters if multiple frames are present
% i.e. not suitable for batch processing unrelated frames

[frames, param_dim] = size(P);
hop = samps/overlap;

    function v = paramvec(P, i, n)
        %turn column i of P into a row vector expanded by a factor of n
        [h, w] = size(P);
        v = reshape(repmat(P(:,i)', n, 1), 1, n*h);
    end

    function a = fm(p, c, r, i)
        modulating_freq = c.*r;
        modulating_signal = i.*cos(p.*modulating_freq);
        a = cos(c.*p+modulating_signal);    
    end

if overlap == 1 % assume we are generating individiual frames/pairs of frames for training
    carrier = paramvec(P, 1, samps);
    ratio = paramvec(P, 2, samps);
    index = paramvec(P, 3, samps);
    phase = (1:samps*frames)./samplerate.*2*pi;
    audio = fm(phase, carrier, ratio, index);
else %assume we are synthesizing output
    windowed = zeros(overlap, (frames/overlap+1)*samps);
    for tier = 1:overlap
        Pt = P(tier:overlap:frames,:);
        [framest, ~] = size(Pt);
        carrier = paramvec(Pt, 1, samps);
        ratio = paramvec(Pt, 2, samps);
        index = paramvec(Pt, 3, samps);
        phase = (1:samps*framest)./samplerate.*2*pi;
        audiot = fm(phase, carrier, ratio, index);
        hann = 1-cos(framest*2*pi*(0:length(audiot)-1)/(length(audiot)-1));
        audiot = [zeros(1, (tier-1)*hop) hann.*audiot];
        windowed(tier, 1:length(audiot)) = audiot;
    end
    audio = sum(windowed, 1)/overlap;
end
    
%v = interp(P(:,i)', samps, 1, 1/samps); %spline(1:frames, P(:,i)', (1:samps*frames)/samps);

% turn a column vector of parameters into a row vector repeated for each
% sample
% params = {amplitude, carrier, ratio, index}
%amp = paramvec(1);


plot(audio);

end
