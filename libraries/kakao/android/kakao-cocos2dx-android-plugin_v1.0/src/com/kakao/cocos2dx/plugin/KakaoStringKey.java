package com.kakao.cocos2dx.plugin;

public class KakaoStringKey {
	
	public class Action {
		static final public String Init 					= "Init";
		static final public String Authorized				= "Authorized";
		static final public String Login 					= "Login";
		static final public String LocalUser 				= "LocalUser";
		static final public String Friends 					= "Friends";
        static final public String ShowMessageBlockDialog = "ShowMessageBlockDialog";
		static final public String SendLinkMessage          = "SendLinkMessage";
		static final public String PostToKakaoStory			= "PostToKakaoStory";
		static final public String GetExecuteUrl			= "GetExecuteUrl";
		static final public String Logout 					= "Logout";
		static final public String Unregister 				= "Unregister";
		static final public String Token					= "Token";
		static final public String ShowAlertMessage			= "ShowAlertMessage";

        // Invitation Tracking
        static final public String InvitationEvent = "InvitationEvent";
        static final public String InvitationStates = "InvitationStates";
        static final public String InvitationHost = "InvitationHost";
		
		static final public String LoadGameInfo = "LoadGameInfo";
		static final public String LoadGameUserInfo = "LoadGameUserInfo";
		static final public String UpdateUser = "UpdateUser";
		static final public String UseHeart = "UseHeart";
		static final public String UpdateResult = "UpdateResult";
		static final public String UpdateMultipleResults = "UpdateMultipleResults";
		static final public String LoadLeaderboard = "LoadLeaderboard";
		static final public String BlockMessage = "BlockMessage";
		static final public String SendLinkGameMessage = "SendLinkGameMessage";
		static final public String SendInviteLinkGameMessage = "SendInviteLinkGameMessage";
		static final public String LoadGameFriends = "LoadGameFriends";
		static final public String LoadGameMessages = "LoadGameMessages";
		static final public String AcceptGameMessage = "AcceptGameMessage";
		static final public String AcceptAllGameMessages = "AcceptAllGameMessages";
		static final public String DeleteUser = "DeleteUser";
	};
	
	static public String action 			= "action";
	
	// auth
	static public String authorized 		= "authorized";
	
	// for init
	static final public String clientId 	= "clientId";
	static final public String secretKey 	= "secretKey";
	
	// for message
	static final public String message 		= "message";
	static final public String receiverId 	= "receiverId";
	static final public String executeUrl 	= "executeUrl";
	
	// for image message
	static final public String templateId 	= "templateId";
	static final public String imageURL     = "imageURL";
	static final public String metaInfo 	= "metaInfo";
	
	// result
	static final public String result		= "result";
	static final public String error		= "error";
	
	static final public String access_token	= "access_token";
	static final public String refresh_token= "refresh_token";
	
	public class Leaderboard {
		static public final String block 			= "block";
		static public final String talkMessage 		= "talkMessage";
		static public final String gameMessage 		= "gameMessage";
		static public final String heart		 	= "heart";
		static public final String useHeart			= "useHeart";
		static public final String currentHeart		= "currentHeart";
		static public final String additionalHeart 	= "additionalHeart";
		static public final String executeUrl 		= "executeUrl";
		static public final String data 			= "data";
		static public final String idArray 			= "idArray";
		
		static public final String publicData		= "public_data";
		static public final String privateData		= "private_data";
		
		static public final String leaderboardKey		= "leaderboardKey";
		static public final String multipleLeaderboards	= "multipleLeaderboards";
		static public final String score 				= "score";
		static public final String exp 					= "exp";
		
		static public final String scores				= "scores";
		static public final String heartRegenStartsAt	= "heart_regen_starts_at";
		static public final String messageCount			= "message_count";
		static public final String serverTime			= "server_time";
		
		static public final String appFriends			= "app_friends";
		static public final String friends				= "friends";
		static public final String bestScore			= "best_score";
		static public final String lastSeasonScore		= "last_season_score";
		static public final String lastScore			= "last_score";
		static public final String seasonScore			= "season_score";
		
		static public final String lastMessageSentAt	= "last_message_sent_at";
		static public final String messageSentAt		= "message_sent_at";
		static public final String rank					= "rank";
		static public final String updateToken			= "update_token";
		
		
		static public final String messageId			= "message_id";
		static public final String senderId				= "sender_id";
		static public final String senderNickName		= "sender_nickname";
		static public final String senderProfileImageUrl = "sender_profile_image_url";
		static public final String message				= "message";
		static public final String sentAt				= "sent_at";
		
		static public final String messages				= "messages";
		static public final String receiverId 			= "receiver_id";
		static public final String templateId 			= "template_id";
        static final public String metaInfo 	        = "metaInfo";
        static final public String imageURL             = "imageURL";
	}
}
