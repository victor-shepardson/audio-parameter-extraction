function [ X, Y ] = gen_train_set_adaptive(F, samps, samplerate, oscs, octaves, use_inst_freq, culling_iterations, initial_samples, samples_per_it, num_nearest_culling, num_components, spectra_or_cepstra )
% given a matrix of feature vectors F,
% sample the space of parameter vectors to produce a training set [X, Y] s.t.
% rows of X resemble rows of F

    % !!! does not support use_inst_freq != 0 !!!

    function [F, E] = eval_feat(A)
        %discard envelope, no overlap
        [F,E] = audio_to_features_cepstrum(A, samplerate, 1, use_inst_freq, spectra_or_cepstra);
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
    function P = sample_params_prior(num)
        % wildly ad hoc distributions for
        % carrier, ratio, index, mix
        for n=1:num
            carriers = 40*pow2(((1:oscs)+rand(1, oscs))*octaves/oscs);
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
    function P = sample_params_adaptive_pca(Y, num)
        %here num is the number of new samples per row of Y
        Y_ldim = Y * pcs;
        sigma = cov(Y_ldim); 
        mus = repmat(Y_ldim, num, 1);
        P = mvnrnd(mus, sigma) * pcs';
    end
    function P = sample_params_adaptive(Y, num)
        %here num is the number of new samples per row of Y
        sigma = cov(Y); 
        mus = repmat(Y, num, 1);
        P = mvnrnd(mus, sigma);
    end

feature_dim = length(eval_feat(zeros(2, samps)));
param_dim = length(sample_params_prior(1));

%bootstrap from ad hoc prior
%sample
disp('sampling prior...');
params = sample_params_prior(initial_samples);
A = eval_synth(params);
[feats, ~] = eval_feat(A);
Y = params;
X = feats;
disp('culling...');
%cull, keeping only those points which are a k-nearest neighbor of some 
%element of the training set
[idxs, dists] = knnsearch(X, F, 'K', num_nearest_culling);
uidxs = unique(idxs);
X = X(uidxs, :);
Y = Y(uidxs, :);
Xctrl = X;
Yctrl = Y;
meandistinit = mean(dists(:,1));

% now for culling_iterations, sample a new crop of pts from normal dists
% around current X, and cull
t = cputime();
for cull=1:culling_iterations
    %sample
    disp(['sampling iteration ', num2str(cull), '...']);
    params = sample_params_adaptive(Y, samples_per_it);
    A = eval_synth(params);
    [feats, env] = eval_feat(A);
    %enforce envelope constraint
    params(:, 4:4:param_dim, :) = params(:, 4:4:param_dim)./repmat(env, 1, param_dim/4);
    Y = [Y ; params];
    X = [X ; feats];
    %cull
    disp(['culling iteration ', num2str(cull), '...']);
    [idxs, dists] = knnsearch(X, F, 'K', num_nearest_culling);
    uidxs = unique(idxs);
    X = X(uidxs, :);
    Y = Y(uidxs, :);
    %plot decreasing min dists
    meandist(cull) = mean(dists(:, 1));
end
elapsed = cputime() - t;

test = 0; %change to true to compare other sampling methods 
if test
    %get principal components
    [pts, m] = size(Y);
    Y_recentered = (Y - repmat(mean(Y, 1), pts, 1))/sqrt(m);
    [U, ~, ~] = svd(Y_recentered'); %U contains pricipal components of Y
    pcs = U(:, 1:num_components);

    X = Xctrl; Y = Yctrl;
    t = cputime();
    for cull=1:culling_iterations
        %sample
        disp(['sampling iteration ', num2str(cull), '...']);
        params = sample_params_adaptive_pca(Y, samples_per_it);
        A = eval_synth(params);
        feats = eval_feat(A);
        Y = [Y ; params];
        X = [X ; feats];
        %cull
        disp(['culling iteration ', num2str(cull), '...']);
        [idxs, dists] = knnsearch(X, F, 'K', num_nearest_culling);
        uidxs = unique(idxs);
        X = X(uidxs, :);
        Y = Y(uidxs, :);
        %plot decreasing min dists
        meandistpca(cull) = mean(dists(:, 1));
    end
    elapsed_pca = cputime()-t;
    t = cputime();
    for cull=1:culling_iterations
        %sample
        disp(['sampling iteration ', num2str(cull), '...']);
        params = sample_params_prior(samples_per_it*size(Yctrl, 1));
        A = eval_synth(params);
        feats = eval_feat(A);
        Yctrl = [Yctrl ; params];
        Xctrl = [Xctrl ; feats];
        %cull
        disp(['culling iteration ', num2str(cull), '...']);
        [idxs, dists] = knnsearch(Xctrl, F, 'K', num_nearest_culling);
        uidxs = unique(idxs);
        Xctrl = Xctrl(uidxs, :);
        Yctrl = Yctrl(uidxs, :);
        %plot decreasing min dists
        meandistctrl(cull) = mean(dists(:, 1));
    end
    elapsed_prior = cputime()-t;
    distcurves = [meandistinit meandistpca; meandistinit meandistctrl; meandistinit meandist]';
    save('data/distcurves3', 'distcurves', 'elapsed', 'elapsed_pca', 'elapsed_prior');
    plot(distcurves);
    legend(['adaptive w/ pca (', num2str(elapsed_pca), 's)'],...
        ['prior only (', num2str(elapsed_prior), 's)'],...
        ['adaptive (', num2str(elapsed), 's)']);
end
%plot([meandistinit meandist]);

%disp(size(X));

end