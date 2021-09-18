//
//  MainController.m
//  2tch
//
//  Created by sonson on 08/02/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"
#import "MainController.h"
#import "CategoryView.h"
#import "BoardView.h"
#import "BBSMenu.h"
#import "subjectTxt.h"
#import "ThreadTitleView.h"
#import "ThreadView.h"
#import "DatFile.h"
#import "global.h"

@implementation MainController

- (id) init {
	self = [super init];

	CGRect  screenRect = CGRectMake( 0,0, 320, 416 );
	
	categoryView_ = [[CategoryView alloc] initWithFrame:screenRect withParentController:self];
	boardView_ = [[BoardView alloc] initWithFrame:screenRect withParentController:self];
	threadTitleView_ = [[ThreadTitleView alloc] initWithFrame:screenRect withParentController:self];
	threadView_ = [[ThreadView alloc] initWithFrame:screenRect withParentController:self];
	bbsMenu_ = [[BBSMenu alloc] initWithParentController:self];
	datFile_ = [[DatFile alloc] init];
	
	subjectTxt_ = [[subjectTxt alloc] init];
	
	mainView_ = [[MainView alloc] initWithFrame:CGRectMake( 0,0, 320, 460) withParentController:self];
	float white[4] = {1.0, 1.0, 1.0, 1};
	[mainView_ setBackgroundColor:CGColorCreate( CGColorSpaceCreateDeviceRGB(), white)];
	
	// success get and extract bbsmenu file
	if( [bbsMenu_ loadBBSMenu] ) {		
		[categoryView_ refreshCells];
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilForwardToView"
				object:categoryView_];
	}
	else {
		id alertButton = [NSArray arrayWithObjects:@"Close",nil];
		id alert = [[UIAlertSheet alloc] initWithTitle:@"2tch" buttons:alertButton defaultButtonIndex:0 delegate:UIApp context:nil];
		[alert setBodyText:NSLocalizedString( @"bbsmenuLoadError", nil )];
		[alert popupAlertAnimated: TRUE];
	}
	return self;
}

- (void) buttonEvent:(id)button {
	id currentView = [mainView_ currentView];
	id buttonDictionary = [mainView_ buttonDictionary];
	if ([button isPressed])
		return;
	if( button == [buttonDictionary objectForKey:@"upButton"] ) {
		if( currentView == threadView_ )
			[threadView_ pageBackward];
	}
	else if( button == [buttonDictionary objectForKey:@"downButton"] ) {
		if( currentView == threadView_ )
			[threadView_ pageForward];
	}
	else if( button == [buttonDictionary objectForKey:@"reloadButton"] ) {
		DNSLog( @"MainView - reloadButton - %@", currentView );
		if( [currentView respondsToSelector:@selector( reload )] ) {
			[currentView reload];
		}
		if( currentView == nil )
			[categoryView_ reload];
	}
	else if( button == [buttonDictionary objectForKey:@"bookmarkButton"] ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"wiilOpenBKView" object:self];
	}
	else if( button == [buttonDictionary objectForKey:@"addButton"] ) {
		id dict = [datFile_ datInfo];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"addBookmark" object:dict];
	}
}

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	id currentView = [mainView_ currentView];
	if( currentView == categoryView_ || currentView == nil )
	if( navbar == [mainView_ navigationbar] ) {
		// make alert sheet
		id sheet = [[[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)] autorelease];
		[sheet setTitle:NSLocalizedString( @"appName", nil )];
		[sheet setBodyText:NSLocalizedString( @"version", nil ) ];
		[sheet addButtonWithTitle:NSLocalizedString( @"okMsg", nil ) ];
		[sheet setRunsModal:NO];
		[sheet setAlertSheetStyle:0];
		[sheet setDelegate: UIApp ];
		//[sheet popupAlertAnimated: TRUE];
		[sheet presentSheetInView: mainView_ ];
	}
}

- (id) view {
	return mainView_;
}

- (id) categoryView {
	return categoryView_;
}

- (id) boardView {
	return boardView_;
}

- (id) threadTitleView {
	return threadTitleView_;
}

- (id) threadView {
	return threadView_;
}

- (id) BBSMenu {
	return bbsMenu_;
}

- (id) SubjectTxt {
	return subjectTxt_;
}

- (id) datFile {
	return datFile_;
}

- (id) currentCategoryName {
	return categoryName_;
}

- (id) currentBoardName {
	return boardName_;
}

- (id) currentThreadTitle {
	return threadName_;
}

- (void) dealloc {
	[categoryView_ release];
	[boardView_ release];
	[bbsMenu_ release];
	[super dealloc];
}

