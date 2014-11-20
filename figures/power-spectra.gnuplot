reset
set terminal epslatex color solid standalone size 10,3.5 \
    header '\usepackage[sfmath,slantedGreeks]{kpfonts}\renewcommand*\familydefault{\sfdefault}'

set view map
set view equal xy
set logscale cb
set xrange [0:511]
set yrange [0:511]
set cbrange [1e-2:1e5]
set xtics format "$%g$"
set ytics format "$%g$"

set output 'power-spectra.tex'
set multiplot layout 1,2
plot 'lena.dat' matrix with image
plot 'elaine.dat' matrix with image
unset multiplot
set output
!pdflatex power-spectra.tex && pdfcrop power-spectra.pdf power-spectra.pdf
