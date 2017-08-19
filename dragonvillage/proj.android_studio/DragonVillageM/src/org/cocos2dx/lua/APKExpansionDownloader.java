package org.cocos2dx.lua;

import com.perplelab.dragonvillagem.kr.R;

import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Messenger;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.util.zip.CRC32;

import com.google.android.vending.expansion.downloader.DownloadProgressInfo;
import com.google.android.vending.expansion.downloader.DownloaderClientMarshaller;
import com.google.android.vending.expansion.downloader.DownloaderServiceMarshaller;
import com.google.android.vending.expansion.downloader.Helpers;
import com.google.android.vending.expansion.downloader.IDownloaderClient;
import com.google.android.vending.expansion.downloader.IDownloaderService;
import com.google.android.vending.expansion.downloader.IStub;
import com.google.android.vending.expansion.downloader.impl.DownloadInfo;
import com.google.android.vending.expansion.downloader.impl.DownloadsDB;

public class APKExpansionDownloader implements IDownloaderClient {

    private IDownloaderService mRemoteService;
    private IStub mDownloaderClientStub;

    private AlertDialog mWifiWarning;

    private Context mContext;

    private boolean mIsShowingWifiWarning;
    private boolean mIsInterruptable;

    private int mDownloadStatus;
    private int mIconId;

    private static String[] mMD5s = { "", "" };
    private static long[] mCRC32s = { 0, 0 };

    private APKExpansionDownloaderCallback mDownloaderCallback;

    public APKExpansionDownloader(Context c, int iconId) {
        mContext = c;

        if (iconId == 0) {
            try {
                ApplicationInfo info = c.getPackageManager().getApplicationInfo(c.getPackageName(), PackageManager.GET_META_DATA);
                iconId = info.icon;
            } catch (NameNotFoundException e) {
                e.printStackTrace();
            }
        }
        mIconId = iconId;
    }

    @Override
    public void onServiceConnected(Messenger m) {
        mRemoteService = DownloaderServiceMarshaller.CreateProxy(m);
        mRemoteService.onClientUpdated(mDownloaderClientStub.getMessenger());
    }

    @Override
    public void onDownloadStateChanged(int newState) {
        boolean isPaused = false;
        boolean isToShowWifiWarning = false;
        boolean isIndeterminate = false;
        boolean isInterruptable = false;

        switch (newState)
        {
        case IDownloaderClient.STATE_IDLE:
            isIndeterminate = true;
            break;
        case IDownloaderClient.STATE_FETCHING_URL:
            isIndeterminate = true;
            break;
        case IDownloaderClient.STATE_CONNECTING:
            isIndeterminate = true;
            if (mIsShowingWifiWarning == true) {
                mWifiWarning.dismiss();
            }
            break;
        case IDownloaderClient.STATE_DOWNLOADING:
            isInterruptable = true;
            break;
        case IDownloaderClient.STATE_COMPLETED:
            if (mDownloadStatus != newState && !isToDownloadExpansionAPKFile(mContext)) {
                if (mDownloaderCallback != null) {
                    mDownloaderCallback.onCompleted();
                }
                disconnectDownloaderClient(mContext);
            }
            break;
        case IDownloaderClient.STATE_PAUSED_NETWORK_UNAVAILABLE:
            isInterruptable = true;
            isPaused = true;
            break;
        case IDownloaderClient.STATE_PAUSED_BY_REQUEST:
            isInterruptable = true;
            isPaused = true;
            break;
        case IDownloaderClient.STATE_PAUSED_WIFI_DISABLED_NEED_CELLULAR_PERMISSION:
        case IDownloaderClient.STATE_PAUSED_NEED_CELLULAR_PERMISSION:
        case IDownloaderClient.STATE_PAUSED_WIFI_DISABLED:
        case IDownloaderClient.STATE_PAUSED_NEED_WIFI:
            isPaused = true;
            isToShowWifiWarning = true;
            if (mIsShowingWifiWarning == false) {
                showWifiDisabledWarning(mContext, mIconId);
            }
            break;
        case IDownloaderClient.STATE_PAUSED_ROAMING:
            isInterruptable = true;
            isPaused = true;
            break;
        case IDownloaderClient.STATE_PAUSED_NETWORK_SETUP_FAILURE:
            isInterruptable = true;
            isPaused = true;
            break;
        case IDownloaderClient.STATE_PAUSED_SDCARD_UNAVAILABLE:
            isInterruptable = true;
            isPaused = true;
            break;
        case IDownloaderClient.STATE_FAILED_UNLICENSED:
        case IDownloaderClient.STATE_FAILED_FETCHING_URL:
        case IDownloaderClient.STATE_FAILED_SDCARD_FULL:
        case IDownloaderClient.STATE_FAILED_CANCELED:
        case IDownloaderClient.STATE_FAILED_WRITE_STORAGE_PERMISSION_DENIED:
        case IDownloaderClient.STATE_FAILED_NO_GOOGLE_ACCOUNT:
        case IDownloaderClient.STATE_FAILED:
            isInterruptable = true;
            isPaused = true;
            break;
        default:
            isInterruptable = true;
            isPaused = true;
            break;
        }

        mIsInterruptable = isInterruptable;
        mIsShowingWifiWarning = isToShowWifiWarning;

        mDownloaderCallback.onUpdateStatus(isPaused, isIndeterminate, isInterruptable,
        		newState, mContext.getString(Helpers.getDownloaderStringResourceIDFromState(newState)));

        if (mDownloadStatus == newState) {
            return;
        }

        mDownloadStatus = newState;
    }

