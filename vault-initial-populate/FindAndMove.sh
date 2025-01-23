#!/bin/bash
for i in $(find . -name ENV.\* -type f ! -iname \*.old); do
  echo "$i moved to $i.old"
  mv "$i" "$i.old"
done

#to undo
#$ for FILE in $(ls *.old | awk '{print $0}'); do mv $FILE $(echo $FILE | sed s/.old//g) ; done