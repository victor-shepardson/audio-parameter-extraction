function A = chop_audio( audio, samps )
% convert an audio signal (row vector)
% to matrix of short audio chunks of length samps

sizeinsamps = length(audio);
sizeinsamps = sizeinsamps - mod(sizeinsamps, samps);

A = reshape(audio(1:sizeinsamps), [], samps);

end

