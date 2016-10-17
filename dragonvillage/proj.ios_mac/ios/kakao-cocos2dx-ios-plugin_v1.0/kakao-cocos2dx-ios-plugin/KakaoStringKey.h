//
//  KakaoStringKey.h
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 9. 14..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KakaoAction : NSObject {
    NSString* Init;
    NSString* Authorized;
    NSString* Login;
    NSString* LocalUser;
    NSString* Friends;
    NSString* SendLinkMessage;
    NSString* ShowMessageBlockDialog;
    NSString* PostToKakaoStory;
    NSString* Logout;
    NSString* Unregister;
    NSString* Token;
    NSString* ShowAlertMessage;
    
    // Invitation Tracking
    NSString* InvitationEvent;
    NSString* InvitationStates;
    NSString* InvitationHost;

    // for leaderboard
    NSString* LoadGameInfo;
	NSString* LoadGameUserInfo;
	NSString* UpdateUser;
	NSString* UseHeart;
	NSString* UpdateResult;
	NSString* UpdateMultipleResults;

	NSString* LoadLeaderboard;
	NSString* BlockMessage;
	NSString* SendGameMessage;
	NSString* SendInviteGameMessage;
    NSString* SendLinkGameMessage;
    NSString* SendInviteLinkGameMessage;
	NSString* LoadGameFriends;
	NSString* LoadGameMessages;
	NSString* AcceptGameMessage;
	NSString* AcceptAllGameMessages;
	NSString* DeleteUser;

}

@property (nonatomic,readonly) NSString* Init;
@property (nonatomic,readonly) NSString* Authorized;
@property (nonatomic,readonly) NSString* Login;
@property (nonatomic,readonly) NSString* LocalUser;
@property (nonatomic,readonly) NSString* Friends;
@property (nonatomic,readonly) NSString* SendLinkMessage;
@property (nonatomic,readonly) NSString* ShowMessageBlockDialog;
@property (nonatomic,readonly) NSString* PostToKakaoStory;
@property (nonatomic,readonly) NSString* Logout;
@property (nonatomic,readonly) NSString* Unregister;
@property (nonatomic,readonly) NSString* Token;
@property (nonatomic,readonly) NSString* ShowAlertMessage;

@property (nonatomic,readonly) NSString* InvitationEvent;
@property (nonatomic,readonly) NSString* InvitationStates;
@property (nonatomic,readonly) NSString* InvitationHost;

@property (nonatomic,readonly) NSString* LoadGameInfo;
@property (nonatomic,readonly) NSString* LoadGameUserInfo;
@property (nonatomic,readonly) NSString* UpdateUser;
@property (nonatomic,readonly) NSString* UseHeart;
@property (nonatomic,readonly) NSString* UpdateResult;
@property (nonatomic,readonly) NSString* UpdateMultipleResults;

@property (nonatomic,readonly) NSString* LoadLeaderboard;
@property (nonatomic,readonly) NSString* BlockMessage;
@property (nonatomic,readonly) NSString* SendGameMessage;
@property (nonatomic,readonly) NSString* SendInviteGameMessage;
@property (nonatomic,readonly) NSString* SendLinkGameMessage;
@property (nonatomic,readonly) NSString* SendInviteLinkGameMessage;
@property (nonatomic,readonly) NSString* LoadGameFriends;
@property (nonatomic,readonly) NSString* LoadGameMessages;
@property (nonatomic,readonly) NSString* AcceptGameMessage;
@property (nonatomic,readonly) NSString* AcceptAllGameMessages;
@property (nonatomic,readonly) NSString* DeleteUser;

+(KakaoAction*)sharedInstance;

@end

@interface KakaoString : NSObject {
    NSString* action;
    NSString* authorized;
    NSString* clientId;
    NSString* secretKey;
    NSString* message;
    NSString* receiverId;
    NSString* executeUrl;
    NSString* templateId;
    NSString* imageURL;
    NSString* metaInfo;
    NSString* result;
    NSString* error;
    NSString* access_token;
    NSString* refresh_token;
    NSString* status;
}

@property (nonatomic,readonly) NSString* action;
@property (nonatomic,readonly) NSString* authorized;
@property (nonatomic,readonly) NSString* clientId;
@property (nonatomic,readonly) NSString* secretKey;
@property (nonatomic,readonly) NSString* message;
@property (nonatomic,readonly) NSString* receiverId;
@property (nonatomic,readonly) NSString* executeUrl;
@property (nonatomic,readonly) NSString* templateId;
@property (nonatomic,readonly) NSString* imageURL;
@property (nonatomic,readonly) NSString* metaInfo;
@property (nonatomic,readonly) NSString* result;
@property (nonatomic,readonly) NSString* error;
@property (nonatomic,readonly) NSString* access_token;
@property (nonatomic,readonly) NSString* refresh_token;
@property (nonatomic,readonly) NSString* status;

+(KakaoString*)sharedInstance;

@end


@interface KakaoLeaderboardString : NSObject {
    NSString* additionalHeart;
    NSString* currentHeart;
    NSString* publicData;
    NSString* privateData;
    
    NSString* useHeart;
    
    NSString* leaderboardKey;
    NSString* score;
    NSString* exp;
    NSString* heart;
    
    NSString* idArray;
    NSString* messageId;
    NSString* multipleLeaderboards;
    NSString* talkMessage;
    NSString* gameMessage;
    NSString* data;
    NSString* receiverId;
    NSString* templateId;
    NSString* block;
}

@property (nonatomic,readonly) NSString* block;
@property (nonatomic,readonly) NSString* receiverId;
@property (nonatomic,readonly) NSString* templateId;
@property (nonatomic,readonly) NSString* additionalHeart;
@property (nonatomic,readonly) NSString* currentHeart;
@property (nonatomic,readonly) NSString* publicData;
@property (nonatomic,readonly) NSString* privateData;

@property (nonatomic,readonly) NSString* useHeart;
@property (nonatomic,readonly) NSString* heart;

@property (nonatomic,readonly) NSString* leaderboardKey;
@property (nonatomic,readonly) NSString* score;
@property (nonatomic,readonly) NSString* exp;
@property (nonatomic,readonly) NSString* data;

@property (nonatomic,readonly) NSString* idArray;
@property (nonatomic,readonly) NSString* multipleLeaderboards;
@property (nonatomic,readonly) NSString* talkMessage;
@property (nonatomic,readonly) NSString* gameMessage;
@property (nonatomic,readonly) NSString* messageId;

+(KakaoLeaderboardString*)sharedInstance;

@end

