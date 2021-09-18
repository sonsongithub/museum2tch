//
//  TitleViewCell.h
//  2tchfree
//
//  Created by sonson on 08/08/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCellForDrawRect.h"

extern float TitleViewCellHeight;

#define _NEW

#ifdef _NEW

@interface TitleViewCell : SNCellForDrawRect {
	NSString		*title_;
	NSString		*boardTitle_;
	NSString		*readDate_;
	NSString		*number_;
	NSString		*res_;
	
	BOOL			isShownCheck_;
	BOOL			isThreadTitle_;
}
@property (nonatomic, assign) NSString	*title;
@property (nonatomic, assign) NSString	*boardTitle;
@property (nonatomic, assign) NSString	*number;
@property (nonatomic, assign) NSString	*res;
@property (nonatomic, assign) BOOL		isShownCheck;

#pragma mark Class Method
+ (UIImage*) getSelectedCheckImage;
+ (UIImage*) getUnselectedCheckImage;

#pragma mark Original Method
- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle;
- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle date:(NSDate*)date;
- (void) setTitle:(NSString*)title number:(int)number;
- (void) confirmHasCacheWithBoardPath:(NSString*)boardPath dat:(NSString*)dat;

@end

#else

@interface TitleViewCell : UITableViewCell {
	UILabel			*title_;
	UILabel			*boardTitle_;
	UILabel			*readDate_;
	UILabel			*number_;
	UILabel			*res_;
	
	UIImageView		*unselected_;
	UIImageView		*selected_;
	UIImageView		*boardIcon_;
	
	BOOL			isShownCheck_;
	BOOL			isThreadTitle_;
}
@property (nonatomic, assign) UILabel	*title;
@property (nonatomic, assign) UILabel	*boardTitle;
@property (nonatomic, assign) UILabel	*number;
@property (nonatomic, assign) UILabel	*res;
@property (nonatomic, assign) BOOL		isShownCheck;

#pragma mark Class Method
+ (UIImage*) getSelectedCheckImage;
+ (UIImage*) getUnselectedCheckImage;

#pragma mark Original Method
- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle;
- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle date:(NSDate*)date;
- (void) setTitle:(NSString*)title number:(int)number;
- (void) confirmHasCacheWithBoardPath:(NSString*)boardPath dat:(NSString*)dat;

@end

#endif
