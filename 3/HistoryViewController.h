#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface HistoryViewController : UIViewController  < 
	UIActionSheetDelegate
>
{
    IBOutlet UIBarButtonItem	*deleteButton_;
}
- (IBAction)deleteAction:(id)sender;
@end
