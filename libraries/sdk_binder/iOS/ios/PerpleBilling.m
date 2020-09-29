//
//  PerpleBilling.m
//  PerpleSDK
//
//  Created by Yonghak on 2016. 9. 4..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleBilling.h"

@implementation PerpleBilling

#pragma mark - Properties

@synthesize mCanMakePayments;
@synthesize mIsRequestPay;
@synthesize mPurchases;
@synthesize mTransactions;
@synthesize mIncompletePurchases;
@synthesize mCheckReceiptServerUrl;
@synthesize mProduct;
@synthesize mGetItem;

#pragma mark - Initialization

- (id) init {
    NSLog(@"PerpleBilling, Billing initializing.");

    if (self = [super init]) {

        self.mPurchases = [NSMutableDictionary dictionary];
        self.mTransactions = [NSMutableDictionary dictionary];
        self.mIncompletePurchases = [NSMutableArray array];
        self.mGetItem = [NSMutableDictionary dictionary];

        if ([SKPaymentQueue canMakePayments] == NO) {
            self.mCanMakePayments = NO;
        }
        else {
            self.mCanMakePayments = YES;
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }

    } else {
        NSLog(@"PerpleBilling, Billing initializing fail.");
    }

    return self;
}

- (void) dealloc {
    self.mPurchases = nil;
    self.mTransactions = nil;
    self.mIncompletePurchases = nil;
    self.mProduct = nil;
    self.mCheckReceiptServerUrl = nil;
    self.mGetItem = nil;
    self.mFailCallback = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) startSetupWithCheckReceiptServerUrl:(NSString *)checkReceiptServerUrl
                                  completion:(PerpleSDKCallback)callback {
    self.mCheckReceiptServerUrl = checkReceiptServerUrl;
    if (self.mCanMakePayments) {
        callback(@"purchase", [self getIncomplePurchases]);
    } else {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_SETUP
                                               msg:@"Billing is not set."]);
    }
}

- (void) purchaseWithSku:(NSString *)sku
                 payload:(NSString *)payload
              completion:(PerpleSDKCallback)callback {
    if (self.mCanMakePayments) {
        [self.mPurchases setObject:@{@"payload":payload,
                                     @"callback":callback}
                            forKey:sku];
        self.mFailCallback = callback;
        self.mIsRequestPay = YES;
        NSSet *productIdentifiers = [NSSet setWithObject:sku];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        [request setDelegate:self];
        [request start];
    } else {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_SETUP
                                               msg:@"Billing is not set."]);
    }
}

- (void) subscriptionWithSku:(NSString *)sku
                     payload:(NSString *)payload
                  completion:(PerpleSDKCallback)callback {
    [self purchaseWithSku:sku
                  payload:payload
               completion:callback];
}

- (void) finishPurchaseTransaction:(NSString *)orderId {
    if (self.mCanMakePayments) {
        SKPaymentTransaction *transaction = [self.mTransactions objectForKey:orderId];
        if (transaction != nil) {
            [self.mTransactions removeObjectForKey:orderId];

            if (self.mPurchases != nil) {
                NSString *sku = transaction.payment.productIdentifier;
                [self.mPurchases removeObjectForKey:sku];
            }

            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

- (void) billingGetItemList:(NSString *)skuList
                 completion:(PerpleSDKCallback)callback
{
    if (self.mCanMakePayments) {
        self.mIsRequestPay = NO;
        [self.mGetItem setObject:@{@"callback":callback}
                          forKey:@"callback"];

        self.mFailCallback = callback;

        NSArray* retSkuList = [skuList componentsSeparatedByString:@";"];

        NSSet *productIdentifiers = [NSSet setWithArray:retSkuList];

        if( [PerpleSDK isDebug] )
        {
            NSLog(@"billingGetItemList : %@", [productIdentifiers allObjects] );
        }

        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        [request setDelegate:self];
        [request start];

    } else {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_SETUP
                                              msg:@"Billing is not set."]);
    }
}

#pragma mark - SKProductsRequestDelegate implement
// SKProductsRequestDelegate - fail
- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"PerpleBilling, request failed : %@", [error description]);

    if (self.mFailCallback != nil) {
        self.mFailCallback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_REQUEST_FAIL
                                                        msg:[error description]]);
        self.mFailCallback = nil;
    }
}

