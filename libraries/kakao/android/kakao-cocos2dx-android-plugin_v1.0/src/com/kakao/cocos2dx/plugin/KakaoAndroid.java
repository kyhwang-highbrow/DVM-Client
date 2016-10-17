package com.kakao.cocos2dx.plugin;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONException;
import org.json.JSONObject;

import com.kakao.api.Kakao;
import com.kakao.api.Kakao.KakaoTokenListener;
import com.kakao.api.KakaoResponseHandler;
import com.kakao.api.Logger;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.net.Uri;
import android.text.TextUtils;
import android.widget.Toast;

public class KakaoAndroid {

	static final private String targetGameObject 			= "KakaoResponseHandler";
	static final private String targetResponseMethod		= "onKakaoResonseComplete";
	static final private String targetErrorMethod			= "onKakaoResonseError";
	
	// @kakao
	static final private String clientId					= "91408462712127840";
	static final private String secretKey					= "A2jBin4gNc0EJ1DVQQs1Dnxw5WtaZgmJgX1Clm6FnGugU2v+bYb+8mu2MMtSmb/3AJ/mxwMW1kjHqcSIfcSrkg==";
	
	static private 	Kakao kakao = null;
	static public 	KakaoAndroidInterface plugin = null;
	static public 	Uri uri = null;

	private HashMap<String,KakaoResponseHandler> handlers = new HashMap<String, KakaoResponseHandler>();
	
    private static KakaoAndroid instance = null;
    public static KakaoAndroid getInstance() {
            if (instance == null) {
                  if (instance == null) {
                        instance = new KakaoAndroid();
                  }
            }
            return instance;
    }
    
    public Kakao getKakao() {
    	return kakao;
    }
    
    public void init(final Activity activity, final String accessToken, final String refreshToken) throws Exception {
    	handlers.clear();

    	activity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Context context = activity.getApplicationContext();
				KakaoResponseHandler loginResponseHandler = new KakaoResponseHandler(context) {
					@Override
					public void onStart() {
						super.onStart();
					}

					@Override
					public void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
						sendSuccess(KakaoStringKey.Action.Login,null);
					}

					@Override
					public void onError(int httpStatus, int kakaoStatus, JSONObject result) {
						sendError(KakaoStringKey.Action.Login, result);
					}
				};
				handlers.put(KakaoStringKey.Action.Login, loginResponseHandler);

				KakaoResponseHandler localUserResponseHandler = new KakaoResponseHandler(context) {

					@Override
					protected void onComplete(int arg0, int arg1, JSONObject arg2) {
						sendSuccess(KakaoStringKey.Action.LocalUser,arg2);
					}

					@Override
					protected void onError(int arg0, int arg1, JSONObject arg2) {
						sendError(KakaoStringKey.Action.LocalUser, arg2);
					}
				};
				handlers.put(KakaoStringKey.Action.LocalUser, localUserResponseHandler);

				KakaoResponseHandler friendsResponseHandler = new KakaoResponseHandler(context) {
					@Override
					protected void onComplete(int arg0, int arg1, JSONObject arg2) {
						sendSuccess(KakaoStringKey.Action.Friends,arg2);
					}

					@Override
					protected void onError(int arg0, int arg1, JSONObject arg2) {
						sendError(KakaoStringKey.Action.Friends, arg2);
					}
				};
				handlers.put(KakaoStringKey.Action.Friends, friendsResponseHandler);

                KakaoResponseHandler messageBlockDialogResponseHandler = new KakaoResponseHandler(context) {
                    @Override
                    protected void onComplete(int arg0, int arg1, JSONObject arg2) {
                        sendSuccess(KakaoStringKey.Action.ShowMessageBlockDialog,arg2);
                    }

                    @Override
                    protected void onError(int arg0, int arg1, JSONObject arg2) {
                        sendError(KakaoStringKey.Action.ShowMessageBlockDialog, arg2);
                    }
                };
                handlers.put(KakaoStringKey.Action.ShowMessageBlockDialog, messageBlockDialogResponseHandler);

				KakaoResponseHandler sendLinkMessageResponseHandler = new KakaoResponseHandler(context) {
					@Override
					protected void onComplete(int arg0, int arg1, JSONObject arg2) {
						sendSuccess(KakaoStringKey.Action.SendLinkMessage,null);
					}

					@Override
					protected void onError(int arg0, int arg1, JSONObject arg2) {
						sendError(KakaoStringKey.Action.SendLinkMessage, arg2);
					}
				};
				handlers.put(KakaoStringKey.Action.SendLinkMessage, sendLinkMessageResponseHandler);

				KakaoResponseHandler logoutResponseHandler = new KakaoResponseHandler(context) {
					@Override
					protected void onComplete(int arg0, int arg1, JSONObject arg2) {
						sendSuccess(KakaoStringKey.Action.Logout,null);
					}

					@Override
					protected void onError(int arg0, int arg1, JSONObject arg2) {
						sendError(KakaoStringKey.Action.Logout, arg2);
					}
				};
				handlers.put(KakaoStringKey.Action.Logout, logoutResponseHandler);

