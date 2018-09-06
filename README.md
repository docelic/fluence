**Build status**: [![Build Status](https://travis-ci.com/crystallabs/fluence.svg?branch=master)](https://travis-ci.com/crystallabs/fluence)
[![Version](https://img.shields.io/github/tag/crystallabs/fluence.svg?maxAge=360)](https://github.com/crystallabs/fluence/releases/latest)
[![License](https://img.shields.io/github/license/crystallabs/fluence.svg)](https://github.com/crystallabs/fluence/blob/master/LICENSE)

**Project status**: `[X] Being developed  [X] Usable  [ ] Functionally complete`

# Fluence

Elegant wiki powered by Crystal, with markdown as native format and a WYSIWYG editor.

It uses file-based storage versioned using Git. Wiki pages are created as files and directories on disk and they can be modified in Fluence or via filesystem directly.
(Please submit any opinions on this approach in [Storage backend - files or database?](https://github.com/crystallabs/fluence/issues/1).)

Fluence uses Bootstrap 4 and jQuery 3.3.1 slim.

## Installation and Startup

Fluence is implemented in Crystal and you will need a Crystal compiler. Obtain it from https://crystal-lang.org/docs/installation/.

Download and compile:

```bash
git clone https://github.com/crystallabs/fluence
cd fluence
shards
crystal spec
make # or 'make release'
```

The result of the compilation will be one executable file &mdash; bin/fluence.

Run it, and visit [http://localhost:3000/](http://localhost:3000/) in your browser.

To configure Fluence, please do so in `config/options.cr`.

## Example

Here's how it currently looks:

![Fluence Wiki Screenshot](https://raw.githubusercontent.com/crystallabs/fluence/master/docs/screenshot.png)

## Maintenance Tips

When Fluence starts, unless you have modified `config/options.cr`, it will create directory `data/` in the current directory (further subdivided into `pages/` and `media/`) to store Wiki pages and their attached media files. Also, it will create `meta/` for meta data, namely `users`, `acl`, `pages`, and `media`.

There are no files or directories required to pre-exist for Fluence to work. Feel free to delete any part of data or metadata as long as you restart Fluence after that.
Files `meta/pages` and `meta/media` contain indexes of pages and media content respectively. If you believe their contents have gone out of sync with the actual on-disk state (possibly due to a bug or external modifications to files which Fluence didn't auto-detect and update), delete these files and restart Fluence; the indices will be regenerated from actual on-disk contents.

## Current State / Usability

All in all, the Fluence Wiki is usable. On-disk format for data won't change so you will be able to upgrade without trouble.

Things to watch out for currently:

1. The default permissions scheme (which works and can be configured via both `meta/acls` and GUI) by default makes all registered users automatically be admin, and registrations are always open and don't require any confirmation. Therefore, the initial target for deployment and test of Fluence are small/trusted intranets and teams.

Things we have in mind or are working on are listed in [project issues](https://github.com/crystallabs/fluence/issues). Your comments will help us decide on priorities.

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - Fluence was originally developed based on Arthur's [Wikicr](https://github.com/Nephos/wikicr). Thanks!