- (void)view: (UIView *)view handleTapWithCount:(int)count event: (GSEventRef)event fingerCount: (int)finger {
	if( threadTitleView_ == [mainView_ currentView] && count == 2 ) {
	
		NSString *titleStr = NSLocalizedString( @"titleRefineSheet", nil );
		NSString *label = NSLocalizedString( @"bodyRefineSheet", nil );
		NSString *yesStr = NSLocalizedString( @"okRefineSheet", nil );
		NSString *noStr = NSLocalizedString( @"cancelRefineSheet", nil );
		
		NSArray *buttons = [NSArray arrayWithObjects:yesStr, noStr, nil];
		searchSheet_ = [[UIAlertSheet alloc] initWithTitle:titleStr buttons:buttons defaultButtonIndex:1 delegate:self context:nil];
		[searchSheet_ setBodyText:nil];
		[searchSheet_ setNumberOfRows: 1];
		[searchSheet_ addTextFieldWithValue:nil label:label];	// label: doesn't seem to work
		[[searchSheet_ textField] setAutoCapsType: 0];					// This turns off autocaps completely I believe
		[[searchSheet_ textField] setPreferredKeyboardType: 3];			// this is the safari url scheme
		[[searchSheet_ textField] setAutoCorrectionType: 1];				// This removes the prompt for autocorrections while typing
		[searchSheet_ popupAlertAnimated:YES];
		[searchSheet_ setDelegate:self];
	}
	else if( threadTitleView_ == [mainView_ currentView] && count == 1 ) {	
		[[threadTitleView_ table] clearAllData];
		[threadTitleView_ hideKeyword];
		[subjectTxt_ cancelRefine];
		[[threadTitleView_ table] reloadData];
	}
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button {
	if( searchSheet_ == sheet ) {
		if( button == 1 ) {	// OK
			DNSLog( @"keyword - %@", [[sheet textFieldAtIndex:0] text]);
			[subjectTxt_ refine:[[sheet textFieldAtIndex:0] text]];
			[[threadTitleView_ table] clearAllData];
			[[threadTitleView_ table] reloadData];
			[threadTitleView_ showKeyword:[[sheet textFieldAtIndex:0] text]];
		}
	}
	
	[sheet dismiss];
}

- (void)tableRowSelected:(NSNotification*)notification {
	id table = [notification object];
	id clickedTitle = nil;
	if( table == [categoryView_ table] ) {
		clickedTitle = [[bbsMenu_ category] objectAtIndex:[table selectedRow]];
		
		//
		[categoryName_ release];
		categoryName_ = [[NSString stringWithString:clickedTitle] retain];
		//
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilForwardToView"
				object:boardView_];
	}
	else if( table == [boardView_ table] ) {
		id clickedCell = [table cellAtRow:[table selectedRow] column:0];
		id dict = [bbsMenu_ boardDataOfName:[clickedCell title]];
		if( dict ) {
			[boardName_ release];
			boardName_ = [[NSString stringWithString:[clickedCell title]] retain];
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"didSelectBoard"
				object:dict];
		}
	}
	else if( table == [threadTitleView_ table] ) {
		int row = [table selectedRow];
		if( row == [[subjectTxt_ subjectTxtData] count] && ![subjectTxt_ hasReadCompletely]) {
			[table clearAllData];
			[threadTitleView_ hideKeyword];
			[subjectTxt_ extendTitleTail];
			[table reloadData];
		}
		else {
			id data = [[subjectTxt_ subjectTxtData] objectAtIndex:row];
			id boardData = [bbsMenu_ boardDataOfName:boardName_];
			[threadName_ release];
			threadName_ = [[NSString stringWithString:[data objectForKey:@"threadTitle"]] retain];
				
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"cancel"
				object:self];
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"didSelectThread"
				object:data];
		}
	}
}

- (void) webView:(WebView *) webView decidePolicyForNewWindowAction:(NSDictionary *) actionInformation request:(NSURLRequest *) request newFrameName:(NSString *) newFrameName decisionListener:(id) listener {
//	[listener performSelector:@selector( ignore )];
//	[UIApp openURL:[actionInformation objectForKey:@"WebActionOriginalURLKey"] asPanel:YES];
}

- (void) openURLWith2tch:(NSString*)url {
	// check url count of url
	NSArray*elements = [url componentsSeparatedByString:@"/"];
	if( [elements count] < 7 ) {
		return;
	}	
	NSString* serverName = [elements objectAtIndex:2];
	NSString* boardID = [elements objectAtIndex:5];
	NSString* dat = [NSString stringWithFormat:@"%@.dat", [elements objectAtIndex:6]];
	NSString* zeroLength = @"unknown";
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
					boardID,		@"boardID",
					@"unknown",		@"boardTitle",
					serverName,		@"boardServer",
					@"unknown",		@"threadTitle",
					zeroLength,		@"threadLength",
					dat,			@"datFile",
					nil
				];
	[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"cancel"
				object:self];
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"didSelectThread"
		object:dict];
}

- (BOOL) isURLOf2ch:(NSString*)url {
	NSArray*elements = [url componentsSeparatedByString:@"/"];
	
	if( [elements count] < 4)
		return NO;
		
	NSString* serverName = [elements objectAtIndex:2];
	NSArray* serverNameElements = [serverName componentsSeparatedByString:@"."];
	
	if( [serverNameElements count] != 3)
		return NO;
	
	NSString* domainName = [serverNameElements objectAtIndex:1];
	
	if( [domainName isEqualToString:@"2ch"] )
		return YES;
	return NO;
}

- (void) open2chURLwith2tch:(NSURL*) url {
	if( [self isURLOf2ch:[url absoluteString]] ) {
		[self openURLWith2tch:[url absoluteString]];
	}
	else {
		[UIApp openURL:url asPanel:NO];
	}
}

- (void) webView:(WebView *) sender decidePolicyForNavigationAction:(NSDictionary *) actionInformation request:(NSURLRequest *) request frame:(WebFrame *) frame decisionListener:(id) listener {
	NSURL *url = [actionInformation objectForKey:@"WebActionOriginalURLKey"];
	if( [[url scheme] isEqualToString:@"about"] ) {
		[listener performSelector:@selector( use )];
	}
	else {
		[listener performSelector:@selector( ignore )];
		[self open2chURLwith2tch:url];
	}
}

@end
