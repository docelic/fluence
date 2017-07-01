# wikicr

Wiki in crystal and markdown

The pages of the wiki are written in markdown and commited on the git repository where it is started.

## Installation

    make

## Usage

    wikicr --help
      -b HOST, --bind HOST             Host to bind (defaults to 0.0.0.0)
      -p PORT, --port PORT             Port to listen for connections (defaults to 3000)
      -s, --ssl                        Enables SSL
      --ssl-key-file FILE              SSL key file
      --ssl-cert-file FILE             SSL certificate file
      -h, --help                       Shows this help

### Configuration

#### Environment variables

- WIKI_DATA (default "data/"): set the directory where the data will be stored. It will be removed in the future for a configuation manager
- WIKI_SECRET: random value that init the sessions (`crystal eval 'require "secure_random"; puts SecureRandom.hex(64)'`)

## Development

### Operations

  * [x] (core) View wiki pages
  * [x] (core) Write new wiki page, edit existing ones
  * [x] (core) Chroot the files to data/: avoid writing / reading files outside of data/
  * [x] (core) If page does not exists, form to create it: if a file does not exist, display the edit form
  * [x] (core) Delete pages: remove the content of a page should remove the file
  * [ ] (core) Index of pages: each modification of a page should update and index with all thes pages (with first h1 and url)
  * [ ] (core) Choose between sqlite3 and the filesystem for the index: sqlite = sql, fs = easier
  * [ ] (core) Move page (rename): box with "mv X Y" and git commit

### Git

  * [ ] (git)  Commit when write on a file: every modification on data/ should be commited
  * [ ] (git)  List of revisions on a file (using git): list the revision of a file
  * [ ] (git)  Revert a revision (avoid vandalism): button to remove a revision (git revert)

### Web

  * [ ] (web)  Add content table: if titles are written, give a content table with them and links to anchors
  * [x] (web)  Sitemap: add a list of all the files available
  * [ ] (web)  Search a page: an input that search a page (content, title) with autocompletion
  * [x] (web)  User login / registration: keep a file with login:group:bcryptpassords
  * [ ] (web)  User LDAP basic (read / write): the groups have rights on directories
  * [ ] (web)  Tags for pages (index): extended markdown and index to keep a list of pages
  * [ ] (web)  Template loader (files in public/): load css, js etc. from public/
  * [ ] (web)  File upload and lists: page that add a file in uploads/

### Advanced usage

  * [ ] (core) Extensions loader (.so files + extended markdown ?): extend the wiki features with hooks
  * [ ] (web)  Configuration page: title of the wiki, rights of the files, etc. should be configurable
  * [ ] (edit) Handle `[[tag]]`: markdown extended to search in the page index (url and title)
  * [ ] (conf) Handle environemnt variables in a .env file

### Other

  * [ ] take a look at https://github.com/kemalyst/kemalyst

## Contributing

1. Fork it ( https://github.com/Nephos/wikicr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - creator, maintainer
