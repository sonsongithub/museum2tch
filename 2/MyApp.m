
#import "MyApp.h"
#import "global.h"

#import "RootController.h"
#import "HistoryController.h"

@implementation MyApp

- (void) applicationDidFinishLaunching: (id) unused {
	// Get screen rect
	CGRect  screenRect = [UIHardware fullScreenApplicationContentRect];
	
	// Create window
	window_ = [[UIWindow alloc] initWithContentRect:screenRect];
	
	// Create main contorller
	rootController_ = [[RootController alloc] init];
	
	// Set main view
	[window_ setContentView:[rootController_ view]];

	// Progress dialog
	progressSpinner_ = [[UIProgressHUD alloc] initWithWindow: window_];
	[progressSpinner_ setText:@"Loading..."];
	[progressSpinner_ drawRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
		
	// Show window
	[window_ orderFront:self];
	[window_ makeKey:self];
	[window_ _setHidden:NO];
}

- (void) showProgressHUD {
	id pool = [[NSAutoreleasePool alloc] init];
	@synchronized(self) {
		[progressSpinner_ show: YES];
		[window_ addSubview:progressSpinner_];
	}
	[pool release];
	[NSThread exit];
}

- (void) hideProgressHUD {
	[self setStatusBarShowsProgress:NO];
	[progressSpinner_ show: NO];
	[progressSpinner_ removeFromSuperview];
}

- (id) applicationDirectory {
	NSString *path = [NSString stringWithFormat:@"%@/%@/%@", [UIApp userLibraryDirectory], @"Preferences", @"2tch"];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	}
	return path;
}

- (void) applicationWillTerminate {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"save" object:self];
}

#ifdef		_DEBUG
#else
- (void)applicationSuspend:(GSEvent*)event {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"save" object:self];
	[self hideProgressHUD];
	CGImageRef defaultPNG = [self createApplicationDefaultPNG];
	if (defaultPNG != nil) {
		NSString *pathToDefault = [NSString stringWithFormat:@"%@/Default.png", [[NSBundle mainBundle] bundlePath]];
		NSURL *urlToDefault = [NSURL fileURLWithPath:pathToDefault];
		CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)urlToDefault, CFSTR("public.png")/*kUTTypePNG*/, 1, NULL);
		CGImageDestinationAddImage(dest, defaultPNG, NULL);
		CGImageDestinationFinalize(dest);
		CFRelease(defaultPNG);
	}
}
#endif

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button {
	[sheet dismiss];
}

- (void) deleteCache {
	int i,j;
	NSArray *subdirectories = [[NSFileManager defaultManager] subpathsAtPath:[UIApp applicationDirectory]];
	//NSMutableArray *cacheDirectoryies = [NSMutableArray array];
	// look for the cache directories
	for( i = 1; i < [subdirectories count]; i++ ) {
		BOOL isDirectory = NO;
		NSString *path = [NSString stringWithFormat:@"%@/%@", [UIApp applicationDirectory], [subdirectories objectAtIndex:i]];
		if( [[subdirectories objectAtIndex:i] isEqualToString:@""] )
			continue;
		if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] ) {
			if( isDirectory ) {
				NSArray *subsubPaths = [[NSFileManager defaultManager] subpathsAtPath:path];
				for( j = 0; j < [subsubPaths count]; j++ ) {
					NSString *deletePath = [NSString stringWithFormat:@"%@/%@",path,[subsubPaths objectAtIndex:j]];
					[[NSFileManager defaultManager] removeFileAtPath:deletePath handler:nil];
				}
			}
		}
	}
}
@end