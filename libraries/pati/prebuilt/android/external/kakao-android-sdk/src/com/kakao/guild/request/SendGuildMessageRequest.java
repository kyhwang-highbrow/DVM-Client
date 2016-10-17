package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.guild.StringSet;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by house.dr on 16. 4. 18..
 */
public class SendGuildMessageRequest extends ApiRequest {
    private final String worldId;
    private final String guildId;
    private final String templateId;
    private final JSONObject args;

    public SendGuildMessageRequest(String worldId, String guildId, String templateId, Map<String, String> args) {
        this.worldId = worldId;
        this.guildId = guildId;
        this.templateId = templateId;
        this.args = args != null ? new JSONObject(args) : null;
    }

    @Override
    public String getMethod() {
        return POST;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + "/" + worldId + GameServerProtocol.GET_GUILDS_PATH;
        return baseUrl + "/" + guildId + GameServerProtocol.GET_CHATS_PATH + GameServerProtocol.GET_LINK_PATH;
    }

    @Override
    public Map<String, String> getParams() {
        Map<String, String> params = new HashMap<String, String>();
        params.put(StringSet.template_id, templateId);
        if (args != null && args.length() > 0) {
            params.put(StringSet.extra, args.toString());
        }
        return params;
    }
}
