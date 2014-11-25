IDL = gdl
CLEAN_FILES = *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.log *.nav *.out \
	      *.run.xml *.snm *.synctex.gz *.toc figures/*.aux \
	      figures/*-inc.eps figures/*-inc-eps-converted-to.pdf \
	      figures/*.log figures/*.tex
DISTCLEAN_FILES = degraded_*.jpg filtered_*.jpg *.dat figures/signal.pdf \
		  figures/signal-noise.pdf figures/result.pdf

.PHONY: all clean distclean

all: wiener.pdf

wiener.pdf: figures/signal.pdf figures/power-spectra.pdf wiener.tex
	latexmk -pdf wiener

figures/signal.pdf: figures/signal.gnuplot figures/signal.dat
	cd figures && gnuplot signal.gnuplot

figures/power-spectra.pdf: figures/signal.gnuplot figures/lena.dat
	cd figures && gnuplot power-spectra.gnuplot

figures/lena.dat figures/signal.dat: filtro_wiener.pro
	echo filtro_wiener | $(IDL)

clean:
	rm -f $(CLEAN_FILES)

distclean: clean
	rm -f $(DISTCLEAN_FILES)
