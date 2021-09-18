
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <GraphicsServices/GraphicsServices.h>

@interface PreferenceView : UIView {
	id						currentTable_;
	UINavigationBar			*bar_;
	UINavigationItem		*barTitle_;
	UITransitionView*		transitionView_;
	UIPreferencesTable*		table_;
	
	UIPreferencesTableCell* titleCell_;
	
	UIPreferencesTableCell* threadIndexCell_;
	UITextLabel*			threadIndex_label_;
	
	UIPreferencesTableCell* threadCell_;
	UITextLabel*			thread_label_;
	
	UIPreferencesTableCell* cacheDaysToDeleteCell_;
	UITextLabel*			daysToDelete_label_;
	
	UIPreferencesTableCell* offlineCell_;
	UISwitchControl* offlineSwitch_;
	
	UIPreferencesTableCell* updataBBSMenuCell_;
	UIPreferencesTableCell* cacheDeleteCell_;
	UIPreferencesTableCell* initializeCell_;
	UIPreferencesTableCell* versionInfoCell_;
	
	UIAlertSheet			*alert_delete_;
	UIAlertSheet			*alert_initialize_;
}
- (BOOL) savePlist;
- (BOOL) setDataToControl:(NSDictionary*)dict;
- (BOOL) setupGroup;
- (void) adjustTextLabel:(UITextLabel*)fp;
- (BOOL) changeNaviBar:(int)mode;
- (void) removeCacheAndReset;
- (void) initializeAll;
@end
