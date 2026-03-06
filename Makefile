PREFIX := /usr

PROGRAMS := $(wildcard scripts/* tap/*)

SHELL_SCRIPTS := \
	git/post-receive \
	pbuilder-hookdir/B20autopkgtest \
	pbuilder-hookdir/B90lintian \
	pbuilder-hookdir/C10shell \
	pbuilder-hookdir/D10-man-db \
	pbuilder-hookdir/D10aptspeedup \
	pbuilder-hookdir/D20releaserepo \
	puppet/apply.sh \
	scripts/jdg-build-and-provide-package \
	scripts/jdg-debc \
	scripts/jdg-generate-git-snapshot \
	scripts/jdg-generate-reprepro-codename \
	scripts/jdg-generate-svn-snapshot \
	scripts/jdg-increase-version-number \
	scripts/jdg-piuparts-wrapper \
	scripts/jdg-remove-reprepro-codename \
	scripts/jdg-repository-checker \
	svn/post-commit \
	svn/trigger_jenkins \
	tap/jdg-tap-tool-dispatcher \
	tests/file-detection \
	tests/increase-version-number \
	tests/merge-conflict \
	# EOL

all: build

build:

check: build
	tests/merge-conflict
	tests/increase-version-number
	tests/file-detection

shellcheck:
	shellcheck $(SHELL_SCRIPTS)

install: build
	mkdir -p $(DESTDIR)/$(PREFIX)/bin/
	for prog in $(PROGRAMS); do \
		install -m 0755 $$prog $(DESTDIR)/$(PREFIX)/bin; \
	done

	mkdir -p $(DESTDIR)/usr/share/jenkins-debian-glue/examples/
	install -m 0664 examples/* $(DESTDIR)/usr/share/jenkins-debian-glue/examples/
	mkdir -p $(DESTDIR)/usr/share/jenkins-debian-glue/pbuilder-hookdir/
	install -m 0775 pbuilder-hookdir/* $(DESTDIR)/usr/share/jenkins-debian-glue/pbuilder-hookdir/

uninstall:
	for prog in $(PROGRAMS); do \
		rm $(DESTDIR)/$(PREFIX)/bin/$${prog#scripts} ; \
	done
	rm -rf $(DESTDIR)/usr/share/jenkins-debian-glue/examples
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/jenkins-debian-glue

deploy: build
	fab all

clean:
	rm -f fabfile.pyc

.PHONY: all build check install uninstall deploy clean shellcheck
