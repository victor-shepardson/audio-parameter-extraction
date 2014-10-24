function audio = apply_envelope(audio, E, samps, overlap)
    hop = samps/overlap;
    pad = length(audio) - length(E)*hop;
    env = [zeros(1,pad) interp(E', hop, 1, 1/samps)];
    audio = audio.*env;
end