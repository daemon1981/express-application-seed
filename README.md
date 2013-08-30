# Node-Plinth

Web site plinth using awesome libs.

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

compile client coffeescripts on save:
```
coffee -wcb -o public/javascripts/ public/coffeescript/*.coffee
```

## Tests

launch unit tests:
```
NODE_ENV=test mocha --compilers coffee:coffee-script --reporter spec --recursive test
```
