function Synthesize( params_name, output_name )
% load a matrix of audio parameters, save an audio file

load('data/constants');

load(params_name, 'P');

audio = synthesize_audio(P, samps, sample_rate);

audiowrite(output_name, audio, sample_rate);

end

