function wrapped = phasewrap( dphase )

%wrapped = dphase + 2*pi*((dphase < -pi) - (dphase > pi));
wrapped = mod(dphase, 2*pi) - pi;

end

