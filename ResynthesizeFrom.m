function ResynthesizeFrom(audio_path, training_path, data_dir, skip)
    %train and evaluate on the same audio
    
    split = regexp(audio_path, '[\/\.]', 'split')
    audio_dir = strjoin(split(1));
    name = strjoin(split(2));
    fmt = strjoin(split(3));
    
    data_features = [data_dir '/' name '_feats']
    data_params = [data_dir '/' name '_params']
    data_train = [data_dir '/' name '_train']
    data_train_features = [data_dir '/' name '_train_feats']
    resynth_path = [audio_dir '/' name '_resynth.' fmt]
    
    Constants();
    
    if skip < 1
        disp('extracting training features...'); 
        Preprocess(training_path, data_train_features);
    end
    if skip < 2
        disp('training...'); 
        Train(data_train_features, data_train);
    end
    if skip < 3
        disp('extracting input features...'); 
       Preprocess(audio_path, data_features); 
    end
    if skip < 4
        disp('evaluating input...'); 
        Evaluate(data_train, data_features, data_params);
    end
    disp('synthesizing audio...'); 
    Synthesize(data_features, data_params, resynth_path);
    disp('done');
end