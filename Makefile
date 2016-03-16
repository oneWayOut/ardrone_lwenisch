####################################
# ARINC653-simulator head Makefile #
####################################
CC 		:= arm-linux-gnueabi-g++
#CC 		:= g++
INCLUDE_DIR	:= $(shell pwd)/include/libApexArinc653
#CC_FLAGS_ALL	:= -Wall -pedantic -g
CC_FLAGS_ALL	:= -fPIC -Wall -pedantic
LIBS		:= -lpthread -L$(shell pwd)/lib/ -lApexArinc653 -Wl,-rpath ./
LIBAPEXARINC653_DIR	:= sources/libApexArinc653


define SRC_2_OBJ
    $(foreach src,$(1),$(patsubst sources/%,build/%,$(src)))
endef

define SRC_2_BIN
    $(foreach src,$(1),$(patsubst sources/%,binary/%,$(src)))
endef

define SRC_2_SYM
    $(foreach src,$(1),$(patsubst sources/%.sym,binary/%,$(src)))
endef

all: lib targets 

build/%.o: sources/%.cpp
	@echo "  [CC]    $< -> $@"
	@mkdir -p $(dir $@)
	@$(CC) $(CC_FLAGS_ALL) $(CC_FLAGS_SPEC) -I$(INCLUDE_DIR) -o $@ -c $< 

%.sym :
	for path in $^ ; do \
	    echo ln -fs $(shell pwd)/$$path $(call SRC_2_SYM, $@)/; \
	    ln -fs $(shell pwd)/$$path $(call SRC_2_SYM, $@)/; \
	done

binary/%.out:
	@echo "  [CC]    $< -> $@"
	@mkdir -p $(dir $@)
	@echo -I$(INCLUDE_DIR)  -o $@ $^ $(LIBS)
	@$(CC) -I$(INCLUDE_DIR)  -o $@ $^ $(LIBS)

# Overriden in rules.mk
TARGETS :=
OBJECTS :=
SYMLINKS :=

dir	:= sources
include	$(dir)/rules.mk

targets: link $(patsubst sources/%, binary/%, $(TARGETS)) symlinks

clean:
	@rm -f $(TARGETS) $(OBJECTS)

mrproper :
	@rm -f $(TARGETS) $(OBJECTS)
	@rm -rf lib
	@find -name *~ | xargs rm -f
	@find -name "*.fifo" | xargs rm -f
	@(cd $(shell pwd)/sources/libApexArinc653/ && $(MAKE) $@)

	

symlinks: $(SYMLINKS)
	@echo symlinks created

info:
	@echo Targets [$(TARGETS)]
	@echo Objects [$(OBJECTS)]
	@echo Symlinks [$(SYMLINKS)]
	
link :
	@export LD_LIBRARY_PATH=$(shell pwd)/lib/

	
lib:
	@(cd $(shell pwd)/$(LIBAPEXARINC653_DIR) && $(MAKE) $@)
