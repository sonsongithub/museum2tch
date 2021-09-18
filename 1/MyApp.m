
#import "MyApp.h"
#import "ThreadController.h"
#import "MainTransitionView.h"

@implementation MyApp

- (void) applicationDidFinishLaunching: (id) unused {
	DNSLog( @"MyApp - applicationDidFinishLaunching" );
	
	// read preference
	[self readPreferenceData];
	
	// Get screen rect
	CGRect  screenRect;
	screenRect = [UIHardware fullScreenApplicationContentRect];
	screenRect.origin.x = screenRect.origin.y = 0.0f;

	// Create window
	window_ = [[UIWindow alloc] initWithContentRect:screenRect];
	transitionView_ = [[[MainTransitionView alloc] initWithFrame:screenRect] autorelease];
	mainView_ = [[[UIView alloc] initWithFrame:screenRect] autorelease];
	
	// Set content view
	[mainView_ addSubview:transitionView_];
	[window_ setContentView:mainView_];
		
	//
	menuCon_ = [[MenuController alloc] init];
	
	// arrange cache files
	[self deleteCache];
	[self readResource];
	
	// make preferencse path	
	NSString *preferencePath = [self preferencePath];
	[[NSFileManager defaultManager] createDirectoryAtPath:preferencePath attributes:nil];
	
	// alloc favourite stack buffer
	favouriteStack_ = [[NSMutableArray array] retain];
	
	// Show window
	[window_ orderFront:self];
	[window_ makeKey:self];
	[window_ _setHidden:NO];

	//
	[transitionView_ showCategoryViewWithTransition:TRANSITION_VIEW_FORWARD fromView:nil];
}

- (void) applicationWillTerminate {
	DNSLog( @"MyApp - applicationWillTerminate" );
	[transitionView_ saveFarourite];
	[self exportFavourites];
	[delegate_ doBookmark];
	releaseDictionariesForHTMLDecode();
	releaseDataCode();
}

- (void) dealloc {
	DNSLog( @"MyApp - dealloc" );
	[window_ release];
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
//
// access image resource
//
////////////////////////////////////////////////////////////////////////////////
- (void) readResource {
	cacheIconImage_ = [[UIImage imageAtPath:
		 [[NSBundle mainBundle] 
			 pathForResource:@"cacheIcon"
			 ofType:@"png" 
			 inDirectory:@"/"]] retain];
}

- (UIImage*) cacheIconUIImage {
	return cacheIconImage_;
}

////////////////////////////////////////////////////////////////////////////////
//
// path management
//
////////////////////////////////////////////////////////////////////////////////
- (NSString*) preferencePath {
	return [[[self userLibraryDirectory] stringByAppendingPathComponent:@"Preferences"] stringByAppendingPathComponent:PREFERENCE_PATH];
}

- (NSString*) makeCacheDirectroy:(NSString*) url {
	NSMutableArray *strs = [NSMutableArray array];
	NSString *delimiter = [NSString stringWithUTF8String:"/"];
	NSCharacterSet* chSet = [NSCharacterSet characterSetWithCharactersInString:delimiter];
	NSScanner* scanner = [NSScanner scannerWithString:url];
	NSString* scannedPart = nil;
	
	while(![scanner isAtEnd]) {
		if([scanner scanUpToCharactersFromSet:chSet intoString:&scannedPart]) {
			[strs addObject:scannedPart];
		}	
		[scanner scanCharactersFromSet:chSet intoString:nil];
	}
	if( [strs count] < 2 ) {
		DNSLog( @"Main - Error:Wrong format can't divide <> -> %@", url );
		return nil;
	}
	DNSLog( @"Main - %@", [strs objectAtIndex:[strs count]-1] );
	
	// make cache path
	NSString *cacheDirectoryPath = [NSString stringWithFormat:@"%@/%@/", [self preferencePath], [strs objectAtIndex:[strs count]-1]];
	
	if( [[NSFileManager defaultManager] isWritableFileAtPath:cacheDirectoryPath] ) {
		DNSLog( @"Main - already cache directory exist - %@", cacheDirectoryPath );
		return cacheDirectoryPath;
	}
	if( [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectoryPath attributes:nil] ) {
		DNSLog( @"Main - make cache directory - %@", cacheDirectoryPath );
		return cacheDirectoryPath;
	}
	return nil;
}

////////////////////////////////////////////////////////////////////////////////
//
// cache management
//
////////////////////////////////////////////////////////////////////////////////
- (NSString*) makeCacheDataPath:(NSString*) url {
	NSArray*lines = [url componentsSeparatedByString:@"/"];
	if( [lines count] > 3 ) {
		NSString *fileName = [lines objectAtIndex:[lines count]-1];
		NSString *directoryName = [lines objectAtIndex:[lines count]-3];
		NSString *cacheDataPath = [NSString stringWithFormat:@"%@/%@/%@", [self preferencePath], directoryName, fileName];
		return cacheDataPath;
	}
	return nil;
}

- (void) deleteCache {
	int i,j;
	NSArray *subdirectories = [[NSFileManager defaultManager] subpathsAtPath:[UIApp preferencePath]];
	NSMutableArray *cacheDirectoryies = [NSMutableArray array];
	// look for the cache directories
	for( i = 0; i < [subdirectories count]; i++ ) {
		BOOL isDirectory = NO;
		NSString *path = [NSString stringWithFormat:@"%@/%@", [UIApp preferencePath], [subdirectories objectAtIndex:i]];
		if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] ) {
			if( isDirectory ) {
				[cacheDirectoryies addObject:path];
			}
		}
	}
	// now
	NSDate *nowDate = [NSDate date];
	
	// diff, 3600 sec is an hour, 86400 sec is a day, 259200 sec is 3 days, 864000 sec is 10 days. 
	NSMutableArray* ary = [self readFavouriteForDeleting];
	
	int favourite_cache = 0;
	int cache = 0;
	int deleted = 0;
	
	double daysToMaintain = (double) 86400 * [self daysToMaintain];

	if( daysToMaintain > 0 )
		for( i = 0; i < [cacheDirectoryies count]; i++ ) {
			NSArray *filesAtCacheDirectory = [[NSFileManager defaultManager] subpathsAtPath:[cacheDirectoryies objectAtIndex:i]];
			for( j = 0; j < [filesAtCacheDirectory count]; j++ ) {
				NSString *path = [NSString stringWithFormat:@"%@/%@", [cacheDirectoryies objectAtIndex:i], [filesAtCacheDirectory objectAtIndex:j] ];
				NSDictionary *fileProperty = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:NO];
				NSDate *lastModifiedDate = [fileProperty objectForKey:NSFileModificationDate];			
				NSTimeInterval diff = [nowDate timeIntervalSinceDate:lastModifiedDate];
				if( [ary containsObject:path] ) {
					DNSLog( @"%@ is included in favourites", path );
					favourite_cache++;
					continue;
				}
				else if( diff > daysToMaintain ) {
					deleted++;
					[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
					DNSLog( @"Main - subdirectory - %@ is old, deleted", path );
				}
				else{
					cache++;
				}
			}
		}
}

