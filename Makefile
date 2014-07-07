PREFIX ?= /usr/local
INSTALLDIR ?= $(PREFIX)/bin

SRC = src
BLD = build
DOC = doc
DIST = dist

LIB = lib
STYLE = css
TEST = test_data

#needs tool check
#http://stackoverflow.com/questions/5618615/check-if-a-program-exists-from-a-makefile

default: doc

all: clean doc test dist

doc: $(SRC)/oschema.xsd

	@echo ""
	@echo "creating schmea documentation for oschema.xsd"
	@echo "---------------------------------------------"
	@echo ""
	@echo "tools needed: java, xmlstarlet"
	@echo ""

	mkdir -p $(BLD) \
	&& cd $(BLD) \
	&& echo ""; echo "creating svg..." \
	&& java -jar ../$(LIB)/xsdvi.jar ../$(SRC)/oschema.xsd >/dev/null 2>&1 \
	&& echo "creating html..." \
	&& xmlstarlet tr ../$(LIB)/xs3p.xsl ../$(SRC)/oschema.xsd > oschema.html \
	&& cd ..

	@echo ""
	@echo "output: $(BLD)/oschema.svg"
	@echo "output: $(BLD)/oschema.html"
	@echo ""
	@echo "done."
	@echo ""

dist: $(BLD)/oschema.svg $(BLD)/oschema.html

	@echo ""
	@echo "creating tarball for distribution"
	@echo "---------------------------------"
	@echo ""

	mkdir -p $(DIST)/oschema-1.0
	cp $(SRC)/oschema.xsd $(DIST)/oschema-1.0
	cp $(SRC)/oschema_validate.sh $(DIST)/oschema-1.0
	cp $(BLD)/oschema.svg $(DIST)/oschema-1.0
	cp $(BLD)/oschema.html $(DIST)/oschema-1.0
	cp $(TEST)/minimal.xml $(DIST)/oschema-1.0

	cd $(DIST) && \
	tar cfvz oschema-1.0.tgz oschema-1.0 && \
	cd ..

	@echo ""
	@echo "output: $(DIST)/oschema-1.0.tgz"
	@echo ""
	@echo "done."

test: $(SRC)/oschema.xsd

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
	@echo "INSTALLDIR: $(INSTALLDIR)"
	@echo ""
	@echo "'make install' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make install"
	@echo ""

	cp $(SRC)/oschema_validate.sh $(INSTALLDIR)/oschema_validate
	cp $(SRC)/oschema.xsd $(INSTALLDIR)/

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
	@echo "INSTALLDIR: $(INSTALLDIR)"
	@echo ""
	@echo "'make uninstall' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make uninstall"
	@echo ""

	rm -f $(INSTALLDIR)/oschema_validate
	rm -f $(INSTALLDIR)/oschema.xsd

	@echo ""
	@echo "done."
	@echo ""

clean:

	@echo ""
	@echo "cleaning up $(BLD) directory"
	@echo "---------------------------"
	@echo ""

	mkdir -p $(BLD)
	rm -f ./$(BLD)/*
	mkdir -p $(DIST)
	rm -rf ./$(DIST)/oschema-1.0
	rm -f ./$(DIST)/*

	@echo ""
	@echo "done."
	@echo ""

.PHONY: all
