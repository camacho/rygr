<!-- @echo PROJECT_NAME -->
======

Simple build tool and server to support thick web clients

Stack
---
Project is supported by npm, Gulp, and Bower.

Front end:
* RequireJS
* CoffeeScript
* SASS w/Bourbon (using LibSass)
* Jade JS templates
* Jade HTML pages
* Static files
* Image optimization
* Bower for 3rd party dependencies

Server:
* Express server with middleware and Jade views

The thick client is supported by a simple Express server. It uses middleware
options to properly load a build of the client and support and push state URLs.
The server can also be extended with additional functionality (like an API) with
no problems.

Build tool
---
This project uses Gulp.js for it's build tool

To build:
```shell
gulp build
```

To start the server:
```shell
gulp server
# or
npm start
```

To build, start the server, and watch for changes:
```shell
gulp
```

To test:
```shell
gulp test
# or
npm test
```

** TODO: Add tests **

Configs
---
The configs directory contains basic options for RequireJS, the client,
livereload, and the server, more can be added as needed. Config files are
automatically read in and made accessible via their filename as follows:

```coffee
{config} = require 'rygr-utils'
config.initialize 'config/*.json'
console.log config.server.port
#8888
```

Install
---
To install all dependencies for a first load:

```shell
# From the project's dir
npm install && bower install
```

Update npms and Bower packages
---
To update all dependencies:

```shell
# From the project's dir
npm update && bower update
```
