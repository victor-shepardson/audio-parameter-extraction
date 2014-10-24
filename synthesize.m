function Synthesize( data_features_name, params_name, output_name )
% load a matrix of audio parameters, save an audio file

load('data/constants');

load(params_name, 'P');
load(data_features_name, 'E');

audio = synthesize_audio(P, window_samps, sample_rate, overlap);

audio = apply_envelope(audio, E, window_samps, overlap);

audiowrite(output_name, audio, sample_rate);

end

