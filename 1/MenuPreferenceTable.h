
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <GraphicsServices/GraphicsServices.h>


@interface MenuPreferenceTable : UIPreferencesTable {
	int						items_;			// count of items
	id						delegate_;		// delegate to the text label
	NSMutableArray*			ary_;
	UIPreferencesTableCell* titleCell_;
}
- (id) initWithFrame:(CGRect)frame withTitles:(NSArray*)titles withDelegate:(id)fp;
- (void) setDataDelegate:(id)fp;
@end
