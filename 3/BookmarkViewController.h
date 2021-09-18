#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface BookmarkViewController : UIViewController < 
	UITableViewDelegate,
	UITableViewDataSource
>
{
    IBOutlet UITableView		*tableView_;
    IBOutlet UIBarButtonItem	*editButton_;
}
- (IBAction)closeAction:(id)sender;
- (IBAction)editAction:(id)sender;
@end
