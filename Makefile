# lazy build C project Makefiles by impressionyang
# user config values
CC="/usr/bin/gcc"
# CC="E:\\impressionyang\\scoop\\apps\\mingw\\12.2.0\\bin\\gcc.exe"
PROJECT=lazy_make_test
BUILD_DIR=build

# check operating system type
ifeq ($(OS), Windows_NT)
	OS_TYPE := WINDOWS
	SHELL := cmd
else
	UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        OS_TYPE := LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        OS_TYPE := OSX
    endif
endif

$(info OS type = $(OS_TYPE))

# patern config
FILES_PATH  := ./
SRC_FILES_SUFFIX := %.c
HDR_FILES_SUFFIX := %.h

# add build flags
CFLAGS += -fdiagnostics-color=always -g 
CFLAGS += -lm

# define func to remove_same_str for debug: $(info get seen ${seen})
define remove_same_str =
  $(eval seen :=)
  $(foreach _,$1,$(if $(filter $_,${seen}),,$(if $_, $(eval seen += $_)))) 
  ${seen}
endef

# find recursive all files
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# get source file and header file
FIND_ALL_FILES := $(foreach files_path,$(FILES_PATH), $(call rwildcard,$(files_path),*.*) ) 
SOURCES  := $(filter $(SRC_FILES_SUFFIX),$(FIND_ALL_FILES)) 
SOURCES  := $(SOURCES:$(LOCAL_PATH)/%=%)
HEADERS  := $(filter $(HDR_FILES_SUFFIX),$(FIND_ALL_FILES)) 
HEADERS  := $(HEADERS:$(LOCAL_PATH)/%=%)

# fillter out all include path
FIND_ALL_FILES_DIR := $(dir $(foreach files_path,$(FILES_PATH), $(call rwildcard,$(files_path),*/) ) )
GET_INC_DIRS := $(call remove_same_str,$(FIND_ALL_FILES_DIR))
INC_DIRS :=
INC_DIRS += $(foreach v, $(GET_INC_DIRS), $(if $(filter %/,$v) , $(eval INC_DIRS+=$v), ))
INC_DIRS := $(subst ./, -I./, $(INC_DIRS))
INC_DIRS := $(wordlist 1, $(words $(INC_DIRS)), $(INC_DIRS))

# debug print info, no need to be change
# $(info "INC_DIRS")
# $(info $(INC_DIRS))
# $(info "HEADERS")
# $(info $(HEADERS))
# $(info "SOURCES")
# $(info $(SOURCES))

# compile job
all : 
ifeq ($(OS_TYPE), WINDOWS)
	mkdir $(BUILD_DIR) 2>nul || ver > nul
endif
ifeq ($(OS_TYPE), LINUX)
	mkdir -p $(BUILD_DIR) 
endif
ifeq ($(OS_TYPE), OSX)
	mkdir -p $(BUILD_DIR) 
endif
	$(CC) $(CFLAGS) $(SOURCES) $(HEADERS) $(INC_DIRS) -o $(BUILD_DIR)/$(PROJECT)

# virtual clean job
.PHONY : clean
clean:
ifeq ($(OS_TYPE), WINDOWS)
	rmdir /S /Q $(BUILD_DIR)
endif
ifeq ($(OS_TYPE), LINUX)
	rm -rf ./$(BUILD_DIR)
endif
ifeq ($(OS_TYPE), OSX)
	rm -rf ./$(BUILD_DIR)
endif
	