////////////////////////////////////////////////////////////////////////////////
//
// access menu controller and main transition view
//
////////////////////////////////////////////////////////////////////////////////
- (MenuController*) menuController {
	return menuCon_;
}

- (MainTransitionView*) view {
	return transitionView_;
}

////////////////////////////////////////////////////////////////////////////////
//
// UI, alertsheet, progrress spinner
//
////////////////////////////////////////////////////////////////////////////////
- (void) showProgressHUD:(NSString*)label {
	progressSpinner_ = [[UIProgressHUD alloc] initWithWindow: window_];
	CGRect rect = CGRectMake(0.0f, 100.0f, 320.0f, 50.0f);
	[progressSpinner_ setText: label];
	[progressSpinner_ drawRect: rect];
	[progressSpinner_ show: YES];
	[mainView_ addSubview:progressSpinner_];
}

- (void) showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect {
	progressSpinner_ = [[UIProgressHUD alloc] initWithWindow: w];
	[progressSpinner_ setText: label];
	[progressSpinner_ drawRect: rect];
	[progressSpinner_ show: YES];
	[v addSubview:progressSpinner_];
}

- (void) hideProgressHUD {
	[progressSpinner_ show: NO];
	[progressSpinner_ removeFromSuperview];
}

- (void) showStandardAlertWithError:(NSString *)error {
	id alertButton = [NSArray arrayWithObjects:@"Close",nil];
	id alert = [[UIAlertSheet alloc] initWithTitle:VERSION_STRING_2CH_VIEWER buttons:alertButton defaultButtonIndex:0 delegate:self context:nil];
	[alert setBodyText: error];
	[alert popupAlertAnimated: TRUE];
}

- (void) showStandardAlertWithString:(NSString *)title closeBtnTitle:(NSString *)closeTitle withError:(NSString *)error {
	id alertButton = [NSArray arrayWithObjects:@"Close",nil];
	id alert = [[UIAlertSheet alloc] initWithTitle:title buttons:alertButton defaultButtonIndex:0 delegate:self context:nil];
	[alert setBodyText: error];
	[alert popupAlertAnimated: TRUE];
}

- (void) showStandardAlertWithCloseBtnTitle:(NSString *)closeTitle withError:(NSString *)error {
	id alertButton = [NSArray arrayWithObjects:@"Close",nil];
	id alert = [[UIAlertSheet alloc] initWithTitle:VERSION_STRING_2CH_VIEWER buttons:alertButton defaultButtonIndex:0 delegate:self context:nil];
	[alert setBodyText: error];
	[alert popupAlertAnimated: TRUE];
}

