//
//  MPRecommendMenuInfoViewController.h
//  Dalia
//
//  Created by M.Amatani on 2016/11/21.
//  Copyright © 2016年 Mobile Innovation. All rights reserved.
//

#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "MPBaseViewController.h"
#import "MPTabBarViewController.h"
#import "ManagerDownload.h"

@protocol MPRecommendMenuInfoViewControllerDelegate<NSObject>
@end

@interface MPRecommendMenuInfoViewController : MPBaseViewController <ManagerDownloadDelegate, UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView* _scr_rootview;
    __weak IBOutlet UIView* _scr_inView;
    CGPoint _scrollBeginingPoint;
    
    __weak IBOutlet UILabel *_lbl_title;
    __weak IBOutlet UIImageView *_img_photo;
    __weak IBOutlet UILabel *_lbl_content;
}
@property (nonatomic, assign) id<MPRecommendMenuInfoViewControllerDelegate> delegate;
@property (nonatomic) NSString* str_title;
@property (nonatomic) NSString* str_imagUrl;
@property (nonatomic) NSString* str_comment;

- (IBAction)btn_hart:(id)sender;
- (IBAction)btn_facebook:(id)sender;
- (IBAction)btn_twitter:(id)sender;
- (IBAction)btn_line:(id)sender;

@end
