all:
	@npm install -d
	@cp scripts/githooks/* .git/hooks/
	@chmod -R +x .git/hooks/


specs := $(shell find ./tests -name '*.test.js' ! -path "*node_modules/*")
reporter = spec
opts =
test:
	@rm -fr tests/_site
	@node_modules/.bin/mocha --reporter ${reporter} ${opts} ${specs}


jsfiles := $(shell find . -name '*.js' ! -path "*node_modules/*" ! -path "*_themes/*" ! -path "*docs/*" ! -path "*_site/*")
lint:
	@node_modules/.bin/jshint ${jsfiles} --config=scripts/config-lint.js

out = _site/coverage.html
coverage:
	@scripts/detect-jscoverage.sh
	@rm -fr lib-cov
	@jscoverage lib lib-cov
	@NICO_COVERAGE=1 $(MAKE) test reporter=html-cov > ${out}
	@echo
	@rm -fr lib-cov
	@echo "Built Report to ${out}"
	@echo

documentation:
	@bin/nico.js build -C nico.json -q

publish: documentation coverage
	@scripts/ghp-import.py _site
	@git push origin gh-pages

clean:
	rm -fr _site

.PHONY: all build test lint coverage
