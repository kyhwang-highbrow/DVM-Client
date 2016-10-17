//
//  KakaoiOS+Leaderboard.m
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 10. 4..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import "KakaoiOS+Leaderboard.h"
#import "KALocalUser+LeaderBoard.h"

@implementation KakaoiOS (Leaderboard)

- (void)loadGameInfo {
    [[KALocalUser localUser] loadGameInfoWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self sendSuccess:[KakaoAction sharedInstance].LoadGameInfo withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].LoadGameInfo withError:error];
            }
        });
    }];
}

- (void)loadGameUserInfo {
    [[KALocalUser localUser] loadGameMeWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:response];

                id publicData = [response objectForKey:@"public_data"];
                if (publicData != nil && [publicData isKindOfClass:[NSData class]] == YES) {
                    NSString *decodedPublicData = [[[NSString alloc] initWithData:publicData encoding:NSUTF8StringEncoding] autorelease];
                    [mutableResponse setValue:decodedPublicData forKey:@"public_data"];
                }

                id privateData = [response objectForKey:@"private_data"];
                if (privateData != nil && [privateData isKindOfClass:[NSData class]] == YES) {
                    NSString *decodedPrivateData = [[[NSString alloc] initWithData:privateData encoding:NSUTF8StringEncoding] autorelease];
                    [mutableResponse setValue:decodedPrivateData forKey:@"private_data"];
                }

                [self sendSuccess:[KakaoAction sharedInstance].LoadGameUserInfo withParam:mutableResponse];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].LoadGameUserInfo withError:error];
            }
        });
    }];
}

- (void)updateUser:(int)additionalHeart withCurrentHeart:(int)currentHeart withPublicData:(NSString *)publicData withPrivateData:(NSString *)privateData {

    NSLog(@"update_user : public_data -> %@, private_data -> %@", publicData, privateData);
    NSData *encodedPublicData = publicData == nil || publicData.length == 0 ? nil : [publicData dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodedPrivateData = privateData == nil || privateData.length == 0 ? nil : [privateData dataUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"update_user : encodedPublicData -> %@, encodedPrivateData -> %@", [[[NSString alloc] initWithData:encodedPublicData encoding:NSUTF8StringEncoding] autorelease], [[[NSString alloc] initWithData:encodedPrivateData encoding:NSUTF8StringEncoding] autorelease]);
    NSDictionary *parameters = [[[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithInt:additionalHeart], @"heart",
            [NSNumber numberWithInt:currentHeart], @"current_heart",
            encodedPublicData, @"public_data",
            encodedPrivateData, @"private_data",
            nil] autorelease];
    NSLog(@"parameters : %@", parameters);
    [[KALocalUser localUser] updateMeWithParameters:parameters withCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self sendSuccess:[KakaoAction sharedInstance].UpdateUser withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].UpdateUser withError:error];
            }
        });
    }];
}

- (void)useHeart:(int)useHeart {
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithInt:useHeart], @"heart_count",
            nil];

    [[KALocalUser localUser] useHeartWithParameters:parameters withCompletionHandler:^(NSDictionary *response, NSError *error) {
        if (error == nil) {
            [self sendSuccess:[KakaoAction sharedInstance].UseHeart withParam:response];
        }
        else {
            [self sendError:[KakaoAction sharedInstance].UseHeart withError:error];
        }
    }];
}

- (void)updateResult:(NSString *)key withScore:(int)score withExp:(int)exp withPublicData:(NSString *)publicData withPrivateData:(NSString *)privateData {

    NSData *encodedPublicData = publicData == nil || publicData.length == 0 ? nil : [publicData dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodedPrivateData = privateData == nil || privateData.length == 0 ? nil : [privateData dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
            key, @"leaderboard_key",
            [NSNumber numberWithInt:score], @"score",
            [NSNumber numberWithInt:exp], @"exp",
            encodedPublicData, @"public_data",
            encodedPrivateData, @"private_data",
            nil];

    [[KALocalUser localUser] updateResult:parameters withCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self sendSuccess:[KakaoAction sharedInstance].UpdateResult withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].UpdateResult withError:error];
            }
        });
    }];
}

