#!/bin/sh
# converts all puml files to svg

BASEDIR=$(dirname "$0")
mkdir -p $BASEDIR/dist
rm $BASEDIR/dist/*
for FILE in $BASEDIR/*.puml; do
  echo Converting $FILE..
  FILE_SVG=${FILE//puml/svg}
  FILE_PDF=${FILE//puml/pdf}
  cat $FILE | docker run --rm -i think/plantuml > $FILE_SVG
  docker run --rm -v $PWD:/diagrams productionwentdown/ubuntu-inkscape inkscape /diagrams/$FILE_SVG --export-area-page --without-gui --export-pdf=/diagrams/$FILE_PDF &> /dev/null
done
mv $BASEDIR/*.svg $BASEDIR/dist/
mv $BASEDIR/*.pdf $BASEDIR/dist/
echo Done