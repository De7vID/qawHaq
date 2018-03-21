# tlhIngan Hol qawHaq

This repository stores Klingon Language Database snapshots compiled from:
https://github.com/De7vID/klingon-assistant-data

Clients should use the manifest file `manifest.json` to identify and locate
database files. The format of the manifest is:

    {
      "<format_version>" : {
        "status" : "<status>",
        "latest" : "<database_version>",
        "<database_version>" : {
          "path" : "<path_to_database_file>",
          "size" : <database_file_size>
        }
      }
    }

`<format_version>` refers to the format version of the database. Multiple
concurrent database formats can be supported by giving each format version
its own section.

`<status>` refers to the current support status of the given format version.
Currently defined status values are:

* "active": this database format is actively supported and updated.
* "deprecated": this database format still receives updates, but has been
  superseded by a newer database format.
* "obsolete": this database format no longer receives updates.

The `latest` field indicates the most recent database version avaialble for
a given format version.

`<database_version>` refers to the version of the database data. A format
version section may include multiple database version entries, but only
one may be present as the value of the `latest` field.

Each `<database_version>` key in a `<format_version>` section holds a
dictionary of metadata about the given database file:

* "path" specifies the location of the database file as a URI. If the path
  contains "://", it should be interpreted as an absolute path; otherwise,
  it should be resolved relative to the location of the manifest file.
* "size" is the size of the database file, in bytes, as a JSON number.

A manifest file may indicate that clients should consult a different location
for updates by exposing a `moved_to` key, and not reference any databases:

    {
      "moved_to" : "<new_location>",
      "note" : "<optional_notes>"
    }

`<new_location>` should ideally be an absolute URI (as determined by the
presence of "://"), but may be relative to the current manifest file, if
need be. If `<new_location>` ends with `/`, the manifest should be named
`manifest.json` and located inside the specified directory. Otherwise,
if `<new_location>` does not end with `/`, it should be treated as a
direct path to the new manifest file.

When indicating a move to a new location, a manifest file may also specify
a `note` field with a note explaining the move in more detail. Clients may
display this message to users, but are not required to.
