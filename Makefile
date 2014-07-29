PREFIX ?= /usr/local
bindir = $(PREFIX)/bin
docdir = $(PREFIX)/share/doc/oschema
XSDDIR = $(bindir)/oschema_xsd

SRC = src
DOC = doc
DIST = dist

LIB = lib
STYLE = css
TEST = test_data

OSCHEMA_VERSION ?= 1.3.1

#needs tool check
#http://stackoverflow.com/questions/5618615/check-if-a-program-exists-from-a-makefile

default: doc

all: doc

doc: $(SRC)/oschema.xsd

	@echo ""
	@echo "creating schmea documentation for oschema.xsd"
	@echo "---------------------------------------------"
	@echo ""
	@echo "tools needed: java, xmlstarlet"
	@echo ""
	@echo "the github repository contains a generated"
	@echo "documentaion that corresponds the the oschema.xsd file."
	@echo ""
	@echo "this step is not necessary to use the install target."
	@echo ""

	java -version

	cd $(DOC) \
	&& echo ""; echo "creating svg..." \
	&& java -jar ../$(LIB)/xsdvi.jar ../$(SRC)/oschema.xsd >/dev/null 2>&1 \
	&& echo "creating html..." \
	&& xmlstarlet tr ../$(LIB)/xs3p.xsl ../$(SRC)/oschema.xsd > oschema.html \
	&& rm xsdvi.log \
	&& cd ..

	@echo ""
	@echo "output: $(DOC)/oschema.svg"
	@echo "output: $(DOC)/oschema.html"
	@echo ""
	@echo "done."
	@echo ""

dist: 
	@echo ""
	@echo "creating tarball for distribution"
	@echo "---------------------------------"
	@echo ""

	mkdir -p $(DIST)/oschema-$(OSCHEMA_VERSION)
	cp $(SRC)/oschema.xsd $(DIST)/oschema-$(OSCHEMA_VERSION)
	cp $(SRC)/oschema_validate.sh $(DIST)/oschema-$(OSCHEMA_VERSION)
	cp $(DOC)/oschema.svg $(DIST)/oschema-$(OSCHEMA_VERSION)
	cp $(DOC)/oschema.html $(DIST)/oschema-$(OSCHEMA_VERSION)
	cp $(TEST)/minimal.xml $(DIST)/oschema-$(OSCHEMA_VERSION)

	cd $(DIST) && \
	tar cfvz oschema-$(OSCHEMA_VERSION).tgz oschema-$(OSCHEMA_VERSION) && \
	cd ..

	@echo ""
	@echo "output: $(DIST)/oschema-$(OSCHEMA_VERSION).tgz"
	@echo ""
	@echo "done."

test: 

	@echo ""
	@echo "testing several invalid and valid instances against scheama"
	@echo "-----------------------------------------------------------"
	@echo ""

	$(TEST)/run_test.sh $(SRC)/oschema.xsd $(SRC)/oschema_validate.sh $(TEST)

	@echo ""
	@echo "done."
	@echo ""

install:

	@echo ""
	@echo "installing oschema_validate"
	@echo "---------------------------"
	@echo ""
	@echo "DESTDIR: $(DESTDIR)"
	@echo "bindir: $(bindir)"
	@echo ""
	@echo "docdir: $(docdir)"
	@echo "'make install' probably needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make install"
	@echo ""

	install -d $(DESTDIR)$(bindir)
	install -m755 $(SRC)/oschema_validate.sh $(DESTDIR)$(bindir)/oschema_validate

	install -d $(DESTDIR)$(XSDDIR)
	install -m644 $(SRC)/oschema.xsd $(DESTDIR)$(XSDDIR)/

	install -d $(DESTDIR)$(docdir)

	install -m644 $(DOC)/oschema.svg $(DESTDIR)$(docdir)
	install -m644 $(DOC)/oschema.html $(DESTDIR)$(docdir)

	@echo ""
	@echo "use: oschema_validate my_oschema_instance.xml"
	@echo ""
	@echo "done."
	@echo ""

uninstall:

	@echo ""
	@echo "uninstalling oschema_validate"
	@echo "-----------------------------"
	@echo ""
	@echo "DESTDIR: $(DESTDIR)"
	@echo "bindir: $(bindir)"
	@echo ""
	@echo "'make uninstall' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make uninstall"
	@echo ""

	rm -f $(DESTDIR)$(bindir)/oschema_validate

	rm -f $(DESTDIR)$(XSDDIR)/oschema.xsd

	-rmdir $(DESTDIR)$(XSDDIR)

	-rmdir $(DESTDIR)$(bindir)

	rm -f $(DESTDIR)$(docdir)/oschema.svg
	rm -f $(DESTDIR)$(docdir)/oschema.html

	-rmdir $(DESTDIR)$(docdir)

	@echo ""
	@echo "done."
	@echo ""

clean:
	@echo ""
	@echo "cleaning up $(DIST) directory"
	@echo "-----------------------------"
	@echo ""

	rm -rf $(DIST)

	@echo ""
	@echo "done."
	@echo ""

.PHONY: all doc clean install uninstall dist test
