package com.kakao.api.story;

import java.io.File;

import org.json.JSONObject;

import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.kakao.api.Kakao;
import com.kakao.api.KakaoResponseHandler;
import com.kakao.api.Logger;
import com.kakao.api.R;
import com.kakao.api.StringKeySet;
import com.kakao.api.imagecache.ImageResizer;
import com.kakao.api.util.KakaoTextUtils;

public abstract class BasePostStoryActivity extends Activity implements OnClickListener {

	private static final String TAG = "BaseWriteArticleActivity";

	private int THUMANIL_IMAGE_MAX_SIZE = 0;
	private int THUMANIL_MASK_MAX_SIZE = 0;

	public static final int IMAGE_MAX = 720;
	public static final int IMAGE_MAX_WIDTH = 800;
	public static final int IMAGE_MAX_HEIGHT = 600;

	protected Button btSubmit = null;
	protected ImageView ivThumbnail = null;
	private ImageView ivThumbMask = null;

	protected EditText etContent = null;
	protected CheckBox cbPermission = null;

	private View customToast = null;

	protected Bitmap bitmap;
	protected Bitmap bitmapThumbnail;

	protected String mediaPath; 
	protected String imagePath;
	protected String postString; 

    private Boolean isPosting = false;


	public static enum UPLOAD_STATE {
		UploadNoExecute, UploadExecute, UploadStart, UploadComplete, UploadError
	}
	public static enum POST_STATE {
		PostNoExecute, PostExecute
	}


	protected UPLOAD_STATE uploadState;
	protected POST_STATE postState;

	private int retryCount = 0;

	protected Kakao kakao;

