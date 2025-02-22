//
//  ManagerDownload.h
//  Oromo
//
//  Created by TUYENBQ on 10/16/13.
//  Copyright (c) 2013 TUYENBQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadParam.h"
#import "AFJSONRequestOperation.h"
#import "MPCouponObject.h"
#import "MPCouponStampObject.h"
#import "MPVideolistObject.h"

@interface ManagerDownload : NSObject<UIAlertViewDelegate>
{
    NSOperationQueue *queue;
    NSOperationQueue *privateImageQueue;
    NSMutableArray *listRequest;
    BOOL appDisable;
}
+ (ManagerDownload *)sharedInstance;

#pragma mark - ACCESS API
//バッジ情報取得
- (void)getDefaultNotification:(NSString*)deviceID withAppID:(NSString*)appID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//トップスライドイメージ取得
- (void)getListImage:(NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
//お知らせ配信依頼
- (void)setSendMessage:(long)member_mode member_ids:(NSArray*)member_ids send_mode:(long)send_mode postion:(long)postion title:(NSString*)title descliption:(NSString*)descliption image:(NSString*)image delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//トップ画面情報取得
- (void)getTopInfo:(NSString*)appID withDeviceID:(NSString*) deviceID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//クーポン取得
- (void)getListCoupon:(NSString*)deviceID withAppID:(NSString*)appID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//新着情報取得
- (void)getListMessage:(NSString*)deviceID withAppID:(NSString*)appID withLimit:(NSString*)limit delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//店舗情報
- (void)getListShop:(NSString*)deviceID withAppID:(NSString*)appID delegate:(NSObject<ManagerDownloadDelegate> *)delegate;
- (void)getDetailShop:(NSString*)appID withShopID:(NSString*)shopID withDeviceID:(NSString*)deviceID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//おすすめメニュー
- (void)getListRecommendMenu:(NSString*)deviceID withAppID:(NSString*)appID delegate:(NSObject<ManagerDownloadDelegate> *)delegate;
//メニュー情報
- (void)getListMenu:(NSString*)deviceID withAppID:(NSString*)appID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//顧客情報取得
- (void)getMemberInfo:(NSString*)appID withDeviceID:(NSString*)deviceID wirhCall:(NSString*)call delegate:(NSObject<ManagerDownloadDelegate>*) delegate;
//顧客情報保存
- (void)setMemberInfo:(NSString*)appID
         withDeviceID:(NSString*)deviceID
       withShrareCode:(NSString*)shareCode
            withfield:(NSMutableArray*)dic_field
             delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
//会員書情報取得
- (void)getMemberCard:(NSString*)appID withDeviceID:(NSString*)deviceID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//スタンプ情報取得
- (void)getDetailCouponStamp:(NSString*)deviceID withAppID:(NSString*)appID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//スタッフ情報
- (void)getStaff:(NSString*)appID withDeviceID:(NSString*)deviceID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//ビデオ
- (void)getVideo:(NSString*)appID withDeviceID:(NSString*)deviceID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//友達クーポン
- (void)getListShareCoupon:(NSString*)appID withDeviceID:(NSString*)deviceID delegate:(NSObject<ManagerDownloadDelegate>*)delegate;






/*
- (void) readMessage: (NSString*) deviceID withAppID: (NSString*) appID withMessageID: (NSString*) messageID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;

- (void) getListLikedMenu: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) getDetailMenu: (NSString*) deviceID withAppID: (NSString*) appID withMenuID: (NSString*) menuID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) getListCatShop: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
// REPLACED BY ama 2016.10.05 START
// パラメータ追加
- (void) getDetailShop: (NSString*) appID withShopID: (NSString*) shopID withDeviceID:(NSString*)deviceID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
// REPLACED BY ama 2016.10.05 END
- (void) setFavoriteShop:(NSString*)appID withDeviceID:(NSString*)deviceID withShopID:(NSString*)shopID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
// INSERTED BY ama 2016.10.05 START
// お気に入り削除追加
- (void) delFavoriteShop:(NSString*)appID withDeviceID:(NSString*)deviceID withShopID:(NSString*)shopID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
// INSERTED BY ama 2016.10.05 END

- (void) getListCouponShare: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) getDetailCouponShare: (NSString*) deviceID withAppID: (NSString*) appID withCoupon:(MPCouponObject*) coupon delegate: (NSObject<ManagerDownloadDelegate>*) delegate;

- (void) getRecommendProduct: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) getLink: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) getBookLink: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) getCompany: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) getTransferCode: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) setTransferDevice: (NSString*) deviceID withAppID: (NSString*) appID transfer_code: (NSString*) transfer_code delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) delTransferCode: (NSString*) deviceID withAppID: (NSString*) appID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;

*/


#pragma mark - SUBMIT DATA TO SERVER
//デバイス登録
- (void)submitDeviceID:(NSString*)deviceID withAppID:(NSString*)appID withType:(NSString*)type delegate:(NSObject<ManagerDownloadDelegate>*)delegate;
//スタンプ捺印
- (void)submitStamp:(NSString*)deviceID withAppID:(NSString*)appID withCoupon:(MPCouponStampObject*)couponstamp withCode:(NSString *)code withAmount:(NSString *)amount withUUID:(NSString *)uuid withMajor:(NSString *)major withMinor:(NSString *)minor delegate:(NSObject<ManagerDownloadDelegate> *)delegate;





/*
- (void) submitDeviceToken: (NSString*) deviceToken withAppID: (NSString*) appID withDeviceID: (NSString*) deviceID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) enableNotificationToDevice: (NSString*) deviceID withAppID: (NSString*) appID withReceived: (NSString*) received delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) submitLikedMenu: (NSString*) deviceID withAppID: (NSString*) appID withMenuID: (NSString*) menuID delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) submitUseCoupon: (NSString*) deviceID withAppID: (NSString*) appID withCoupon: (MPCouponObject*) coupon delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) submitRegistCoupon: (NSString*) deviceID withAppID: (NSString*) appID withCoupon: (MPCouponObject*) coupon delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
- (void) submitBirthDay: (NSString*) deviceID withAppID: (NSString*) appID withBirthday: (NSString*) birthDay delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
// REPLACED BY ama 2016.10.05 START
// iBeacon識別追加
- (void) submitStamp: (NSString*) deviceID withAppID: (NSString*) appID withCoupon: (MPCouponObject*) coupon withCode: (NSString*) code withAmount:(NSString *)amount withUUID:(NSString *)uuid withMajor:(NSString *)major withMinor:(NSString *)minor delegate: (NSObject<ManagerDownloadDelegate>*) delegate;
// REPLACED BY ama 2016.10.05 END
*/
@end
