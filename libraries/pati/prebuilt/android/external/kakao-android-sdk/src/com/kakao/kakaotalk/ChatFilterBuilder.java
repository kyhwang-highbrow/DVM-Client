package com.kakao.kakaotalk;

import com.kakao.util.helper.log.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by leoshin on 16. 2. 17..
 * 권한이 있는 채팅방의 리스트중, 내가 얻어올 수 있는 채팅방의 목록을 filtering 하기위해 필요한 데이터를 만들어주는 wrapper class.
 * filter로 넘겨주었지만 권한이 없는경우, 채팅방이 내려가지 않을 수 있다.
 */
public class ChatFilterBuilder {
    public enum ChatFilter {
        /**
         * 카카오톡 OPEN 채팅방
         */
        OPEN("open"),

        /**
         * 카카오톡 일반 채팅방
         */
        REGULAR("regular"),

        /**
         * 그룹 채팅방
         */
        MULTI("multi"),

        /**
         * 1:1 방
         */
        DIRECT("direct");

        private String value;
        ChatFilter(String value) {
            this.value = value;
        }
    }

    private final List<ChatFilter> filterList = new ArrayList<>();

    public ChatFilterBuilder addFilter(ChatFilter filter) {
        filterList.add(filter);
        return this;
    }

    public String build() {
        String filterString = "";

        int size = filterList.size();
        for (int i = 0; i < size; i++) {
            filterString += filterList.get(i).value;
            if (i < size) {
                filterString += ",";
            }
        }

        Logger.i("filter = " + filterString);
        return filterString;
    }
}
