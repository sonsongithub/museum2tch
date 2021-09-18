
#import "CategoryView.h"
#import "BBSMenu.h"
#import "Downloader.h"
//#import "BoardCell.h"
#import "global.h"

@implementation BBSMenu

- (void) dealloc {
//	[categoryDataArray_ release];
//	[boardData_ release];
	
	[super dealloc];
}

- (id) initWithParentController:(id)fp {
	self = [super init];
	parentController_ = fp;
	
//	categoryDataArray_ = [[NSMutableArray array] retain];
//	boardData_ = [[NSMutableDictionary dictionary] retain];
	
	categories_ = [[NSMutableArray array] retain];
	boards_ = [[NSMutableArray array] retain];
	
	return self;
}

- (id) boardDataOfName:(NSString*)name {
	int i;
	for( i = 0; i < [boards_ count]; i++ ) {
		id dict = [boards_ objectAtIndex:i];
		if( [[dict objectForKey:@"title"] isEqualToString:name] ) {
			return dict;
		}
	}
	return nil;
}

- (id) category {
	return categories_;
}

- (id) board {
	return boards_;
}
/*
- (id) boardOfCategory:(NSString*)categoryName {
	return [boardData_ objectForKey:categoryName];
}
*/

- (BOOL) loadBBSMenu {
	if( [self loadCache] )
		return YES;
	return [self downloadBBSMenu];
}

- (BOOL) loadCache {
	NSString *categoryCachePath = [NSString stringWithFormat:@"%@/categoryCache.plist", [UIApp applicationDirectory]];
	NSString *boardCachePath = [NSString stringWithFormat:@"%@/boardCache.plist", [UIApp applicationDirectory]];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:categoryCachePath] && [[NSFileManager defaultManager] fileExistsAtPath:boardCachePath] ) {
		NSData *categoryData = [NSData dataWithContentsOfFile:categoryCachePath];
		NSData *boardData = [NSData dataWithContentsOfFile:boardCachePath];
		NSString *categoryStr = [[[NSString alloc] initWithData:categoryData encoding:NSUTF8StringEncoding] autorelease];
		NSString *boardStr = [[[NSString alloc] initWithData:boardData encoding:NSUTF8StringEncoding] autorelease];
		
		categories_ = [[categoryStr propertyList] objectForKey:@"NSArray"];
		[categories_ retain];
		boards_ = [[boardStr propertyList] objectForKey:@"NSArray"];
		[boards_ retain];
		return YES;
	}
	return NO;
}

- (BOOL) downloadBBSMenu {
	NSString *saveFilePath = [NSString stringWithFormat:@"%@/bbsmenu.html",  [UIApp applicationDirectory]];
	NSData *dataFromLocal = nil;
	categories_ = [[NSMutableArray array] retain];
	boards_ = [[NSMutableArray array] retain];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:saveFilePath] ) {
		DNSLog( @"BBSMenu - read bbsmenu.html from local" );
		dataFromLocal = [[NSFileManager defaultManager] contentsAtPath:saveFilePath];
	}
	if( dataFromLocal != nil && [dataFromLocal length] > 0 ) {
		return [self extractBoard:dataFromLocal];
	}
	NSURLResponse *response = nil;
	NSError *error = nil;	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://menu.2ch.net/bbsmenu.html"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	NSData *dataFromRemote = nil;

	dataFromRemote = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	
	return [self extractBoard:dataFromRemote];
}

