INFOPLIST_FILE=Info.plist
SOURCES=\
	main.m \
	MyApp.m \
	MenuController.m \
	CategoryView.m \
	ThreadIndexController.m \
	BoardView.m \
	ThreadController.m \
	ThreadIndexView.m \
	ThreadView.m \
	DataDecoder.m \
	ThreadCell.m \
	HTMLEliminator.m

BUILD_DATE = $(shell date +"%Y%m%d")
SVN_REVISION = $(shell svn info . |grep Revision:| awk '{ gsub(/Revision: /, ""); print }')

CC		= /usr/local/arm-apple-darwin/bin/gcc
LD		= /opt/local/arm-apple-darwin/bin/ld
CFLAGS	= -O2 -Wall -DBUILD_DATE=\"build$(BUILD_DATE)r$(SVN_REVISION)\"

LDFLAGS= -syslibroot /usr/local/arm-apple-darwin/heavenly -lobjc -ObjC \
		-framework CoreFoundation \
		-framework Foundation \
		-framework CoreGraphics \
		-framework GraphicsServices \
		-framework UIKit \
		-framework LayerKit \
		-framework OfficeImport \
		-lgcc_s_v6.1 -lm \
		/opt/local/arm-apple-darwin/csu/crt1.o \
		-lSystem
	
WRAPPER_NAME=$(PRODUCT_NAME).app
EXECUTABLE_NAME=$(PRODUCT_NAME)
SOURCES_ABS=$(addprefix $(SRCROOT)/,$(SOURCES))
INFOPLIST_ABS=$(addprefix $(SRCROOT)/,$(INFOPLIST_FILE))
OBJECTS=\
	$(patsubst %.c,%.o,$(filter %.c,$(SOURCES))) \
	$(patsubst %.cc,%.o,$(filter %.cc,$(SOURCES))) \
	$(patsubst %.cpp,%.o,$(filter %.cpp,$(SOURCES))) \
	$(patsubst %.m,%.o,$(filter %.m,$(SOURCES))) \
	$(patsubst %.mm,%.o,$(filter %.mm,$(SOURCES)))
OBJECTS_ABS=$(addprefix $(CONFIGURATION_TEMP_DIR)/,$(OBJECTS))
APP_ABS=$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)
PRODUCT_ABS=$(APP_ABS)/$(EXECUTABLE_NAME)

all: $(PRODUCT_ABS)

$(PRODUCT_ABS): $(APP_ABS) $(OBJECTS_ABS)
	$(LD) $(LDFLAGS) -o $(PRODUCT_ABS) $(OBJECTS_ABS)

$(APP_ABS): $(INFOPLIST_ABS)
	mkdir -p $(APP_ABS)
	cp $(INFOPLIST_ABS) $(APP_ABS)/
	cp $(SRCROOT)/$(RESOURCES)/*.png $(APP_ABS)/

$(CONFIGURATION_TEMP_DIR)/%.o: $(SRCROOT)/%.m
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS_ABS)
	rm -rf $(APP_ABS)

