
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface MainController : NSObject {
	// data models
	id		bbsMenu_;
	id		subjectTxt_;
	id		datFile_;
	
	// views
	id		mainView_;
	id		categoryView_;
	id		boardView_;
	id		threadTitleView_;
	id		threadView_;
	
	id		searchSheet_;
	
	// status information
	id		categoryName_;
	id		boardName_;
	id		threadName_;
}
- (id) init;
- (id) view;
- (id) categoryView;
- (id) boardView;
- (id) threadTitleView;
- (id) threadView;
- (id) BBSMenu;
- (id) SubjectTxt;
- (id) datFile;
- (id) currentCategoryName;
- (id) currentBoardName;
- (id) currentThreadTitle;
- (void) dealloc;
- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button;
- (void) tableRowSelected:(NSNotification*)notification;
@end
