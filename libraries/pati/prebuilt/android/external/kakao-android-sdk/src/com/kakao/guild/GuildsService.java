package com.kakao.guild;


import android.app.Activity;

import com.kakao.network.callback.ResponseCallback;
import com.kakao.network.tasks.KakaoResultTask;
import com.kakao.network.tasks.KakaoTaskQueue;
import com.kakao.guild.response.CreateGuildResponse;
import com.kakao.guild.response.GuildMembersResponse;
import com.kakao.guild.response.GuildsResponse;
import com.kakao.guild.response.MyGuildsResponse;
import com.kakao.guild.response.model.GuildInfo;

import java.util.Map;

/**
 * Created by house.dr on 15. 8. 21..
 */
public class GuildsService {
    public static void requestMyGuilds(final ResponseCallback<MyGuildsResponse> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<MyGuildsResponse>(callback) {
            @Override
            public MyGuildsResponse call() throws Exception {
                return GuildsApi.requestMyGuilds();
            }
        });
    }

    public static void requestMyPendingGuilds(final ResponseCallback<MyGuildsResponse> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<MyGuildsResponse>(callback) {
            @Override
            public MyGuildsResponse call() throws Exception {
                return GuildsApi.requestMyPendingGuilds();
            }
        });
    }

    public static void requestMyBannedGuilds(final ResponseCallback<MyGuildsResponse> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<MyGuildsResponse>(callback) {
            @Override
            public MyGuildsResponse call() throws Exception {
                return GuildsApi.requestMyBannedGuilds();
            }
        });
    }

    public static void requestGuilds(final ResponseCallback<GuildsResponse> callback,
                                     final int offset, final int limit) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<GuildsResponse>(callback) {
            @Override
            public GuildsResponse call() throws Exception {
                return GuildsApi.requestGuilds(offset, limit);
            }
        });
    }

    public static void requestCreateGuild(final ResponseCallback<CreateGuildResponse> callback, final Map<String, String> properties) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<CreateGuildResponse>(callback) {
            @Override
            public CreateGuildResponse call() throws Exception {
                return GuildsApi.createGuild(properties);
            }
        });
    }

    public static void requestDeleteGuild(final ResponseCallback<Boolean> callback,
                                          final String id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestDeleteGuild(id);
            }
        });
    }

    public static void requestGuildInfo(final ResponseCallback<GuildInfo> callback, final String id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<GuildInfo>(callback) {
            @Override
            public GuildInfo call() throws Exception {
                return GuildsApi.requestGuildInfo(id);
            }
        });
    }

    public static void requestUpdateGuild(final ResponseCallback<Boolean> callback,
                                          final String id, final Map<String, String> properties) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestUpdateGuild(id, properties);
            }
        });
    }

    public static void requestJoinGuild(final ResponseCallback<Boolean> callback, final String id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestJoinGuild(id);
            }
        });
    }

    public static void requestLeaveGuild(final ResponseCallback<Boolean> callback, final String id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestLeaveGuild(id);
            }
        });
    }

    public static void requestGuildMembers(final ResponseCallback<GuildMembersResponse> callback,
                                           final String id, final int offset, final int limit, final int joinStatus) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<GuildMembersResponse>(callback) {
            @Override
            public GuildMembersResponse call() throws Exception {
                return GuildsApi.requestGuildMembers(id, offset, limit, joinStatus);
            }
        });
    }

    public static void requestDeleteGuildMember(final ResponseCallback<Boolean> callback,
                                                final String id, final String memberId) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestDeleteGuildMember(id, memberId);
            }
        });
    }

    public static void requestApproveGuildMember(final ResponseCallback<Boolean> callback,
                                                final String id, final String memberId) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestApproveGuildMember(id, memberId);
            }
        });
    }

    public static void requestSearchGuild(final ResponseCallback<GuildsResponse> callback,
                                          final String query, final int offset, final int limit) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<GuildsResponse>(callback) {
            @Override
            public GuildsResponse call() throws Exception {
                return GuildsApi.requestSearchGuild(query, offset, limit);
            }
        });
    }

    public static void requestPrivateSearchGuild(final ResponseCallback<GuildInfo> callback, final String name) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<GuildInfo>(callback) {
            @Override
            public GuildInfo call() throws Exception {
                return GuildsApi.requestPrivateSearchGuild(name);
            }
        });
    }

    public static void requestDenyJoin(final ResponseCallback<Boolean> callback,
                                                 final String id, final String memberId) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestDenyJoin(id, memberId);
            }
        });
    }

    public static void requestCancelJoin(final ResponseCallback<Boolean> callback, final String id) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestCancelJoin(id);
            }
        });
    }

    public static void requestAppointSubLeader(final ResponseCallback<Boolean> callback, final String id, final String memberId) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestAppointSubLeader(id, memberId);
            }
        });
    }

    public static void requestDismissSubLeader(final ResponseCallback<Boolean> callback, final String id, final String memberId) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestDismissSubLeader(id, memberId);
            }
        });
    }

    public static void requestChangeLeader(final ResponseCallback<Boolean> callback, final String id, final String memberId) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestChangeLeader(id, memberId);
            }
        });
    }

    public static void requestJoinGuildChat(final Activity activity, final String worldId, final String guildId) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>() {
            @Override
            public Boolean call() throws Exception {
                GuildsApi.requestJoinGuildChat(activity, worldId, guildId);
                return true;
            }
        });
    }

    public static void requestSendGuildMessage(final ResponseCallback<Boolean> callback, final String worldId, final String guildId, final String templateId, final Map<String, String> args) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {
            @Override
            public Boolean call() throws Exception {
                return GuildsApi.requestSendGuildMessage(worldId, guildId, templateId, args);
            }
        });
    }
}
