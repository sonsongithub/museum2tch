#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface CategoryView : UIView {
	id					parentController_;
	id					cells_;
	id					table_;
	UINavigationBar*	bar_;
}
- (id) initWithFrame:(CGRect)frame withParentController:(id)fp;
- (void) dealloc;
- (id) cells;
- (void) setUpNavigationBar;
- (void) setUpTable;
- (void) refreshCells;
- (BOOL) table:(UITable *)aTable canSelectRow:(int)row;
- (int) numberOfRowsInTable:(UITable*)table;
- (UITableCell*) table:(UITable*)table cellForRow:(int)row column:(int)col;
- (id) table;
- (id) navibar;
- (void) reload;
@end