				KakaoResponseHandler unregisterResponseHandler = new KakaoResponseHandler(context) {
					@Override
					protected void onComplete(int arg0, int arg1, JSONObject arg2) {
						sendSuccess(KakaoStringKey.Action.Unregister,null);
					}

					@Override
					protected void onError(int arg0, int arg1, JSONObject arg2) {
						sendError(KakaoStringKey.Action.Unregister, arg2);
					}
				};
				handlers.put(KakaoStringKey.Action.Unregister, unregisterResponseHandler);

                KakaoResponseHandler storyPostHandler = new KakaoResponseHandler(context) {
                    @Override
                    protected void onComplete(int arg0, int arg1, JSONObject arg2) {
                        sendSuccess(KakaoStringKey.Action.PostToKakaoStory,null);
                    }

                    @Override
                    protected void onError(int arg0, int arg1, JSONObject arg2) {
                        sendError(KakaoStringKey.Action.PostToKakaoStory, arg2);
                    }
                };
                handlers.put(KakaoStringKey.Action.PostToKakaoStory, storyPostHandler);

                KakaoResponseHandler invitationEventHandler = new KakaoResponseHandler(context) {
                    @Override
                    protected void onComplete(int arg0, int arg1, JSONObject arg2) {
                        sendSuccess(KakaoStringKey.Action.InvitationEvent,arg2);
                    }

                    @Override
                    protected void onError(int arg0, int arg1, JSONObject arg2) {
                        sendError(KakaoStringKey.Action.InvitationEvent, arg2);
                    }
                };
                handlers.put(KakaoStringKey.Action.InvitationEvent, invitationEventHandler);

                KakaoResponseHandler invitationStatesHandler = new KakaoResponseHandler(context) {
                    @Override
                    protected void onComplete(int arg0, int arg1, JSONObject arg2) {
                        sendSuccess(KakaoStringKey.Action.InvitationStates,arg2);
                    }

                    @Override
                    protected void onError(int arg0, int arg1, JSONObject arg2) {
                        sendError(KakaoStringKey.Action.InvitationStates, arg2);
                    }
                };
                handlers.put(KakaoStringKey.Action.InvitationStates, invitationStatesHandler);

                KakaoResponseHandler invitationHostHandler = new KakaoResponseHandler(context) {
                    @Override
                    protected void onComplete(int arg0, int arg1, JSONObject arg2) {
                        sendSuccess(KakaoStringKey.Action.InvitationHost,arg2);
                    }

                    @Override
                    protected void onError(int arg0, int arg1, JSONObject arg2) {
                        sendError(KakaoStringKey.Action.InvitationHost, arg2);
                    }
                };
                handlers.put(KakaoStringKey.Action.InvitationHost, invitationHostHandler);

                KakaoTokenListener tokenListener = new KakaoTokenListener() {
		            public void onSetTokens(String accessToken, String refreshToken) {
		                try {
		                	JSONObject tokens = new JSONObject();
		                	tokens.put(KakaoStringKey.access_token, accessToken);
		                	tokens.put(KakaoStringKey.refresh_token, refreshToken);
			                sendSuccess(KakaoStringKey.Action.Token,tokens);
						} catch (JSONException e) {
							e.printStackTrace();
						}
		            }
		        };

