#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "invariables.h"

@interface CategoryView : UIView {
	id cells_;
	id table_;
}
// original method
- (id) initWithFrame:(CGRect)frame;
- (void) rebuildCells;
// UINavigationbar's delegate method
- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button;
// UITable's delegate method
- (BOOL) table:(UITable *)aTable canSelectRow:(int)row;
- (int) numberOfRowsInTable:(UITable*)table;
- (UITableCell*) table:(UITable*)table cellForRow:(int)row column:(int)col;
- (void) tableRowSelected:(NSNotification*)notification;
- (id) initWithFrame:(CGRect)frame;
@end
