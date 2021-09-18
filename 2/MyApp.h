#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIProgressHUD.h>
#import <GraphicsServices/GraphicsServices.h>

@interface MyApp : UIApplication {
	id		window_;
	id		rootController_;
	
	id		progressSpinner_;
	
	id		historyController_;
}
- (void) applicationDidFinishLaunching: (id) unused;
- (void) showProgressHUD;
- (void) hideProgressHUD;
- (id) applicationDirectory;
- (void) applicationWillTerminate;
- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button;
- (void) deleteCache;
@end
