package com.tnkfactory.offerwall;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ParseException;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tnkfactory.ad.AdvertisingIdInfo;
import com.tnkfactory.ad.Logger;
import com.tnkfactory.ad.NativeAdItem;
import com.tnkfactory.ad.NativeAdListener;
import com.tnkfactory.ad.ServiceCallback;
import com.tnkfactory.ad.TnkAdListener;
import com.tnkfactory.ad.TnkCode;
import com.tnkfactory.ad.TnkLayout;
import com.tnkfactory.ad.TnkSession;
import com.tnkfactory.ad.TnkStyle;

public class MainActivity extends Activity {

	@Override
    public void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
                
        Logger.enableLogging(true);
        
        
        Intent intent = this.getIntent();
        if (intent != null) {
        	Log.d("tnkad","#### getIntent : " + intent.getData());
        	
        	Uri referrerUri = this.getReferrer();
            Log.d("tnkad", "#### get referrer URI : " + referrerUri);
        }
        
        // 상단 타이틀 숨기기
        TnkStyle.AdWall.Header.height = 0;
        
        // 충전소 리스트 포인트 Tag 크기 조절 및 라밸 설정
    	TnkStyle.AdWall.Item.Tag.width = 60;
    	TnkStyle.AdWall.Item.Tag.height = 26;
    	TnkStyle.AdWall.Item.Tag.pointLabelFormat = "{point}{unit}";
    	TnkStyle.AdWall.Item.Tag.confirmLabelFormat = "설치확인";
    	
    	// 충전소 상세화면에서 포인트 Tag 크기 조절 및 라벨 설정
    	TnkStyle.AdWall.Detail.Body.Tag.width = 60;
    	TnkStyle.AdWall.Detail.Body.Tag.height = 26;
    	TnkStyle.AdWall.Detail.Body.Tag.pointLabelFormat = "{point}{unit}";
    	
    	TnkStyle.AdWall.showProgress = false;
    	TnkStyle.AdWall.Detail.showProgress = false;
    	
        //TnkStyle.AdInterstitial.closeButtonHeightScale = 2.0f;
        //TnkStyle.AdInterstitial.closeButtonWidthScale = 2.0f;
        
        // show PPI interstitial AD on start up
        // 전면화면 로직 (Interstital Display logic) 을 사용하여 
        // 서버에서 원하는 공지사항이나 크로스 광고등을 설정할수 있습니다.
        TnkSession.prepareInterstitialAd(this, "notice_start", new TnkAdListener() {

			@Override
			public void onClose(int type) {
				if (type == TnkAdListener.CLOSE_EXIT) {
					MainActivity.this.finish();
				}
			}

			@Override
			public void onFailure(int errCode) {				
			}

			@Override
			public void onLoad() {
				TnkSession.showInterstitialAd(MainActivity.this);
			}

			@Override
			public void onShow() {				
			}
        });
        
