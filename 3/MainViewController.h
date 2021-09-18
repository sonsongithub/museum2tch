//
//  MainViewController.h
//  2tch
//
//  Created by sonson on 08/05/15.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Downloader.h"

extern NSString *kCategoryViewCell;
extern NSString *kBBSMenuHTMLURL;
extern NSString *kMainViewBBSMenu;

@interface MainViewController : UIViewController < 
													UINavigationBarDelegate,
													UITableViewDelegate,
													UITableViewDataSource,
													UIActionSheetDelegate,
													Downloader
												>
{
    IBOutlet UITableView		*tableView_;
    IBOutlet UIToolbar			*underToolbar_;
    IBOutlet UIBarButtonItem	*openInfoViewButton_;
	Downloader					*downloader_;
	NSMutableArray				*categories_;
}
#pragma mark Override
- (void) awakeFromNib;
- (void)dealloc;
- (void)viewWillDisappear:(BOOL)animated;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)didReceiveMemoryWarning;
#pragma mark original method
- (void) setUIToolbarReload;
- (void) setUIToolbarStop;
#pragma mark IBAction
- (IBAction) startLoading:(id)sender;
- (IBAction) cancelLoading:(id)sender;
- (IBAction) openSettingAction:(id)sender;
- (IBAction)openBookmarkAction:(id)sender;
#pragma mark Downloader delegates
- (void) didFinishLoading:(id)data identifier:(NSString*)identifier;
- (void) didFailLoadingWithIdentifier:(NSString*)identifier isDifferentURL:(BOOL)isDifferentURL;
#pragma mark UITableView delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