    @Override
    public void onDownloadProgress(DownloadProgressInfo progress) {
        long current = progress.mOverallProgress;
        long total = progress.mOverallTotal;

        String progressText = Helpers.getDownloadProgressString(current, total);
        String percentText = Helpers.getDownloadProgressPercent(current, total);

        mDownloaderCallback.onUpdateProgress(current, total, progressText, percentText);
    }

    public void initExpansionDownloader(Context c) {
        Intent intent = new Intent(c, AppActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(c, AppActivity.RC_OBB_DOWNLOAD_STATE, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        int startResult = 0;
        try {
            startResult = DownloaderClientMarshaller.startDownloadServiceIfRequired(c, pendingIntent, APKExpansionDownloaderService.class);

            if (startResult != DownloaderClientMarshaller.NO_DOWNLOAD_REQUIRED) {
                mDownloaderClientStub = DownloaderClientMarshaller.CreateStub(this, APKExpansionDownloaderService.class);
            }
        } catch (NameNotFoundException e) {
            e.printStackTrace();
        }

        mDownloaderCallback.onInit();
    }

    public void setDownloaderCallback(APKExpansionDownloaderCallback callback) {
        mDownloaderCallback = callback;
    }

    private void showWifiDisabledWarning(final Context c, final int iconId) {

        AlertDialog.Builder builder = new AlertDialog.Builder(c);
        builder.setTitle(c.getString(R.string.wifi_warning_title));
        builder.setMessage(c.getString(R.string.wifi_warning_message));
        builder.setIcon(iconId);
        builder.setPositiveButton(c.getString(R.string.wifi_warning_positive_button), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
            	// 계속 진행
            }
        });

        builder.setNegativeButton(c.getString(R.string.wifi_warning_negative_button), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
            	// WIFI 연결
            }
        });

        builder.setCancelable(false);
        mWifiWarning = builder.create();
        final AlertDialog alert = mWifiWarning;
        alert.show();

        // Notes: workarounds (to prevent AlertDialog to dismiss itself automatically)
        Button continueButton = alert.getButton(AlertDialog.BUTTON_POSITIVE);
        continueButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mRemoteService.setDownloadFlags(IDownloaderService.FLAGS_DOWNLOAD_OVER_CELLULAR);
                mRemoteService.requestContinueDownload();

                alert.dismiss();
            }
        });

        Button wifiButton = alert.getButton(AlertDialog.BUTTON_NEGATIVE);
        wifiButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                c.startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
            }
        });

    }

    public boolean isToDownloadExpansionAPKFile(Context c) {
        DownloadsDB db = DownloadsDB.getDB(c);

        DownloadInfo[] infos = db.getDownloads();
        if (infos == null) {
            Log.d(c.getPackageName(), "No DownloadInfo from DB from isToDownloadExpansionAPKFile()");
            return true;
        }

        for (int i = 0; i < infos.length; i++) {
            DownloadInfo info = infos[i];
            
            String obbFilePath = Helpers.generateSaveFileName(c, info.mFileName);
            File obbFile = new File(obbFilePath);
            if (!obbFile.exists() || obbFile.length() != info.mTotalBytes) {
                Log.d(c.getPackageName(), "OBB file[" + info.mFileName + "(size=" + info.mTotalBytes + ")] does not exist.");
                //obbFile.delete();
                return true;
            } else {
                // Check MD5
                if (!mMD5s[i].isEmpty()) {
                    try {
                        String md5 = getFastMD5(obbFilePath);
                        if (!md5.equals(mMD5s[i])) {
                            Log.d(c.getPackageName(), "Check MD5, Source:" + md5 + ", Target:" + mMD5s[i]);
                            obbFile.delete();
                            return true;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                // Check CRC32
                if (mCRC32s[i] != 0) {
                    try {
                        long crc32 = getCRC32(obbFilePath);
                        if (crc32 != mCRC32s[i]) {
                            Log.d(c.getPackageName(), "Check CRC32, Source:" + crc32 + ", Target:" + mCRC32s[i]);
                            obbFile.delete();
                            return true;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        return false;
    }

    public void connectDownloaderClient(Context c) {
        if (mDownloaderClientStub != null) {
            mDownloaderClientStub.connect(c);
        }
    }

    public void disconnectDownloaderClient(Context c) {
        if (mDownloaderClientStub != null) {
            mDownloaderClientStub.disconnect(c);
        }
    }

    public boolean requestContinueDownload() {
        if (mIsInterruptable) {
            mRemoteService.requestContinueDownload();
            mIsInterruptable = false;

            return true;
        }

        return false;
    }

    public boolean requestPauseDownload() {
        if (mIsInterruptable) {
            mRemoteService.requestPauseDownload();
            mIsInterruptable = false;

            return true;
        }

        return false;
    }

    public static boolean isNeedToDownloadObbFile(Context c, int versionCode, long fileSize, String[] md5s, long[] crc32s) {
        mMD5s = md5s;
        mCRC32s = crc32s;

        if (fileSize > 0) {
            String mainFileName = Helpers.getExpansionAPKFileName(c, true, versionCode);
            String obbFilePath = Helpers.generateSaveFileName(c, mainFileName);
            File obbFile = new File(obbFilePath);
            if (!obbFile.exists() || obbFile.length() != fileSize) {
                //obbFile.delete();
                return true;
            } else {
                // Check MD5
                if (!mMD5s[0].isEmpty()) {
                    try {
                        String md5 = getFastMD5(obbFilePath);
                        if (!md5.equals(mMD5s[0])) {
                            Log.d(c.getPackageName(), "Check MD5, Source:" + md5 + ", Target:" + mMD5s[0]);
                            obbFile.delete();
                            return true;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                // Check CRC32
                if (mCRC32s[0] != 0) {
                    try {
                        long crc32 = getCRC32(obbFilePath);
                        if (crc32 != mCRC32s[0]) {
                            Log.d(c.getPackageName(), "Check CRC32, Source:" + crc32 + ", Target:" + mCRC32s[0]);
                            obbFile.delete();
                            return true;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        return false;
    }

    public static String getMD5(String filepath) throws Exception {
        String md5 = "";

        MessageDigest md = MessageDigest.getInstance("MD5");
        InputStream fis = new FileInputStream(filepath);
        byte[] buffer = new byte[1024];
        int numRead = 0;
        while (numRead != -1) {
            numRead = fis.read(buffer);
            if (numRead > 0) {
                md.update(buffer, 0, numRead);;
            }
        }
        fis.close();

        byte byteData[] = md.digest();
        for (int i=0; i < byteData.length; i++) {
            md5 += Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1);
        }

        return md5;
    }

    public static String getFastMD5(String filepath) throws Exception {
        String md5 = "";

        MessageDigest md = MessageDigest.getInstance("MD5");
        DigestInputStream  dis = new DigestInputStream(new FileInputStream(new File(filepath)), md);

        byte[] buffer = new byte[8192];
        try {
            while (dis.read(buffer) != -1);
        } finally {
            dis.close();
        }

        byte byteData[] = md.digest();
        for (int i=0; i < byteData.length; i++) {
            md5 += Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1);
        }

        return md5;
    }

    public static long getCRC32(String filepath) throws Exception {
        InputStream bis = new BufferedInputStream(new FileInputStream(filepath));
        CRC32 crc32 = new CRC32();
        int cnt;
        while ((cnt = bis.read()) != -1) {
            crc32.update(cnt);
        }
        bis.close();
        return crc32.getValue();
    }

}