		        try {
					kakao = new Kakao(context,clientId, secretKey, "kakao"+clientId+"://exec");
					kakao.setTokenListener(tokenListener);
			        kakao.setTokens(accessToken, refreshToken);
			        sendSuccess(KakaoStringKey.Action.Init,null);

				} catch (Exception e) {
					e.printStackTrace();
				}
			}
    	});
    }

    public void execute(final Activity activity, final String param) {
    	JSONObject json = null;
		try {
			json = new JSONObject(param);
			process(activity,json);
		} catch (Exception e) {
			e.printStackTrace();
		}
    }
    
    public void sendSuccess(String action, JSONObject result) {
    	JSONObject json = new JSONObject();
    	try {
			json.put(KakaoStringKey.action, action);
			json.put(KakaoStringKey.result, result);

	    	plugin.sendMessage(targetGameObject, targetResponseMethod, json.toString());
		} catch (JSONException e) {
			e.printStackTrace();
		}
    }
    
    public void sendError(String action, JSONObject error) {
    	JSONObject json = new JSONObject();
    	try {
			json.put(KakaoStringKey.action, action);
	    	json.put(KakaoStringKey.error,error);
	    	plugin.sendMessage(targetGameObject, targetErrorMethod, json.toString());
		} catch (JSONException e) {
			e.printStackTrace();
		}
    }
    
    protected void process(final Activity activity, final JSONObject param) throws Exception {
    	final String action = param.getString(KakaoStringKey.action);
    	
    	if( action.equals(KakaoStringKey.Action.Init)==true ) {
    		
    		String accessToken = null;
    		if( param.has(KakaoStringKey.access_token)==true ) {
    			accessToken 	= param.getString(KakaoStringKey.access_token);
    		}
    		
    		String refreshToken = null;
    		if( param.has(KakaoStringKey.refresh_token)==true ) {
    			refreshToken = param.getString(KakaoStringKey.refresh_token);
    		}
    		
    		init(activity,accessToken, refreshToken);
        }
    	else if( action.equals(KakaoStringKey.Action.Authorized)==true ) {
    		JSONObject result = new JSONObject();
    		result.put(KakaoStringKey.authorized, kakao.hasTokens()==true?"true":"false");
    		sendSuccess(action,result);
    	}
    	else if( action.equals(KakaoStringKey.Action.Login)==true ) {
    		activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					kakao.login(activity, handlers.get(action));
				}
			});
    	}
    	else if( action.equals(KakaoStringKey.Action.LocalUser)==true ) {
    		activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					kakao.localUser(handlers.get(action));
				}
			});
    	}
    	else if( action.equals(KakaoStringKey.Action.Friends)==true ) {
    		activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					kakao.friends(handlers.get(action));
				}
            });
    	}
        else if( action.equals(KakaoStringKey.Action.ShowMessageBlockDialog)==true ) {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    kakao.showMessageBlockDialog(activity, handlers.get(action));
                }
            });
        }
    	else if( action.equals(KakaoStringKey.Action.SendLinkMessage)==true ) {
            final String templateId 		= param.getString(KakaoStringKey.templateId);
            final String receiverId 			= param.getString(KakaoStringKey.receiverId);

            String _imagePath = null;
            if( param.has(KakaoStringKey.imageURL)==true ) {
                _imagePath 		= param.getString(KakaoStringKey.imageURL);
            }
            final String imagePath = _imagePath;

            String _executeUrl = null;
            if( param.has(KakaoStringKey.executeUrl)==true ) {
                _executeUrl 		= param.getString(KakaoStringKey.executeUrl);
            }
            final String executeUrl = _executeUrl;

            JSONObject _metaInfo = null;
            if( param.has(KakaoStringKey.metaInfo)==true ) {
                _metaInfo 	= param.getJSONObject(KakaoStringKey.metaInfo);
            }
            final JSONObject metaInfo = _metaInfo;

            if( TextUtils.isEmpty(templateId) || TextUtils.isEmpty(receiverId) ) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity.getApplicationContext(),"Invalid parameter. please check templateId and receiverId.",Toast.LENGTH_LONG).show();
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
                    image = BitmapFactory.decodeStream((InputStream)new URL(imagePath).getContent());
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

            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {

                    kakao.sendLinkMessage(activity.getApplicationContext(), handlers.get(action), receiverId, templateId, linkMessageMetaInfo);
                }
            });
    	}
    	else if( action.equals(KakaoStringKey.Action.PostToKakaoStory)==true ) {

    		final String imageURL = param.getString(KakaoStringKey.imageURL);
            final String message  = param.getString(KakaoStringKey.message);

    		activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Bitmap image = null;
					if( imageURL!=null && imageURL.length()>0 ) {
                        URL url = null;
                        try {
                            url = new URL(imageURL);
                        } catch (MalformedURLException e) {
                            e.printStackTrace();
                        }
                        try {
                            image = BitmapFactory.decodeStream(url.openConnection().getInputStream());
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        if (image != null)
					        // 스토리 포스팅 액티비티 실행
					        kakao.startPostStoryActivity(handlers.get(action), activity, ThirdPartyPostStoryActivity.class, image, message);
                    }
				}
			});
    	}
        else if (action.equals(KakaoStringKey.Action.InvitationEvent) == true) {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    kakao.loadInvitationEvent(handlers.get(action));
                }
            });
        }
        else if (action.equals(KakaoStringKey.Action.InvitationStates) == true) {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    kakao.loadInvitationStates(handlers.get(action));
                }
            });
        }
        else if (action.equals(KakaoStringKey.Action.InvitationHost) == true) {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    kakao.loadInvitationSender(handlers.get(action));
                }
            });
        }
    	else if( action.equals(KakaoStringKey.Action.Logout)==true ) {
    		activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					kakao.logout(handlers.get(action));
				}
    		});
    	}
    	else if( action.equals(KakaoStringKey.Action.Unregister)==true ) {
    		activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					kakao.unregister(handlers.get(action));
				}
    		});
    	}
    	else if( action.equals(KakaoStringKey.Action.ShowAlertMessage)==true ) {
    		final String message 	= param.getString(KakaoStringKey.message);

    		activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Toast.makeText(activity.getApplicationContext(),message,Toast.LENGTH_LONG).show();
				}
    		});
    	}
    	else {
    		KakaoLeaderboardService.getInstance().process(activity, param);
    	}
    }
    
    public void activityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    	kakao.onActivityResult(requestCode, resultCode, data, activity, handlers.get(KakaoStringKey.Action.Login));
    }
    
    public void resume(Activity activity) {
    	if( kakao==null )
    		return;
    	
    	activity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (kakao.hasTokens()) {
		    		kakao.localUser(handlers.get(KakaoStringKey.Action.LocalUser));
				} else {
					kakao.authorize(handlers.get(KakaoStringKey.Action.Login));
				}
			}
    	});
    }
}
