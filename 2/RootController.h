
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface RootController : NSObject {
	id	rootView_;
	
	id	mainController_;
	id	bkMainController_;
}
- (id) view;
@end
