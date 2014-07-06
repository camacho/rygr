Bedrock
======

Foundational build tool and simple server to support thick web clients.

Prerequisites
---
For the install command to work, Node and
[Xcode Command Line Tools](http://stackoverflow.com/questions/9329243/xcode-4-4-command-line-tools)
must already be on the machine.

To install Node via [Homebrew](http://brew.sh/), run:
```sh
brew update
brew install node
```

Install
---
```shell
rake install
```

Update
---
```shell
rake update
```

Stack
---
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

Build Tool
---
Bedrock uses Gulp.js as it's build tool.

To build:
```shell
gulp build
```

To start the server:
```shell
gulp server
```

To build, start the server, and watch for changes:
```shell
gulp
```

Configs
---
The configs directory contains basic options for RequireJS, the client,
livereload, and the server. Feel free to add additional configs. They will
automatically be read in and can be access via their filename as follows:

```coffee
config = require 'config'
console.log config.server.port
#8888
```
