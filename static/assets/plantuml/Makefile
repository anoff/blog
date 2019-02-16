.PHONY: pdf inject-git-version verify-git-clean clean

COMMIT_SHA := $(shell git rev-parse --short=8 HEAD)

inject-git-version:
	sed -i.bak 's/\({v\.\)[[:alnum:]]*\(}\)/\1${COMMIT_SHA}\2/' puml-cheatsheet.tex

verify-git-clean:
	git diff-index --quiet HEAD

pdf:
	docker run -v ${CURDIR}:/doc/ -t -i thomasweise/texlive xelatex.sh puml-cheatsheet.tex

clean:
	mv puml-cheatsheet.tex.bak puml-cheatsheet.tex
	mv puml-cheatsheet.pdf ../..

build: verify-git-clean inject-git-version pdf clean

puml:
	sh diagrams/convert.sh

puml-language:
	docker run --rm think/plantuml java -Djava.awt.headless=true -jar plantuml.jar -language > puml-language.txt