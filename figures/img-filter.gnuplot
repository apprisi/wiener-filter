reset
set terminal epslatex color solid standalone \
    header '\usepackage[sfmath,slantedGreeks]{kpfonts}\renewcommand*\familydefault{\sfdefault}'

set view map
set view equal xy
set logscale cb
set xrange [0:511]
set yrange [0:511]
unset xtics
unset ytics

set output 'img-filter.tex'
plot 'img-filter.dat' matrix with image notitle
set output
!pdflatex img-filter.tex && pdfcrop img-filter.pdf img-filter.pdf
