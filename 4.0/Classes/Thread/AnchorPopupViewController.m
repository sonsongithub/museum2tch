//
//  AnchorPopupViewController.m
//  2tch
//
//  Created by sonson on 08/12/03.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AnchorPopupViewController.h"
#import "ThreadViewController.h"
#import "ThreadResData.h"
#import "ThreadCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ThreadLayoutComponent.h"
#import "Dat.h"

NSString* kAnchorPopupViewCell = @"kAnchorPopupViewCell";

@implementation AnchorPopupViewController

@synthesize delegate = delegate_;
@synthesize source = source_;

#pragma mark Original method

- (void)cancel {
	DNSLogMethod
	[super cancel];
	
	historyCounter_ = 0;
}

- (void)adjustSize:(float)allHeight{
	float width = 256;
	float height = allHeight / 0.8 > 384 ? 384 : allHeight / 0.8;
	height = height < 25 ? 25 : height;
	
	contentView.frame = CGRectMake( 0, 0, width, height );
	background.frame = CGRectMake( 0, 0, width, height );
	background.center = CGPointMake( width / 2, height / 2 );
	contentView.center = CGPointMake( 320 / 2, 480 / 2 );
	
	CGRect rect = contentView.bounds;
	rect.size.width *= 0.79;
	rect.size.height *= 0.79;
	tableView_.frame = rect;
	tableView_.center = CGPointMake( width / 2, height / 2 );
}

- (void)showInView:(UIView*)view withNumbers:(NSArray*)numbers {
	DNSLogMethod
	[cell_ removeAllObjects];
	for( NSNumber* num in numbers ) {
		int i = [num intValue];
		if( i - 1 >= 0 && i - 1 < [source_ count] ) {
			ThreadResData *data = [source_ objectAtIndex:i-1];
			ThreadResData *p = [data copy];
			[cell_ addObject:p];
			[p release];
			DNSLog( @"%@", data.numberString );
			p.isPopup = YES;
		}
	}
	DNSLog( @"%d", [cell_ count] );
	layout( cell_, 210 );
/*	
	float allHeight = 0;
	for( ThreadResData* data in cell_ ) {
		allHeight += ( data.height + [ThreadCell offsetHeightOfPopup] );
	}
	[self adjustSize:allHeight];
*/	
	[tableView_ reloadData];
	[tableView_ scrollsToTop];
	
	[super showInView:view];
}

#pragma mark Override

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DNSLogMethod
	return [cell_ count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	ThreadResData* r = [cell_ objectAtIndex:indexPath.row];
	return r.height + [ThreadCell offsetHeightOfPopup];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThreadCell *cell = (ThreadCell*)[tableView dequeueReusableCellWithIdentifier:kAnchorPopupViewCell];
    if (cell == nil) {
        cell = [[[ThreadCell alloc] initWithFrame:CGRectZero reuseIdentifier:kAnchorPopupViewCell] autorelease];
    }
	else {
		[cell prepareForReuse];
	}
	ThreadResData* r = [cell_ objectAtIndex:indexPath.row];
	cell.resObject = r;
//	cell.height = r.height;
	cell.delegate = self.delegate;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (id)init {
	DNSLogMethod
    if (self = [super init]) {
		
		tableView_ = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		tableView_.frame = CGRectMake( 0, 0, contentView.frame.size.width - 30, contentView.frame.size.height - 30 );
		tableView_.center = CGPointMake( contentView.frame.size.width * 0.5, contentView.frame.size.height * 0.5 );
		
		tableView_.delegate = self;
		tableView_.dataSource = self;
		tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		[contentView addSubview:tableView_];
		cell_ = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[tableView_ release];
	[cell_ release];
    [super dealloc];
}


@end
