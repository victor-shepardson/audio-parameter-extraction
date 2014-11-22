function Constants()
%save constants.mat with the values given in this script

sample_rate = 44100;
window_samps = 2048;
overlap = 2;
oscs = 8;
octaves = 8;
kernel_k = 1; %vestigial
kernel_width = .1; %vestigial
use_inst_freq = 0; %vestigial

spectra_or_cepstra = 1; % 0 for mel spectrum, 1 for cepstrum

culling_iterations = 100;
initial_samples = 1000;
samples_per_it = 1;
num_nearest_culling = 1;
num_components = oscs;

rng(0);

save 'data/constants';

end

