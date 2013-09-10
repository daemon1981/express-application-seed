check: test

test:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter spec --timeout 2000 test

test-unit:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter spec test/unit

test-functional:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter spec --timeout 2000 test/functional

test-report:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter markdown --timeout 2000 test > ./test.md

.PHONY: test test-unit test-functional test-report
