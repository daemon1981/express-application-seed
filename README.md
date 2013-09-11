# Project plinth in node.js [![Build Status](https://secure.travis-ci.org/daemon1981/express-site-plinth-example.png)](https://travis-ci.org/daemon1981/express-site-plinth-example)

## Introduction

The purporse of this project is to create a real life web application plinth to learn good coding practices and functional strategies.

Good coding practices:
  * No duplication (DRY)
  * Orthogonality (Eliminate effects between unrelated things)
  * Decoupling
  * Testing

Functional Stategies:
  * Signing up
    - http://davidcel.is/blog/2012/09/06/stop-validating-email-addresses-with-regex/
  * Login
  * Locale
  * Contact

## Main librairies used

  * [Coffeescript](https://github.com/jashkenas/coffee-script)
  * [ExpressJs](https://github.com/visionmedia/express)
  * [TwitterBootstrap](https://github.com/twbs/bootstrap)
  * [MongooseJs](https://github.com/LearnBoost/mongoose)
  * [Jade](https://github.com/visionmedia/jade)
  * [PassportJs](https://github.com/jaredhanson/passport)
  * [Nodemailer](https://github.com/andris9/Nodemailer)
  * [Formidable](https://github.com/felixge/node-formidable)

## Setup

### Installation

```
npm install -g coffee-script
npm install -g mocha
npm install
git submodule sync
git submodule update --init --recursive
bower install
```

### Prerequisite

[Install Redis](http://redis.io/topics/quickstart)

compile client coffeescripts on save:
```
coffee -wcb -o public/javascripts/ public/coffeescript/*.coffee
```

## Tests

launch tests:
```
make REPORTER=dot test
```

launch unit tests:
```
make REPORTER=dot test-unit
```

[Unit tests table of content](https://github.com/daemon1981/express-site-plinth-example/blob/master/test-unit.md)

launch functional tests:
```
make REPORTER=dot test-functional
```

[Functional tests table of content](https://github.com/daemon1981/express-site-plinth-example/blob/master/test-functional.md)
