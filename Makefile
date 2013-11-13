default: ruby lint

ruby:
	find attributes libraries recipes -name '*.rb' | xargs -n 1 ruby -c

.make.bundle: Gemfile.lock
	GEM_HOME=$(CURDIR)/vendor gem install bundler --no-ri --no-rdoc
	GEM_HOME=$(CURDIR)/vendor bundle install --path $(CURDIR)/vendor/bundle
	touch $@

lint: .make.bundle
	GEM_HOME=$(CURDIR)/vendor/bundle bundle exec foodcritic . --epic-fail any

mrproper:
	rm -rf .bundle .make.* vendor
