package com.kakao.game;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Environment;

import com.kakao.auth.ApiResponseCallback;
import com.kakao.game.request.InvitationEventListRequest;
import com.kakao.game.request.InvitationEventRequest;
import com.kakao.game.request.InvitationSenderRequest;
import com.kakao.game.request.InvitationStatesRequest;
import com.kakao.game.request.RecommendedInvitableFriendsRequest;
import com.kakao.game.request.SendRecommendedInviteMessageRequest;
import com.kakao.game.response.ExtendedFriendsResponse;
import com.kakao.game.response.InvitationEventListResponse;
import com.kakao.game.response.InvitationEventResponse;
import com.kakao.game.response.InvitationSenderResponse;
import com.kakao.game.response.InvitationStatesResponse;
import com.kakao.game.response.model.ExtendedFriendInfo;
import com.kakao.network.ErrorResult;
import com.kakao.network.callback.ResponseCallback;
import com.kakao.auth.SingleNetworkTask;
import com.kakao.auth.network.response.ApiResponse;
import com.kakao.network.tasks.KakaoResultTask;
import com.kakao.network.tasks.KakaoTaskQueue;
import com.kakao.friends.api.FriendsApi;
import com.kakao.friends.response.FriendsResponse;
import com.kakao.friends.response.model.FriendInfo;
import com.kakao.game.request.GameImageUploadRequest;
import com.kakao.game.request.PostStoryRequest;
import com.kakao.game.response.GameImageResponse;
import com.kakao.guild.GuildsService;
import com.kakao.guild.response.CreateGuildResponse;
import com.kakao.guild.response.GuildMembersResponse;
import com.kakao.guild.response.GuildsResponse;
import com.kakao.guild.response.MyGuildsResponse;
import com.kakao.guild.response.model.GuildInfo;
import com.kakao.kakaostory.KakaoStoryService;
import com.kakao.kakaostory.callback.StoryResponseCallback;
import com.kakao.kakaotalk.api.KakaoTalkApi;
import com.kakao.kakaotalk.KakaoTalkService;
import com.kakao.kakaotalk.callback.TalkResponseCallback;
import com.kakao.kakaotalk.response.ChatListResponse;
import com.kakao.kakaotalk.response.KakaoTalkProfile;
import com.kakao.kakaotalk.response.model.ChatInfo;
import com.kakao.network.response.ResponseData;
import com.kakao.usermgmt.UserManagement;
import com.kakao.usermgmt.callback.LogoutResponseCallback;
import com.kakao.usermgmt.callback.MeResponseCallback;
import com.kakao.usermgmt.callback.UnLinkResponseCallback;
import com.kakao.usermgmt.response.model.UserProfile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by house.dr on 15. 9. 3..
 */
public class GameAPI {

    public static void requestSignUp(final ApiResponseCallback<Long> callback, final Map<String, String> properties) {
        UserManagement.requestSignup(callback, properties);
    }

    public static void requestLogout(final LogoutResponseCallback callback) {
        UserManagement.requestLogout(callback);
    }

    public static void requestUnlink(final UnLinkResponseCallback callback) {
        UserManagement.requestUnlink(callback);
    }

    public static void requestMe(final MeResponseCallback callback) {
        UserManagement.requestMe(callback);
    }

    public static void requestUpdateProfile(final ApiResponseCallback<Long> callback, final Map<String, String> properties) {
        UserManagement.requestUpdateProfile(callback, properties);
    }

