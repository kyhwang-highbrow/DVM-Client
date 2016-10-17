package com.kakao.gameutil.helper;

import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;

/**
 * Created by house.dr on 15. 9. 16..
 */
public class BodyParser {
    public static Integer optInteger(ResponseBody body, String key) {
        if (body.has(key)) {
            try {
                return body.getInt(key);
            } catch (ResponseBodyException e) {
                return null;
            }
        } else {
            return null;
        }
    }

    public static Long optLong(ResponseBody body, String key) {
        if (body.has(key)) {
            try {
                return body.getLong(key);
            } catch (ResponseBodyException e) {
                return null;
            }
        } else {
            return null;
        }
    }

    public static Boolean optBool(ResponseBody body, String key) {
        if (body.has(key)) {
            try {
                return body.getBoolean(key);
            } catch (ResponseBodyException e) {
                return null;
            }
        } else {
            return null;
        }
    }
}
