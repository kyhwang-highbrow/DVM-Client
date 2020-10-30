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

@property (nonatomic, copy) NSString *mCheckReceiptServerUrl;
@property (nonatomic, copy) NSString *mSaveTransactionUrl;
@property (nonatomic, copy) NSString *mPayload;
@property PerpleSDKCallback mFailCallback;

@property (nonatomic, retain) NSMutableDictionary *mPurchases;
@property (nonatomic, retain) NSMutableDictionary *mTransactions;
@property (nonatomic, retain) NSMutableDictionary *mProduct;
@property (nonatomic, retain) NSMutableDictionary *mGetItem;

#pragma mark - APIs

- (void) startSetupWithCheckReceiptServerUrl:(NSString *)checkReceiptServerUrl saveTransactionUrl:(NSString *)saveTransactionUrl completion:(PerpleSDKCallback)callback;
- (void) purchaseWithSku:(NSString *)sku payload:(NSString *)payload completion:(PerpleSDKCallback)callback;
- (void) subscriptionWithSku:(NSString *)sku payload:(NSString *)payload completion:(PerpleSDKCallback)callback;
- (void) finishPurchaseTransaction:(NSString *)orderId;
- (void) getItemList:(NSString *)skuList completion:(PerpleSDKCallback)callback;
- (void) getIncompletePurchaseList:(PerpleSDKCallback)callback;

@end
