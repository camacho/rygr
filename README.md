Bedrock
======

Foundational build tool and simple server to support thick web clients.

Prerequisites
---
Bedrock's only dependency is Node.

To install Node via [Homebrew](http://brew.sh/), run:
```sh
brew update
brew install node
```

Bedrock is intended to be run as a global NPM:
```shell
npm install -g bedrock
```

Init
---
To initialize a new Bedrock project, go to the directory and run
```shell
bedrock init
```

What's generated?
---
Bedrock generates a new project that is supported by NPM, Gulp, and Bower.

Front end:
* RequireJS modules (including templates)
* Coffeescript
* SASS w/Bourbon
* HAMLC JS templates
* HAMLC HTML pages
* Static files
* Bower for 3rd party dependencies

Server:
* Express with middleware

The thick client is supported by a simple Express server. It uses middleware
options to properly load a build of the client and support and push state URLs.
The server can also be extended with additional functionality (like an API) with
no problems.

Build tool
---
Bedrock uses Gulp.js as it's build tool.

To compile the NPM:
```shell
gulp compile
```

To compile, watch for changes, and test locally:
```shell
gulp clean && gulp compile && npm link && gulp watch
```
