#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface InfoViewController : UIViewController < 
	UITableViewDelegate,
	UITableViewDataSource,
	UIActionSheetDelegate
>
{
    IBOutlet UILabel		*versionLabel_;
    IBOutlet UIImageView	*appImageView_;
    IBOutlet UIView			*contentView_;
    IBOutlet UITableView	*tableView_;

	unsigned long long		allCacheSize_;
	NSMutableDictionary		*cells_;
	
	
	volatile BOOL			isFinishedCheckSize_;
	volatile BOOL			isTryingToStopCheckSize_;
}
@end
