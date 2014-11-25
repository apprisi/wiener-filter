;; Compatibility function for IDL/GDLs without /CENTER keyword.
function fft_2d_center, array, direction, DIMENSION=dimension, DOUBLE=double, $
                        INVERSE=inverse, OVERWRITE=overwrite
  on_error, 2
  if n_elements(direction) le 0 then direction = -1
  if n_elements(inverse) le 0 then inverse = 0
  if (direction gt 0) or (inverse) then begin
     ;; Inverse transform: shift backward the input array.
     shift_param = -ceil(size(array, /dimensions)/2 + 1)
     transform = fft(shift(array, shift_param[0], shift_param[1]), $
                     direction, DIMENSION=dimension, DOUBLE=double, $
                     INVERSE=inverse, OVERWRITE=overwrite)
  endif else begin
     ;; Forward transform: shift forward the transform.
     shift_param = ceil(size(array, /dimensions)/2 + 1)
     transform = shift(fft(array, direction, DIMENSION=dimension, DOUBLE=double, $
                           INVERSE=inverse, OVERWRITE=overwrite), $
                       shift_param[0], shift_param[1])
  endelse
  return, transform
end

pro filtro_wiener
  on_error, 2
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;  Signal  ;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ntime = 1001
  ff = 100
  ;; Define the times array.
  time = findgen(ntime)/ff
  ;; The orignal signal.
  sign = sin(time) - 0.7*cos(0.7*time) + 0.5*sin(0.5*time)^2
  ;; The noise.
  noise = 0.3*randomu(a, ntime)*cos(10*randomu(a, ntime)*time)
  ;; Signal + noise.
  sign_noise = sign + noise
  ;; Its Fourier transform.
  ft = fft(sign_noise)

  ;; Determine the power spectra of the signal and the noise.
  signal_power_spectrum = abs(fft(sign))^2
  noise_power_spectrum = abs(fft(noise))^2
  ;; Calculate the Wiener filter.
  filter = signal_power_spectrum/(signal_power_spectrum + noise_power_spectrum)
  ;; Get the filtered signal + noise.
  result = fft(ft*filter, /inverse)

  ;; The frequencies array, adapted from FFT documentation.
  x = findgen((ntime - 1)/2) + 1
  if ((ntime mod 2) eq 0) then $
     freq = [0.0, x, ntime/2, -ntime/2 + x]/(ntime/ff)*2*!dpi $
  else $
     freq = [0.0, x, -(ntime/2 + 1) + x]/(ntime/ff)*2*!dpi
  ;; Write relevant data to file.
  openw, 1, 'figures/signal.dat'
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
  img_noise = 1.8d*mean(lena)*randomu(systime(/seconds), 512, 512)
  degraded_img = lena + img_noise
  ;; Fourier transform of the degraded image.
  ftimg = fft(degraded_img)
  
  ;; For the Wiener filter, use a completely different picture.
  read_jpeg, "elaine.jpg", elaine, /grayscale
  ;; Determine the power spectrum of Elaine.
  elaine_power_spectrum = abs(fft(elaine))^2
  ;; To further increase entropy, calculate a new noise.
  img_noise_new = 2d*mean(lena)*randomu(systime(/seconds), 512, 512)
  ;; Power spectrum of the new noise.
  img_noise_power_spectrum = abs(fft(img_noise_new))^2
  
  ;; Calculate the Wiener filter.
  filter = elaine_power_spectrum/(elaine_power_spectrum + $
                                  img_noise_power_spectrum)
  ;; Get the filtered picture.
  result_img = fft(ftimg*filter, /inverse)

  ;; Write images to file.
  write_jpeg, 'figures/degraded_lena.jpg', degraded_img
  write_jpeg, 'figures/filtered_lena.jpg', result_img
  ;; Write images power spectra to file.
  openw, 1, 'figures/elaine.dat'
  printf, 1, shift(elaine_power_spectrum, 257, 257), format='(512(f10.3,x))'
  close, 1
  openw, 1, 'figures/lena.dat'
  printf, 1, abs(fft_2d_center(lena))^2, format='(512(f10.3,x))'
  close, 1

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;  Other example  ;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; This example is largely based on the code provided in WIENER_FILTER
  ;; documentation, see http://www.exelisvis.com/docs/WIENER_FILTER.html.
  read_jpeg, 'moon.jpg', moon, /grayscale
  moon_noise = 0.5*mean(moon)*randomu(systime(/seconds), 512, 512)
  ;; Generate some atmospheric turbulence degradation.
  xCoords = lindgen(512,512) mod 512 - 257
  yCoords = transpose(xCoords)
  k = 0.0025
  degradation = exp(-k*(xCoords^2 + yCoords^2)^(5d/6d))
  imageDegraded = degradation*fft_2d_center(moon) + fft_2d_center(moon_noise)
  ;; Filter the degraded image with the Wiener filter
  powerClean = abs(fft_2d_center(moon))^2
  powerNoise = abs(fft_2d_center(moon_noise))^2
  degradationConjugate = conj(degradation)
  imageFiltered = fft_2d_center( $
                  degradationconjugate/(degradation* $
                                        degradationconjugate + powerNoise/ $
                                        powerClean)*imageDegraded, $
                  /inverse)
  
  ;; Hide any divide by zero errors
  void = CHECK_MATH(MASK=16)

  imageDegraded = fft_2d_center(imageDegraded, /inverse)
  write_jpeg, 'figures/degraded_moon.jpg', imageDegraded
  write_jpeg, 'figures/filtered_moon.jpg', imageFiltered
  return
end
