//
//  MPHomeViewController.h
//  Misepuri
//
//  Created by M.Amatani on 2016/11/02.
//  Copyright © 2016年 Mobile Innovation. All rights reserved.
//

#import "MPBaseViewController.h"
#import "MPTabBarViewController.h"
#import "ManagerDownload.h"
#import "MPTopImagesView.h"
#import "MPConfigObject.h"
#import "Configuration.h"

#import "MPMenuListCollectionCell.h"

#import "FirstSettingViewController.h"
#import "MPWebViewController.h"
#import "MPMenuTopinfoObject.h"
#import "MPRecommend_menuObject.h"
#import "MPMenuRecommend_itemObject.h"
#import "MPWhatNewsObject.h"
#import "MPRecommendMenuCell.h"
#import "MPWhatNewsCell.h"
#import "MPApnsObject.h"

#import "MPRecommendMenuViewController.h"
#import "MPRecommendMenuInfoViewController.h"

#import "MPWhatNewViewController.h"
#import "MPWhatNewInfoViewController.h"

#import "MPMembersCardViewController.h"
#import "MPStampCardViewController.h"
#import "MPHearCatalogViewController.h"
#import "MPReservationViewController.h"
#import "MPStaffViewController.h"
#import "MPMovieViewController.h"

@interface MPHomeViewController : MPBaseViewController <ManagerDownloadDelegate, UIScrollViewDelegate, MPTopImagesViewDelegate, UITableViewDelegate, UITableViewDataSource, FirstSettingViewControllerDelegate ,UICollectionViewDataSource, UICollectionViewDelegate, MPRecommendMenuViewControllerDelegate ,MPRecommendMenuInfoViewControllerDelegate, MPWhatNewViewControllerDelegate, MPWhatNewInfoViewControllerDelegate, MPMembersCardViewControllerDelegate, MPStampCardViewControllerDelegate, MPHearCatalogViewControllerDelegate, MPReservationViewControllerDelegate>
{
    __weak IBOutlet UIScrollView* _scr_rootview;
    __weak IBOutlet UIView* _scr_inView;
    CGPoint _scrollBeginingPoint;

    __weak IBOutlet UIView* _topimg_rootView;
    MPTopImagesView* _topImageView;

    __weak IBOutlet UIView *view_item;
    __weak IBOutlet UIButton* btn_block1;
    __weak IBOutlet UIButton* btn_block2;
    __weak IBOutlet UIButton* btn_block3;
    __weak IBOutlet UIButton* btn_block4;
    __weak IBOutlet UIButton* btn_block5;

    __weak IBOutlet UIImageView *img_notification_block1;
    __weak IBOutlet UIImageView *img_notification_block2;
    __weak IBOutlet UIImageView *img_notification_block3;
    __weak IBOutlet UIImageView *img_notification_block4;
    __weak IBOutlet UIImageView *img_notification_block5;

    __weak IBOutlet UICollectionView *_item_collectionView;

    __weak IBOutlet UIView *view_recommend;
    __weak IBOutlet UITableView* _RecommendMenuList_tableView;

    __weak IBOutlet UIView *view_news;
    __weak IBOutlet UITableView* _WhatsNew_tableView;

    NSArray* _ary_blockSet;
    NSMutableArray* _list_RecommendItem;
    NSMutableArray* _list_RecommendMenu;
    NSMutableArray* _list_news;
}

- (IBAction)btn_block1:(id)sender;
- (IBAction)btn_block2:(id)sender;
- (IBAction)btn_block3:(id)sender;
- (IBAction)btn_block4:(id)sender;
- (IBAction)btn_block5:(id)sender;

- (IBAction)btn_Recommend_Menu_More:(id)sender;
- (IBAction)btn_WhatsNew_More:(id)sender;

@end
