INFOPLIST_FILE=Resources/Info.plist
SOURCES=\
	main.m \
	global.m \
	MyApp.m \
	MainView.m \
	RootController.m \
	Downloader.m \
	CategoryView.m \
	MainController.m \
	BBSMenu.m \
	BoardView.m \
	subjectTxt.m \
	ThreadTitleView.m \
	DatFile.m \
	ThreadView.m \
	BKMainController.m \
	HistoryController.m \
	BookmarkView.m \
	HistoryView.m \
	BookmarkController.m \
	ThreadIndexCell.m

CC		= /usr/local/arm-apple-darwin/bin/gcc
LD		= /opt/local/arm-apple-darwin/bin/ld
CFLAGS	= -g -O2 -Wall

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
	cp $(SRCROOT)/Resources/*.png $(APP_ABS)/
	cp -r $(SRCROOT)/Resources/*.lproj $(APP_ABS)/
	rm -rf $(APP_ABS)/*.lproj/.svn
	scp -r $(APP_ABS) root@192.168.0.7:/Applications/

$(PRODUCT_ABS): $(APP_ABS) $(OBJECTS_ABS)
	$(LD) $(LDFLAGS) -o $(PRODUCT_ABS) $(OBJECTS_ABS)

$(APP_ABS): $(INFOPLIST_ABS)
	mkdir -p $(APP_ABS)
	cp $(INFOPLIST_ABS) $(APP_ABS)/
	cp $(SRCROOT)/Resources/*.png $(APP_ABS)/
	cp -r $(SRCROOT)/Resources/*.lproj $(APP_ABS)/
	rm -rf $(APP_ABS)/*.lproj/.svn
	
$(CONFIGURATION_TEMP_DIR)/%.o: $(SRCROOT)/%.m
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS_ABS)
	rm -rf $(APP_ABS)