// SKProductsRequestDelegate - success
- (void) productsRequest:(SKProductsRequest *)request
      didReceiveResponse:(SKProductsResponse *)response {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleBilling, productRequest:didReceiveResponse:");
        NSLog(@"PerpleBilling, mIsRequestPay:%d", self.mIsRequestPay);
    }

    //결제 일때
    if( self.mIsRequestPay == YES )
    {
        for (SKProduct *p in response.products) {
            if (p != nil) {
                if ([PerpleSDK isDebug]) {
                    NSLog(@"PerpleBilling, Requested Payment Product, id:%@, title:%@, desc:%@, price:%@", p.productIdentifier, p.localizedTitle, p.localizedDescription, p.price);
                }

                SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:p];
                [self.mProduct setObject:p forKey:payment.productIdentifier];
                NSDictionary *dict = [mPurchases objectForKey:payment.productIdentifier];
                payment.applicationUsername = dict[@"payload"];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
                break;
            }
        }

    #if !__has_feature(objc_arc)
        [request release];
    #endif

        for (NSString *pId in response.invalidProductIdentifiers) {
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleBilling, Invalid Product, id: %@", pId);
            }

            NSDictionary *dict = [mPurchases objectForKey:pId];
            PerpleSDKCallback callback = dict[@"callback"];
            if (callback != nil) {
                callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_INVALIDPRODUCT
                                                      msg:[NSString stringWithFormat:@"Invalid Product ID:%@", pId]]);
            }
        }
    }
    else
    {
        NSMutableArray *outArray = [NSMutableArray array];
        for (SKProduct *p in response.products)
        {
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleBilling, Requested item list, id:%@, title:%@, desc:%@, price:%@, price_currency_code:%@", p.productIdentifier, p.localizedTitle, p.localizedDescription, p.price, p.priceLocale);
            }

            [outArray addObject:@{@"productId":p.productIdentifier,
                                  @"description":p.localizedDescription,
                                  @"title":p.localizedTitle,
                                  @"price":[NSString stringWithFormat:@"%@%@", [p.priceLocale currencySymbol], p.price],
                                  @"price_currency_code":[p.priceLocale currencyCode],
                                  }];
            /*
            NSString* ret = [NSString stringWithFormat:@"SkuDetails:{\"productId\":\"%@\",\"description\":\"%@\",\"title\":\"%@\",\"price\":\"%@\",\"price_currency_code\":\"%@\"}",
                             p.productIdentifier,
                             p.localizedDescription,
                             p.localizedTitle,
                             [NSString stringWithFormat:@"%@%@", [p.priceLocale currencySymbol], p.price],
                             [p.priceLocale currencyCode] ];
             */
        }

        NSDictionary *getItem = [self.mGetItem objectForKey:@"callback"];
        PerpleSDKCallback callback = getItem[@"callback"];
        if (callback != nil) {
            callback(@"success", [PerpleSDK getJSONStringFromNSArray:outArray]);
        }
    }
}

#pragma mark - SKPaymentTransactionObserver

// SKPaymentTransactionObserver
- (void) paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *t in transactions) {
        // 트랜잭션을 종료하는 것은
        // SKPaymentTransactionStatePurchased
        // SKPaymentTransactionStateFailed
        // SKPaymentTransactionStateRestored
        // 에서만 하면 된다.
        switch (t.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                [self showTransactionAsInProgress:t deferred:NO];
                break;
            case SKPaymentTransactionStateDeferred:
                [self showTransactionAsInProgress:t deferred:YES];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:t];
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:t];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:t];
                break;
            default:
                if ([PerpleSDK isDebug]) {
                    NSLog(@"PerpleBilling, Unexpected transaction state %@", @(t.transactionState));
                }
                break;
        }
    }
}

