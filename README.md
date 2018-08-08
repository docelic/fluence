# Fluence

Elegant wiki powered by Crystal, with markdown as native format and a WYSIWYG editor.

It currently uses file-based storage, versioned using Git. Wiki pages are created as files and directories on disk. Please submit your opinion on this in the issue [Storage backend - files or database?](https://github.com/crystallabs/fluence/issues/1).

It uses Bootstrap 4 and jQuery 3.3.1.

## Installation and Startup

Download and compile:

```bash
git clone https://github.com/crystallabs/fluence
cd fluence
shards
crystal spec # or just: crystal s
make # or make release
```

The result of the compilation will be one executable file &mdash; bin/fluence.

Run it, and visit [http://localhost:3000/](http://localhost:3000/) in your browser.

## Example

Here's how it currently looks:

![Fluence Wiki Screenshot](https://raw.githubusercontent.com/crystallabs/fluence/master/docs/screenshot.png)

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - Fluence was originally developed based on Arthur's [Wikicr](https://github.com/Nephos/wikicr). Thanks!