        // show PPI offer-wall as activity
        final Button showAdButton = (Button)findViewById(R.id.main_ad);
        showAdButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
   				//TnkStyle.clear();
				TnkSession.showAdList(MainActivity.this,"Your title here");
			}
        });
        
        // show PPI offer-wall as popup view
        final Button showAdPopupButton = (Button)findViewById(R.id.main_ad_popup);
        showAdPopupButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
   				TnkStyle.clear();
				TnkSession.popupAdList(MainActivity.this,"Your title here");
			}
        });
        
        // show PPI interstitial Ad
        final Button showFadButton = (Button)findViewById(R.id.main_fad);
        showFadButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
   				TnkSession.prepareInterstitialAd(MainActivity.this, TnkSession.PPI);
   				TnkSession.showInterstitialAd(MainActivity.this);
			}
        });
        
        // show PPI offer-wall with styled design as activity
        final Button showStyledAdButton = (Button)findViewById(R.id.main_ad_style);
        showStyledAdButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
   				setTnkStyleFull();
				TnkSession.showAdList(MainActivity.this,"Your title here");
			}
        });
        
        // show PPI offer-wall with styled design as popup view
        final Button showStyledAdPopupButton = (Button)findViewById(R.id.main_ad_style_popup);
        showStyledAdPopupButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
   				setTnkStylePopup();
				TnkSession.popupAdList(MainActivity.this,"Your title here", null);
			}
        });
        
        final Button showStyledAdEmbedButton = (Button)findViewById(R.id.main_ad_style_embed);
        showStyledAdEmbedButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
   				setTnkStyleFull();
				Intent intent = new Intent(MainActivity.this, OfferwallEmbedActivity.class);
				startActivity(intent);
			}
        });
        
        // show PPI offer-wall with customzied design as activity
        final Button showCustomziedAdButton = (Button)findViewById(R.id.main_ad_custom);
        showCustomziedAdButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
				TnkSession.showAdList(MainActivity.this,"Your title here", makeLayout());
			}
        });
        
        // show PPI offer-wall with customzied design as popup view
        final Button showCustomziedAdPopupButton = (Button)findViewById(R.id.main_ad_custom_popup);
        showCustomziedAdPopupButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
				TnkSession.popupAdList(MainActivity.this,"Your title here", null, makePopupLayout());
			}
        });
        
        final Button showCustomziedAdEmbedButton = (Button)findViewById(R.id.main_ad_custom_embed);
        showCustomziedAdEmbedButton.setOnClickListener(new OnClickListener() {
   			@Override
			public void onClick(View v) {
				Intent intent = new Intent(MainActivity.this, OfferwallEmbedActivity.class);
				intent.putExtra("tnk_layout", makeLayout());
				startActivity(intent);
			}
        });
        
        // purchase item with tnk point
        final Button buyItemButton = (Button)findViewById(R.id.main_item);
        buyItemButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				TnkSession.purchaseItem(MainActivity.this, 30, "item.00001", true, new ServiceCallback() {
					@Override
					public void onReturn(Context context, Object result) {
						long[] ret = (long[])result;
						Log.d("tnkad", "purchase result " + ret[0] + ", " + ret[1]);
						TextView pointView = (TextView)findViewById(R.id.main_point);
						pointView.setText(String.valueOf(ret[0]));
					}
				});
			}
       	});
        
        // show CPC interstitial Ad
        final Button cpcFadButton = (Button)findViewById(R.id.main_cpc_fad);
        cpcFadButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				TnkSession.prepareInterstitialAd(MainActivity.this, TnkSession.CPC, new TnkAdListener() {

					@Override
					public void onClose(int type) {
						if (type == TnkAdListener.CLOSE_EXIT) {
							MainActivity.this.finish();
						}
					}

					@Override
					public void onFailure(int errCode) {
					}

					@Override
					public void onLoad() {
					}

					@Override
					public void onShow() {
					}
   					
   				});
   				TnkSession.showInterstitialAd(MainActivity.this);
			}
       	});
        
        // show CPC featured Ad
        final Button cpcAdListButton = (Button)findViewById(R.id.main_cpc_ad);
        cpcAdListButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				TnkSession.showMoreApps(MainActivity.this, "Today's Apps");
			}
       	});

        // Native ad
        final Button nativeAdButton = (Button)findViewById(R.id.main_native_ad);
        nativeAdButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				loadNativeAd();
			}
       	});
        
        
        // 사용자 정보를 설정하면 보고서 화면에서 관련된 분석 데이터를 확인하실 수 있습니다.
        TnkSession.setUserGender(this,TnkCode.MALE);
        TnkSession.setUserAge(this, 25);
        
        TnkSession.applicationStarted(this); // for analytics
        
        Thread thread = new Thread() {
        	public void run() {
        	     AdvertisingIdInfo idInfo = AdvertisingIdInfo.requestIdInfo(MainActivity.this);
        	     Log.d("tnkad", "adid : " + idInfo.getId() + " limited : " + idInfo.isLimited());
        	}
        };
        
        thread.start();
       
    }
    
    @Override
    protected void onResume() {
    	super.onResume();
    	
    	final TextView pointView = (TextView)findViewById(R.id.main_point);
        TnkSession.queryPoint(this, true, new ServiceCallback() {
			@Override
			public void onReturn(Context context, Object result) {
				Integer point = (Integer)result;
				pointView.setText(String.valueOf(point));
			}
        });
    }
    
    @Override
	public void onBackPressed() {
		TnkSession.showMoreAppsWithButtons(this, "오늘의 추천앱", "취소", "종료",  new TnkAdListener() {
			@Override
			public void onClose(int type) {
				Log.d("tnkad", "MoreApps onClose() : " + type);
				if (type == TnkAdListener.CLOSE_EXIT) {
					MainActivity.this.finish();
				}
			}

			@Override
			public void onShow() {
				Log.d("tnkad", "MoreApps onShow()");
			}

			@Override
			public void onFailure(int errCode) {				
			}
			
			@Override
			public void onLoad() {
			}
		});
    }
   
    private void loadNativeAd() {
    	Log.d("tnkad", "load Native ad");
    	
    	NativeAdItem adItem = new NativeAdItem(this, NativeAdItem.STYLE_LANDSCAPE | NativeAdItem.STYLE_ICON, new NativeAdListener() {
    	//TnkSession.prepareNativeAd(this, TnkSession.CPC, NativeAdItem.STYLE_LANDSCAPE | NativeAdItem.STYLE_ICON, new NativeAdListener() {

			@Override
			public void onFailure(int errCode) {
				Log.d("tnkad", "Native Ad load error " + errCode);
			}

			@Override
			public void onLoad(NativeAdItem adItem) {
				showNativeAd(adItem);
			}

			@Override
			public void onClick() {
				Log.d("tnkad", "Native Ad onClick.");
			}

			@Override
			public void onShow() {
				Log.d("tnkad", "Native Ad onShow");
			}
    		
    	});
    	
    	adItem.prepareAd("native_ad");
    }
    
    private void showNativeAd(NativeAdItem adItem) {
    	ViewGroup adContainer = (ViewGroup)findViewById(R.id.native_ad_container);
    	adContainer.removeAllViews();
    	
    	// ad view 만들기
    	LayoutInflater inflater = (LayoutInflater)getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    	RelativeLayout adItemView = (RelativeLayout)inflater.inflate(R.layout.native_ad_item, null);
    	
    	ImageView adIcon = (ImageView)adItemView.findViewById(R.id.ad_icon);
    	adIcon.setImageBitmap(adItem.getIconImage());
    	
    	TextView titleView = (TextView)adItemView.findViewById(R.id.ad_title);
    	titleView.setText(adItem.getTitle());
    	
    	TextView descView = (TextView)adItemView.findViewById(R.id.ad_desc);
    	descView.setText(adItem.getDescription());
    	
    	ImageView adImage = (ImageView)adItemView.findViewById(R.id.ad_image);
    	adImage.setImageBitmap(adItem.getCoverImage());
    	
    	adContainer.addView(adItemView);
    	
    	adItem.attachLayout(adItemView);
    }
    
    private TnkLayout makeLayout() {
		TnkLayout res = new TnkLayout();
		
		res.adwall.numColumnsPortrait = 2;
		res.adwall.numColumnsLandscape = 3;
		
		res.adwall.layout = R.layout.myofferwall_adlist;
		res.adwall.idTitle = R.id.offerwall_title;
		res.adwall.idList = R.id.offerwall_adlist;
		
		res.adwall.item.layout = R.layout.myofferwall_item;
		res.adwall.item.height = 150;
		res.adwall.item.idIcon = R.id.ad_icon;
		res.adwall.item.idTitle = R.id.ad_title;
		res.adwall.item.idSubtitle = R.id.ad_desc;
		res.adwall.item.idTag = R.id.ad_tag;
		res.adwall.item.colorBg = 0xffe5e5e5;
		
//		res.adwall.item.bgItemEven = R.drawable.list_item_bg;
//		res.adwall.item.bgItemOdd = R.drawable.list_item_bg2;
		
		res.adwall.item.tag.bgTagFree = R.drawable.az_list_bt_free;
		res.adwall.item.tag.bgTagPaid = R.drawable.az_list_bt_pay;
		res.adwall.item.tag.bgTagWeb = R.drawable.az_list_bt_web;
		res.adwall.item.tag.bgTagCheck = R.drawable.az_list_bt_install;
		
		res.adwall.item.tag.tcTagFree = 0xffffffff;
		res.adwall.item.tag.tcTagPaid = 0xffffffff;
		res.adwall.item.tag.tcTagWeb = 0xffffffff;
		res.adwall.item.tag.tcTagCheck = 0xffffffff;
		
		res.adwall.detail.layout = R.layout.myofferwall_detail;
		res.adwall.detail.idIcon = R.id.ad_icon;
		res.adwall.detail.idTitle = R.id.ad_title;
		res.adwall.detail.idSubtitle = R.id.ad_desc;
		res.adwall.detail.idTag = R.id.ad_tag;
		res.adwall.detail.idAction = R.id.ad_action;
		res.adwall.detail.idConfirm = R.id.ad_ok;
		res.adwall.detail.idCancel = R.id.ad_cancel;
		
		return res;
	}
    
