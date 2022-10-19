paper: images/rules.png
	latexmk -xelatex main.tex

view:
	okular main.pdf &

watch:
	while inotifywait -r -e modify --exclude  '(\.git/.*|.*(\.swp|\.swo|\.swn|\.fdb_latexmk|~))'  . ; do $(MAKE) paper; done

images/rules.png: images/rules.svg
	convert -density 600 images/rules.svg images/rules.png
	optipng images/rules.png

clean:
	latexmk -c
