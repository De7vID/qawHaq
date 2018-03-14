#!/bin/sh

dir="`dirname $0`"
version=`cat "$dir/data/VERSION"`
outfile="$dir/qawHaq-$version.json.bz2"

"$dir/data/xml2json.py" | bzip2 > "$outfile"
size=`stat -c %s "$outfile"`

tee $dir/manifest.json <<EOF
{
  "1" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.json.bz2",
      "size" : $size
    }
  }
}
EOF
