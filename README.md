# wikicr

Wiki in crystal and markdown

The pages of the wiki are written in markdown and committed on the git repository where it is started.

## How to install

### Dependencies

Verify that you have crystal v0.23.0 or greater installed, as well as shards and git.

### Get the application

    git clone https://github.com/Nephos/wikicr.git
    cd wikicr

### Test the application

    make test

### Build the binary

    make

### Run the server

    ./wikicr --port 3000

### Verify your files

A directory `meta/` should be created into wikicr.
It must contains several files and directories (acl, index, users, ...).
You may want to save this directory because it contains meta-data about the pages.

Another `data/` should be a git repository (initialized at the first start).
Those files are the ALL the "displayed data" of the wiki.

## Security and ACLs

* Admin panel to manage the directories and pages
* Rules on directories are terminated with a \*
* If several rules conflict, take the more specific one
  * Directories with the longer name prevails
  * Files rules prevails over directory rules

## Administration and usage tutorial

### Edit / Create a page
<img width=240 src="https://i.imgur.com/5bfJstb.png" />

### Show a page
<img width=240 src="https://i.imgur.com/gllJ8Nr.png" />

### Remove a page
Simply edit the page to remove and delete all the content.
The page will be deleted completely.

### Administrate users and acls
<img width=240 src="https://i.imgur.com/1zWiAV3.png" />

### Custom Markdown
A special markdown (wikimd) is used in the pages. It provides several interesting features:

#### Internal links
An internal link will search through the index of pages to find a matching one and render a valid link to it.

```markdown
blabla [[my page]] blabla
```

##### Notes about the wikimd
- internal link algorithm have been benchmarked a bit
[benchmark link](https://gist.github.com/Nephos/ad292a3e2acc9201e6ea6342eb85dacb)
The algorithm has been improved since, but it gave me a first idea of what to do.

## Development and Roadmap

### You want to add or modify something ?

Don't hesitate to open an issue, I'm always happy to discuss about my projects
or include other developers than me.

## Contributing

1. Open an issue to see what you want to implement and how to do it.
2. Fork it ( https://github.com/Nephos/wikicr/fork )
3. Create your feature branch (git checkout -b my-new-feature)
4. Commit your changes (git commit -am 'Add some feature')
5. Push to the branch (git push origin my-new-feature)
6. Create a new Pull Request

### Operations

For now, there is no "important" core operation to add (they are all already implemented).
However, there are still lots of improvements to write on the current implementation,
documentation, security check, error management and consistency of the code.

  - [x] (core) View wiki pages
  - [x] (core) Write new wiki page, edit existing ones
  - [x] (core) Chroot the files to data/: avoid writing / reading files outside of data/
  - [x] (core) If page does not exists, form to create it: if a file does not exist, display the edit form
  - [x] (core) Delete pages: remove the content of a page should remove the file
  - [x] (core) Index of pages: each modification of a page should update and index with all these pages (with first h1 and url)
  - [x] (core) Choose between sqlite3 and the file system for the index: sqlite = sql, fs = easier
  - [x] (core) Move page (rename): box with "mv X Y" and git commit
  - [x] (core) Lock system for acl/users/index: A thread safe method should be provided to avoid conflict when executing read+write or write operations

### Git

At the beginning, I tried to used libgit2. However, it seems to be a bad idea
because the lib was not documented (no tutorial or at least not up-to-date, API
not very well documented, etc.) so I want to write a little git-* wrapper to
handle some operations (add, commit, revert, etc.).

It is not something very likely to be done first (even if it's a lot of important
features) because it is boring and requires to take care of the security issues.
I must have to replace the "system" calls (in backquote) with `Proccess.new.run`.

  - [x] (git)  Commit when write on a file: every modification on data/ should be committed
  - [ ] (git)  List of revisions on a file (using git): list the revision of a file
  - [ ] (git)  Revert a revision (avoid vandalism): button to remove a revision (git revert)

### Web

There is some important features in order to have a good interface and a fluent
wiki experience. That's not the stuff I prefer because it requires some css/js
(front-end stuff).

There is also work around string matching to write a valid research engine.
This is the most important feature to add right now.

  - [x] (web)  Add content table: if titles are written, give a content table with them and links to anchors
  - [x] (web)  Sitemap: add a list of all the files available
  - [x] (web)  User login / registration: keep a file with login:group:bcryptpassords
  - [x] (web)  User ACL basic (read / write): the groups have rights on directories (globing)
  - [x] (web)  Groups ACL on EVERY wiki url
  - [ ] (web)  Search a page: an input that search a page (content, title) with auto-completion
  - [ ] (web)  Template loader (files in public/): load css, js etc. from public/
  - [ ] (web)  File upload and lists: page that add a file in uploads/
  - [ ] (web)  Tags for pages (index): extended markdown and index to keep a list of pages

### Advanced usage

The current implementation of Markdown in crystal is limited and may be fully rewritten with more standard features in some weeks or months.
For now, I choose to use Markd, another markdown parser, and wrote a wikimd wrapper (Wikicr::Page::Markdown).
It allows me to expand the default markdown by writting HTML inside the markdown to render.

The rest is boring stuff (code factorization, make everything configurable, document the code, add a lot of specs, ...).

  - [x] (edit) Handle `[[tag]]`: markdown extended to search in the page index (url and title)
  - [x] (edit) Handle `[[tag|title]]`: same than internal links but with a fixed title
  - [ ] (core) Index the internal links of a page to update them if a page is move or the title changed.
  - [ ] (web)  Configuration page: title of the wiki, rights of the files, etc. should be configurable
  - [ ] (conf) Handle environment variables in a .env file
  - [ ] (core) Extensions loader (.so files + extended markdown ?): extend the wiki features with hooks

### Other

  - [x] Improve the controller/routes architecture

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - creator, maintainer
