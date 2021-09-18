
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface MainView : UIView {
	UITransitionView*	transitionView_;
	id					bar_;
	id					underBar_;
	id					barTitle_;
	
	//
	id					currentView_;
	id					previousView_;
	
	//
	id					parentController_;
	
	//
	id					buttonDictionary_;
}
- (id) initWithFrame:(CGRect)frame withParentController:(id)fp;
- (void) setUpUnderNavigationBar;
- (void) buttonEvent:(UIPushButton *)button;
- (void) setUpNavigationBar;
- (void)navigationBar:(UINavigationBar*)navigationBar poppedItem:(UINavigationItem*)item;
- (void) setNavigationBarToView:(id)to FromView:(id)from;
- (void)transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to;
- (void) wiilForwardToView:(NSNotification *)notification;
- (void) wiilBackToView:(NSNotification *)notification;
@end
