
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface FavouriteView : UIView {
	id					table_;
	NSMutableArray*		urlArray_;
	NSMutableArray*		cellArray_;
}
- (void) delete:(id)cell;
- (BOOL) open;
- (BOOL) backupFavourite;
@end