private TnkLayout makePopupLayout() {
	TnkLayout res = new TnkLayout();
	
	res.adwall.numColumnsPortrait = 2;
	res.adwall.numColumnsLandscape = 3;
	
	res.adwall.layout = R.layout.myofferwall_popup;
	res.adwall.idTitle = R.id.offerwall_title;
	res.adwall.idList = R.id.offerwall_adlist;
	res.adwall.idClose = R.id.close_button;
	
	res.adwall.item.layout = R.layout.myofferwall_item;
	res.adwall.item.height = 150;
	res.adwall.item.idIcon = R.id.ad_icon;
	res.adwall.item.idTitle = R.id.ad_title;
	res.adwall.item.idSubtitle = R.id.ad_desc;
	res.adwall.item.idTag = R.id.ad_tag;
	
	//res.adwall.item.bgItemEven = R.drawable.list_item_bg;
	//res.adwall.item.bgItemOdd = R.drawable.list_item_bg2;
	
	res.adwall.item.tag.bgTagFree = R.drawable.az_list_bt_free;
	res.adwall.item.tag.bgTagPaid = R.drawable.az_list_bt_pay;
	res.adwall.item.tag.bgTagWeb = R.drawable.az_list_bt_web;
	res.adwall.item.tag.bgTagCheck = R.drawable.az_list_bt_install;
	
	res.adwall.item.tag.tcTagFree = 0xffffffff;
	res.adwall.item.tag.tcTagPaid = 0xffffffff;
	res.adwall.item.tag.tcTagWeb = 0xffffffff;
	res.adwall.item.tag.tcTagCheck = 0xffffffff;
	
	res.adwall.detail.layout = R.layout.myofferwall_detail;
	res.adwall.detail.idIcon = R.id.ad_icon;
	res.adwall.detail.idTitle = R.id.ad_title;
	res.adwall.detail.idSubtitle = R.id.ad_desc;
	res.adwall.detail.idTag = R.id.ad_tag;
	res.adwall.detail.idAction = R.id.ad_action;
	res.adwall.detail.idConfirm = R.id.ad_ok;
	res.adwall.detail.idCancel = R.id.ad_cancel;
	
	return res;
}
    
    private void setTnkStylePopup() {
    	TnkStyle.clear();
    	
    	TnkStyle.AdWall.background = R.drawable.black_middle_bg;
    	
    	TnkStyle.AdWall.Header.background = R.drawable.black_upper_bg;
    	TnkStyle.AdWall.Header.textColor = 0xffffffff;
    	TnkStyle.AdWall.Header.textSize = 22;
    	
    	TnkStyle.AdWall.Footer.background = R.drawable.black_bottom_bg;
    	TnkStyle.AdWall.Footer.textColor = 0xffffffff;
    	TnkStyle.AdWall.Footer.textSize = 13;
    	
    	TnkStyle.AdWall.Item.Title.textSize = 16;
    	TnkStyle.AdWall.Item.Subtitle.textColor = 0xffff871c;
    	TnkStyle.AdWall.Item.Subtitle.textSize = 12;
    	
   	    TnkStyle.AdWall.Item.Tag.Free.background = R.drawable.az_list_bt_free;
   	    TnkStyle.AdWall.Item.Tag.Free.textColor = 0xffffffff;
   	    TnkStyle.AdWall.Item.Tag.Paid.background = R.drawable.az_list_bt_pay;
   	    TnkStyle.AdWall.Item.Tag.Paid.textColor = 0xffffffff;
   	    TnkStyle.AdWall.Item.Tag.Web.background = R.drawable.az_list_bt_web;
   	    TnkStyle.AdWall.Item.Tag.Web.textColor = 0xffffffff;
   	    TnkStyle.AdWall.Item.Tag.Confirm.background = R.drawable.az_list_bt_install;
   	    TnkStyle.AdWall.Item.Tag.Confirm.textColor = 0xffffffff;
    }
    
    private void setTnkStyleFull() {
    	TnkStyle.clear();
    	
    	TnkStyle.AdWall.Header.backgroundColor = 0xff000000;
    	TnkStyle.AdWall.Header.textColor = 0xffffffff;
    	TnkStyle.AdWall.Header.textSize = 22;
    	
    	TnkStyle.AdWall.Item.Title.textSize = 16;
    	TnkStyle.AdWall.Item.Subtitle.textColor = 0xffff871c;
    	TnkStyle.AdWall.Item.Subtitle.textSize = 12;
    	
   	    TnkStyle.AdWall.Item.Tag.Free.background = R.drawable.az_list_bt_free;
   	    TnkStyle.AdWall.Item.Tag.Free.textColor = 0xffffffff;
   	    TnkStyle.AdWall.Item.Tag.Paid.background = R.drawable.az_list_bt_pay;
   	    TnkStyle.AdWall.Item.Tag.Paid.textColor = 0xffffffff;
   	    TnkStyle.AdWall.Item.Tag.Web.background = R.drawable.az_list_bt_web;
   	    TnkStyle.AdWall.Item.Tag.Web.textColor = 0xffffffff;
   	    TnkStyle.AdWall.Item.Tag.Confirm.background = R.drawable.az_list_bt_install;
   	    TnkStyle.AdWall.Item.Tag.Confirm.textColor = 0xffffffff;
    }
    
    /** Returns the referrer who started this Activity. */
    @Override
    public Uri getReferrer() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            return super.getReferrer();
        }
        return getReferrerCompatible();
    }

    /** Returns the referrer on devices running SDK versions lower than 22. */
    private Uri getReferrerCompatible() {
        Intent intent = this.getIntent();
        Uri referrerUri = intent.getParcelableExtra(Intent.EXTRA_REFERRER);
        if (referrerUri != null) {
            return referrerUri;
        }
        String referrer = intent.getStringExtra("android.intent.extra.REFERRER_NAME");
        if (referrer != null) {
            // Try parsing the referrer URL; if it's invalid, return null
            try {
                return Uri.parse(referrer);
            } catch (ParseException e) {
                return null;
            }
        }
        return null;
    }
}
