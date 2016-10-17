//
//  KakaoStringKey.m
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 9. 14..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import "KakaoStringKey.h"

@implementation KakaoAction

@synthesize Init;
@synthesize Authorized;
@synthesize Login;
@synthesize LocalUser;
@synthesize Friends;
@synthesize SendLinkMessage;
@synthesize ShowMessageBlockDialog;
@synthesize PostToKakaoStory;
@synthesize Logout;
@synthesize Unregister;
@synthesize Token;
@synthesize ShowAlertMessage;

@synthesize InvitationEvent;
@synthesize InvitationStates;
@synthesize InvitationHost;

@synthesize LoadGameInfo;
@synthesize LoadGameUserInfo;
@synthesize UpdateUser;
@synthesize UseHeart;
@synthesize UpdateResult;
@synthesize UpdateMultipleResults;

@synthesize LoadLeaderboard;
@synthesize BlockMessage;
@synthesize SendGameMessage;
@synthesize SendInviteGameMessage;
@synthesize SendLinkGameMessage;
@synthesize SendInviteLinkGameMessage;
@synthesize LoadGameFriends;
@synthesize LoadGameMessages;
@synthesize AcceptGameMessage;
@synthesize AcceptAllGameMessages;
@synthesize DeleteUser;


+ (KakaoAction*)sharedInstance {
    static KakaoAction *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[KakaoAction alloc] init];
	});
	return sharedInstance;
}

-(id)init {
    self = [super init];
    if( self!=nil ) {
        Init = [[NSString alloc] initWithString:@"Init"];
        Authorized = [[NSString alloc] initWithString:@"Authorized"];
        Login = [[NSString alloc] initWithString:@"Login"];
        LocalUser = [[NSString alloc] initWithString:@"LocalUser"];
        Friends = [[NSString alloc] initWithString:@"Friends"];
        SendLinkMessage = [[NSString alloc] initWithString:@"SendLinkMessage"];
        ShowMessageBlockDialog = [[NSString alloc] initWithString:@"ShowMessageBlockDialog"];
        PostToKakaoStory = [[NSString alloc] initWithString:@"PostToKakaoStory"];
        Logout = [[NSString alloc] initWithString:@"Logout"];
        Unregister = [[NSString alloc] initWithString:@"Unregister"];
        Token = [[NSString alloc] initWithString:@"Token"];
        ShowAlertMessage = [[NSString alloc] initWithString:@"ShowAlertMessage"];

        InvitationEvent = [[NSString alloc] initWithString:@"InvitationEvent"];
        InvitationStates = [[NSString alloc] initWithString:@"InvitationStates"];
        InvitationHost = [[NSString alloc] initWithString:@"InvitationHost"];

        LoadGameInfo = [[NSString alloc] initWithString:@"LoadGameInfo"];
        LoadGameUserInfo = [[NSString alloc] initWithString:@"LoadGameUserInfo"];
        UpdateUser = [[NSString alloc] initWithString:@"UpdateUser"];
        UseHeart = [[NSString alloc] initWithString:@"UseHeart"];
        UpdateResult = [[NSString alloc] initWithString:@"UpdateResult"];
        UpdateMultipleResults = [[NSString alloc] initWithString:@"UpdateMultipleResults"];
        
        LoadLeaderboard = [[NSString alloc] initWithString:@"LoadLeaderboard"];
        BlockMessage = [[NSString alloc] initWithString:@"BlockMessage"];
        SendGameMessage = [[NSString alloc] initWithString:@"SendGameMessage"];
        SendInviteGameMessage = [[NSString alloc] initWithString:@"SendInviteGameMessage"];
        SendLinkGameMessage = [[NSString alloc] initWithString:@"SendLinkGameMessage"];
        SendInviteLinkGameMessage = [[NSString alloc] initWithString:@"SendInviteLinkGameMessage"];
        LoadGameFriends = [[NSString alloc] initWithString:@"LoadGameFriends"];
        LoadGameMessages = [[NSString alloc] initWithString:@"LoadGameMessages"];
        AcceptGameMessage = [[NSString alloc] initWithString:@"AcceptGameMessage"];
        AcceptAllGameMessages = [[NSString alloc] initWithString:@"AcceptAllGameMessages"];
        DeleteUser = [[NSString alloc] initWithString:@"DeleteUser"];
    }
    return self;
}
-(void)dealloc {
    [Init release];
    [Authorized release];
    [Login release];
    [LocalUser release];
    [Friends release];
    [SendLinkMessage release];
    [ShowMessageBlockDialog release];
    [PostToKakaoStory release];
    [Logout release];
    [Unregister release];
    [Token release];
    [ShowAlertMessage release];
    
    [InvitationEvent release];
    [InvitationStates release];
	[InvitationHost release];

    [LoadGameInfo release];
    [LoadGameUserInfo release];
	[UpdateUser release];
	[UseHeart release];
	[UpdateResult release];
	[UpdateMultipleResults release];

	[LoadLeaderboard release];
	[BlockMessage release];
	[SendGameMessage release];
	[SendInviteGameMessage release];
    [SendLinkGameMessage release];
    [SendInviteLinkGameMessage release];
	[LoadGameFriends release];
	[LoadGameMessages release];
	[AcceptGameMessage release];
	[AcceptAllGameMessages release];
	[DeleteUser release];

    [super dealloc];
}


