.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install-aggregate-root:
	@make -C aggregate_root install

test-aggregate-root:
	@make -C aggregate_root test

mutate-aggregate-root:
	@make -C aggregate_root mutate

install-ruby-event-store:
	@make -C ruby_event_store install

test-ruby-event-store:
	@make -C ruby_event_store test

mutate-ruby-event-store:
	@make -C ruby_event_store mutate

install-rails-event-store:
	@make -C rails_event_store install

test-rails-event-store:
	@make -C rails_event_store test

mutate-rails-event-store:
	@make -C rails_event_store mutate

install-rails-event-store-active-record:
	@make -C rails_event_store_active_record install

test-rails-event-store-active-record:
	@make -C rails_event_store_active_record test

mutate-rails-event-store-active-record:
	@make -C rails_event_store_active_record mutate

git-check-clean:
	@git diff --quiet --exit-code

git-check-committed:
	@git diff-index --quiet --cached HEAD

RES_VERSION = `cat RES_VERSION`

git-tag:
	@git tag -m "Version v$(RES_VERSION)" v$(RES_VERSION)
	@git push origin master --tags

set-version:
	@find . -name version.rb -exec sed -i "" "s/\(VERSION = \)\(.*\)/\1\"$(RES_VERSION)\"/" {} \;
	@find . -name *.gemspec -exec sed -i "" "s/\('ruby_event_store', \)\(.*\)/\1'= $(RES_VERSION)'/" {} \;
	@find . -name *.gemspec -exec sed -i "" "s/\('rails_event_store_active_record', \)\(.*\)/\1'= $(RES_VERSION)'/" {} \;
	@find . -name *.gemspec -exec sed -i "" "s/\('aggregate_root', \)\(.*\)/\1'= $(RES_VERSION)'/" {} \;
	@git add -A **/*.gemspec **/version.rb
	@git ci -m "Version v$(RES_VERSION)"

release-rails-event-store:
	@make -C rails_event_store release

release-ruby-event-store:
	@make -C ruby_event_store release

release-rails-event-store-active-record:
	@make -C rails_event_store_active_record release

release-aggregate-root:
	@make -C aggregate_root release

install: install-aggregate-root install-ruby-event-store install-rails-event-store install-rails-event-store-active-record ## Install all deps

test: test-aggregate-root test-ruby-event-store test-rails-event-store test-rails-event-store-active-record ## Run all specs

mutate: mutate-aggregate-root mutate-ruby-event-store mutate-rails-event-store mutate-rails-event-store-active-record ## Run all mutation tests

release: git-check-clean git-check-committed set-version git-tag release-rails-event-store release-ruby-event-store release-rails-event-store-active-record release-aggregate-root ## Make a new release and push to RubyGems
	@echo Released v$(RES_VERSION)

