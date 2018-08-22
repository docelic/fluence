# Fluence

Elegant wiki powered by Crystal, with markdown as native format and a WYSIWYG editor.

It uses file-based storage versioned using Git. Wiki pages are created as files and directories on disk and they can be modified in Fluence or via filesystem directly.
(Please submit any opinions on this approach in [Storage backend - files or database?](https://github.com/crystallabs/fluence/issues/1).)

Fluence uses Bootstrap 4 and jQuery 3.3.1 slim.

## Installation and Startup

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
Files `meta/pages` and `meta/media` are indexes of pages and media content respectively. If you believe the contents have gone out of sync with the actual on-disk state (possibly due to a bug, or external modifications to files which Fluence didn't auto-detect and update), feel free to delete these files and restart Fluence. They will be regenerated from actual on-disk contents.

## Current State / Usability

All in all, the Fluence Wiki is usable. On-disk format for data won't change so you will be able to upgrade without trouble.

Things to watch out for currently:

1. The default permissions scheme (which works and can be configured via both `meta/acls` and GUI) makes all registered users automatically be admin, and registration is open and does not require email confirmation. Therefore, the initial target for deployment and test are small and trusted intranets or groups.
1. Uploaded media files do not show automatically in the list of media attached to the page. A page reload is needed after upload for them to show, and also there is no GUI button to delete uploaded media.

To give you better idea of improvements coming, the following issues have highest priority:

1. Fix small visual misalignments (#3)
1. Implement visual improvements to attachments section (#48)
1. Improve visual appearance of hierarchical list of pages on the left (#24, #45)
1. Add ability to search for pages, page content, and media (#11, #19)
1. Add ability to see page history and add log messages when saving (#40, #42)

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - Fluence was originally developed based on Arthur's [Wikicr](https://github.com/Nephos/wikicr). Thanks!
