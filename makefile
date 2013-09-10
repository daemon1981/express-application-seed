REPORTER = dot

check: test

test:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter $(REPORTER) --timeout 2000 test

test-unit:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter $(REPORTER) test/unit

test-functional:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter $(REPORTER) --timeout 2000 test/functional

test-unit-report:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter markdown test/unit > ./test-unit.md

test-functional-report:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter markdown --timeout 2000 test/functional > ./test-functional.md

.PHONY: test test-unit test-functional test-report