- (BOOL) extractBoard:(NSData*)data {
	NSString* str = decodeNSData(data);
	
	if( str == nil )
		return NO;
	
	DNSLog( @"BBSMenu - read bbsmenu.html from remote" );
	
	if( [self extractBbsMenuHtml:str] ) {
		NSString *saveFilePath = [NSString stringWithFormat:@"%@/bbsmenu.html",  [UIApp applicationDirectory]];
		[data writeToFile:saveFilePath atomically:NO];
		
	//	DNSLog( [categories_ description] );
	//	DNSLog( [boards_ description] );
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:categories_, @"NSArray", nil];
		NSString *str = [dict description];
		NSString *path = [NSString stringWithFormat:@"%@/categoryCache.plist", [UIApp applicationDirectory]];
		[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
		
		dict = [NSDictionary dictionaryWithObjectsAndKeys:boards_ , @"NSArray", nil];
		str = [dict description];
		path = [NSString stringWithFormat:@"%@/boardCache.plist", [UIApp applicationDirectory]];
		[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
		return YES;
	}
	return NO;
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
	
//	[categoryDataArray_ removeAllObjects];
//	[boardData_ removeAllObjects];
	
	if ( [[rootNode name] isEqualToString: @"html"] ) {
		NSXMLNode *nodesInHTML = (NSXMLNode*)[[rootNode children] objectEnumerator];
		NSXMLNode *nodeInHTML = nil;
		while( ( nodeInHTML = [(NSEnumerator*)nodesInHTML nextObject] ) != nil ) {
			if( [[nodeInHTML name] isEqualToString:@"head"] ) {
				NSXMLNode *nodesInBody = (NSXMLNode*)[[nodeInHTML children] objectEnumerator];
				NSXMLNode *nodeInBody = nil;
				while( ( nodeInBody = [(NSEnumerator*)nodesInBody nextObject] ) != nil ) {
					if( [[nodeInBody name] isEqualToString:@"title"] ) {
						DNSLog( [nodeInBody stringValue] );
						if( [[nodeInBody stringValue] isEqualToString:NSLocalizedString( @"bbsmenuHTMLTitle", nil )] ) {
							
							isCorrectTitle = YES;
						}
					}
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
						
						[categories_ addObject:category_name];
						/*
						id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
						[cell setTitle:category_name];
						[cell setDisclosureStyle:2];
						[cell setShowDisclosure:YES];
						//[categoryDataArray_ addObject:cell];
						*/
						//[boardData_ setObject:[NSMutableArray array] forKey:category_name];
					}
					else if( [[nodeInBody name] isEqualToString:@"a"] && category_name) {

						NSString *title = [NSString stringWithCString:[[nodeInBody stringValue] UTF8String] encoding:OUTPUT_ENCODE_TYPE];
						NSString *href = [NSString stringWithCString:[[[(NSXMLElement*)nodeInBody attributeForName:@"href"] stringValue] UTF8String] encoding:OUTPUT_ENCODE_TYPE];
			
						if( [href isEqualToString: BOARD_URL_TERMINATER])
							continue;
						
					//	id ary = [boardData_ objectForKey:category_name];
/*
						id cell = [[[BoardCell alloc] init] autorelease];
						[cell setTitle:title];
						[cell setDisclosureStyle:2];
						[cell setShowDisclosure:YES];
						[cell setHref:href];
*/
						/*
						NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
										title,			@"title",
										href,			@"href",
										category_name,	@"category",
										nil
										];
						*/
						NSDictionary* dict = [self makeBoardDictionaryWithTitle:title
								HREF:href
								Category:category_name
								];
						if( dict )
							[boards_ addObject:dict];
						/*
						if( dict )
							[boards_ setObject:dict forKey:[dict objectForKey:@"boardID"]];
						*/
					//	[ary addObject:cell];
					}
				}
			}
		}
	}
	return isCorrectTitle;
}

- (NSDictionary*) makeBoardDictionaryWithTitle:(NSString*)title HREF:(NSString*)href Category:(NSString*)category {
	NSMutableArray *strs = [NSMutableArray array];
	NSString *delimiter = [NSString stringWithUTF8String:"/"];
	NSCharacterSet* chSet = [NSCharacterSet characterSetWithCharactersInString:delimiter];
	NSScanner* scanner = [NSScanner scannerWithString:href];
	NSString* scannedPart = nil;
	
	while(![scanner isAtEnd]) {
		if([scanner scanUpToCharactersFromSet:chSet intoString:&scannedPart]) {
			[strs addObject:scannedPart];
		}	
		[scanner scanCharactersFromSet:chSet intoString:nil];
	}
/*	
	int i;
	for( i = 0; i < [strs count]; i++ ) {
		NSLog( [strs objectAtIndex:i] );
	}
	*/
	NSString *idStr = nil; 
	NSString *serverAddress = nil;
	
	if( [strs count] > 2 ) {
		idStr = [strs objectAtIndex:[strs count]-1];
		serverAddress = [strs objectAtIndex:[strs count]-2];
	}
	else
		return nil;
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
					idStr,			@"boardID",
					title,			@"title",
					href,			@"href",
					serverAddress,	@"server",
					category,		@"category",
					nil
				];
	return dict;
}

@end
