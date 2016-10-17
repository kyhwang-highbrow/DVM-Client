package com.kakao.guild;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import com.kakao.auth.SingleNetworkTask;
import com.kakao.auth.network.response.ApiResponse;
import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.guild.request.AppointSubLeaderRequest;
import com.kakao.guild.request.ChangeLeaderRequest;
import com.kakao.guild.request.DismissSubLeaderRequest;
import com.kakao.guild.request.JoinGuildChatRequest;
import com.kakao.guild.request.MyBannedsRequest;
import com.kakao.guild.request.MyPendingsRequest;
import com.kakao.guild.request.SendGuildMessageRequest;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseData;
import com.kakao.guild.request.ApproveGuildMemberRequest;
import com.kakao.guild.request.CancelJoinRequest;
import com.kakao.guild.request.CreateGuildRequest;
import com.kakao.guild.request.DeleteGuildMemberRequest;
import com.kakao.guild.request.DeleteGuildRequest;
import com.kakao.guild.request.DenyJoinRequest;
import com.kakao.guild.request.GuildInfoRequest;
import com.kakao.guild.request.GuildMembersRequest;
import com.kakao.guild.request.GuildsRequest;
import com.kakao.guild.request.JoinGuildRequest;
import com.kakao.guild.request.LeaveGuildRequest;
import com.kakao.guild.request.MyGuildsRequest;
import com.kakao.guild.request.PrivateSearchGuildRequest;
import com.kakao.guild.request.SearchGuildRequest;
import com.kakao.guild.request.UpdateGuildRequest;
import com.kakao.guild.response.CreateGuildResponse;
import com.kakao.guild.response.GuildInfoResponse;
import com.kakao.guild.response.GuildMembersResponse;
import com.kakao.guild.response.GuildsResponse;
import com.kakao.guild.response.MyGuildsResponse;
import com.kakao.guild.response.model.GuildInfo;
import com.kakao.util.helper.log.Logger;

import java.util.Map;

/**
 * Created by house.dr on 15. 8. 21..
 */
public class GuildsApi {

    public static MyGuildsResponse requestMyGuilds() throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new MyGuildsRequest());
        return new MyGuildsResponse(result);
    }

    public static MyGuildsResponse requestMyPendingGuilds() throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new MyPendingsRequest());
        return new MyGuildsResponse(result);
    }

    public static MyGuildsResponse requestMyBannedGuilds() throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new MyBannedsRequest());
        return new MyGuildsResponse(result);
    }

    public static GuildsResponse requestGuilds(int offset, int limit) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new GuildsRequest(offset, limit));
        return new GuildsResponse(result);
    }

    public static CreateGuildResponse createGuild(Map<String, String> properties) throws  Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new CreateGuildRequest(properties));
        return new CreateGuildResponse(result);
    }

    public static boolean requestDeleteGuild(String id) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new DeleteGuildRequest(id));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static GuildInfo requestGuildInfo(String id) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new GuildInfoRequest(id));
        GuildInfoResponse guildInfoResponse = new GuildInfoResponse(result);
        return guildInfoResponse.getGuildInfo();
    }

    public static boolean requestUpdateGuild(String id, Map<String, String> properties) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new UpdateGuildRequest(id, properties));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static boolean requestJoinGuild(String id) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new JoinGuildRequest(id));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static boolean requestLeaveGuild(String id) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new LeaveGuildRequest(id));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static GuildMembersResponse requestGuildMembers(String id, int offset, int limit, int joinStatus) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new GuildMembersRequest(id, offset, limit, joinStatus));
        return new GuildMembersResponse(result);
    }

    public static boolean requestDeleteGuildMember(String id, String memberId) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new DeleteGuildMemberRequest(id, memberId));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static boolean requestApproveGuildMember(String id, String memberId) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new ApproveGuildMemberRequest(id, memberId));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static GuildsResponse requestSearchGuild(String query, int offset, int limit) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new SearchGuildRequest(query, offset, limit));
        return new GuildsResponse(result);
    }

    public static GuildInfo requestPrivateSearchGuild(String name) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new PrivateSearchGuildRequest(name));
        GuildInfoResponse guildInfoResponse = new GuildInfoResponse(result);
        return guildInfoResponse.getGuildInfo();
    }

    public static boolean requestDenyJoin(String id, String memberId) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new DenyJoinRequest(id, memberId));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static boolean requestCancelJoin(String id) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new CancelJoinRequest(id));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static boolean requestAppointSubLeader(String id, String memberId) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new AppointSubLeaderRequest(id, memberId));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static boolean requestDismissSubLeader(String id, String memberId) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new DismissSubLeaderRequest(id, memberId));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static boolean requestChangeLeader(String id, String memberId) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new ChangeLeaderRequest(id, memberId));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }

    public static void requestJoinGuildChat(Activity activity, String worldId, String guildId) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new JoinGuildChatRequest(worldId, guildId));
        ResponseBody body = new ResponseBody(result.getHttpStatusCode(), result.getData());
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(body.optString(StringSet.chat_link, null)));
        activity.startActivity(intent);
    }

    public static boolean requestSendGuildMessage(String worldId, String guildId, String templateId, Map<String, String> args) throws Exception {
        SingleNetworkTask networkTask = new SingleNetworkTask();
        ResponseData result = networkTask.requestApi(new SendGuildMessageRequest(worldId, guildId, templateId, args));
        new ApiResponse.BlankApiResponse(result);
        return true;
    }
}
