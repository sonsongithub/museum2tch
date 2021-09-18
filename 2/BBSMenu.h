
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

#define		BOARD_URL_TERMINATER		@"http://count.2ch.net/?bbsmenu"

@interface BBSMenu : NSObject {
	id	parentController_;
	
	id	downloader_;

	id	categoryView_;
	id	boardView_;
	
	id	categories_;
	id	boards_;
	
//	id	categoryDataArray_;
//	id	boardData_;
}
- (void) dealloc;
- (id) initWithParentController:(id)fp;
- (id) boardDataOfName:(NSString*)name;
- (id) category;
- (id) board;
- (id) boardOfCategory:(NSString*)categoryName;
- (BOOL) downloadBBSMenu;
- (BOOL) extractBoard:(NSData*)data;
- (BOOL) extractBbsMenuHtml:(NSString*) htmlString;
- (NSDictionary*) makeBoardDictionaryWithTitle:(NSString*)title HREF:(NSString*)href Category:(NSString*)category;
@end
