
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIProgressHUD.h>

#import "MenuController.h"
#import "MainTransitionView.h"

@interface MyApp : UIApplication {
	UIWindow*				window_;
	MainTransitionView*		transitionView_;
	UIView*					mainView_;

	id						delegate_;

	NSTimer*				spinnerDuration_;
	id						progressSpinner_;
	id						menuCon_;
	
	UIImage*				cacheIconImage_;
	
	NSString*				subjectTxtURL_;
	NSString*				datFileURL_;
	NSString*				threadRawTitle_;
	NSString*				threadTitle_;
	NSString*				categoryTitle_;
	NSString*				boardTitle_;
	
	NSMutableArray*			favouriteStack_;
	
	float					threadIndexSize_;
	float					threadSize_;
	int						daysToMaintain_;
	BOOL					offlineMode_;
	
}
- (void) readResource;
- (UIImage*) cacheIconUIImage;

- (NSString*) preferencePath;
- (NSString*) makeCacheDirectroy:(NSString*) url;
- (NSString*) makeCacheDataPath:(NSString*) url;
- (void) deleteCache;
- (MenuController*) menuController;
- (MainTransitionView*) view;
- (void) showProgressHUD:(NSString*)label;
- (void) showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect;
- (void) hideProgressHUD;
- (void) showStandardAlertWithError:(NSString *)error;
- (void) showStandardAlertWithString:(NSString *)title closeBtnTitle:(NSString *)closeTitle withError:(NSString *)error;
- (void) showStandardAlertWithCloseBtnTitle:(NSString *)closeTitle withError:(NSString *)error;
- (void) alertSheet: (UIAlertSheet*)sheet buttonClicked:(int)button;
- (NSMutableArray*) readFavouriteSubjectTxt;
- (NSMutableArray*) mergeFavourite:(NSMutableArray*)new_array into:(NSMutableArray*)ary;
- (NSString*) extractFolderAndDatName:(NSString*)url;
- (NSMutableArray*) readFavouriteForDeleting;
- (BOOL) exportFavourites;

- (void) setSubjectTxtURL:(NSString*)str;
- (NSString*) subjectTxtURL;
- (void) setDatFileURL:(NSString*)str;
- (NSString*) datFileURL;
- (void) setThreadRewTitle:(NSString*)str;
- (NSString*) threadRawTitle;
- (void) setThreadTitle:(NSString*)str;
- (NSString*) threadTitle;
- (void) setCategoryTitle:(NSString*)str;
- (NSString*) categoryTitle;
- (void) setBoardTitle:(NSString*)str;
- (NSString*) boardTitle;
- (BOOL) addThreadIntoFavouriteStackURL:(NSString*)url andTitle:(NSString*)title;
- (NSMutableArray*) favouriteStack;
- (void) readPreferenceData;
- (NSDictionary*) readPlist;
- (NSDictionary*) makeDefaultDictionaryOfPreference;
- (void) setDelegate:(id)fp;
- (id) delegate;
- (float) threadIndexSize;
- (float) threadSize;
- (int) daysToMaintain;
- (BOOL) isOfflineMode;
@end