- (void) alertSheet: (UIAlertSheet*)sheet buttonClicked:(int)button {
	[sheet dismissAnimated: TRUE];
}

////////////////////////////////////////////////////////////////////////////////
//
// management favourites
//
////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*) readFavouriteSubjectTxt {
	NSString* path = [NSString stringWithFormat:@"%@/favouriteSubject.txt", [UIApp preferencePath]];
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	NSMutableArray* ary= [NSMutableArray array];
	
	if( data == nil || [data length] == 0 )		// check file
		return ary;
	
	NSString *decoded = decodeNSData(data);
	
	if( decoded == nil )						// check if success?
		return ary;
	
	NSArray*lines = [decoded componentsSeparatedByString:@"\n"];
	
	int i;
	for( i = 0; i < [lines count]; i++ ) {
		NSString *line = [lines objectAtIndex:i];
		NSArray*values = [line componentsSeparatedByString:@"<>"];
		
		if( [values count] < 2 )
			continue;
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
				[values objectAtIndex:0],		@"url",
				[values objectAtIndex:1],		@"title",
				nil];
		[ary addObject:dict];
	}
	return ary;
}

- (NSMutableArray*) mergeFavourite:(NSMutableArray*)new_array into:(NSMutableArray*)ary{
	int i,j;
	for( i = 0; i < [new_array count]; i++ ) {
		BOOL canAdd = YES;
		for( j = 0; j < [ary count]; j++ ) {
			NSString *url_new = [[new_array objectAtIndex:i] objectForKey:@"url"];
			NSString *url_ary = [[ary objectAtIndex:j] objectForKey:@"url"];
			if( [url_new isEqualToString:url_ary] ) {
				canAdd = NO;
				break;
			}
		}
		if( canAdd )
			[ary addObject:[new_array objectAtIndex:i]];
	}
	return nil;
}

- (NSString*) extractFolderAndDatName:(NSString*)url {
	NSArray*values = [url componentsSeparatedByString:@"/"];
	if( [values count] <= 3 )
		return nil;
	return [NSString stringWithFormat:@"%@/%@/%@", [UIApp preferencePath], [values objectAtIndex:[values count]-3], [values objectAtIndex:[values count]-1]];
}

- (NSMutableArray*) readFavouriteForDeleting {
	NSString* path = [NSString stringWithFormat:@"%@/favouriteSubject.txt", [UIApp preferencePath]];
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	NSMutableArray* favouriteURLs = [NSMutableArray array];
	
	if( data == nil || [data length] == 0 )		// check file
		return favouriteURLs;
	
	NSString *decoded = decodeNSData(data);
	
	if( decoded == nil )						// check if success?
		return favouriteURLs;
	
	NSArray*lines = [decoded componentsSeparatedByString:@"\n"];
	
	int i;
	for( i = 0; i < [lines count]; i++ ) {
		NSString *line = [lines objectAtIndex:i];
		NSArray*values = [line componentsSeparatedByString:@"<>"];
		
		if( [values count] < 2 )
			continue;
		NSString* folder_dat = [self extractFolderAndDatName:[values objectAtIndex:0]];
		if( folder_dat ) {
			// DNSLog( folder_dat );
			[favouriteURLs addObject:folder_dat];
			[favouriteURLs addObject:[NSString stringWithFormat:@"%@.data",folder_dat]];
		}
	}
	return favouriteURLs;
}

- (BOOL) exportFavourites {
	int i;
	
	NSMutableString* output = [NSMutableString string];
	NSMutableArray *new_favourite = [UIApp favouriteStack];
	NSMutableArray *favourite_from_file = [UIApp readFavouriteSubjectTxt];
	
	if( [favourite_from_file count] == 0 ) {
		DNSLog( @"Can't read file" );
	}
	
	[UIApp mergeFavourite:new_favourite into:favourite_from_file];
	
	for( i = 0; i < [favourite_from_file count]; i++ ) {
		NSString *title = [[favourite_from_file objectAtIndex:i] objectForKey:@"title"];
		NSString *url = [[favourite_from_file objectAtIndex:i] objectForKey:@"url"];
		[output appendFormat:@"%@<>%@\n", url, title ];
	}
	NSString* path = [NSString stringWithFormat:@"%@/favouriteSubject.txt", [UIApp preferencePath]];
	if( [output writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil] ) {
		DNSLog( @"Save favourite" );
	}
	return YES;
}

// 

- (void) setSubjectTxtURL:(NSString*)str {
	[subjectTxtURL_ release];
	subjectTxtURL_ = [[NSString stringWithString:str] retain];
}

