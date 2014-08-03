rygr
======

Simple build tool and server to support thick web clients.

Install NPMs and Bower packages
---
Rygr provides a simple command to install both NPMs and Bower packages. *It is not neccessary to use this command, and NPMs and Bower packages and can be installed independently using their respective CLIs*

```shell
# From the project's dir
rygr install
```

Update NPMs and Bower packages
---
rygr provides a simple command to update both NPMs and Bower packages. *It is not neccessary to use this command, and NPMs and Bower packages and can be updated independently using their respective CLIs*

```shell
# From the project's dir
rygr update
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