    public static void requestRegisteredFriends(final ResponseCallback<FriendsResponse> callback, final RegisteredFriendContext registeredFriendContext) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<FriendsResponse>(callback) {
            @Override
            public FriendsResponse call() throws Exception {
                return FriendsApi.requestFriends(registeredFriendContext.getFriendContext());
            }
        });
    }

    public static void requestReachInvitableFriends(final ResponseCallback<FriendsResponse> callback, final ReachInvitableFriendContext reachInvitableFriendContext) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<FriendsResponse>(callback) {
            @Override
            public FriendsResponse call() throws Exception {
                return FriendsApi.requestFriends(reachInvitableFriendContext.getFriendContext());
            }
        });
    }

    public static void requestInvitableFriends(final ResponseCallback<FriendsResponse> callback, final InvitableFriendContext invitableFriendContext) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<FriendsResponse>(callback) {
            @Override
            public FriendsResponse call() throws Exception {
                return FriendsApi.requestFriends(invitableFriendContext.getFriendContext());
            }
        });
    }

    public static void requestSendGameMessage(final TalkResponseCallback<Boolean> callback,
                                              final FriendInfo friendInfo,
                                              final String templateId,
                                              final Map<String, String> args) {
        if (!friendInfo.isAppRegistered()) {
            callback.onFailure(new ErrorResult(new Exception("receiver user is not registered")));
        } else {
            KakaoTalkService.requestSendMessage(callback, friendInfo, templateId, args);
        }
    }

    public static void requestSendInviteMessage(final TalkResponseCallback<Boolean> callback,
                                                final FriendInfo friendInfo,
                                                final String templateId,
                                                final Map<String, String> args) {
        if (friendInfo.isAppRegistered()) {
            callback.onFailure(new ErrorResult(new Exception("receiver user is not invitable")));
        } else {
            KakaoTalkService.requestSendMessage(callback, friendInfo, templateId, args);
        }
    }

    public static void requestSendMultiChatMessage(final TalkResponseCallback<Boolean> callback,
                                                   final ChatInfo chatInfo,
                                                   final String templateId,
                                                   final Map<String, String> args) {
        KakaoTalkService.requestSendMessage(callback, chatInfo, templateId, args);
    }

    public static void requestTalkProfile(final TalkResponseCallback<KakaoTalkProfile> callback) {
        KakaoTalkService.requestProfile(callback);
    }

    public static void requestMultiChatList(final TalkResponseCallback<ChatListResponse> callback, final GameMultichatContext gameMultichatContext) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<ChatListResponse>(callback) {
            @Override
            public ChatListResponse call() throws Exception {
                return KakaoTalkApi.requestChatRoomList(gameMultichatContext.getChatListContext());
            }
        });
    }

    public static GameImageResponse requestGameImageUpload(List<File> fileList) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new GameImageUploadRequest(fileList));
        return new GameImageResponse(result);
    }

    public static void requestSendImageMessage(final TalkResponseCallback<Boolean> callback,
                                               final FriendInfo friendInfo,
                                               final String templateId,
                                               final Map<String, String> args,
                                               final Bitmap bitmap) {
        if (!friendInfo.isAppRegistered()) {
            callback.onFailure(new ErrorResult(new Exception("receiver user is not registered")));
            return;
        }
        File dir = new File(Environment.getExternalStorageDirectory()+"/Temp");
        if (!dir.exists()) {
            dir.mkdir();
        }
        File file = new File(dir, "temp" + System.currentTimeMillis() + ".png");
        FileOutputStream fOut;
        try {
            fOut = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);
            fOut.flush();
            fOut.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        final List<File> fileList = new ArrayList<File>();
        fileList.add(file);

        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                String imageUrl;
                imageUrl = requestGameImageUpload(fileList).getImageUrl();
                args.put("${image_url}", imageUrl);
                args.put("${imageWidth}", String.valueOf(bitmap.getWidth()));
                args.put("${imageHeight}", String.valueOf(bitmap.getHeight()));
                return KakaoTalkApi.requestSendMessage(friendInfo, templateId, args);
            }
        });
    }

    public static void requestIsStoryUser(final StoryResponseCallback<Boolean> callback) {
        KakaoStoryService.requestIsStoryUser(callback);
    }

    public static void requestPostStory(final ResponseCallback<Boolean> callback, final String templateId, final String content) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {

            @Override
            public Boolean call() throws Exception {
                SingleNetworkTask networkTask = new SingleNetworkTask();
                ResponseData result = networkTask.requestApi(new PostStoryRequest(templateId, content));
                new ApiResponse.BlankApiResponse(result);
                return true;
            }
        });
    }

    public static void requestJoinGuildChat(final Activity activity, final String worldId, final String guildId) {
        GuildsService.requestJoinGuildChat(activity, worldId, guildId);
    }

    public static void requestSendGuildMessage(final ResponseCallback<Boolean> callback, final String worldId, final String guildId, final String templateId, final Map<String, String> args) {
        GuildsService.requestSendGuildMessage(callback, worldId, guildId, templateId, args);
    }

    public static void showMessageBlockDialog(final Activity activity, final ResponseCallback<Boolean> callback) {
        requestMe(new MeResponseCallback() {
            @Override
            public void onSessionClosed(ErrorResult errorResult) {

            }

            @Override
            public void onNotSignedUp() {

            }

            @Override
            public void onSuccess(UserProfile result) {
                GameMessageBlockDialog dialog = new GameMessageBlockDialog(activity, callback);
                dialog.show();
            }
        });
    }

    public static void requestInvitationEventList(final ResponseCallback<InvitationEventListResponse> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<InvitationEventListResponse>(callback) {
            @Override
            public InvitationEventListResponse call() throws Exception {
                SingleNetworkTask networkTask = new SingleNetworkTask();
                ResponseData result = networkTask.requestApi(new InvitationEventListRequest());
                return new InvitationEventListResponse(result);
            }
        });
    }

    public static void requestInvitationEvent(final ResponseCallback<InvitationEventResponse> callback, final int id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<InvitationEventResponse>(callback) {
            @Override
            public InvitationEventResponse call() throws Exception {
                SingleNetworkTask networkTask = new SingleNetworkTask();
                ResponseData result = networkTask.requestApi(new InvitationEventRequest(id));
                return new InvitationEventResponse(result);
            }
        });
    }

    public static void requestInvitationStates(final ResponseCallback<InvitationStatesResponse> callback, final int id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<InvitationStatesResponse>(callback) {
            @Override
            public InvitationStatesResponse call() throws Exception {
                SingleNetworkTask networkTask = new SingleNetworkTask();
                ResponseData result = networkTask.requestApi(new InvitationStatesRequest(id));
                return new InvitationStatesResponse(result);
            }
        });
    }

    public static void requestInvitationSender(final ResponseCallback<InvitationSenderResponse> callback, final int id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<InvitationSenderResponse>(callback) {
            @Override
            public InvitationSenderResponse call() throws Exception {
                SingleNetworkTask networkTask = new SingleNetworkTask();
                ResponseData result = networkTask.requestApi(new InvitationSenderRequest(id));
                return new InvitationSenderResponse(result);
            }
        });
    }

    public static void requestRecommendedInvitableFriends(final ResponseCallback<ExtendedFriendsResponse> callback, final InvitableFriendContext invitableFriendContext) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<ExtendedFriendsResponse>(callback) {
            @Override
            public ExtendedFriendsResponse call() throws Exception {
                SingleNetworkTask networkTask = new SingleNetworkTask();
                ResponseData result = networkTask.requestApi(new RecommendedInvitableFriendsRequest(invitableFriendContext));
                ExtendedFriendsResponse response = new ExtendedFriendsResponse(result);
                invitableFriendContext.getFriendContext().setBeforeUrl(response.getBeforeUrl());
                invitableFriendContext.getFriendContext().setAfterUrl(response.getAfterUrl());
                invitableFriendContext.getFriendContext().setId(response.getId());

                return response;
            }
        });
    }

    public static void requestSendRecommendedInviteMessage(final TalkResponseCallback<Boolean> callback,
                                                           final ExtendedFriendInfo friendInfo,
                                                           final String templateId,
                                                           final Map<String, String> args) {
        if (friendInfo.isAppRegistered()) {
            callback.onFailure(new ErrorResult(new Exception("receiver user is not invitable")));
        } else {
            KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {

                @Override
                public Boolean call() throws Exception {
                    SingleNetworkTask networkTask = new SingleNetworkTask();
                    ResponseData result = networkTask.requestApi(new SendRecommendedInviteMessageRequest(friendInfo, templateId, args));
                    new ApiResponse.BlankApiResponse(result);
                    return true;
                }
            });
        }

    }
}
