#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "invariables.h"

@interface BoardView : UIView {
	id cells_;
	id table_;
	UINavigationItem*	naviTitle_;
}
// override
- (id)initWithFrame:(CGRect)frame withMainControllerId:(id)mainController;
- (void) rebuildCells;
- (void) reload;
// UINavigationbar's delegate method
- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button;
// UITable's delegate method
- (BOOL) table:(UITable *)aTable canSelectRow:(int)row;
- (int) numberOfRowsInTable:(UITable*)table;
- (UITableCell*) table:(UITable*)table cellForRow:(int)row column:(int)col;
- (void) tableRowSelected:(NSNotification*)notification;
@end