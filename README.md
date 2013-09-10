# Project plinth in node.js

## Main librairies used

  * [Coffeescript](https://github.com/jashkenas/coffee-script)
  * [ExpressJs](https://github.com/visionmedia/express)
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
