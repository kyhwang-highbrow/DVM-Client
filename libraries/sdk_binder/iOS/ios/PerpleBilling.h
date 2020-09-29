//
//  PerpleBilling.h
//  PerpleSDK
//
//  Created by Yonghak on 2016. 9. 4..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "PerpleSDK.h"

@interface PerpleBilling : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

#pragma mark - Properties

@property BOOL mCanMakePayments;
@property BOOL mIsRequestPay;
@property (nonatomic, retain) NSMutableDictionary *mPurchases;
@property (nonatomic, retain) NSMutableDictionary *mTransactions;
@property (nonatomic, retain) NSMutableArray *mIncompletePurchases;
@property (nonatomic, copy) NSString *mCheckReceiptServerUrl;
@property (nonatomic, retain) NSMutableDictionary *mProduct;
@property (nonatomic, retain) NSMutableDictionary *mGetItem;
@property PerpleSDKCallback mFailCallback;

#pragma mark - APIs

- (void) startSetupWithCheckReceiptServerUrl:(NSString *)checkReceiptServerUrl completion:(PerpleSDKCallback)callback;
- (void) purchaseWithSku:(NSString *)sku payload:(NSString *)payload completion:(PerpleSDKCallback)callback;
- (void) subscriptionWithSku:(NSString *)sku payload:(NSString *)payload completion:(PerpleSDKCallback)callback;
- (void) finishPurchaseTransaction:(NSString *)orderId;
- (void) billingGetItemList:(NSString *)skuList completion:(PerpleSDKCallback)callback;

@end
