
#import "MenuController.h"
#import "global.h"

@implementation MenuController

// override

- (void) dealloc {
	DNSLog( @"MenuController - dealloc" );
	[boardData_ release];
	[categoryData_ release];
	[super dealloc];
}

- (id) init {
	DNSLog( @"MenuController - init" );
	BOOL result = NO;
	self = [super init];
	
	// alloc array
	boardData_ = [[NSMutableArray array] retain];
	categoryData_ = [[NSMutableArray array] retain];
	
	// get data
	NSData* data = [self getDataOfBBSMenuHTML];
	
	// get decoded string
	NSString *decodedString = decodeNSData(data);
	
	// check can be decoded
	if( decodedString != nil )
		result = [self extractBbsMenuHtml:decodedString];

	// check is extracted titles successfully
	if( !result ) {
		// make alert sheet
		[UIApp terminate];
	}
	
	// try to save
	NSString *saveFilePath = [NSString stringWithFormat:@"%@/bbsmenu.html", [UIApp preferencePath]];
	[data writeToFile:saveFilePath atomically:NO];
	
	return self;
}


- (BOOL) updateBBSMenuHTML {
	[[UIApp view] showLoadingAfterReloadAndSendReloadMethodToDelegate:self];
}

- (BOOL) reload {
	BOOL result = NO;
	NSURLResponse *response = nil;
	NSError *error = nil;	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BOARD_URL_MENU] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	NSData *data = nil;
	if( [UIApp isOfflineMode] )
		data = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error]; 
	else
		data = [NSData data];
	
	// get decoded string
	NSString *decodedString = decodeNSData(data);//[decoder decodeNSData:data];

	// check can be decoded
	if( decodedString != nil )
		result = [self extractBbsMenuHtml:decodedString];

	// check is extracted titles successfully
	if( !result ) {
		[UIApp hideProgressHUD];
		return NO;
	}
	
	// try to save
	NSString *saveFilePath = [NSString stringWithFormat:@"%@/bbsmenu.html", [UIApp preferencePath]];
	[data writeToFile:saveFilePath atomically:NO];
	[UIApp hideProgressHUD];
}

// original method

- (NSData*) getDataOfBBSMenuHTML {
	// read from local
	NSString *saveFilePath = [NSString stringWithFormat:@"%@/bbsmenu.html", [UIApp preferencePath]];
	NSData *dataFromLocal = nil;
	if( [[NSFileManager defaultManager] fileExistsAtPath:saveFilePath] ) {
		dataFromLocal = [[NSFileManager defaultManager] contentsAtPath:saveFilePath];
	}
	if( dataFromLocal != nil && [dataFromLocal length] > 0 )
		return dataFromLocal;
	
	NSURLResponse *response = nil;
	NSError *error = nil;	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BOARD_URL_MENU] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	NSData *dataFromRemote = nil;
	if( [UIApp isOfflineMode] )
		dataFromRemote = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error]; 
	else
		dataFromRemote = [NSData data];
	return dataFromRemote;
}

- (BOOL) extractBbsMenuHtml:(NSString*) htmlString {
	NSError *err = nil;
	NSString *category_name = nil;
	NSXMLDocument *xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc]
			initWithXMLString:htmlString 
			options:NSXMLDocumentTidyHTML
			error:&err] autorelease];
	NSXMLNode *rootNode = [xmlDoc rootElement];
	
	BOOL isCorrectTitle = NO;
	
	[boardData_ removeAllObjects];
	[categoryData_ removeAllObjects];
	
	if ( [[rootNode name] isEqualToString: @"html"] ) {
		NSXMLNode *nodesInHTML = (NSXMLNode*)[[rootNode children] objectEnumerator];
		NSXMLNode *nodeInHTML = nil;
		while( ( nodeInHTML = [(NSEnumerator*)nodesInHTML nextObject] ) != nil ) {
			if( [[nodeInHTML name] isEqualToString:@"head"] ) {
				NSXMLNode *nodesInBody = (NSXMLNode*)[[nodeInHTML children] objectEnumerator];
				NSXMLNode *nodeInBody = nil;
				while( ( nodeInBody = [(NSEnumerator*)nodesInBody nextObject] ) != nil ) {
					if( [[nodeInBody name] isEqualToString:@"title"] )
						if( [[nodeInBody stringValue] isEqualToString:NSLocalizedString( @"bbsmenuHTMLTIitle", nil )] )
							isCorrectTitle = YES;
				}
			}
			else if( [[nodeInHTML name] isEqualToString:@"body"] ) {
				NSXMLNode *nodesInBody = (NSXMLNode*)[[nodeInHTML children] objectEnumerator];
				NSXMLNode *nodeInBody = nil;
				// NSMutableArray *ary = nil;
				while( ( nodeInBody = [(NSEnumerator*)nodesInBody nextObject] ) != nil ) {
					if( [[nodeInBody name] isEqualToString:@"b"] ) {
						category_name = [NSString stringWithCString:[[nodeInBody stringValue] UTF8String] encoding:OUTPUT_ENCODE_TYPE];
						
						if( [category_name isEqualToString: @""] || !category_name)
							continue;
						[categoryData_ addObject:category_name];
					}
					else if( [[nodeInBody name] isEqualToString:@"a"] && category_name) {

						NSString *title = [NSString stringWithCString:[[nodeInBody stringValue] UTF8String] encoding:OUTPUT_ENCODE_TYPE];
						NSString *href = [NSString stringWithCString:[[[(NSXMLElement*)nodeInBody attributeForName:@"href"] stringValue] UTF8String] encoding:OUTPUT_ENCODE_TYPE];
			
						if( [href isEqualToString: BOARD_URL_TERMINATER])
							continue;
							
						NSMutableArray *board_data = [NSMutableArray array];
						[board_data addObject:title];
						[board_data addObject:href];
						[board_data addObject:category_name];
						[boardData_ addObject:board_data];
					}
				}
			}
		}
	}
	return isCorrectTitle;
}

