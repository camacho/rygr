Rygr
======

Simple scaffolding CLI to setup up a build tool and server to support thick web clients

Stack
---
Rygr generates a new project that is supported by npm, Gulp, and Bower.

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
```

To build, start the server, and watch for changes:
```shell
gulp
```

Rygr also provides a blank test command via Gulp that is accessible by either 
running `npm test` or `gulp test`.

Configs
---
The configs directory contains basic options for RequireJS, the client,
livereload, and the server. Feel free to add additional configs. They will
automatically be read in and can be access via their filename as follows:

```coffee
{config} = require 'rygr-utils'
config.initialize 'config/*.json'
console.log config.server.port
#8888
```

Install npms and Bower packages
---
Rygr provides a simple command to install both npms and Bower packages. *It is not neccessary to use this command, and npms and Bower packages and can be installed independently using their respective CLIs*

```shell
# From the project's dir
rygr install
```

Update npms and Bower packages
---
Rygr provides a simple command to update both npms and Bower packages. *It is not neccessary to use this command, and npms and Bower packages and can be updated independently using their respective CLIs*

```shell
# From the project's dir
rygr update
```
