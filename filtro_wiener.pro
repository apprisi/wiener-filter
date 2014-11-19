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
  ntime=1001
  ff=100
  ;; Define the times array.
  time=findgen(ntime)/ff
  ;; The orignal signal.
  sign=sin(time) - 0.7*cos(0.7*time) + 0.5*sin(0.5*time)^2
  ;; The noise.
  noise=0.3*randomu(a, ntime)*cos(10*randomu(a, ntime)*time)
  ;; Signal + noise.
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

  ;; Determine the power spectra of the signal and the noise.
  signal_power_spectrum=abs(fft(sign))^2
  noise_power_spectrum=abs(fft(noise))^2
  ;; Calculate the Wiener filter.
  filter1=signal_power_spectrum/(signal_power_spectrum + noise_power_spectrum)
  ;; Get the filtered signal + noise.
  synt1=fft(ft*filter1, 1)
  window, 2
  plot, time, synt1

  ;; Let's do the same but with a wrong signal function.
  wrong_signal_power_spectrum=abs(fft((10^(-0.85)*time)^4))^2
  filter2=signal_power_spectrum/(wrong_signal_power_spectrum + noise_power_spectrum)
  synt2=fft(ft*filter2, 1)
  window, 3
  plot, time, synt2

  window, 4
  plot, freq, wrong_signal_power_spectrum, xrange=[-20,20]

  window, 5
  plot, freq, signal_power_spectrum, xrange=[-20,20]
  return
end
