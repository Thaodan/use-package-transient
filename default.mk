TOP := $(dir $(lastword $(MAKEFILE_LIST)))

PKG = use-package-transient

ELS   = $(PKG).el
ELCS  = $(ELS:.el=.elc)

DEPS  = use-package

DOMAIN      ?= magit.vc
CFRONT_DIST ?= E2LUHBKU1FBV02

VERSION ?= $(shell test -e $(TOP).git && git describe --tags --abbrev=0 | cut -c2-)
REVDESC := $(shell test -e $(TOP).git && git describe --tags)

EMACS      ?= emacs
EMACS_ARGS ?=

LOAD_PATH  ?= $(addprefix -L ../,$(DEPS))
LOAD_PATH  += -L .