- (void)updateMultipleResults:(NSDictionary *)scores withExp:(int)exp withPublicData:(NSString *)publicData withPrivateData:(NSString *)privateData {
    NSData *encodedPublicData = publicData == nil || publicData.length == 0 ? nil : [publicData dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodedPrivateData = privateData == nil || privateData.length == 0 ? nil : [privateData dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithInt:exp], @"exp",
            [scores allKeys], @"leaderboard_keys",
            [scores allValues], @"scores",
            encodedPublicData, @"public_data",    //optional
            encodedPrivateData, @"private_data",  //optional
            nil];

    [[KALocalUser localUser] updateResults:parameters withCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self sendSuccess:[KakaoAction sharedInstance].UpdateMultipleResults withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].UpdateMultipleResults withError:error];
            }
        });
    }];
}

- (void)loadLeaderboard:(NSString *)key {
    NSDictionary *parameters = [[[NSDictionary alloc] initWithObjectsAndKeys:key, @"leaderboard_key", nil] autorelease];

    [[KALocalUser localUser] loadLeaderBoardWithParameters:parameters withCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:response];
                [mutableResponse setObject:key forKey:[KakaoLeaderboardString sharedInstance].leaderboardKey];
                [self sendSuccess:[KakaoAction sharedInstance].LoadLeaderboard withParam:mutableResponse];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].LoadLeaderboard withError:error];
            }
        });
    }];
}

- (void)loadGameFriends {
    [[KALocalUser localUser] loadGameFriendsWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                NSArray *appFriends = [response objectForKey:@"app_friends"];
                NSMutableArray *mutableAppFriends = [[NSMutableArray alloc] initWithArray:appFriends];
                NSDictionary *appFriendsInfo = nil;
                for (int i = 0; i < appFriends.count; ++i) {
                    appFriendsInfo = appFriends[i];
                    if (appFriendsInfo == nil)
                        continue;

                    id publicData = [appFriendsInfo objectForKey:@"public_data"];
                    if ([publicData isKindOfClass:[NSData class]]) {
                        if ([(NSData *) publicData length] > 0) {
                            NSString *decodedPublicData = [[[NSString alloc] initWithData:publicData encoding:NSUTF8StringEncoding] autorelease];
                            [appFriendsInfo setValue:decodedPublicData forKey:@"public_data"];
                        }
                        mutableAppFriends[i] = appFriendsInfo;
                    }
                }

                [response setValue:mutableAppFriends forKey:@"app_friends"];
                [self sendSuccess:[KakaoAction sharedInstance].LoadGameFriends withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].LoadGameFriends withError:error];
            }
        });
    }];
}

- (void)loadGameMessages {
    [[KALocalUser localUser] loadGameMessagesWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                NSArray *messages = [response objectForKey:@"messages"];
                //NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:messages];
                for (int i = 0; i < messages.count; ++i) {
                    id message = [messages objectAtIndex:i];
                    if (message == nil)
                        continue;

                    id data = [message objectForKey:@"data"];
                    if (data != nil && [data isKindOfClass:[NSData class]] == YES) {
                        NSString *decodedData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                        [message setValue:decodedData forKey:@"data"];
                    }
                }

                [response setValue:messages forKey:@"messages"];

                [self sendSuccess:[KakaoAction sharedInstance].LoadGameMessages withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].LoadGameMessages withError:error];
            }
        });
    }];
}

- (void)deleteUser {
    [[KALocalUser localUser] deleteMeWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self sendSuccess:[KakaoAction sharedInstance].DeleteUser withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].DeleteUser withError:error];
            }
        });
    }];
}

