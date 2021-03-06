.SHELL: /bin/bash

.PHONY: all install base submodules update clean dist-clean
.DEFAULT: all

REPO ?= $(shell pwd)

INSTALL_DIR = $(HOME)/.vim
# INSTALL_DIR is linked no need to have any targets inside it besides those
#   required for pathogen
TARGETS = $(HOME)/.vim/autoload/pathogen.vim
NOOP_TARGETS = $(HOME)/.vim/bundle/jedi-vim \
	$(HOME)/.vim/bundle/supertab \
	$(HOME)/.vim/bundle/syntastic \
	$(HOME)/.vim/bundle/vim-indent-guides \
	$(HOME)/.vim/bundle/vim-surround \
	$(HOME)/.vim/vim-pathogen

# Ignore Makefile targets and specified NoOp targets
$(INSTALL_DIR)/Makefile $(REPO)/Makefile $(NOOP_TARGETS)::

all: install

base: install

install: $(INSTALL_DIR) $(TARGETS)

update: update/bundle/jedi-vim update/bundle/supertab update/bundle/syntastic update/bundle/vim-indent-guides update/bundle/vim-surround update/vim-pathogen

update/bundle/jedi-vim:
	pip3 install --user -U jedi

update/bundle/syntastic:
	pip3 install --user -U pylint

update/%:
	git submodule update --init --recursive --remote --merge ./$*

clean: clean/pathogen

clean/pathogen:
	rm $(INSTALL_DIR)/vim-pathogen/autoload/pathogen.vim
	rm $(REPO)/autoload/pathogen.vim

clean/%:
	rm $(INSTALL_DIR)/$*

dist-clean: clean
	rm $(INSTALL_DIR)

$(HOME)/.local/lib/python3%/site-packages/jedi:
	pip3 install --user jedi

$(HOME)/.local/bin/pylint:
	pip3 install --user pylint

$(INSTALL_DIR):
	ln -sf $(REPO) $@

$(REPO)/vim-pathogen/autoload/pathogen.vim: update/vim-pathogen

$(REPO)/autoload/pathogen.vim: $(REPO)/autoload $(REPO)/vim-pathogen/autoload/pathogen.vim
	ln -sf $(REPO)/vim-pathogen/autoload/pathogen.vim $@

$(INSTALL_DIR)/autoload/pathogen.vim: $(INSTALL_DIR) $(REPO)/autoload/pathogen.vim
	ln -sf $(REPO)/vim-pathogen/autoload/pathogen.vim $@

$(INSTALL_DIR)/%: $(INSTALL_DIR) $(REPO)/%
	ln -sf $(REPO)/$* $@

