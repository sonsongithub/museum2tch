
#import "subjectTxt.h"
#import "Downloader.h"
#import "global.h"

@implementation subjectTxt

- (id) init {
	self = [super init];
	
	id center = [NSNotificationCenter defaultCenter];
	[center addObserver:self 
			selector:@selector(didSelectBoard:)
			name:@"didSelectBoard"
			object:nil];
			
	subjectTxtData_ = [[NSMutableArray array] retain];
	backUpData_;
	
	isRefined_ = NO;
	
	downloader_ = [[Downloader alloc] initWithDelegate:self];
	
	return self;
}

- (void) dealloc {
	[subjectTxtPath_ release];
	[downloader_ release];
	[super dealloc];
}

- (void) refine:(NSString*) keyword {
	[self cancelRefine];
	backUpData_ = subjectTxtData_;
	subjectTxtData_ = [[NSMutableArray array] retain];
	int i;
	for( i = 0; i < [backUpData_ count]; i++ ) {
		id dict = [backUpData_ objectAtIndex:i];
		NSRange r = [[dict objectForKey:@"threadTitle"] rangeOfString:keyword];
	
		if( r.location != NSNotFound ) {
			[subjectTxtData_ addObject:dict];
		}
		
		
	}
	isRefined_ = YES;
}

- (void) cancelRefine {
	if( isRefined_ ) {
		[subjectTxtData_ release];
		subjectTxtData_ = backUpData_;
		isRefined_ = NO;
	}
}

- (void) extractSubjectTxt {
	// search endline
	[self cancelRefine];
	[subjectTxtData_ removeAllObjects];
	NSData* data = [NSData dataWithContentsOfFile:subjectTxtPath_];
	
	DNSLog( decodeNSData( data ) );
	
	int hist[256];
	memset( hist, 0, sizeof( char)*256 );
	int length = [data length];
	char*p = (char*)[data bytes];
	int i;
	for( i = 0; i < length; i++ )
		hist[(int)*p++]++;
	
	titleNum_ = hist[0x0A];
	currentTitleTail_ = 0;
}

- (BOOL) hasReadCompletely {
	DNSLog( @"subjectTxt = %d/%d", currentTitleTail_, titleNum_ );
	if( currentTitleTail_ == titleNum_ - 1 )
		return YES;
	else
		return NO;
}

- (void) extendTitleTail {
	NSData* data = [NSData dataWithContentsOfFile:subjectTxtPath_];
	int length = [data length];
	
	[self cancelRefine];
	
	int newTitleTail = currentTitleTail_ + _THREAD_PER_PAGE;
	newTitleTail = ( newTitleTail > titleNum_ ) ? titleNum_ : newTitleTail;
	
	char*p = (char*)[data bytes];
	int i,head = 0;
	int now_title = 0;
	for( i = 0; i < length; i++ ) {
		id pool = [[NSAutoreleasePool alloc] init];
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			if( now_title >= currentTitleTail_ ) {
				NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
				NSString *decoded = decodeNSData( sub );
				
				NSArray*values = [decoded componentsSeparatedByString:@"<>"];
				if( [values count] == 2 ) {
					NSString *threadLength = getThreadNumber( [values objectAtIndex:1] );
					NSString *title = getThreadTitle( [values objectAtIndex:1] );
		
					NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						[boardData_ objectForKey:@"boardID"],	@"boardID",
						[boardData_ objectForKey:@"title"],		@"boardTitle",
						[boardData_ objectForKey:@"server"],	@"boardServer",
						title,									@"threadTitle",
						threadLength,							@"threadLength",
						[values objectAtIndex:0],				@"datFile",
						nil
					];
					[subjectTxtData_ addObject:dict];
					if( newTitleTail == [subjectTxtData_ count] ) {
						currentTitleTail_ = now_title;
						[pool release];
						break;
					}
				}
				head = i + 1;
			}
			now_title++;
		}
		[pool release];
	}
}

- (id) subjectTxtData {
	return subjectTxtData_;
}

- (void) didSelectBoard:(NSNotification *)notification {
	boardData_ = [notification object];
	[self startDownload];
}

- (void) startDownload {
	id dict = boardData_;
	[downloader_ cancel];
	
	NSString* cachePath = [NSString stringWithFormat:@"%@/%@/", [UIApp applicationDirectory], [dict objectForKey:@"boardID"]];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:cachePath] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath attributes:nil];
	}
	subjectTxtPath_ = [[NSString stringWithFormat:@"%@subject.txt", cachePath] retain];

	NSString* url = [NSString stringWithFormat:@"%@subject.txt", [dict objectForKey:@"href"]];
	DNSLog( @"subjectTxt - url - %@", url );
	[downloader_ startWithURL:url];
}

- (void) didFinishLoadging:(id)fp {
	NSData *data =[fp data];
	if( ![data length] ) {
		if( [[NSFileManager defaultManager] fileExistsAtPath:subjectTxtPath_] ) {
			[self extractSubjectTxt];
			[self extendTitleTail];
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"openThreadTitleView"
				object:boardData_];
		}
		else
			return;
	}	
	
	if( [data writeToFile:subjectTxtPath_ atomically:NO] ) {
		[self extractSubjectTxt];
		[self extendTitleTail];
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"openThreadTitleView"
				object:boardData_];
	}
}

- (void) didFailLoadging:(NSString*)str {
	if( [[NSFileManager defaultManager] fileExistsAtPath:subjectTxtPath_] ) {
		[self extractSubjectTxt];
		[self extendTitleTail];
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"openThreadTitleView"
				object:boardData_];
	}
}

@end
