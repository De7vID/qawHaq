#!/bin/sh

dir="`dirname $0`"

# Delete old versions.
git rm "$dir/qawHaq-*"

# Generate Android-3 format version file.
cd data
./renumber.py
./generate_db.sh --noninteractive
./unnumber.sh
cd ..

version=`cat "$dir/data/VERSION"`
extra=`cat "$dir/data/EXTRA"`
android_outfile="$dir/qawHaq-$version.db.zip"
zip $android_outfile "$dir/data/qawHaq.db"

# Generate Android-2 format version file (exclude pt).
# TODO: Remove this section.
cd data
./strip_pt.sh
./renumber.py
./generate_db.sh --noninteractive
git reset --hard
cd ..

old_android_outfile="$dir/qawHaq-$version-2.db.zip"
zip $old_android_outfile "$dir/data/qawHaq.db"

# Generate iOS-1 format version file.
ios_outfile="$dir/qawHaq-$version.json.bz2"
"$dir/data/xml2json.py" | bzip2 > "$ios_outfile"
ios_size=`stat -c %s "$ios_outfile" 2>/dev/null ||
          stat -f %z "$ios_outfile"`

# Add new versions.
git add "$dir/qawHaq-*"

# Write manifest.
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
  "Android-2" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version-2.db.zip",
      "extra" : $extra
    }
  },
  "Android-3" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.db.zip",
      "extra" : $extra
    }
  }
}
EOF

git add "$dir/manifest.json"
git add "$dir/data"
git commit -m "version $version"