-(void)sendLinkGameMessage:(NSString*)receiverId
            withTemplateId:(NSString*)templateId
           withGameMessage:(NSString*)gameMessage
                 withHeart:(int)heart
                  withData:(NSData*)data
                 withImage:(UIImage*)image
            withExecuteUrl:(NSString*)executeUrl
              withMetainfo:(NSDictionary*)metaInfo {

    NSMutableDictionary* mutableMetaInfo = [NSMutableDictionary dictionary];
    if( executeUrl!=nil )
        [mutableMetaInfo setValue:executeUrl forKeyPath:@"executeurl"];

    if( image!=nil )
        [mutableMetaInfo setValue:image forKeyPath:@"image"];

    if( metaInfo!=nil ) {
        NSArray* keys = [metaInfo allKeys];
        for( NSString* key in keys ) {
            [mutableMetaInfo setObject:metaInfo[key] forKey:key];
        }
    }

    [[KALocalUser localUser] sendLinkGameMessageWithReceiver:receiverId
                                                withTemplate:templateId
                                                   withHeart:[NSNumber numberWithInt:heart]
                                             withGameMessage:gameMessage
                                                    withData:data
                                                withMetaInfo:mutableMetaInfo
                                       withCompletionHandler:^(NSDictionary *response, NSError *error)
                                       {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (!error) {
                                                   [self sendSuccess:[KakaoAction sharedInstance].SendLinkGameMessage withParam:response];
                                               }
                                               else {
                                                   [self sendError:[KakaoAction sharedInstance].SendLinkGameMessage withError:error];
                                               }
                                           });
                                       }];
}

-(void)sendInviteLinkGameMessage:(NSString*)receiverId
                  withTemplateId:(NSString*)templateId
                  withExecuteUrl:(NSString*)executeUrl
                    withMetaInfo:(NSDictionary*)metaInfo {

    NSMutableDictionary* mutableMetaInfo = [NSMutableDictionary dictionary];
    if( executeUrl!=nil )
        [mutableMetaInfo setValue:executeUrl forKeyPath:@"executeurl"];

    if( metaInfo!=nil ) {
        NSArray* keys = [metaInfo allKeys];
        for( NSString* key in keys ) {
            [mutableMetaInfo setObject:metaInfo[key] forKey:key];
        }
    }

    [[KALocalUser localUser] sendInviteLinkGameMessageWithReceiver:receiverId
                                                      withTemplate:templateId
                                                      withMetaInfo:mutableMetaInfo
                                             withCompletionHandler:^(NSDictionary *response, NSError *error)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     if (!error) {
                                                         [self sendSuccess:[KakaoAction sharedInstance].SendInviteLinkGameMessage withParam:response];
                                                     }
                                                     else {
                                                         [self sendError:[KakaoAction sharedInstance].SendInviteLinkGameMessage withError:error];
                                                     }
                                                 });
                                             }];
}

- (void)acceptGameMessage:(NSString *)messageId {

    NSDictionary *parameters = [[[NSDictionary alloc] initWithObjectsAndKeys:
            messageId, @"ids[]",
            nil] autorelease];


    [[KALocalUser localUser] acceptMessageWithParameters:parameters withCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:response];
                [mutableResponse setObject:messageId forKey:@"message_id"];
                [self sendSuccess:[KakaoAction sharedInstance].AcceptGameMessage withParam:mutableResponse];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].AcceptGameMessage withError:error];
            }
        });
    }];
}

- (void)acceptAllGameMessages {
    [[KALocalUser localUser] acceptAllMessagesWithCompletionHandler:^(NSDictionary *response, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self sendSuccess:[KakaoAction sharedInstance].AcceptAllGameMessages withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].AcceptAllGameMessages withError:error];
            }
        });
    }];
}

- (void)blockMessage:(BOOL)beBlock {
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithBool:beBlock], @"block", nil];

    [[KALocalUser localUser] messageBlockWithParameters:parameters withCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self sendSuccess:[KakaoAction sharedInstance].BlockMessage withParam:response];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].BlockMessage withError:error];
            }
        });
    }];
}
@end
