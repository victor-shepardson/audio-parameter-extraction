function Constants()
%save constants.mat with the values given in this script

sample_rate = 44100;
window_samps = 2048;
overlap = 4;
oscs = 24;
octaves = 8;
kernel_k = 1; %vestigial
kernel_width = .1; %vestigial
use_inst_freq = 0; %vestigial

culling_iterations = 1000;
initial_samples = 1000;
samples_per_it = 1;
num_nearest_culling = 1;
num_components = oscs;

save 'data/constants';

end