- (NSString*) subjectTxtURL {
	return subjectTxtURL_;
}

- (void) setDatFileURL:(NSString*)str {
	[datFileURL_ release];
	datFileURL_ = [[NSString stringWithString:str] retain];
}

- (NSString*) datFileURL {
	return datFileURL_;
}

- (void) setThreadRewTitle:(NSString*)str {
	[threadRawTitle_ release];
	threadRawTitle_ = [[NSString stringWithString:str] retain];
}

- (NSString*) threadRawTitle {
	return threadRawTitle_;
}

- (void) setThreadTitle:(NSString*)str {
	[threadTitle_ release];
	threadTitle_ = [[NSString stringWithString:str] retain];
}

- (NSString*) threadTitle {
	return threadTitle_;
}

- (void) setCategoryTitle:(NSString*)str {
	[categoryTitle_ release];
	categoryTitle_ = [[NSString stringWithString:str] retain];
}

- (NSString*) categoryTitle {
	return categoryTitle_;
}

- (void) setBoardTitle:(NSString*)str {
	[boardTitle_ release];
	boardTitle_ = [[NSString stringWithString:str] retain];
}

- (NSString*) boardTitle {
	return boardTitle_;
}

// add a thread into the favourites stack
- (BOOL) addThreadIntoFavouriteStackURL:(NSString*)url andTitle:(NSString*)title {
	DNSLog( @"MyApp -  %@ - %@", url, title );
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
					url,		@"url",
					title,		@"title",
					nil
				];
	[favouriteStack_ addObject:dict];
}

- (NSMutableArray*) favouriteStack {
	return favouriteStack_;
}

////////////////////////////////////////////////////////////////////////////////
//
// management preference
//
////////////////////////////////////////////////////////////////////////////////
- (void) readPreferenceData {
	NSDictionary *dict = [UIApp readPlist];
	NSArray *font = [NSArray arrayWithObjects:
							NSLocalizedString( @"font0", nil ),
							NSLocalizedString( @"font1", nil ),
							NSLocalizedString( @"font2", nil ),
							NSLocalizedString( @"font3", nil ),
							NSLocalizedString( @"font4", nil ),
							nil ];
	NSArray *day = [NSArray arrayWithObjects:
							NSLocalizedString( @"delete0", nil ),
							NSLocalizedString( @"delete1", nil ),
							NSLocalizedString( @"delete2", nil ),
							NSLocalizedString( @"delete3", nil ),
							NSLocalizedString( @"delete4", nil ),
							NSLocalizedString( @"delete5", nil ),
							nil ];
	NSArray	*bin = [NSArray arrayWithObjects:
							NSLocalizedString( @"string_true", nil ),
							NSLocalizedString( @"string_false", nil ),
							nil];
	id theadIndex = [dict objectForKey:@"threadIndexSize"];
	id thread = [dict objectForKey:@"threadSize"];
	id days = [dict objectForKey:@"daysToMaintain"];
	id offline_flag = [dict objectForKey:@"offlineMode"];
	
	threadIndexSize_ = 10.0f + 2.0f * [font indexOfObject:theadIndex];
	threadSize_ = 10.0f + 2.0f * [font indexOfObject:thread];
	daysToMaintain_ = 5 * ( [day indexOfObject:days] );
	offlineMode_ = [bin indexOfObject:offline_flag];

	DNSLog( @"%lf, %lf, %d, %d", threadIndexSize_, threadSize_, daysToMaintain_, offlineMode_ );
}

- (NSDictionary*) readPlist {
	NSDictionary *dict = nil;
	NSData *data = [NSData dataWithContentsOfFile:@"/private/var/root/Library/Preferences/com.sonson.2tch/preference.plist"];
	NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if( [dataStr length] ) {
		DNSLog( @"MyApp - try to read plist" );
		dict = [dataStr propertyList];
		return dict;
	}
	if( !dict ) {
		DNSLog( @"MyApp - try to make default plist" );
		dict = [UIApp makeDefaultDictionaryOfPreference];
		NSString *str = [dict description];
		[str writeToFile:@"/private/var/root/Library/Preferences/com.sonson.2tch/preference.plist" atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}
	return dict;
}

- (NSDictionary*) makeDefaultDictionaryOfPreference {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Medium",		@"threadIndexSize",
			@"Medium",		@"threadSize",
			@"15",			@"daysToMaintain",
			@"false",		@"offlineMode",
			nil];
	return dict;
}

- (void) setDelegate:(id)fp {
	delegate_ = fp;
}

- (id) delegate {
	return delegate_;
}

- (float) threadIndexSize {
	return threadIndexSize_;
}

- (float) threadSize {
	return threadSize_;
}

- (int) daysToMaintain {
	return daysToMaintain_;
}

- (BOOL) isOfflineMode {
	return offlineMode_;
}

@end
