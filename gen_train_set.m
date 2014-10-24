function [ X, Y ] = gen_train_set(F, train_set_size, samps, samplerate )
% given a matrix of feature vectors F,
% sample the space of parameter vectors to produce a training set [X, Y] s.t.
% rows of X resemble rows of F

    function F = eval_feat(A)
        %discard envelope, no overlap
        [F,E] = audio_to_features(A, samplerate);
    end
    function A = eval_synth(P)
        %need two frames to get phase difference
        audio = synthesize_audio(P, 2*samps, samplerate, 1);
        A = chop_audio(audio, samps, 1);
    end
    function P = sample_params()
        % wildly ad hoc distributions for
        % amp, carrier, ratio, index
        carrier = 40*pow2(random('unif', 0, 5));
        %pool = primes(11);
        ratio = 1;%pool(random('unid', length(pool))) / pool(random('unid', length(pool)));
        index = 0;%exp(random('unif', 0, 1))-1;
        P = [carrier ratio index];
    end

param_dim = 3;
feature_dim = length(eval_feat(zeros(2, samps)));

Y = zeros(train_set_size, param_dim);
X = zeros(train_set_size, feature_dim);

%we go row by row because the synth process isn't conveniently vectorized
%and we may want the sampling process to be iterative
for i=1:train_set_size
   params = sample_params();
   A = eval_synth(params);
   feats = eval_feat(A);
   Y(i, :) = params;
   X(i, :) = feats;
end

end

