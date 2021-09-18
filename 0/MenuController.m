
#import "MenuController.h"

@implementation MenuController

// override

- (void) dealloc {
	[boardData_ release];
	[categoryData_ release];
	[super dealloc];
}

// original method

- (id) initWithUserLibraryPath:(NSString*)path {
	self = [super init];
	
	[menufilePath_ release];
	currentCategory_ = 0;
	menufilePath_ = [[NSString stringWithFormat:@"%@/menu.xml", path] retain];
	DNSLog( @"MenuController - Try to read local table file." );
	if( ![self readXML] ) {
	DNSLog( @"MenuController - Try to read remote table file, and wrtie local file." );
		[self writeXML];
	}
	return self;
}

- (void) setCurrentCategoryId:(int)categoryId {
	currentCategory_ = categoryId;
}

- (void) setCurrentBoardId:(int) input {
	currentBoard_ = input;
}

- (NSMutableArray*) pullBoardTitles:(NSString*)url {
	NSURLResponse *response = nil;
	NSError *error = nil;	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	NSData *rssData = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];   
	NSString *decoded_strings = [[[NSString alloc] initWithData:rssData encoding:READ_FROM_MENU_HTML] autorelease];
	return [self processXML: decoded_strings];
}

- (NSMutableArray*) processXML:(NSString*)data {
	NSError *err = nil;
	NSString *category_name = nil;
	NSXMLDocument *xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc]
			initWithXMLString:data 
			options:NSXMLDocumentTidyHTML
			error:&err] autorelease];
	NSXMLNode *rootNode = [xmlDoc rootElement];
	
	boardData_ = [[NSMutableArray array] retain];
	categoryData_ = [[NSMutableArray array] retain];
	
	if ( [[rootNode name] isEqualToString: @"html"] ) {
		NSXMLNode *nodesInHTML = (NSXMLNode*)[[rootNode children] objectEnumerator];
		NSXMLNode *nodeInHTML = nil;
		while( ( nodeInHTML = [(NSEnumerator*)nodesInHTML nextObject] ) != nil ) {
			if( [[nodeInHTML name] isEqualToString:@"body"] ) {
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
	DNSLog( @"MenuController - Extracted bbsmenu.html." );
}

- (BOOL) readXML {
	boardData_ = [[NSMutableArray array] retain];
	categoryData_ = [[NSMutableArray array] retain];
	NSData *dataToRead = [NSData dataWithContentsOfFile:menufilePath_];
	
	if( !dataToRead )
		return NO;
		
	NSString *decoded_strings = [[[NSString alloc] initWithData:dataToRead encoding:NSUTF8StringEncoding] autorelease];
	id xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc] initWithXMLString:decoded_strings options:NSXMLDocumentTidyXML error:nil] autorelease];	
	NSXMLElement*rootNode = [xmlDoc rootElement];
	
	if ( [[rootNode name] isEqualToString: @"XML"] ) {
		NSEnumerator *categoryNodeEnum = [[rootNode children] objectEnumerator];
		NSXMLElement*categoryNode;
		while ( ( categoryNode = [categoryNodeEnum nextObject] ) != nil ) {
			if( [[categoryNode name] isEqualToString: @"Category"]){

				NSString *name = [NSString stringWithCString:[[[categoryNode attributeForName:@"name"] stringValue] UTF8String] encoding:READ_FROM_XML];
				[categoryData_ addObject:name];
				
				NSEnumerator *boardNodeEnum = [[categoryNode children] objectEnumerator];
				NSXMLElement*boardNode;
				while ( ( boardNode = [boardNodeEnum nextObject] ) != nil ) {
					if( [[boardNode name] isEqualToString: @"board"]) {

						NSString *href = [NSString stringWithCString:[[boardNode stringValue] UTF8String] encoding:READ_FROM_XML];
						NSString *title = [NSString stringWithCString:[[[boardNode attributeForName:@"name"] stringValue] UTF8String] encoding:READ_FROM_XML];
						NSString *category = [NSString stringWithCString:[[[boardNode attributeForName:@"category"] stringValue] UTF8String] encoding:READ_FROM_XML];

						NSMutableArray *board_data = [NSMutableArray array];
						[board_data addObject:title];
						[board_data addObject:href];
						[board_data addObject:category];
						[boardData_ addObject:board_data]; 
					}
				}
			}
		}
	}
	DNSLog( @"MenuController - Read bbsmenu.html." );
	return YES;
}

- (BOOL) writeXML {
	int i,j = 0;

	[self pullBoardTitles:BOARD_URL_MENU];
	NSXMLElement*rootElement = (NSXMLElement *)[NSXMLNode elementWithName:@"XML"];	
		
	for( i = 0; i < [categoryData_ count]; i++ ) {
		NSString *category_name = [categoryData_ objectAtIndex:i];
		NSXMLElement *category = [NSXMLElement elementWithName:@"Category"];
		NSXMLNode *attribute_category = [NSXMLNode attributeWithName:@"name" stringValue:category_name];
		[category addAttribute:attribute_category];
		for( ; j < [boardData_ count]; j++ ) {
			id aData = [boardData_ objectAtIndex:j];
			if( ![category_name isEqualToString:[aData objectAtIndex:CATEGORY_ARRAY_APPEND]] )
				break;
			NSString *board_name = [aData objectAtIndex:TITLE_ARRAY_APPEND];
			NSString *board_url = [aData objectAtIndex:HREF_ARRAY_APPEND];
			NSString *board_category = [aData objectAtIndex:CATEGORY_ARRAY_APPEND];
			
			NSXMLElement *href_node = [NSXMLElement elementWithName:@"board" stringValue:board_url];
			NSXMLNode *href_name_attr = [NSXMLNode attributeWithName:@"name" stringValue:board_name];
			NSXMLNode *href_category_attr = [NSXMLNode attributeWithName:@"category" stringValue:board_category];
			[href_node addAttribute:href_name_attr];
			[href_node addAttribute:href_category_attr];
			[category addChild:href_node];
		}
		[rootElement addChild:category];
	}
	id xmlDoc = [[[NSXMLDocument alloc] initWithRootElement:rootElement] autorelease];
	NSData *dataToRead = [xmlDoc XMLData];
	[dataToRead writeToFile:menufilePath_ atomically:YES];
	return YES;
}

- (void) reload {
	DNSLog( @"MenuController - Try to read remote table file, and wrtie local file." );
	[boardData_ release];
	[categoryData_ release];
	[self writeXML];
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