- (void) setCurrentCategoryId:(int)categoryId {
	currentCategory_ = categoryId;
}

- (void) setCurrentBoardId:(int) input {
	currentBoard_ = input;
}

- (id) getCategories {
	int i;
	NSMutableArray *ary = [NSMutableArray array];
	for( i = 0; i < [categoryData_ count]; i++ )
		[ary addObject:[categoryData_ objectAtIndex:i]];
	return ary;
}

- (id) currentBoardName {
	id ary = [[UIApp menuController] getTitlesInCurrentCategory];
	return [ary objectAtIndex:currentBoard_];
}

- (id) getCurrentCategoryName {
	return [categoryData_ objectAtIndex:currentCategory_];
}

- (id) getTitlesInCurrentCategory {
	int i;
	NSMutableArray *ary = [NSMutableArray array];
	NSString* category_name;
	
	if( [categoryData_ count] > currentCategory_ && currentCategory_ >= 0 )
		category_name = [categoryData_ objectAtIndex:currentCategory_];
	else
		return nil;
		
	for( i = 0; i < [boardData_ count]; i++ ) {
		id aData = [boardData_ objectAtIndex:i];
		if( [[aData objectAtIndex:CATEGORY_ARRAY_APPEND] isEqualToString:category_name] ) {
			NSString *converted = [NSString stringWithCString:[[aData objectAtIndex:TITLE_ARRAY_APPEND] UTF8String] encoding:OUTPUT_INTO_GUI];
			[ary addObject:converted];
		}
	}
	return ary;
}

- (id) getURLsInCurrentCategory {
	int i;
	NSMutableArray *ary = [NSMutableArray array];
	NSString* category_name = [categoryData_ objectAtIndex:currentCategory_];
	for( i = 0; i < [boardData_ count]; i++ ) {
		id aData = [boardData_ objectAtIndex:i];
		if( [[aData objectAtIndex:CATEGORY_ARRAY_APPEND] isEqualToString:category_name] ) {
			NSString *converted = [NSString stringWithCString:[[aData objectAtIndex:HREF_ARRAY_APPEND] UTF8String] encoding:OUTPUT_INTO_GUI];
			[ary addObject:converted];
		}
	}
	return ary;
}

@end

/*
- (id) init2 {
	self = [super init];
	NSString *htmlString = [self readBbsmenuHtml];
	if( htmlString == nil ) {
		DNSLog( @"MenuController - Error cant read bbsmenu file" );
		[self deleteCache];
		exit(1);
	}
	[self extractBbsMenuHtml:htmlString];
	return self;
}
*/
/*
- (void) reload {
	DNSLog( @"MenuController - Try to read remote table file, and wrtie local file." );
	[boardData_ removeAllObjects];
	[categoryData_ removeAllObjects];
	NSString *htmlString = [self readBbsmenuHtml];
	if( htmlString == nil ) {
		DNSLog( @"MenuController - Error cant read bbsmenu file" );
		exit(1);
	}
	[self extractBbsMenuHtml:htmlString];
}
*/
/*
- (BOOL) deleteCache {
	NSString *saveFilePath = [NSString stringWithFormat:@"%@/bbsmenu.html", [UIApp preferencePath]];
	if( [[NSFileManager defaultManager] isDeletableFileAtPath:saveFilePath] ) {
		// delete cache file
		[[NSFileManager defaultManager] removeFileAtPath:saveFilePath handler:nil];
		DNSLog( @"MenuController - Delete bbsmenu.html cache" );
		return YES;
	}
	return NO;
}
*/
/*
- (NSString*) readBbsmenuHtml {
	NSString *saveFilePath = [NSString stringWithFormat:@"%@/bbsmenu.html", [UIApp preferencePath]];
	NSData *dataFromLocal = nil;
	if( [[NSFileManager defaultManager] fileExistsAtPath:saveFilePath] ) {
		dataFromLocal = [[NSFileManager defaultManager] contentsAtPath:saveFilePath];
	}
	if( dataFromLocal != nil && [dataFromLocal length] > 0 ) {
		DNSLog( @"MenuController - Read bbsmenu.html from cache" );
		id decoder = [[[DataDecoder alloc] init] autorelease];
		return [NSString stringWithString:[decoder decodeNSData:dataFromLocal]];
	}
	
	NSURLResponse *response = nil;
	NSError *error = nil;	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BOARD_URL_MENU] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	NSData *dataFromRemote = nil;
	if( [UIApp isOfflineMode] )
		dataFromRemote = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error]; 
	else
		dataFromRemote = [NSData data];
	
	id decoder = [[[DataDecoder alloc] init] autorelease];
	NSString *decodedString = [NSString stringWithString:[decoder decodeNSData:dataFromRemote]];
	if( decodedString ) {
		if( ![dataFromRemote writeToFile:saveFilePath atomically:NO] ) {
			DNSLog( @"MenuController - Error cant write bbsmenu file" );
		}
		DNSLog( @"MenuController - Read bbsmenu.html from remote" );
		return decodedString;
	}
	
	return nil;
}
*/