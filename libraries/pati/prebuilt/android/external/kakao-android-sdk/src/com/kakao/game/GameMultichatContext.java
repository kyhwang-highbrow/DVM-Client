package com.kakao.game;

import com.kakao.kakaotalk.ChatFilterBuilder;
import com.kakao.kakaotalk.ChatListContext;
import com.kakao.kakaotalk.KakaoTalkService.ChatType;

/**
 * Created by house.dr on 15. 9. 8..
 */
public class GameMultichatContext {

    private ChatListContext chatListContext;

    private GameMultichatContext(ChatFilterBuilder filterBuilder, int fromId, int limit) {
        chatListContext = ChatListContext.createContext(filterBuilder, fromId, limit, "asc");
    }

    public static GameMultichatContext createContext(final ChatFilterBuilder filterBuilder, final int fromId, final int limit) {
        return new GameMultichatContext(filterBuilder, fromId, limit);
    }

    public ChatListContext getChatListContext() {
        return chatListContext;
    }
}
