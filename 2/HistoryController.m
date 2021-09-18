
#import "HistoryController.h"
#import "global.h"

@implementation HistoryController

- (id) initWithDelegate:(id) fp {
	self = [super init];
	delegate_ = fp;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(addHistory:)
			name:@"addHistory"
			object:nil];
			
	[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(save:)
			name:@"save"
			object:nil];
	
	NSString *path = [NSString stringWithFormat:@"%@/history.plist", [UIApp applicationDirectory]];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		NSData *data = [NSData dataWithContentsOfFile:path];
		NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		id ary = [[str propertyList] objectForKey:@"NSArray"];
		historyArray_ = [[NSMutableArray arrayWithArray:ary] retain];
		[self debugaa];
	}
	else
		historyArray_ = [[NSMutableArray array] retain];
	
	return self;
}

- (void) debugaa {
	int i;
	for( i = 0; i < [historyArray_ count]; i++ ) {
		id obj = [historyArray_ objectAtIndex:i];
		DNSLog( @"%@, %d", [obj objectForKey:@"threadTitle"], [[obj objectForKey:@"threadLength"] intValue] );
	}
}

- (void) save:(NSNotification *)notification {	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:historyArray_, @"NSArray", nil];
	NSString *str = [dict description];
	NSString *path = [NSString stringWithFormat:@"%@/history.plist", [UIApp applicationDirectory]];
	[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (void) dealloc {
	[historyArray_ release];
	[super dealloc];
}

- (void) addHistory:(NSNotification *)notification {
	int i;
	id dict = [notification object];
	
	for( i = 0; i < [historyArray_ count]; i++ ) {
		id obj = [historyArray_ objectAtIndex:i];
		id input_boardID = [dict objectForKey:@"boardID"];
		id temp_boardID = [obj objectForKey:@"boardID"];
		id input_datFile = [dict objectForKey:@"datFile"];
		id temp_datFile = [obj objectForKey:@"datFile"];
		if( [input_boardID isEqualToString:temp_boardID] && [input_datFile isEqualToString:temp_datFile] ) {
			[historyArray_ removeObjectAtIndex:i];
			break;
		}
	}
	[historyArray_ insertObject:dict atIndex:0];
	if( [historyArray_ count] > 100 )
		[historyArray_ removeLastObject];
#ifdef _DEBUG
	dict = [NSDictionary dictionaryWithObjectsAndKeys:historyArray_, @"NSArray", nil];
	NSString *str = [dict description];
	NSString *path = [NSString stringWithFormat:@"%@/history.plist", [UIApp applicationDirectory]];
	[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
#endif
}

- (id) clear {
	[historyArray_ removeAllObjects];
#ifdef _DEBUG
	id dict = [NSDictionary dictionaryWithObjectsAndKeys:historyArray_, @"NSArray", nil];
	NSString *str = [dict description];
	NSString *path = [NSString stringWithFormat:@"%@/history.plist", [UIApp applicationDirectory]];
	[str writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
#endif
}

- (id) history {
	return historyArray_;
}

@end
