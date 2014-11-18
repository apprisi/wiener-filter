;; Compatibility function for IDL/GDLs without /CENTER keyword.
function fft_center, array, direction, DIMENSION=dimension, DOUBLE=double, $
                     INVERSE=inverse, OVERWRITE=overwrite
  on_error, 2
  if n_elements(direction) le 0 then direction=-1
  return, shift( $
          fft(array, direction, DIMENSION=dimension, DOUBLE=double, $
              INVERSE=inverse, OVERWRITE=overwrite), $
          ceil(n_elements(array)/2 + 1))
end

pro filtro_wiener
  ntime=101
  ff=10
  ;; Define the times array.
  time=findgen(ntime)/ff
  ;; The signal.
  sign=sin(time) - 0.7*cos(0.7*time) + 0.5*sin(0.5*time)
  noise=0.3*randomu(a, ntime)*cos(10*randomu(a, ntime)*time)
  sign_noise=sign+noise

  window, 0
  plot, time, sign

  window, 1
  plot, time, sign_noise
  
  ;; Its Fourier transform.
  ft=fft(sign_noise)

  ;; The frequencies array, adapted from FFT documentation.
  x = findgen((ntime - 1)/2) + 1
  if ((ntime mod 2) eq 0) then $
     freq = [0.0, x, ntime/2, -ntime/2 + x]/(ntime/ff)*2*!dpi $
  else $
     freq = [0.0, x, -(ntime/2 + 1) + x]/(ntime/ff)*2*!dpi

  signal_power_spectrum=abs(fft(sign))^2
  noise_power_spectrum=abs(fft(noise))^2
  filter=signal_power_spectrum/(signal_power_spectrum + noise_power_spectrum)
  synt=fft(ft*filter, 1)
  window, 2
  plot, time, synt
  return
end
