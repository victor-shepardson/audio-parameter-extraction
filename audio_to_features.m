function F = audio_to_features( A, samplerate )
% A is chunks of audio in row vectors
% convert to F, matrix of feature vectors

[chunks, samps] = size(A);

% window
hann = 1-cos(2*pi*(0:samps-1)/samps);
windowed = A.*repmat(hann, chunks, 1);
% compute fft
spectra = fft(windowed, [], 2);
spectra = spectra(:, 1:samps/2);
power = abs(spectra);
phase = angle(spectra);
% convert phase to phase difference, discarding first frame
power = power(2:chunks, :);
deltaphase = phase(2:chunks, :) - phase(1:chunks-1, :);
% normalize amplitudes, append scaling feature
peak = max(power, [], 2);
norm = power./repmat(peak, 1, samps/2);

F = [peak norm deltaphase];

end

