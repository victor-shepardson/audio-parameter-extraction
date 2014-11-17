function [F, E] = audio_to_features( A, samplerate )
% A is chunks of audio in row vectors
% convert to F, matrix of feature vectors
% and E, envelope column vector

[chunks, samps] = size(A);

% window
hann = 1-cos(2*pi*(0:samps-1)/(samps-1));
windowed = A.*repmat(hann, chunks, 1);
% compute fft
spectra = fft(windowed, [], 2);
%discard mirrored half of spectrum, and lowest bin
spectra = spectra(:, 2:samps/2)/samps;
%convert to phase and power
power = abs(spectra);%.^2;
phase = angle(spectra);
% convert phase to phase difference, discarding first frame
power = power(2:chunks, :);
deltaphase = phase(2:chunks, :) - phase(1:chunks-1, :);
% compute envelope and normalize power
env = sum(power, 2);
[~, bins] = size(power);

respectra = power.*cos(deltaphase) + i*power.*sin(deltaphase);

norm = respectra./repmat(env, 1, bins);%power./repmat(env, 1, bins);%

%noisefloor = -30;

%logged = (noisefloor-max(log(norm), -30))/noisefloor;

F = [ real(norm) imag(norm) ];%abs(norm);%norm.*cos(deltaphase) norm.*sin(deltaphase)];
E = env;

%imagesc(log(abs(norm)));

end

