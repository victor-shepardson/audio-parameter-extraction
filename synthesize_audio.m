function audio = synthesize_audio( P, samps, samplerate )
% given matrix P of parameter row vectors,
% and number of samples samps corresponding to each parameter vector,
% synthesize a row vector of audio

%simple fm without antialiasing

% smooths parameters if multiple frames are present
% i.e. not suitable for batch processing unrelated frames

[frames, param_dim] = size(P);

phase = (1:samps*frames)./samplerate.*2*pi;

% turn a column vector of parameters into a row vector repeated for each
% sample
if frames <= 2
    paramvec = @(i) reshape(repmat(P(:,i)', samps, 1), 1, samps*frames);
else
    paramvec = @(i) interp(P(:,i)', samps, 1, 1/samps);
end
% params = {amplitude, carrier, ratio, index}
amp = paramvec(1);
carrier = paramvec(2);
ratio = paramvec(3);
index = paramvec(4);

modulating_freq = carrier.*ratio;
modulating_signal = index.*cos(phase.*modulating_freq);
audio = amp.*cos(carrier.*phase+modulating_signal);
end
