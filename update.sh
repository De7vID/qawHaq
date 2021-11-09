#!/bin/bash

dir="`dirname $0`"

# Check for MacOS and use GNU-sed if detected.
if [[ "$(uname -s)" = "Darwin" ]]
then
    SED=gsed
else
    SED=sed
fi

# Record sizes of old versions.
old_android_outfile="$dir/qawHaq-*.db.zip"
old_android_size=`stat -c %s $old_android_outfile 2>/dev/null ||
                  stat -f %z $old_android_outfile`
old_ios_outfile="$dir/qawHaq-*.json.bz2"
old_ios_size=`stat -c %s $old_ios_outfile 2>/dev/null ||
              stat -f %z $old_ios_outfile`

# Delete old versions.
git rm "$dir/qawHaq-*"

# Generate Android-4 format version file.
cd data
./generate_db.sh --noninteractive
cd ..

version=`cat "$dir/data/VERSION"`
extra=`cat "$dir/data/EXTRA"`
android_outfile="$dir/qawHaq-$version.db.zip"
zip $android_outfile "$dir/data/qawHaq.db"
android_size=`stat -c %s "$android_outfile" 2>/dev/null ||
              stat -f %z "$android_outfile"`

# Generate iOS-1 format version file.
ios_outfile="$dir/qawHaq-$version.json.bz2"
# Temporarily delete "klcp1" tags until flingon-assister is fixed.
"$dir/data/xml2json.py" > temp.json
${SED} -e "s/,klcp1//g" temp.json | bzip2 > "$ios_outfile"
rm temp.json
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
  "JSON-1" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.json.bz2",
      "size" : $ios_size
    }
  },
  "Android-4" : {
    "status" : "active",
    "latest" : "$version",
    "$version" : {
      "path" : "qawHaq-$version.db.zip",
      "extra" : $extra
    }
  }
}
EOF

# Update repository.
git add "$dir/manifest.json"
git add "$dir/data"
git commit -m "version $version"

# Sanity check file size changes.
echo "Android: $old_android_size to $android_size"
echo "iOS:     $old_ios_size to $ios_size"
