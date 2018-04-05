#!/bin/sh

dir="`dirname $0`"
version=`cat "$dir/data/VERSION"`
extra=`cat "$dir/data/EXTRA"`

cd data
./renumber.py
./generate_db.sh --noninteractive
cd ..

android_outfile="$dir/qawHaq-$version.db.zip"
zip $android_outfile "$dir/data/qawHaq.db"
android_size=`stat -c %s "$android_outfile" 2>/dev/null ||
              stat -f %z "$android_outfile"`

ios_outfile="$dir/qawHaq-$version.json.bz2"
"$dir/data/xml2json.py" | bzip2 > "$ios_outfile"
ios_size=`stat -c %s "$ios_outfile" 2>/dev/null ||
          stat -f %z "$ios_outfile"`

tee $dir/manifest.json <<EOF
{
  "iOS-1" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.json.bz2",
      "size" : $ios_size
    }
  },
  "Android-1" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.db.zip",
      "extra" : $extra,
      "size" : $android_size
    }
  }
}
EOF
