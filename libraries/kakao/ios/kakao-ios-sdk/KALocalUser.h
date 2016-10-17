//
//  KALocalUser.h
//  kakao-ios-sdk
//
//  Created by Insoo Kim on 4/22/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@class KALinkMessageRequest;

typedef void(^KACompletionResponseBlock)(NSDictionary *response, NSError *error);
typedef void(^KACompletionSuccessBlock)(BOOL success, NSError *error);

@interface KALocalUser : NSObject

+ (KALocalUser*)localUser;

- (void)loadLocalUserWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadFriendsWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)uploadImageToServer:(UIImage *)willUploadImage completionHandler:(KACompletionResponseBlock)completionHandler;

- (void)sendLinkMessageWithReceiver:(NSString*)receiver
                          templateId:(NSString*)templateId
                            metaInfo:(NSDictionary*)metaInfo
                   completionHandler:(KACompletionSuccessBlock)completionHandler;

- (void)unregisterWithCompletionHandler:(KACompletionSuccessBlock)completionHandler;

- (void)logoutWithCompletionHandler:(KACompletionSuccessBlock)completionHandler;

@end

@interface KALocalUser(Push)

- (BOOL)hasValidDeviceToken;

- (void)registerDeviceTokenWithCompletionHandler:(KACompletionResponseBlock) completionHandler;

- (void)getPushInfoWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)setPushAlert:(BOOL)pushAlert withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)sendPushToReceiverId:(NSString *)receiverId
                     message:(NSString *)message
                 customField:(NSDictionary *)customField
       withCompletionHandler:(KACompletionResponseBlock)completionHandler;

@end

@interface KALocalUser(Invitation)

- (void)loadInvitationEventWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadInvitationStatesWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadInvitationSenderWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

@end

@interface KALocalUser(Deprecated)

/* @Deprecated
 * 1. Link 2.0 사용을 막기 위해 sendLinkMessageWithRequest deprecated
 * 2. sendLinkMessageWithRequest 메소드는 Link2.0, Link3.0에 대한 분기 및 이미지 업로드 등 너무 많은 처리를 담당하고 있음.
 * 3. Android에서 사용하는 메소드와 일치 시키기 위하여 sendLinkMessageWithReceiver or sendInviteLinkMessageWithReceiver를 사용
 */
- (void)sendLinkMessageWithRequest:(KALinkMessageRequest *)request
                 completionHandler:(KACompletionSuccessBlock)completionHandler
__attribute((deprecated("[KAKAO] You must use sendLinkMessageWithReceiver or sendInviteLinkMessageWithReceiver instead of sendLinkMessageWithRequest.")));

@end
