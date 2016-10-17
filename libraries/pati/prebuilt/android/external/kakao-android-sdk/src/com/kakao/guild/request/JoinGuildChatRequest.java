package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by house.dr on 15. 10. 22..
 */
public class JoinGuildChatRequest extends ApiRequest {
    private final String worldId;
    private final String guildId;

    public JoinGuildChatRequest(String worldId, String guildId) {
        this.worldId = worldId;
        this.guildId = guildId;
    }

    @Override
    public String getMethod() {
        return POST;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + "/" + worldId + GameServerProtocol.GET_GUILDS_PATH;
        return baseUrl + "/" + guildId + GameServerProtocol.GET_CHATS_PATH + GameServerProtocol.GET_GUILDS_MEMBERS_PATH;
    }
}
