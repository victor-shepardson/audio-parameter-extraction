function [F, E] = audio_to_features_cepstrum( A, samplerate, overlap, use_inst_freq )
% A is chunks of audio in row vectors
% convert to F, matrix of feature vectors
% and E, envelope column vector

[frames, samps] = size(A);

noisefloor = -70;

% window
hann = .5-.5*cos(2*pi*(0:samps-1)/(samps-1));
%hamm = .54-.46*cos(2*pi*(0:samps-1)/(samps-1));
windowed = A.*repmat(hann, frames, 1);
% compute fft
spectra = fft(windowed, [], 2);

%discard mirrored half of spectrum, discard low bins?, and scale to [0,1]
spectra = spectra(:, 1:samps/2)/samps;

%convert to phase and power
power = abs(spectra);
phase = angle(spectra);

if use_inst_freq
    % convert phase to phase difference, discarding first frame
    power = power(2:frames, :);
    %binidxs = repmat((1:bins), frames, 1);

    %deltaphase = phasewrap(phase(2:frames+1, :) - phase(1:frames, :) - 2*pi*binidxs/overlap);
    deltaphase = phasewrap(phase(2:frames+1, :) - phase(1:frames, :));

    % instantaneous frequency
    %omega = (2*pi*binidxs + overlap*deltaphase)/samps;
    omega = (2*pi*binidxs + deltaphase*overlap)/samps;
    omegahz = omega*samplerate/(2*pi);
    
    %h = (deltaphase)/(2*pi)+.5;
    %v = (noisefloor-mag2db(norm))/noisefloor;
    %s = ones(size(v));
    %imtool(hsv2rgb(cat(3, h, s, v)));
    
    %return
end
[frames, bins] = size(power);

% compute envelope and normalize power
env = sum(power, 2);
norm = power./repmat(env, 1, bins);

%weight by loudness
%octave = log2(samplerate*omega/(20*2*pi));
%dbweight = -2*(octave-5).^2;
%ampweight = db2mag(dbweight);

% denoised log power
%lognorm = max(mag2db(norm+eps) - dbweight, noisefloor);
%lognorm = (noisefloor-max(log(norm), noisefloor))/noisefloor;
%lognorm = (noisefloor-max(log(ampweight.*norm), noisefloor))/noisefloor;
%lognorm = log(norm);

%logspectra = lognorm + 1i*deltaphase;

%downsample to mel space
melsamps = samps/8;
melmin = 30;
melmax = 3500;
melmeans = repmat(((1:melsamps)/melsamps*(melmax-melmin)+melmin), bins, 1);
melwidth = ((melmax-melmin)/(melsamps));
if use_inst_freq
    melspectra = zeros(frames, melsamps);
    for idx=1:frames
        kernelhz = omegahz(idx,:)';
        kernelmel = repmat(1127*log(1+kernelhz/700), 1, melsamps);
        kernels = sparse(max(0, (1-abs(kernelmel-melmeans)/melwidth)));
        kernelnorms = sum(kernels, 1);
        kernels = kernels./max(eps, repmat(kernelnorms, bins, 1));
        melspectra(idx, :) = norm(idx, :)*kernels;
    end
else
    kernelbins = (1:bins)';
    kernelhz = kernelbins/samps*samplerate;
    kernelmel = repmat(1127*log(1+kernelhz/700), 1, melsamps);
    kernels = sparse(max(0, (1-abs(kernelmel-melmeans)/melwidth)));
    kernelnorms = sum(kernels, 1);
    kernels = kernels./max(eps, repmat(kernelnorms, bins, 1));
    melspectra = norm*kernels;
end
dbweight = repmat(-(.002*(melmeans(1, :)-2200)).^2, frames, 1);
melspectra = db2mag(max(mag2db(melspectra+eps) + dbweight, noisefloor));

% back to complex number
%respectra = ampweight.*lognorm.*(cos(omega) + 1i*sin(omega));
%respectra = ampweight.*lognorm.*(cos(overlap*deltaphase) + 1i*sin(overlap*deltaphase));
%respectra = lognorm.*(cos(overlap*deltaphase) + 1i*sin(overlap*deltaphase));


%  compute cepstrum
%centered = melspectra-repmat(mean(melspectra, 2), 1, melsamps);
cepstra = fft(log(melspectra), [], 2);%cepstra = dct(melspectra')';
cepstra = cepstra(:, 1:melsamps/2)/melsamps;

%[frames, csamps] = size(cepstra);

%powercepstra = abs(cepstra);
%for k=1:frames
%    v = log(powercepstra(k,:));
%    covarcepstra(k, :) = reshape(v'*v, 1, melsamps^2);
%end
%logcepstra = (noisefloor-max(log(abs(cepstra)), noisefloor))/noisefloor;

%covar = zeros(frames, melsamps^2);
%mask = triu(ones(size(cv)))>0;
%for k=1:frames
%    v = melspectra(k,:);
%    cv = v'*v;
%    covar(k, :) = cv();
%end

%plot(kernels);

%F = melspectra;
F = [real(cepstra) imag(cepstra)];
E = env;

%imagesc(kernels);
%plot(kernels);
%plot(octave(100, :),dbweight(100, :));

end

