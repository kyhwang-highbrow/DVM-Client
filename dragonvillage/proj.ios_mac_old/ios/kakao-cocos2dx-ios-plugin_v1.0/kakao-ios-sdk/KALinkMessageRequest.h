//
//  KALinkMessageRequest.h
//  kakao-ios-sdk-test
//
//  Created by Insoo Kim on 4/30/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute((deprecated("[KAKAO] Do not use this KALinkMessageRequest class, You must use sendLinkMessageWithReceiver or sendInviteLinkMessageWithReceiver in KALocalUser ")))
@interface KALinkMessageRequest : NSObject {
@private 
    NSString *_receiverID;
    NSString *_chatID;
    NSString *_message;
    NSString *_executeURLString;
    NSString *_templateID;
    NSDictionary *_metaInfo;
}
@property (nonatomic, readonly) NSString *receiverID;
@property (nonatomic, readonly) NSString *chatID;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *executeURLString;
@property (nonatomic, readonly) NSString *templateID;
@property (nonatomic, readonly) NSDictionary *metaInfo;

// Deprecated
+ (KALinkMessageRequest *)requestWithReceiverID:(NSString *)receiverID
                                        message:(NSString *)message
                               executeURLString:(NSString *)executeURLString;

+ (KALinkMessageRequest *)requestWithReceiverID:(NSString *)receiverID
                                     templateID:(NSString *)templateID
                                       metaInfo:(NSDictionary *)metaInfo;

+ (KALinkMessageRequest *)requestWithChatID:(NSString *)chatID
                                 templateID:(NSString *)templateID
                                   metaInfo:(NSDictionary *)metaInfo;

+ (KALinkMessageRequest *)requestWithReceiverID:(NSString *)receiverID
                                     templateID:(NSString *)templateID
                                       metaInfo:(NSDictionary *)metaInfo
                                excuteURLString:(NSString*)excuteURLString;

@end
