reset
set terminal epslatex color solid standalone \
    header '\usepackage[sfmath,slantedGreeks]{kpfonts}\renewcommand*\familydefault{\sfdefault}'

set xtics format "$%g$"
set ytics format "$%g$"
set key width -4
set yrange [-1:1.5]
set mxtics 2
set mytics 2
set grid xtics ytics mxtics mytics

set output 'signal.tex'
plot 'signal.dat' using 1:3 with lines linewidth 2 title 'Original signal'
set output
!pdflatex signal.tex && pdfcrop signal.pdf signal.pdf

set output 'signal-noise.tex'
plot 'signal.dat' using 1:3 with lines  linewidth 2 title 'Original signal', \
     'signal.dat' using 1:5 with lines linewidth 2 linecolor 3 title 'Noisy signal'
set output
!pdflatex signal-noise.tex && pdfcrop signal-noise.pdf signal-noise.pdf

set output 'result.tex'
plot 'signal.dat' using 1:3 with lines  linewidth 2 title 'Original signal', \
     'signal.dat' using 1:7 with lines linewidth 2 linecolor 3 title 'Filtered noisy signal'
set output
!pdflatex result.tex && pdfcrop result.pdf result.pdf
