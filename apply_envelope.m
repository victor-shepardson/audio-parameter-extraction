function audio = apply_envelope(audio, E)
    pts = length(E); %number of envelope points
    samps = length(audio);
    %hop = samps/overlap;
    %pad = length(audio) - length(E)*hop;
    %env = [zeros(1,pad) interp(E', hop, 1, 1/samps)];
    env_samp_locs = ((0:pts+1)-.5)*samps/pts;
    env_samps = [E(1) E' E(pts)];
    env = interpn(env_samp_locs, env_samps, (1:samps)-.5, 'linear', 0);
    audio = audio.*repmat(env, size(audio, 1), 1);
end