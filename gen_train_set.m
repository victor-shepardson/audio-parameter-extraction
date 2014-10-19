function [ X, Y ] = gen_train_set( f_synth, f_feat, F, train_set_size, samps, samplerate )
% given synthesis process f_synth(v) mapping params to audio,
% a converter f_feat(A) from audio to features,
% and matrix of feature vectors F,
% sample the space of parameter vectors to produce a training set [X, Y] s.t.
% rows of X resemble rows of F

param_dim = 4;
feature_dim = length(f_feat(zeros(2, samps)));

Y = zeros(train_set_size, param_dim);
X = zeros(train_set_size, feature_dim);

for i=1:train_set_size
   % wildly ad hoc distributions for
   % amp, carrier, ratio, index
   amp = 1;%random('unif', 1);
   carrier = 80*pow2(random('unif', 0, 4));
   pool = primes(11);
   ratio = 1;%pool(random('unid', length(pool))) / pool(random('unid', length(pool)));
   index = 0;%exp(random('unif', 0, .1))-1;
   params = [amp carrier ratio index];
   %need two frames of audio to get phase difference
   audio = reshape(synthesize_audio(params, 2*samps, samplerate), samps, 2)';
   features = audio_to_features(audio, samplerate);
   Y(i, :) = params;
   X(i, :) = features;
end

end

