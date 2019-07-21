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
done
mv $BASEDIR/*.svg $BASEDIR/dist/
echo Done