#pragma mark - Private methods

//----------------------------------------------------------------------------------------------------

- (void) showTransactionAsInProgress:(SKPaymentTransaction *)transaction deferred:(BOOL)isDeferred {
    if ([PerpleSDK isDebug]) {
        if (!isDeferred) {
            NSLog(@"PerpleBilling, SKPaymentTransactionStatePurchasing");
        } else {
            NSLog(@"PerpleBilling, SKPaymentTransactionStateDeferred");
        }
        NSLog(@"PerpleBilling, transaction id:%@, data:%@", transaction.transactionIdentifier, transaction.transactionDate);
    }
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleBilling, SKPaymentTransactionStateFailed");
        NSLog(@"PerpleBilling, transaction id:%@, data:%@", transaction.transactionIdentifier, transaction.transactionDate);
        NSLog(@"PerpleBilling, error code:%@, msg:%@", @(transaction.error.code), transaction.error.localizedDescription);
    }

    NSString *sku = transaction.payment.productIdentifier;
    NSDictionary *purchase = [self.mPurchases objectForKey:sku];
    PerpleSDKCallback callback = purchase[@"callback"];

    if (callback != nil) {
        if (transaction.error.code != SKErrorPaymentCancelled) {
            callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_PURCHASEFINISH
                                              subcode:[@(transaction.error.code) stringValue]
                                                  msg:transaction.error.localizedDescription]);
        }
        else {
            callback(@"cancel", @"");
        }
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self.mPurchases removeObjectForKey:sku];
}

- (void) completeTransaction:(SKPaymentTransaction *)transaction {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleBilling, SKPaymentTransactionStatePurchased");
        NSLog(@"PerpleBilling, transaction id:%@, data:%@", transaction.transactionIdentifier, transaction.transactionDate);
    }

    NSString *transactionId = transaction.transactionIdentifier;
    NSString *sku = transaction.payment.productIdentifier;
    NSString *applicationName = transaction.payment.applicationUsername;
    NSString *payload = applicationName ? applicationName : @"";

    NSData *receiptData;
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle respondsToSelector:@selector(appStoreReceiptURL)]) {
        NSURL *receiptURL = [bundle performSelector:@selector(appStoreReceiptURL)];
        receiptData= [NSData dataWithContentsOfURL:receiptURL];
    }
    else {
        receiptData = transaction.transactionReceipt;
    }

    if (self.mCheckReceiptServerUrl == nil) {
        NSDictionary *purchse = @{@"orderId":transactionId,
                                  @"payload":payload,
                                  @"receipt":receiptData,
                                  @"transaction":transaction};

        [self.mIncompletePurchases addObject:purchse];
        return;
    }

    NSDictionary *checkReceiptResult = [PerpleSDK getNSDictionaryFromJSONString:[self checkReceiptWithUrl:self.mCheckReceiptServerUrl
                                                                                                  receipt:receiptData
                                                                                                  payload:payload]];

    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleBilling, checkReceiptResult - %@", checkReceiptResult);
    }

    NSNumber *retcode = checkReceiptResult[@"retcode"];
    NSString *subcode = checkReceiptResult[@"subcode"];
    NSString *msg = checkReceiptResult[@"message"];

    NSDictionary *purchase = [self.mPurchases objectForKey:sku];
    PerpleSDKCallback callback = purchase[@"callback"];

    if ([retcode isEqualToNumber:@0]) {
        // 영수증 검증에 성공한 경우,
        // 성공 처리하여 게임 서버를 통해 아이템을 지급한 후 트랙잭션을 닫는다.
        // 성공 콜백(PerpleSDK) -> 게임 서버에 아이템 지급 요청(클라이언트) -> 아이템 지급 후 결과 리턴(게임 서버) ->
        // 결과가 성공일 경우 PerpleSDK 의 billingConfirm 호출(클라이언트) -> 트랙잭션 종료 처리(PerplesdK, finishPurchaseTransaction)

        SKProduct *product = [self.mProduct objectForKey:sku];
        [[PerpleSDK sharedInstance] payment:transaction product:product];

        if (callback != nil) {
            [self.mTransactions setObject:transaction forKey:transactionId];
            NSDictionary *purchse = @{@"orderId":transactionId,
                                      @"payload":payload};
            callback(@"success", [PerpleSDK getJSONStringFromNSDictionary:purchse]);
        }

        return;
    }

    if (![retcode isEqualToNumber:@1]) {
        // 영수증 검증에 실패(영수증 서버에서 검증하였으나 무효한 영수증이라고 리턴하는 경우)한 경우,
        // 트랜잭션을 바로 닫고 실패 처리한다.
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        subcode = [retcode stringValue];
    }

    // 통신 오류 등으로 영수증 정보를 가져오지 못했거나 영수증 검증을 시행하지 못한 경우,
    // 트랜잭션을 닫지 않고 실패처리만 한다. 앱을 재시작하면 트랙잭션이 재개된다.

    if (callback != nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_CHECKRECEIPT
                                          subcode:(subcode ? subcode : @"")
                                              msg:msg]);
    }
}

