#!/bin/sh

dir="`dirname $0`"
version=`cat "$dir/data/VERSION"`
outfile="$dir/qawHaq-$version.json.bz2"

"$dir/data/xml2json.py" | bzip2 > "$outfile"
size=`stat -c %s "$outfile" 2>/dev/null ||
      stat -f %z "$outfile"`

# Database format "1" will be removed once all existing installations of the
# pre-release iOS boQwI' have been updated to versions that use "iOS-1".

tee $dir/manifest.json <<EOF
{
  "iOS-1" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.json.bz2",
      "size" : $size
    }
  },
  "1" : {
    "status" : "deprecated",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.json.bz2",
      "size" : $size
    }
  }
}
EOF
