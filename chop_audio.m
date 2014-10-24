function A = chop_audio( audio, samps, overlap )
% convert an audio signal (row vector)
% to matrix of short audio chunks of length samps

%sizeinsamps = length(audio);
%sizeinsamps = sizeinsamps - mod(sizeinsamps, samps);\
%A = reshape(audio(1:sizeinsamps), samps, [])';

hop = samps/overlap;

i = 0;
while (i*hop + samps) <= length(audio)
    A(i+1, :) = audio(1+i*hop:i*hop+samps);
    i = i+1;
end

