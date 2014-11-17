function Synthesize( data_features_name, params_name, output_name )
% load a matrix of audio parameters, save an audio file

load('data/constants');

load(params_name, 'P');
load(data_features_name, 'E');

audio = synthesize_audio(P, window_samps, sample_rate, overlap, 0, 1, 2);

audio = apply_envelope(audio, E);

plot(audio');

audiowrite(output_name, audio', sample_rate);

end

