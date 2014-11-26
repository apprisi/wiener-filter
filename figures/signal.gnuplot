reset
set terminal epslatex color solid standalone \
    header '\usepackage[sfmath,slantedGreeks]{kpfonts}\usepackage{siunitx}\renewcommand*\familydefault{\sfdefault}'

set xtics format '\num{%g}'
set ytics format '\num{%g}'
set key width -4
set yrange [-1:1.5]
set mxtics 2
set mytics 2
set grid xtics ytics mxtics mytics
set xlabel 'Time'

set output 'signal.tex'
plot 'signal.dat' using 1:3 with lines linewidth 3 title 'Original signal'
set output
!pdflatex signal.tex && pdfcrop signal.pdf signal.pdf

set output 'signal-noise.tex'
plot 'signal.dat' using 1:3 with lines linewidth 3 title 'Original signal', \
     'signal.dat' using 1:5 with lines linewidth 2 linecolor 3 title 'Noisy signal'
set output
!pdflatex signal-noise.tex && pdfcrop signal-noise.pdf signal-noise.pdf

set output 'result.tex'
plot 'signal.dat' using 1:3 with lines linewidth 3 title 'Original signal', \
     'signal.dat' using 1:8 with lines linewidth 2 linecolor 3 title 'Filtered noisy signal'
set output
!pdflatex result.tex && pdfcrop result.pdf result.pdf

set lmargin 8
set xlabel 'Frequency'
set xrange [-315:315]
set mxtics 4
set yrange [*:*]
set logscale y
set output 'filter.tex'
plot 'signal.dat' using 2:9 smooth unique with lines linewidth 2 title 'Wiener filter'
set output
!pdflatex filter.tex

set output 'signal-spectra.tex'
set yrange [*:0.16]
set key width -1.5
plot 'signal.dat' using 2:6 smooth unique with lines linewidth 3 title '$|\hat{S}|^2$', \
     'signal.dat' using 2:7 smooth unique with lines linewidth 2 linecolor 3 title '$|\hat{N}|^2$'
set output
!pdflatex signal-spectra.tex