- (void) restoreTransaction:(SKPaymentTransaction *)transaction {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleBilling, SKPaymentTransactionStateRestored");
        NSLog(@"PerpleBilling, transaction id:%@, data:%@", transaction.transactionIdentifier, transaction.transactionDate);
    }

    // Apple 이 호스팅하는 다운로드 컨텐츠 등을 구매한 경우에 OS 재설치나 새로운 기기로의 이전 등의 경우 이전 구매 컨텐츠를 재구매하지 않고 복구 요청을 하면 이 트랙잭션이 발생한다.
    // 게임 서버에서 아이템을 지급하는 일반적인 게임의 아이템 구매의 경우에는 이 트랜잭션을 사용하지 않으므로 별다른 처리없이 그대로 트랜잭션을 닫는다.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//----------------------------------------------------------------------------------------------------

- (NSString *) getIncomplePurchases {

    NSMutableArray *array = [NSMutableArray array];

    for (NSDictionary *purchase in self.mIncompletePurchases) {

        NSString *transactionId = purchase[@"orderId"];
        NSString *payload = purchase[@"payload"];
        NSData *receiptData = purchase[@"receipt"];
        SKPaymentTransaction *transaction = purchase[@"transaction"];

        NSDictionary *checkReceiptResult = [PerpleSDK getNSDictionaryFromJSONString:[self checkReceiptWithUrl:self.mCheckReceiptServerUrl
                                                                                                      receipt:receiptData
                                                                                                      payload:payload]];
        NSNumber *retcode = checkReceiptResult[@"retcode"];

        if ([retcode isEqualToNumber:@0]) {

            // 영수증 검증에 성공한 경우,
            // 성공 처리하여 게임 서버를 통해 아이템을 지급한 후 트랙잭션을 닫는다.
            // 성공 콜백(PerpleSDK) -> 게임 서버에 아이템 지급 요청(클라이언트) -> 아이템 지급 후 결과 리턴(게임 서버) ->
            // 결과가 성공일 경우 PerpleSDK 의 billingConfirm 호출(클라이언트) -> 트랙잭션 종료 처리(PerplesdK, finishPurchaseTransaction)
            [self.mTransactions setObject:transaction forKey:transactionId];
            [array addObject:@{@"orderId":transactionId,
                               @"payload":payload}];

        } else if (![retcode isEqualToNumber:@1]) {

            // 영수증 검증에 실패(영수증 서버에서 검증하였으나 무효한 영수증이라고 리턴하는 경우)한 경우,
            // 트랜잭션을 닫아준다.
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }

    [self.mIncompletePurchases removeAllObjects];

    return [PerpleSDK getJSONStringFromNSArray:array];
}

// 불완전 처리된 구매에 대한 처리 로직이 지나치게 복잡하여 새로 작성,
// 테스트 후 이상 없다면 기존 처리(getIncomplePurchases, mIncompletePurchases) 제거하고,
// getIncomplePurchases 를 본 함수로 교체할 것
/*
- (NSString *) getIncomplePurchases {

    NSMutableArray *array = [NSMutableArray array];

    for (SKPaymentTransaction *transaction in [SKPaymentQueue defaultQueue].transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {

            NSString *transactionId = transaction.transactionIdentifier;
            NSString *payload = transaction.payment.applicationUsername ? transaction.payment.applicationUsername : @"";

            NSData *receiptData;
            NSBundle *bundle = [NSBundle mainBundle];
            if ([bundle respondsToSelector:@selector(appStoreReceiptURL)]) {
                NSURL *receiptURL = [bundle performSelector:@selector(appStoreReceiptURL)];
                receiptData= [NSData dataWithContentsOfURL:receiptURL];
            }
            else {
                receiptData = transaction.transactionReceipt;
            }

            NSDictionary *checkReceiptResult = [PerpleSDK getNSDictionaryFromJSONString:[self checkReceiptWithUrl:self.mCheckReceiptServerUrl
                                                                                                          receipt:receiptData
                                                                                                          payload:payload]];
            NSNumber *retcode = checkReceiptResult[@"retcode"];
            if ([retcode isEqualToNumber:@0]) {

                // 영수증 검증에 성공한 경우,
                // 성공 처리하여 게임 서버를 통해 아이템을 지급한 후 트랙잭션을 닫는다.
                // 성공 콜백(PerpleSDK) -> 게임 서버에 아이템 지급 요청(클라이언트) -> 아이템 지급 후 결과 리턴(게임 서버) ->
                // 결과가 성공일 경우 PerpleSDK 의 billingConfirm 호출(클라이언트) -> 트랙잭션 종료 처리(PerplesdK, finishPurchaseTransaction)
                [self.mTransactions setObject:transaction forKey:transactionId];
                [array addObject:@{@"orderId":transactionId,
                                   @"payload":payload}];

            } else if (![retcode isEqualToNumber:@1]) {

                // 영수증 검증에 실패(영수증 서버에서 검증하였으나 무효한 영수증이라고 리턴하는 경우)한 경우,
                // 트랜잭션을 닫아준다.
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
        }
    }

    return [PerpleSDK getJSONStringFromNSArray:array];
}
*/

- (NSString *) checkReceiptWithUrl:(NSString *)url receipt:(NSData *)receipt payload:(NSString*)payload {

    if (receipt == nil) {
        return [PerpleSDK getJSONStringFromNSDictionary:@{@"retcode":@1,
                                                          @"subcode":@"0",
                                                          @"message":@"Receipt data is not received from app store's receipt server."}];
    }

    NSString *result = nil;
    NSError *error = nil;

    NSString *jsonObjectString = [receipt base64EncodedStringWithOptions:0];
    NSDictionary *contentBody = @{@"platform":@"apple",
                                  @"receipt":jsonObjectString,
                                  @"payload":payload};

    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleBilling, checkReceipt request - %@", contentBody);
    }

    [PerpleSDK requestHttpPostWithUrl:url
                          contentBody:contentBody
                               result:&result
                                error:&error];


    if (error != nil) {
        return [PerpleSDK getJSONStringFromNSDictionary:@{@"retcode":@1,
                                                          @"subcode":[@(error.code) stringValue],
                                                          @"message":error.localizedDescription}];
    }

    NSDictionary *dict = [PerpleSDK getNSDictionaryFromJSONString:result];
    NSDictionary *status = dict[@"status"];

    if (status == nil) {
        return [PerpleSDK getJSONStringFromNSDictionary:@{@"retcode":@1,
                                                          @"subcode":@"0",
                                                          @"message":@"No status key in response data."}];
    }

    return [PerpleSDK getJSONStringFromNSDictionary:status];
}

//----------------------------------------------------------------------------------------------------

@end
