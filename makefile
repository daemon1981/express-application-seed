test-unit:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter spec test/unit

test-functional:
	NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter spec --timeout 2000 test/functional
