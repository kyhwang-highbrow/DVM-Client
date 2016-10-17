//
//  KakaoiOS.m
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 9. 14..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import "KakaoiOS.h"
#import "KakaoiOS+Process.h"
#import "KakaoiOS+Leaderboard.h"
#import "KAJSON.h"
#import <Kakao.h>
#import "Kakao/Plugins/KakaoNativeExtension.h"
#import <string>


@implementation KakaoiOS

@synthesize launchURL;
@synthesize isProccessLogin;

+ (KakaoiOS*)sharedInstance {
    static KakaoiOS *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[KakaoiOS alloc] init];
	});
	return sharedInstance;
}

-(id)init {
    self = [super init];
    if( self!=nil ) {
        self.isProccessLogin = NO;
    }
    return self;
}

-(void)registerEvent {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kakaoCocos2dxExtension"];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"kakaoCocos2dxExtension" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSString* param = [[NSUserDefaults standardUserDefaults] objectForKey:@"kakaoCocos2dxExtension"];
    NSLog(@"observed param : %@",param);
    NSDictionary* dict = [param kakaoObjectFromJSONStringWithError:nil];
    if( dict==nil ) {
        NSLog(@"parameter is null");
        return;
    }

    KakaoString* kakaoString = [KakaoString sharedInstance];
    KakaoAction* kakaoAction = [KakaoAction sharedInstance];
    KakaoLeaderboardString* kakaoLeaderboardString = [KakaoLeaderboardString sharedInstance];
    
    NSString* action = [dict objectForKey:kakaoString.action];
    if( action==nil ) {
        NSLog(@"test");
        return;
    }

    NSLog(@"action : %@", action);

    if( [action isEqualToString:kakaoAction.Init]==YES ) {
        NSString* accessToken   = dict[kakaoString.access_token];
        NSString* refreshToken  = dict[kakaoString.refresh_token];
        [self initWithAccessToken:accessToken withRefreshToken:refreshToken];
    }
    else if( [action isEqualToString:kakaoAction.Authorized]==YES ) {
        [self authorized];
    }
    else if( [action isEqualToString:kakaoAction.Login]==YES ) {
        [self login];
    }
    else if( [action isEqualToString:kakaoAction.LocalUser]==YES ) {
        [self localUser];
    }
    else if( [action isEqualToString:kakaoAction.ShowMessageBlockDialog]==YES) {
        [self showMessageBlockDialog];
    }
    else if( [action isEqualToString:kakaoAction.Friends]==YES ) {
        [self friends];
    }
    else if([action isEqualToString:kakaoAction.SendLinkMessage]==YES ) {
        // image message example
        //{"action":"SendLinkMessage", "templateId":"196", "receiverId":"88032923008076785", "imageUrl":"/var/mobile/Applications/18600F28-2DE6-43BC-A998-67793021BEBB/Documents/capture_for_image_message.png", "executeUrl":"itemid=01&count=1", "metaInfo":{"nickname":"A Good Friend"}}
        
        NSString* templateId    = [dict objectForKey:kakaoString.templateId];
        NSString* receiverId    = [dict objectForKey:kakaoString.receiverId];
        NSString* executeUrl    = [dict objectForKey:kakaoString.executeUrl];
        NSDictionary* tags      = [dict objectForKey:kakaoString.metaInfo];
        

        NSString*imageUrl = [dict objectForKey:kakaoString.imageURL];
        UIImage* image = nil;

        NSData * imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        image = [UIImage imageWithData:imageData];

        [self sendLinkMessage:image withTemplateId:templateId withReceiverId:receiverId withTags:tags withExecuteUrl:executeUrl];
        
        [imageData release];
    }
    else if( [action isEqualToString:kakaoAction.PostToKakaoStory]==YES ) {
        // example
        //{"action":"PostToKakaoStory", "message":"This is testing", "imageURL":"/var/mobile/Applications/2294BE8E-DF42-4903-9AC5-58EA38481A67/Documents/capture_for_post_story.png", "executeUrl":"itemid=03"}
        NSString* message    = [dict objectForKey:kakaoString.message];
        NSString* imageUrl  = [dict objectForKey:kakaoString.imageURL];
        NSString* executeUrl = [dict objectForKey:kakaoString.executeUrl];
        
        UIImage* image = nil;
        NSData * imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        image = [UIImage imageWithData:imageData];
        
        [self postStoryWithImage:image withMessage:message withExecuteUrl:executeUrl];

        [imageData release];
    }
    else if( [action isEqualToString:kakaoAction.InvitationEvent]==YES ) {
        [[KALocalUser localUser] loadInvitationEventWithCompletionHandler:^(NSDictionary *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if( error==nil ) {
                    [self sendSuccess:[KakaoAction sharedInstance].InvitationEvent withParam:response];
                }
                else {
                    [self sendError:[KakaoAction sharedInstance].InvitationEvent withError:error];
                }
            });
        }];
    }
    else if( [action isEqualToString:kakaoAction.InvitationStates]==YES ) {
        [[KALocalUser localUser] loadInvitationStatesWithCompletionHandler:^(NSDictionary *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                    [self sendSuccess:[KakaoAction sharedInstance].InvitationStates withParam:response];
                }
                else {
                    [self sendError:[KakaoAction sharedInstance].InvitationStates withError:error];
                }
            });
        }];
    }
    else if( [action isEqualToString:kakaoAction.InvitationHost]==YES ) {
        [[KALocalUser localUser] loadInvitationSenderWithCompletionHandler:^(NSDictionary *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if( error==nil ) {
                    [self sendSuccess:[KakaoAction sharedInstance].InvitationHost withParam:response];
                }
                else {
                    [self sendError:[KakaoAction sharedInstance].InvitationHost withError:error];
                }
            });
        }];
    }
    else if( [action isEqualToString:kakaoAction.Logout]==YES ) {
        [self logout];
    }
    else if( [action isEqualToString:kakaoAction.Unregister]==YES ) {
        [self unregister];
    }
    else if( [action isEqualToString:kakaoAction.ShowAlertMessage]==YES ) {
        NSString* message      = dict[kakaoString.message];
        if( message!=nil )
            [self showAlertMessage:message];
    }
    
    else if( [action isEqualToString:kakaoAction.LoadGameInfo]==YES ) {
        [self loadGameInfo];
    }
    else if( [action isEqualToString:kakaoAction.LoadGameUserInfo]==YES ) {
        [self loadGameUserInfo];
    }
    else if( [action isEqualToString:kakaoAction.UpdateUser]==YES ) {
        NSString* additionalHeart = dict[kakaoLeaderboardString.additionalHeart];
        NSString* currentHeart = dict[kakaoLeaderboardString.currentHeart];
        NSString* publicData = dict[kakaoLeaderboardString.publicData];
        NSString* privateData = dict[kakaoLeaderboardString.privateData];
        
        [self updateUser:additionalHeart!=nil?[additionalHeart intValue]:0 withCurrentHeart:currentHeart!=nil?[currentHeart intValue]:0 withPublicData:publicData withPrivateData:privateData];
    }
    else if( [action isEqualToString:kakaoAction.UseHeart]==YES ) {
        NSString* useHeart = dict[kakaoLeaderboardString.useHeart];
        [self useHeart:useHeart!=nil?[useHeart intValue]:0];
    }
    else if( [action isEqualToString:kakaoAction.UpdateResult]==YES ) {
        NSString* leaderboardKey = dict[kakaoLeaderboardString.leaderboardKey];
        NSString* score = dict[kakaoLeaderboardString.score];
        NSString* exp = dict[kakaoLeaderboardString.exp];
        NSString* publicData = dict[kakaoLeaderboardString.publicData];
        NSString* privateData = dict[kakaoLeaderboardString.privateData];
        
        [self updateResult:leaderboardKey
                 withScore:score!=nil?[score intValue]:0
                   withExp:exp!=nil?[exp intValue]:0
            withPublicData:publicData withPrivateData:privateData];
    }
    else if( [action isEqualToString:kakaoAction.UpdateMultipleResults]==YES ) {
        NSDictionary* scores = dict[kakaoLeaderboardString.multipleLeaderboards];
        NSString* exp = dict[kakaoLeaderboardString.exp];
        NSString* publicData = dict[kakaoLeaderboardString.publicData];
        NSString* privateData = dict[kakaoLeaderboardString.privateData];
        
        [self updateMultipleResults:scores
                            withExp:exp!=nil?[exp intValue]:0
                     withPublicData:publicData
                    withPrivateData:privateData];
        
    }
    else if( [action isEqualToString:kakaoAction.LoadLeaderboard]==YES ) {
        NSString* leaderboardKey = dict[kakaoLeaderboardString.leaderboardKey];
        [self loadLeaderboard:leaderboardKey];
    }
    else if( [action isEqualToString:kakaoAction.LoadGameFriends]==YES ) {
        [self loadGameFriends];
    }
    else if( [action isEqualToString:kakaoAction.SendLinkGameMessage]==YES ) {
        NSLog(@"SendLinkGameMessage");
        NSString* receiverId = dict[kakaoLeaderboardString.receiverId];
        NSString* templateId = dict[kakaoLeaderboardString.templateId];
        NSString* heart = dict[kakaoLeaderboardString.heart];
        NSString* gameMessage = dict[kakaoLeaderboardString.gameMessage];
        NSString* dataString = dict[kakaoLeaderboardString.data];
        NSString* executeUrl = dict[kakaoString.executeUrl];

        NSDictionary *metaInfo = dict[kakaoString.metaInfo];
        NSString* imageUrl = dict[kakaoString.imageURL];
        UIImage* image = nil;

        NSData * imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        image = [UIImage imageWithData:imageData];

        NSData* data = dataString==nil||dataString.length==0?nil:[dataString dataUsingEncoding:NSUTF8StringEncoding];

        [self sendLinkGameMessage:receiverId
                   withTemplateId:templateId
                  withGameMessage:gameMessage
                        withHeart:[heart intValue]
                         withData:data
                        withImage:image withExecuteUrl:executeUrl withMetainfo:metaInfo];
    }
    else if( [action isEqualToString:kakaoAction.SendInviteLinkGameMessage]==YES ) {
        NSString* receiverId = dict[kakaoLeaderboardString.receiverId];
        NSString* templateId = dict[kakaoLeaderboardString.templateId];
        NSString* executeUrl = dict[kakaoString.executeUrl];
        NSDictionary *metaInfo = dict[kakaoString.metaInfo];

        [self sendInviteLinkGameMessage:receiverId withTemplateId:templateId withExecuteUrl:executeUrl withMetaInfo:metaInfo];
    }
    else if( [action isEqualToString:kakaoAction.LoadGameMessages]==YES ) {
        [self loadGameMessages];
    }
    else if( [action isEqualToString:kakaoAction.AcceptGameMessage]==YES ) {
        NSString* messageId = dict[kakaoLeaderboardString.messageId];
        [self acceptGameMessage:messageId];
    }
    else if( [action isEqualToString:kakaoAction.AcceptAllGameMessages]==YES ) {
        [self acceptAllGameMessages];
    }
    else if( [action isEqualToString:kakaoAction.BlockMessage]==YES ) {
        NSString* beBlock = dict[kakaoLeaderboardString.block];
        [self blockMessage:[beBlock isEqualToString:@"true"]];
    }
    else if( [action isEqualToString:kakaoAction.DeleteUser]==YES ) {
        [self deleteUser];
    }
}

-(void)sendSuccess:(NSString*)action withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:action forKey:[KakaoString sharedInstance].action];
        if (param != nil )
            [dictionary setValue:param forKey:[KakaoString sharedInstance].result];
       
        std::string cppString = [[dictionary kakaoJSONStringWithError:nil] UTF8String];
        KakaoResponseHandler::onSuccessComplete(cppString);
    });
}

-(void)sendError:(NSString*)action withError:(NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:action forKey:[KakaoString sharedInstance].action];
        if( error!=nil ) {
            NSMutableDictionary* errorDictionary = [NSMutableDictionary dictionary];
            
            [errorDictionary setObject:[NSString stringWithFormat:@"%d",error.code]
                                forKey:[KakaoString sharedInstance].status];
            
            [errorDictionary setObject:error.localizedDescription
                                forKey:[KakaoString sharedInstance].message];
            [dictionary setValue:errorDictionary forKey:[KakaoString sharedInstance].error];
        }
        
        std::string cppString = [[dictionary kakaoJSONStringWithError:nil] UTF8String];
        KakaoResponseHandler::onErrorComplete(cppString);
    });
}

-(BOOL)handleOpenURL:(NSURL*)url {
    return [[KAAuth sharedAuth] handleOpenURL:url];
}

@end
