
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface BoardView : UIView {
	id	parentController_;
	
	
	id				cells_;
	id				table_;
	UINavigationBar*bar_;
}
- (id) initWithFrame:(CGRect)frame withParentController:(id)fp;
- (id) cells;
- (void) dealloc;
- (void) setUpNavigationBar;
- (void) setUpTable;
- (void) refreshCells;
- (void) reload;
- (BOOL)table:(UITable *)aTable canSelectRow:(int)row;
- (int)numberOfRowsInTable:(UITable*)table;
- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(int)col;
- (id) table;
- (id) navibar;

@end
