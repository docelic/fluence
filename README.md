# Fluence.cr

Elegant wiki powered by Crystal, with markdown as native format and a WYSIWYG editor.

It works, but currently it uses on-disk files as backend. One of the first steps is to migrate it to an SQL database.

## Installation and Startup

Download and compile:

```bash
git clone https://github.com/crystallabs/fluence.cr
cd fluence.cr
shards
crystal spec # or just: crystal s
make # or make release
```

The result of the compilation will be one executable file &mdash; bin/fluence.

Run it, and visit [http://localhost:3000/](http://localhost:3000/) in your browser.

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - Fluence was originally developed based on Arthur's [Wikicr](https://github.com/Nephos/wikicr). Thanks!