	private KakaoResponseHandler uploadHandler;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.layout_write_article);

		THUMANIL_IMAGE_MAX_SIZE = dipToPixel(64);
		THUMANIL_MASK_MAX_SIZE = dipToPixel(12);

		uploadState = UPLOAD_STATE.UploadNoExecute;
		postState = POST_STATE.PostNoExecute;

		uploadHandler = new KakaoResponseHandler(getApplicationContext()) {

			@Override
			protected void onStart() {
				super.onStart();
				uploadState = UPLOAD_STATE.UploadStart;
            }

			@Override
			protected void onComplete(int httpStatus, int kakaoStatus, JSONObject result) {
				uploadState = UPLOAD_STATE.UploadComplete;
				deleteImageFile();
				setMediaPath(result);
                isPosting = false;
			}

			@Override
			protected void onError(int httpStatus, int kakaoStatus, JSONObject result) {
				uploadState = UPLOAD_STATE.UploadError;
				setMediaPath(result);
                isPosting = false;
			}

		};

		// Bitmap을 가져오고 화면에 보여준다.
		setData();

		// 화면을 세팅한다.
		initializePage();
	}

	private void setData() {

		Intent intent = getIntent();

		if (intent.hasExtra(Kakao.EXTRA_KEY_IMAGE_PATH)) {

			imagePath = intent.getStringExtra(Kakao.EXTRA_KEY_IMAGE_PATH); 

			bitmap = ImageResizer.createBitmapWithDisplaySampleSize(imagePath, 0, 0, IMAGE_MAX);

			int thumnailWidth = 0;
			int thumnailHeight = 0;

			if (bitmap.getWidth() > bitmap.getHeight()) {
				thumnailHeight = (int) (THUMANIL_IMAGE_MAX_SIZE * bitmap.getHeight()) / bitmap.getWidth();
				thumnailWidth = THUMANIL_IMAGE_MAX_SIZE;
			} else {
				thumnailHeight = THUMANIL_IMAGE_MAX_SIZE;
				thumnailWidth = (int) (THUMANIL_IMAGE_MAX_SIZE * bitmap.getWidth()) / bitmap.getHeight();
			}

			bitmapThumbnail = Bitmap.createScaledBitmap(bitmap, thumnailWidth, thumnailHeight, true);

			// Bitmap을 서버로 전송한다.
			uploadImage();
		} 
		
		if (intent.hasExtra(Kakao.EXTRA_KEY_POST_STRING)) {
			postString = intent.getStringExtra(Kakao.EXTRA_KEY_POST_STRING);
		} 
	}

	private void initializePage() {

		TextView tvTitle = (TextView) findViewById(R.id.ID_TV_TITLE);
		tvTitle.setText(R.string.story_title);

		customToast = getLayoutInflater().inflate(R.layout.view_custom_toast,
				null);
		btSubmit = (Button) findViewById(R.id.ID_BT_NEXT_ACTION);
		btSubmit.setText(R.string.story_upload);
		btSubmit.setOnClickListener(this);
		etContent = (EditText) findViewById(R.id.ID_ET_CONTENT);

		cbPermission = (CheckBox) findViewById(R.id.ID_CB_PERMISSION);
		ivThumbnail = (ImageView) findViewById(R.id.ID_IV_THUMBNAIL);
		ivThumbMask = (ImageView) findViewById(R.id.ID_IV_THUMB_MASK);
		
		if( postString!=null && postString.length()>0 )
			etContent.setText(postString);

		if (bitmapThumbnail != null) {
			ivThumbnail.setVisibility(View.VISIBLE);
			ivThumbMask.setVisibility(View.VISIBLE);
			ivThumbnail.setImageBitmap(bitmapThumbnail);
			ivThumbnail.setOnClickListener(this);

			LayoutParams params = ivThumbnail.getLayoutParams();
			params.width = bitmapThumbnail.getWidth();
			params.height = bitmapThumbnail.getHeight();
			ivThumbnail.setLayoutParams(params);

			LayoutParams params1 = ivThumbMask.getLayoutParams();
			params1.width = bitmapThumbnail.getWidth() + THUMANIL_MASK_MAX_SIZE;
			params1.height = bitmapThumbnail.getHeight() + THUMANIL_MASK_MAX_SIZE;
			ivThumbMask.setLayoutParams(params1);
		} else {
			ivThumbnail.setVisibility(View.GONE);
			ivThumbMask.setVisibility(View.GONE);
			ivThumbnail.setImageBitmap(null);
			ivThumbnail.setOnClickListener(null);
		}

		cbPermission.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {
				if (isChecked) {
					showNotifyToast(R.drawable.game_lock2_friends,
							R.string.story_permission_friends);
				} else {
					showNotifyToast(R.drawable.game_lock2_all,
							R.string.story_permission_public);
				}
			}
		});
	}

	@Override
	public void onClick(View v) {
        if (isPosting) {
            return;
        }
        isPosting = true;

        int id = v.getId();

        if (id == R.id.ID_IV_THUMBNAIL) {
            showThumbnailDetail();
        } else if (id == R.id.ID_BT_NEXT_ACTION) {
            preprocessPostStory();
        }
    }



	private int dipToPixel(int dip) {
		return (int) (dip * getResources().getDisplayMetrics().density);
	}

	private void showThumbnailDetail() {
		if (bitmap == null) {
			return;
		}

		final Dialog dialog = new Dialog(this, R.style.story_dialog);
		View layout = View
				.inflate(this, R.layout.layout_thumbnail_detail, null);
		ImageView ivThumbNail = (ImageView) layout
				.findViewById(R.id.ID_IV_THUMBNAIL);
		ivThumbNail.setImageBitmap(bitmap);
		dialog.addContentView(layout, new LayoutParams(
				LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));

		layout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				dialog.dismiss();
			}
		});

		try {
			dialog.show();
		} catch (Exception e) {
			Logger.getInstance().e(TAG, e);
		}
	}

	private void showNotifyToast(int iconResId, int msgResId) {
		ImageView ivIcon = (ImageView) customToast
				.findViewById(R.id.ID_IV_ICON);
		TextView tvMessage = (TextView) customToast
				.findViewById(R.id.ID_TV_NOTI);

		Toast toast = new Toast(this);
		ivIcon.setImageResource(iconResId);
		tvMessage.setText(getString(msgResId));
		toast.setView(customToast);
		toast.setGravity(Gravity.TOP | Gravity.CENTER_HORIZONTAL, 0, 300);
		toast.setDuration(Toast.LENGTH_LONG);
		toast.show();
	}

	protected void setMediaPath(JSONObject result) {
		if (result == null || !result.has("media_path")) {
			uploadState = UPLOAD_STATE.UploadError;
			return;
		}

		mediaPath = result.optString(StringKeySet.media_path);

		switch(postState) {
		// 올리기(글쓰기)를 실행하지 않았으면 그냥 종료.
		case PostNoExecute:
			return;
		// 글쓰기를 실행했다면, 시퀀셜하게 글쓰기를 수행.
		case PostExecute:
			preprocessPostStory();
			break;
		}
	}

	private void preprocessPostStory() {

		switch(uploadState) {
		// 실행안함, 실행함(실행했지만 시작안함), 에러의 경우에는 업로드 재실행, 포스트 상태 변경하고 종료. 
		case UploadNoExecute:
		case UploadExecute:
		case UploadError:
			uploadImage();
			postState = POST_STATE.PostExecute;
			return;

		// 업로드가 시작된 경우에는 어떤 방식(complete, error, networkerror)으로든 결과가 나오기때문에, 포스트 상태만 변경하고 종료.
		case UploadStart:
			postState = POST_STATE.PostExecute;
			return;

		// 업로드가 완료된 경우에는 포스트 상태를 변경하고 이후 처리 시작.
		case UploadComplete:
			postState = POST_STATE.PostExecute;
			break;
		}

		// 이미지 uri가 없는 경우에 대한 예외처리입니다.
		if (KakaoTextUtils.isEmpty(mediaPath)) {

			if (bitmap == null || retryCount >= 3) 
				return;

			// 이미지 업로드 재실행
			uploadImage();
			retryCount++;
			return;
		}

		postStory();
	}

	private void uploadImage() {
		if (kakao == null) {
			Logger.getInstance().e(TAG, "Kakao instance is null.");
			return;
		}

		uploadState = UPLOAD_STATE.UploadExecute;

		if (!KakaoTextUtils.isEmpty(imagePath))
			kakao.uploadImageFile(uploadHandler, new File(Uri.parse(imagePath).getPath()));
		else
			kakao.uploadImage(uploadHandler, bitmap);
	}

	private boolean deleteImageFile() {
		if (KakaoTextUtils.isEmpty(imagePath))
			return false;

		File file = new File(Uri.parse(imagePath).getPath());

		if (file.exists())
			return file.delete();

		return false;
	}


	protected abstract void postStory();
}