@end

@implementation KakaoString

@synthesize action;
@synthesize authorized;
@synthesize clientId;
@synthesize secretKey;
@synthesize message;
@synthesize receiverId;
@synthesize executeUrl;
@synthesize templateId;
@synthesize imageURL;
@synthesize metaInfo;
@synthesize result;
@synthesize error;
@synthesize access_token;
@synthesize refresh_token;
@synthesize status;

+ (KakaoString*)sharedInstance {
    static KakaoString *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[KakaoString alloc] init];
	});
	return sharedInstance;
}

-(id)init {
    self = [super init];
    if( self!=nil ) {
        action = [[NSString alloc] initWithString:@"action"];
        authorized = [[NSString alloc] initWithString:@"authorized"];
        clientId = [[NSString alloc] initWithString:@"clientId"];
        secretKey = [[NSString alloc] initWithString:@"secretKey"];
        message = [[NSString alloc] initWithString:@"message"];
        receiverId = [[NSString alloc] initWithString:@"receiverId"];
        executeUrl = [[NSString alloc] initWithString:@"executeUrl"];
        templateId = [[NSString alloc] initWithString:@"templateId"];
        imageURL = [[NSString alloc] initWithString:@"imageURL"];
        metaInfo = [[NSString alloc] initWithString:@"metaInfo"];
        result = [[NSString alloc] initWithString:@"result"];
        error = [[NSString alloc] initWithString:@"error"];
        access_token = [[NSString alloc] initWithString:@"access_token"];
        refresh_token = [[NSString alloc] initWithString:@"refresh_token"];
        status = [[NSString alloc] initWithString:@"status"];
        
    }
    return self;
}

-(void)dealloc {
    [action release];
    [authorized release];
    [clientId release];
    [secretKey release];
    [message release];
    [receiverId release];
    [executeUrl release];
    [templateId release];
    [imageURL release];
    [metaInfo release];
    [result release];
    [error release];
    [access_token release];
    [refresh_token release];
    [status release];
    
    [super dealloc];
}

@end

@implementation KakaoLeaderboardString

@synthesize receiverId;
@synthesize templateId;
@synthesize additionalHeart;
@synthesize currentHeart;
@synthesize publicData;
@synthesize privateData;

@synthesize useHeart;

@synthesize leaderboardKey;
@synthesize score;
@synthesize exp;

@synthesize idArray;
@synthesize multipleLeaderboards;
@synthesize talkMessage;
@synthesize gameMessage;
@synthesize heart;
@synthesize data;
@synthesize messageId;
@synthesize block;

+ (KakaoLeaderboardString*)sharedInstance {
    static KakaoLeaderboardString *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[KakaoLeaderboardString alloc] init];
	});
	return sharedInstance;
}

-(id)init {
    self = [super init];
    if( self!=nil ) {
        block = [[NSString alloc] initWithString:@"block"];
        additionalHeart = [[NSString alloc] initWithString:@"additionalHeart"];
        currentHeart = [[NSString alloc] initWithString:@"currentHeart"];
        publicData = [[NSString alloc] initWithString:@"public_data"];
        privateData = [[NSString alloc] initWithString:@"private_data"];
        
        useHeart = [[NSString alloc] initWithString:@"useHeart"];
        
        leaderboardKey = [[NSString alloc] initWithString:@"leaderboardKey"];
        score = [[NSString alloc] initWithString:@"score"];
        exp = [[NSString alloc] initWithString:@"exp"];
        
        idArray = [[NSString alloc] initWithString:@"idArray"];
        multipleLeaderboards = [[NSString alloc] initWithString:@"multipleLeaderboards"];
        talkMessage = [[NSString alloc] initWithString:@"talkMessage"];
        gameMessage = [[NSString alloc] initWithString:@"gameMessage"];
        
        heart = [[NSString alloc] initWithString:@"heart"];
        data = [[NSString alloc] initWithString:@"data"];
        
        messageId = [[NSString alloc]initWithString:@"message_id"];
        
        receiverId = [[NSString alloc]initWithString:@"receiver_id"];
        templateId = [[NSString alloc]initWithString:@"template_id"];
    }
    return self;
}

-(void)dealloc {
    [block release];
    [additionalHeart release];
    [currentHeart release];
    [publicData release];
    [privateData release];
    
    [useHeart release];
    
    [leaderboardKey release];
    [score release];
    [exp release];
    
    [idArray release];
    [multipleLeaderboards release];
    [talkMessage release];
    [gameMessage release];
    
    [heart release];
    [data release];
    [messageId release];
    [receiverId release];
    
    [super dealloc];
}

@end