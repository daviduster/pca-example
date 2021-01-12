PDFLATEX:=pdflatex
MAINTEX=report.tex
OUTPUT_DIR=../
MAIN=report

all:
	cd doc/ && pdflatex $(MAINTEX) > /dev/null && bibtex $(MAIN) > /dev/null && pdflatex $(MAINTEX) > /dev/null && pdflatex -output-directory=$(OUTPUT_DIR) $(MAINTEX) > /dev/null && cd $(OUTPUT_DIR) && make clean

clean: 
	@rm -f *aux *xml *bbl *blg *toc *log *out *lof *lot report-blx.bib

view:
	open report.pdf
 