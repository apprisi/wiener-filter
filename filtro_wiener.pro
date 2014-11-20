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
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;  Signal  ;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
  ;; The frequencies array, adapted from FFT documentation.
  x = findgen((ntime - 1)/2) + 1
  if ((ntime mod 2) eq 0) then $
     freq = [0.0, x, ntime/2, -ntime/2 + x]/(ntime/ff)*2*!dpi $
  else $
     freq = [0.0, x, -(ntime/2 + 1) + x]/(ntime/ff)*2*!dpi
  ;; Its Fourier transform.
  ft=fft(sign_noise)

  ;; Determine the power spectra of the signal and the noise.
  signal_power_spectrum=abs(fft(sign))^2
  noise_power_spectrum=abs(fft(noise))^2
  ;; Calculate the Wiener filter.
  filter=signal_power_spectrum/(signal_power_spectrum + noise_power_spectrum)
  ;; Get the filtered signal + noise.
  result=fft(ft*filter, 1)

  ;; Write relevant data to file.
  openw, 1, 'signal.dat'
  for ii = 0L, ntime - 1L do begin
     printf, 1, time[ii], freq[ii], sign[ii], noise[ii], sign_noise[ii], $
             abs(ft[ii]), real_part(result[ii]), format='(7f20.8)'
  endfor
  close, 1
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;  Image  ;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Read the Lena image.
  read_jpeg, "lena.jpg", lena, /grayscale
  ;; Add a large noise to Lena.
  imgnoise=2d*mean(lena)*randomu(systime(/seconds), 512, 512)
  degraded_img=lena + imgnoise
  ;; Fourier transform of the degraded image.
  ftimg=fft(degraded_img)
  ;; For the Wiener filter, use Elaine picture.
  read_jpeg, "elaine.jpg", elaine, /grayscale
  ;; Determine the power spectrum of Elaine and the noise.
  elaine_power_spectrum=abs(fft(elaine))^2
  imgnoise=2d*mean(lena)*randomu(systime(/seconds), 512, 512)
  imgnoise_power_spectrum=abs(fft(imgnoise))^2
  ;; Calculate the Wiener filter.
  filter=elaine_power_spectrum/(elaine_power_spectrum + imgnoise_power_spectrum)
  ;; Get the filtered picture.
  resultimg=fft(ftimg*filter, 1)

  ;; Write images power spectra to file.
  openw, 1, 'elaine.dat'
  printf, 1, shift(elaine_power_spectrum, 257, 257), format='(512(f10.3,x))'
  close, 1
  openw, 1, 'lena.dat'
  printf, 1, shift(abs(fft(lena))^2, 257, 257), format='(512(f10.3,x))'
  close, 1
  return
end
