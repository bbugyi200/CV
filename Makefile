NAME    := BryanBugyi_CV
TEX     := $(NAME).tex
PDFS    := $(NAME).pdf $(NAME)_extended.pdf
PREVIEW := assets/$(NAME).png
LATEX   := pdflatex -interaction=nonstopmode -halt-on-error

# Strings that must never appear in the source (stale or unverifiable claims).
FORBIDDEN := 99\.99|billion|firm-wide|Founder|Prometheus|sandbox|replay|\\today

.PHONY: all check clean

all: $(PDFS) $(PREVIEW) check

$(NAME).pdf: $(TEX)
	$(LATEX) $(TEX)

$(NAME)_extended.pdf: $(TEX)
	$(LATEX) -jobname=$(NAME)_extended "\def\fullcv{}\input{$(NAME)}"

$(PREVIEW): $(NAME).pdf
	mkdir -p $(dir $@)
	mutool draw -q -r 110 -o $@ $< 1

check: $(PDFS)
	@set -e; \
	pages() { mutool info "$$1" | awk '/^Pages:/ {print $$2}'; }; \
	test "$$(pages $(NAME).pdf)" = 1 || { echo "check: $(NAME).pdf must be exactly 1 page"; exit 1; }; \
	test "$$(pages $(NAME)_extended.pdf)" = 2 || { echo "check: $(NAME)_extended.pdf must be exactly 2 pages"; exit 1; }; \
	for log in $(NAME).log $(NAME)_extended.log; do \
	  test -f "$$log" || { echo "check: missing $$log; run 'make clean all'"; exit 1; }; \
	  if grep -E 'Overfull|Underfull' "$$log"; then echo "check: bad boxes in $$log"; exit 1; fi; \
	done; \
	for pdf in $(PDFS); do \
	  txt="$$(mutool draw -q -F txt $$pdf)"; \
	  for s in 'Bryan Bugyi' sase Google Bloomberg Edgestream Java; do \
	    printf '%s' "$$txt" | grep -q "$$s" || { echo "check: '$$s' missing from $$pdf text"; exit 1; }; \
	  done; \
	done; \
	mutool draw -q -F txt $(NAME)_extended.pdf | grep -q Comcast || { echo "check: Comcast missing from extended edition"; exit 1; }; \
	if grep -n -i -E '$(FORBIDDEN)' $(TEX) || grep -n -w GA $(TEX); then echo "check: forbidden string in $(TEX)"; exit 1; fi; \
	echo "check: OK"

clean:
	rm -f *.aux *.log *.out
