package com.kakao.cocos2dx.plugin;
import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.widget.Toast;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import android.text.TextUtils;
import com.kakao.api.KakaoLeaderboard;
import com.kakao.api.KakaoResponseHandler;
import com.kakao.api.Logger;

public class KakaoLeaderboardService extends KakaoAndroid {
    private KakaoLeaderboard kakaoLeaderboard = null;

    private static KakaoLeaderboardService instance = null;
    public static KakaoLeaderboardService getInstance() {
        if (instance == null) {
            if (instance == null) {
                instance = new KakaoLeaderboardService();
            }
        }
        return instance;
    }

    public void process(final Activity activity, final JSONObject param) throws Exception {
        final String action = param.getString(KakaoStringKey.action);

        if( kakaoLeaderboard==null ) {
            kakaoLeaderboard = KakaoLeaderboard.getInstance();
        }

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if( action.equals(KakaoStringKey.Action.LoadGameInfo)==true ) {
                    kakaoLeaderboard.loadGameInfo(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    });
                }
                else if( action.equals(KakaoStringKey.Action.LoadGameUserInfo)==true ) {
                    kakaoLeaderboard.loadGameMe(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            try {
                                String publicData = result.optString("public_data");
                                if( publicData!=null ){
                                    byte[] decoded = Base64.decode(publicData, 0);
                                    publicData = new String(decoded);

                                    result.putOpt("public_data", publicData);
                                }

                                String private_data = result.optString("private_data");
                                if( private_data!=null ){
                                    byte[] decoded = Base64.decode(private_data, 0);
                                    private_data = new String(decoded);
                                    result.putOpt("private_data", private_data);
                                }
                            } catch (JSONException e) {
                                // TODO Auto-generated catch block
                                e.printStackTrace();
                            }
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    });
                }
                else if( action.equals(KakaoStringKey.Action.UpdateUser)==true ) {
                    byte[] publicData = null;
                    String encodedPublicData = null;
                    encodedPublicData = param.optString(KakaoStringKey.Leaderboard.publicData);
                    if (encodedPublicData!=null && encodedPublicData.length() > 0)
                    {
                        publicData = encodedPublicData.getBytes();
                    }

                    byte[] privateData = null;
                    String encodedPrivateData = null;
                    encodedPrivateData = param.optString(KakaoStringKey.Leaderboard.privateData);
                    if (encodedPrivateData!=null && encodedPrivateData.length() > 0)
                    {
                        privateData = encodedPrivateData.getBytes();
                    }

                    String heartString = null;
                    int heart = 0;
                    heartString = param.optString(KakaoStringKey.Leaderboard.additionalHeart);
                    if( TextUtils.isEmpty(heartString)==false ) {
                        heart = Integer.parseInt(heartString);
                    }

                    String currentHeartString = null;
                    int currentHeart = 0;
                    currentHeartString = param.optString(KakaoStringKey.Leaderboard.currentHeart);
                    if( TextUtils.isEmpty(currentHeartString)==false ) {
                        currentHeart = Integer.parseInt(currentHeartString);
                    }

                    kakaoLeaderboard.updateMe(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    }, heart, currentHeart, publicData, privateData);
                }
                else if( action.equals(KakaoStringKey.Action.UseHeart)==true ) {

                    String useHeartString = param.optString(KakaoStringKey.Leaderboard.useHeart);
                    int useHeart = 0;
                    if( TextUtils.isEmpty(useHeartString)==false ) {
                        useHeart = Integer.parseInt(useHeartString);
                    }

                    kakaoLeaderboard.useHeart(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    }, useHeart);
                }
                else if( action.equals(KakaoStringKey.Action.UpdateResult)==true ) {
                    String leaderboardKey = param.optString(KakaoStringKey.Leaderboard.leaderboardKey);
                    String scoreString = param.optString(KakaoStringKey.Leaderboard.score);
                    int score = 0;
                    if( TextUtils.isEmpty(scoreString)==false ) {
                        score = Integer. parseInt(scoreString);
                    }

                    String expString = param.optString(KakaoStringKey.Leaderboard.exp);
                    int exp = 0;
                    if( TextUtils.isEmpty(expString)==false ) {
                        exp = Integer. parseInt(expString);
                    }

                    byte[] publicData = null;
                    String encodedPublicData = param.optString(KakaoStringKey.Leaderboard.publicData);
                    if (encodedPublicData!=null && encodedPublicData.length() > 0)
                    {
                        publicData = encodedPublicData.getBytes();
                    }

                    byte[] privateData = null;
                    String encodedPrivateData = param.optString(KakaoStringKey.Leaderboard.privateData);
                    if (encodedPrivateData!=null && encodedPrivateData.length() > 0)
                    {
                        privateData = encodedPrivateData.getBytes();
                    }
                    kakaoLeaderboard.updateResult(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }


                    }, leaderboardKey, score, exp, publicData, privateData);
                }
                else if( action.equals(KakaoStringKey.Action.UpdateMultipleResults)==true ) {
                    JSONObject multipleLeaderboards = param.optJSONObject(KakaoStringKey.Leaderboard.multipleLeaderboards);
                    HashMap<String, Integer> scores = new HashMap<String,Integer>();

                    @SuppressWarnings("unchecked")
                    Iterator<String> keys = multipleLeaderboards.keys();
                    while(keys.hasNext()){
                        String leaderboardKey = keys.next();
                        Integer score = multipleLeaderboards.optInt(leaderboardKey,0);
                        scores.put(leaderboardKey, score);
                    }

                    int exp = param.optInt(KakaoStringKey.Leaderboard.exp,0);

                    byte[] publicData = null;
                    String encodedPublicData = param.optString(KakaoStringKey.Leaderboard.publicData);
                    if (encodedPublicData!=null && encodedPublicData.length() > 0)
                    {
                        publicData = encodedPublicData.getBytes();
                    }

                    byte[] privateData = null;
                    String encodedPrivateData = param.optString(KakaoStringKey.Leaderboard.privateData);
                    if (encodedPrivateData!=null && encodedPrivateData.length() > 0)
                    {
                        privateData = encodedPrivateData.getBytes();
                    }

                    kakaoLeaderboard.updateResults(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        protected void onComplete(int httpstatus, int kakaostatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        protected void onError(int httpstatus, int kakaostatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    }, scores, exp, publicData, privateData);
                }
                else if( action.equals(KakaoStringKey.Action.LoadLeaderboard)==true ) {
                    final String leaderboardKeyString = param.optString(KakaoStringKey.Leaderboard.leaderboardKey);
                    kakaoLeaderboard.loadLeaderboard(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            try {
                                result.put(KakaoStringKey.Leaderboard.leaderboardKey, leaderboardKeyString);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    }, leaderboardKeyString);
                }
                else if( action.equals(KakaoStringKey.Action.BlockMessage)==true ) {
                    String blockString = param.optString(KakaoStringKey.Leaderboard.block);
                    boolean block = false;
                    if( TextUtils.isEmpty(blockString)==false ) {
                        block = blockString.equals("true");
                    }

                    kakaoLeaderboard.blockMessage(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }
                        @Override
                        public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    }, block);
                }
                else if( action.equals(KakaoStringKey.Action.SendLinkGameMessage)==true ) {
                    Logger.getInstance().w(param.toString());

                    final String userId = param.optString(KakaoStringKey.Leaderboard.receiverId,null);
                    final String templateId = param.optString(KakaoStringKey.Leaderboard.templateId,null);
                    final String gameMessage = param.optString(KakaoStringKey.Leaderboard.gameMessage,null);
                    final int heart = param.optInt(KakaoStringKey.Leaderboard.heart, 0);

                    byte[] data = null;
                    String encodedData = param.optString(KakaoStringKey.Leaderboard.data,null);
                    if (encodedData!=null ) {
                        data = encodedData.getBytes();
                    }

                    String _imagePath = null;
                    if( param.has(KakaoStringKey.Leaderboard.imageURL)==true ) {
                        _imagePath 		= param.optString(KakaoStringKey.Leaderboard.imageURL, null);
                    }
                    final String imagePath = _imagePath;

                    String _executeUrl = null;
                    if( param.has(KakaoStringKey.Leaderboard.executeUrl)==true ) {
                        _executeUrl 		= param.optString(KakaoStringKey.Leaderboard.executeUrl, null);
                    }
                    final String executeUrl = _executeUrl;

                    JSONObject _metaInfo = null;
                    if( param.has(KakaoStringKey.metaInfo)==true ) {
                        _metaInfo 	= param.optJSONObject(KakaoStringKey.metaInfo);
                    }
                    final JSONObject metaInfo = _metaInfo;

                    if( TextUtils.isEmpty(templateId) || TextUtils.isEmpty(userId) ) {
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(activity.getApplicationContext(), "Invalid parameter. please check templateId and receiverId.", Toast.LENGTH_LONG).show();
                            }
                        });
                        return;
                    }

                    final HashMap<String, Object> linkMessageMetaInfo = new HashMap<String, Object>();
                    if( executeUrl!=null )
                        linkMessageMetaInfo.put("executeurl",executeUrl);

                    if( imagePath!=null && imagePath.length()>0 ) {
                        Logger.getInstance().d(imagePath);
                        Bitmap image = null;
                        try {
                            image = BitmapFactory.decodeStream((InputStream) new URL(imagePath).getContent());
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        if( image!=null )
                            linkMessageMetaInfo.put("image",image);
                    }

                    if( metaInfo!=null ) {
                        Iterator<String> keys = metaInfo.keys();
                        while( keys.hasNext() ){
                            String key = keys.next();
                            try {
                                String value = metaInfo.getString(key);
                                if( value!=null ) {
                                    linkMessageMetaInfo.put(key, value);
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                    }

                    final byte[] finalData = data;

                    kakaoLeaderboard.sendLinkGameMessage(activity.getApplicationContext(), new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            sendError(action, result);
                        }

                        @Override
                        protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            sendSuccess(action, result);
                        }
                    }, userId, templateId, gameMessage, heart, finalData, linkMessageMetaInfo);
                }
                else if( action.equals(KakaoStringKey.Action.SendInviteLinkGameMessage)==true ) {
                    final String userId = param.optString(KakaoStringKey.Leaderboard.receiverId,null);
                    final String templateId = param.optString(KakaoStringKey.Leaderboard.templateId,null);

                    String _executeUrl = null;
                    if( param.has(KakaoStringKey.Leaderboard.executeUrl)==true ) {
                        _executeUrl 		= param.optString(KakaoStringKey.Leaderboard.executeUrl, null);
                    }
                    final String executeUrl = _executeUrl;

                    JSONObject _metaInfo = null;
                    if( param.has(KakaoStringKey.metaInfo)==true ) {
                        _metaInfo 	= param.optJSONObject(KakaoStringKey.metaInfo);
                    }
                    final JSONObject metaInfo = _metaInfo;

                    if( TextUtils.isEmpty(templateId) || TextUtils.isEmpty(userId) ) {
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(activity.getApplicationContext(), "Invalid parameter. please check templateId and receiverId.", Toast.LENGTH_LONG).show();
                            }
                        });
                        return;
                    }

                    final HashMap<String, Object> linkMessageMetaInfo = new HashMap<String, Object>();
                    if( executeUrl!=null )
                        linkMessageMetaInfo.put("executeurl",executeUrl);

                    if( metaInfo!=null ) {
                        Iterator<String> keys = metaInfo.keys();
                        while( keys.hasNext() ){
                            String key = keys.next();
                            try {
                                String value = metaInfo.getString(key);
                                if( value!=null ) {
                                    linkMessageMetaInfo.put(key, value);
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                    }

                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            kakaoLeaderboard.sendInviteLinkGameMessage(activity.getApplicationContext(), new KakaoResponseHandler(activity.getApplicationContext()) {

                                @Override
                                protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                                    sendError(action, result);
                                }

                                @Override
                                protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                                    sendSuccess(action, result);
                                }
                            }, userId, templateId, linkMessageMetaInfo);
                        }
                    });
                }
                else if( action.equals(KakaoStringKey.Action.LoadGameFriends)==true ) {
                    kakaoLeaderboard.loadGamefriends(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            JSONArray appFriendArray = result.optJSONArray("app_friends");
                            for (int i = 0, n = appFriendArray.length(); i < n; i++) {
                                JSONObject friend = appFriendArray.optJSONObject(i);
                                if (friend != null) {
                                    String publicData = friend.optString("public_data");
                                    if( publicData!=null ) {
                                        byte[] decoded = Base64.decode(publicData, 0);
                                        publicData = new String(decoded);
                                        try {
                                            friend.putOpt("public_data", publicData);
                                        } catch (JSONException e) {
                                            e.printStackTrace();
                                        }
                                    }
                                }
                            }
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    });
                }
                else if( action.equals(KakaoStringKey.Action.LoadGameMessages)==true ) {
                    kakaoLeaderboard.loadMessages(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            if (result.has("messages") == true) {
                                JSONArray messageArray = result.optJSONArray("messages");
                                if (messageArray != null && messageArray.length() > 0) {
                                    JSONArray renewMessageArray = new JSONArray();
                                    try {
                                        for (int i = 0; i < messageArray.length(); i++) {
                                            JSONObject message = messageArray.optJSONObject(i);
                                            if (message == null) {
                                                continue;
                                            }
                                            String data = message.optString("data");
                                            if (data == null || data.length() == 0) {
                                                renewMessageArray.put(message);
                                            } else {
                                                byte[] decoded = Base64.decode(data, 0);
                                                data = new String(decoded);
                                                message.putOpt("data", data);
                                                renewMessageArray.put(message);
                                            }
                                        }

                                        result.putOpt("messages", renewMessageArray);
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }
                                }
                            }

                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    });
                }
                else if( action.equals(KakaoStringKey.Action.AcceptGameMessage)==true ) {
                    final String messageId = param.optString(KakaoStringKey.Leaderboard.messageId);
                    kakaoLeaderboard.acceptMessage(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            try {
                                result.put(KakaoStringKey.Leaderboard.messageId, messageId);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }

                    }, messageId);
                }
                else if( action.equals(KakaoStringKey.Action.AcceptAllGameMessages)==true ) {
                    kakaoLeaderboard.acceptAllMessages(new KakaoResponseHandler(activity.getApplicationContext()) {

                        @Override
                        protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    });
                }
                else if( action.equals(KakaoStringKey.Action.DeleteUser)==true ) {
                    kakaoLeaderboard.deleteMe(new KakaoResponseHandler(activity.getApplicationContext()) {
                        @Override
                        public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendSuccess(action, result);
                        }

                        @Override
                        public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
                            KakaoAndroid.getInstance().sendError(action, result);
                        }
                    });
                }
            }
        });
    }
}
