function [ X, Y ] = gen_train_set(F, train_set_size, samps, samplerate, oscs, use_inst_freq, culling_iterations )
% given a matrix of feature vectors F,
% sample the space of parameter vectors to produce a training set [X, Y] s.t.
% rows of X resemble rows of F

    %number of frames per loop iteration. is use_inst_freq is true, must be
    %1
    vectorize = 100*(1-use_inst_freq)+use_inst_freq;

    function F = eval_feat(A)
        %discard envelope, no overlap
        [F,E] = audio_to_features_cepstrum(A, samplerate, 1, use_inst_freq);
    end
    function A = eval_synth(P)
        if use_inst_freq %need two frames to get phase difference (vectorize is always 1)
            audio = synthesize_audio(P, 2*samps, samplerate, 1, 0, 0, 1);
            A = chop_audio(audio, samps, 1); %eval_feat will discard one of two frames
        else
            audio = synthesize_audio(P, samps, samplerate, 1, 0, 0, 1);
            A = chop_audio(audio, samps, 1);
        end
    end
    function P = sample_params(num)
        % wildly ad hoc distributions for
        % carrier, ratio, index, mix
        for n=1:num
            carriers = 40*pow2(((1:oscs)+rand(1, oscs))/1);
            %factors = repmat([2 3 5 7 9 11 13]',1,oscs);
            %[nfactors, ~] = size(factors);
            %maxpow =  repmat([4 2 2 1 1 1  1 ]',1,oscs);
            %ratios = prod(factors.^(floor(rand(nfactors, oscs).*(2*maxpow+1))-maxpow),1);%
            factors = [2 3 4 5 6 7 8 9 10 11 12 13];
            nfactors = length(factors);
            numidxs = ceil(rand(1,oscs)*nfactors);
            denomidxs = ceil(rand(1, oscs).*numidxs);
            ratios = factors(numidxs)./factors(denomidxs);%pow2(rand(1, oscs)*8-4);
            indeces = rand(1, oscs)*100;%exp(rand(1, oscs)*3)-1;%ones(1, oscs);%
            mix = rand(1, oscs).^5;
            mix = mix/sum(mix);
            %[~, order] = sort(carriers);
            %P(n, :) = reshape([carriers(order);ratios(order);indeces(order);mix(order)], 1, oscs*4);
            P(n, :) = reshape([carriers;ratios;indeces;mix], 1, oscs*4);
        end
    end

feature_dim = length(eval_feat(zeros(2, samps)));

param_dim = length(sample_params(1));

pct = 0;

Y = zeros(0, param_dim);
X = zeros(0, feature_dim);

for cull=1:culling_iterations
    Yt = zeros(train_set_size, param_dim);
    Xt = zeros(train_set_size, feature_dim);
    for i=1:train_set_size/vectorize
        cur_pct = (cull-1)*100/culling_iterations + i*100*vectorize/(train_set_size*culling_iterations);
        if  cur_pct > pct
            disp(['generating train set: ' num2str(pct) '%']); 
            pct = ceil(cur_pct);
        end
        params = sample_params(vectorize);
        A = eval_synth(params);
        feats = eval_feat(A);
        rows = (i-1)*vectorize+1 : i*vectorize ;
        Yt(rows, :) = params;
        Xt(rows, :) = feats;
    end
    disp('culling train set...'); 
    X = [X;Xt];
    Y = [Y;Yt];
    [idxs, ~] = knnsearch(X, F);
    uidxs = unique(idxs);
    X = X(uidxs, :);
    Y = Y(uidxs, :);
end

disp(size(X));

end