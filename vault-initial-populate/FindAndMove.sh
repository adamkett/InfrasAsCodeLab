#!/bin/bash
for i in $(find . -name ENV.\* ! -iname \*.old); do
  echo "$i moved to $i.old"
  mv "$i" "$i.old"
done