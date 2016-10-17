package com.kakao.gameutil.helper;

import com.kakao.util.helper.log.Logger;

/**
 * Created by house.dr on 15. 9. 4..
 */
public class GameServerProtocol {
    private static final Logger.DeployPhase DEPLOY_PHASE = Logger.DeployPhase.current();
    public static final String KAGE_API_AUTHORITY = initKageAPIAuthority();
    public static final String KAGE_CDN_AUTHORITY = "http://gc.kakaocdn.net/dn/";
    public static final String IMAGE_UPLOAD_PATH = "/upload/game-sdk/";
    public static final String GAME_API_AUTHORITY = initGameAPIAuthority();
    public static final String GAME_GUILD_API_AUTHORITY = initGameGuildAPIAuthority();
    public static final String API_PROXY_AUTHORITY = initAPIProxyAuthority();
    public static final String REACH_AUTHORITY = initReachAuthority();

    // api url
    public static final String API_VERSION = "/v1";
    public static final String API_VERSION_2 = "/v2";

    // guild
    public static final String GET_GUILDS_PATH = "/groups";
    public static final String GET_GUILDS_JOIN_PATH = "/join";
    public static final String GET_GUILDS_LEAVE_PATH = "/leave";
    public static final String GET_GUILDS_MEMBERS_PATH = "/members";
    public static final String GET_GUILDS_APPROVE_PATH = "/approve";
    public static final String GET_GUILDS_ME_PATH = "/me";
    public static final String GET_GUILDS_SEARCH_PATH = "/search";
    public static final String GET_GUILDS_PRIVATE = "/privates";
    public static final String GET_GUILDS_DENY_PATH = "/deny";
    public static final String GET_GUILDS_PENDING_PATH = "/pendings";
    public static final String GET_GUILDS_BANNEDS_PATH = "/banneds";
    public static final String GET_PLAY_GAME_PATH = "/playgame";
    public static final String GET_STORY_FEED_PATH = "/story_feed";
    public static final String GET_TEMPLATE_PATH = "/template";
    public static final String GET_APP_POST_PATH = "/app_post";
    public static final String GET_SUB_LEADERS_PATH = "/sub_leaders";
    public static final String GET_LEADER_PATH = "/leader";
    public static final String GET_CHATS_PATH = "/chats";

    public static final String GET_COMMON_PATH = "/common";
    public static final String GET_INVITATION_EVENTS_PATH = "/invitation_events";
    public static final String GET_INVITATION_SENDER_PATH = "/invitation_sender";
    public static final String GET_INVITATION_STATES_PATH = "/invitation_states";

    public static final String GET_FRIENDS_RECOMMEND_PATH = "/friends/recommend";
    public static final String GET_MESSAGE_SEND_PATH = "/message/send";
    public static final String GET_LINK_PATH = "/link";

    // reach header
    public static String KGA_HEADER_KEY = "KGA";
    public static String KGA_APP_KEY = "appKey/";
    public static String KGA_USER_ID = "userId/";

    // reach api version
    private static final String REACH_API_VERSION = "reach/v1";

    // ingame
    public static final String INGAME_STATUS = REACH_API_VERSION + "/ingame/status";

    // reach-uri path
    public static final String PLUS_FRIEND_ADD = "/plus_friend/add";
    public static final String PUBLIC_ERROR = "/public/error";

    // Web-App URL Scheme
    public static final String REACH_WEB_APP_URL_SCHEME = "kakaoreach";

    private static String initKageAPIAuthority() {
        switch (DEPLOY_PHASE) {
            case Alpha:
                return "http://alpha-api1-kage.kakao.com";
            case Sandbox:
                return "http://vega001.kr.iwilab.com";
            case Beta:
            case Release:
            default:
                return "http://up.api1.kage.kakao.com";
        }
    }

    private static String initGameGuildAPIAuthority() {
        switch (DEPLOY_PHASE) {
            case Local:
                return "localhost:";
            case Alpha:
                return "alpha-kapi.kakao.com";
            case Sandbox:
                return "sandbox-game-api.kakao.com/guild";
            case Beta:
                return "beta-game-api.kakao.com/guild";
            case Release:
                return "game-api.kakao.com/guild";
//                return "alpha-api-gg.kakao.com";
            default:
                return null;
        }
    }

    private static String initGameAPIAuthority() {
        switch (DEPLOY_PHASE) {
            case Alpha:
                return "alpha-game-api.kakao.com";
            case Release:
                return "game-api.kakao.com";
            case Beta:
                return "beta-game-api.kakao.com";
            default:
                return null;
        }
    }

    private static String initAPIProxyAuthority() {
        switch (DEPLOY_PHASE) {
            case Local:
                return "localhost:";
            case Alpha:
                return "alpha-game-api.kakao.com";
            case Sandbox:
                return "sandbox-game-api.kakao.com";
            case Beta:
                return "beta-game-api.kakao.com";
            case Release:
                return "game-api.kakao.com";
            default:
                return null;
        }
    }

    private static final String initReachAuthority() {
        switch (DEPLOY_PHASE) {
            case Local:
                return "localhost:";
            case Alpha:
                return "alpha-reach.kakao.com";
            case Sandbox:
                return "sandbox-reach.kakao.com";
            case Beta:
                return "beta-reach.kakao.com";
            case Release:
                return "reach.kakao.com";
            default:
                return null;
        }
    }
}
