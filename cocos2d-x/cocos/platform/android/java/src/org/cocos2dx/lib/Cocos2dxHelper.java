/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2013-2014 Chukong Technologies Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lib;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Locale;
import java.util.LinkedHashSet;
import java.util.Set;

import com.android.vending.expansion.zipfile.APKExpansionSupport;
import com.android.vending.expansion.zipfile.ZipResourceFile;

import java.lang.Runnable;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.preference.PreferenceManager.OnActivityResultListener;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;

public class Cocos2dxHelper {
    // ===========================================================
    // Constants
    // ===========================================================
    private static final String PREFS_NAME = "Cocos2dxPrefsFile";
    private static final int RUNNABLES_PER_FRAME = 5;

    // @obb
    private static final String TAG = Cocos2dxHelper.class.getSimpleName();

    // ===========================================================
    // Fields
    // ===========================================================

    private static Cocos2dxMusic sCocos2dMusic;
    private static Cocos2dxSound sCocos2dSound;
    private static AssetManager sAssetManager;
    private static Cocos2dxAccelerometer sCocos2dxAccelerometer;
    private static boolean sAccelerometerEnabled;
    private static boolean sActivityVisible;
    private static String sPackageName;
    private static String sFileDirectory;
    private static Activity sActivity;
    private static Cocos2dxHelperListener sCocos2dxHelperListener;
    private static Set<OnActivityResultListener> onActivityResultListeners = new LinkedHashSet<OnActivityResultListener>();

    // @obb
    // The absolute path to the OBB if it exists, else the absolute path to the APK.
    private static String sAssetsPath;

    // @obb
    // The OBB file
    private static ZipResourceFile sOBBFile;
    private static int sOBBVersionCode = 1;


    // ===========================================================
    // Constructors
    // ===========================================================

    public static void runOnGLThread(final Runnable r) {
        ((Cocos2dxActivity)sActivity).runOnGLThread(r);
    }

    private static boolean sInited = false;
    public static void init(final Activity activity) {
        Cocos2dxHelper.sActivity = activity;
        Cocos2dxHelper.sCocos2dxHelperListener = (Cocos2dxHelperListener)activity;
        if (!sInited) {

            PackageManager pm = activity.getPackageManager();
            boolean isSupportLowLatency = pm.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY);

            Log.d(TAG, "isSupportLowLatency:" + isSupportLowLatency);

            int sampleRate = 44100;
            int bufferSizeInFrames = 192;

            if (getSDKVersion() >= 17) {
                AudioManager am = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
                // use reflection to remove dependence of API 17 when compiling

                // AudioManager.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE);
                final Class audioManagerClass = AudioManager.class;
                Object[] parameters = new Object[]{Cocos2dxReflectionHelper.<String>getConstantValue(audioManagerClass, "PROPERTY_OUTPUT_SAMPLE_RATE")};
                final String strSampleRate = Cocos2dxReflectionHelper.<String>invokeInstanceMethod(am, "getProperty", new Class[]{String.class}, parameters);

                // AudioManager.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER);
                parameters = new Object[]{Cocos2dxReflectionHelper.<String>getConstantValue(audioManagerClass, "PROPERTY_OUTPUT_FRAMES_PER_BUFFER")};
                final String strBufferSizeInFrames = Cocos2dxReflectionHelper.<String>invokeInstanceMethod(am, "getProperty", new Class[]{String.class}, parameters);

                try {
                    sampleRate = Integer.parseInt(strSampleRate);
                    bufferSizeInFrames = Integer.parseInt(strBufferSizeInFrames);
                } catch (NumberFormatException e) {
                    Log.e(TAG, "parseInt failed", e);
                }
                Log.d(TAG, "sampleRate: " + sampleRate + ", framesPerBuffer: " + bufferSizeInFrames);
            } else {
                Log.d(TAG, "android version is lower than 17");
            }

            nativeSetAudioDeviceInfo(isSupportLowLatency, sampleRate, bufferSizeInFrames);

            Cocos2dxHelper.sPackageName = activity.getApplicationInfo().packageName;
            Cocos2dxHelper.sFileDirectory = activity.getFilesDir().getAbsolutePath();

            Cocos2dxHelper.sCocos2dxAccelerometer = new Cocos2dxAccelerometer(activity);
            Cocos2dxHelper.sCocos2dMusic = new Cocos2dxMusic(activity);
            Cocos2dxHelper.sCocos2dSound = new Cocos2dxSound(activity);
            Cocos2dxHelper.sAssetManager = activity.getAssets();
            Cocos2dxHelper.nativeSetContext((Context)activity, Cocos2dxHelper.sAssetManager);

            Cocos2dxBitmap.setContext(activity);
            Cocos2dxETCLoader.setContext(activity);

            // @obb
            setupObbAssetFileInfo(getAPKVersionCode());

            sInited = true;
        }
    }

    // @obb
    public static int getAPKVersionCode() {
        int versionCode = 1;
        try {
            versionCode = Cocos2dxHelper.sActivity.getPackageManager().getPackageInfo(Cocos2dxHelper.sPackageName, 0).versionCode;
        } catch(Exception e) {
            e.printStackTrace();
        }
        return versionCode;
    }

    // @obb
    // This function returns the absolute path to the OBB if it exists,
    // else it returns the absolute path to the APK.
    public static String getObbAssetsPath()
    {
        if (Cocos2dxHelper.sAssetsPath == null) {
            String pathToOBB = Environment.getExternalStorageDirectory().getAbsolutePath() + "/Android/obb/" + Cocos2dxHelper.sPackageName + "/main." + sOBBVersionCode + "." + Cocos2dxHelper.sPackageName + ".obb";
            File obbFile = new File(pathToOBB);
            if (obbFile.exists()) {
                Cocos2dxHelper.sAssetsPath = pathToOBB;
            } else {
                Cocos2dxHelper.sAssetsPath = Cocos2dxHelper.sActivity.getApplicationInfo().sourceDir;
            }
        }
        return Cocos2dxHelper.sAssetsPath;
    }

    // @obb
    public static ZipResourceFile getObbAssetFile()
    {
        return Cocos2dxHelper.sOBBFile;
    }

    // @obb
    public static void setupObbAssetFileInfo(int versionCode) {
        sOBBVersionCode = versionCode;

        try {
            Cocos2dxHelper.sOBBFile = APKExpansionSupport.getAPKExpansionZipFile(Cocos2dxHelper.sActivity, sOBBVersionCode, 0);
        } catch (IOException e) {
            e.printStackTrace();
        }

        Cocos2dxHelper.sAssetsPath = null;
        Cocos2dxHelper.nativeSetApkPath(Cocos2dxHelper.getObbAssetsPath());
    }

    // @obb
    public static long[] getObbAssetFileDescriptor(final String path) {
        long[] array = new long[]{-1, 0, 0};
        if (Cocos2dxHelper.sOBBFile != null) {
            AssetFileDescriptor descriptor = Cocos2dxHelper.sOBBFile.getAssetFileDescriptor(path);
            if (descriptor != null) {
                try {
                    ParcelFileDescriptor parcel = descriptor.getParcelFileDescriptor();
                    Method method = parcel.getClass().getMethod("getFd", new Class[] {});
                    array[0] = (Integer)method.invoke(parcel);
                    array[1] = descriptor.getStartOffset();
                    array[2] = descriptor.getLength();
                } catch (NoSuchMethodException e) {
                    Log.e(Cocos2dxHelper.TAG, "Accessing file descriptor directly from the OBB is only supported from Android 3.1 (API level 12) and above.");
                } catch (IllegalAccessException e) {
                    Log.e(Cocos2dxHelper.TAG, e.toString());
                } catch (InvocationTargetException e) {
                    Log.e(Cocos2dxHelper.TAG, e.toString());
                }
            }
        }
        return array;
    }

    public static Activity getActivity() {
        return sActivity;
    }

    public static void addOnActivityResultListener(OnActivityResultListener listener) {
        onActivityResultListeners.add(listener);
    }

    public static Set<OnActivityResultListener> getOnActivityResultListeners() {
        return onActivityResultListeners;
    }

    public static boolean isActivityVisible(){
        return sActivityVisible;
    }

    public static int getSDKVersion() {
        return Build.VERSION.SDK_INT;
    }

    // ===========================================================
    // Getter & Setter
    // ===========================================================

    // ===========================================================
    // Methods for/from SuperClass/Interfaces
    // ===========================================================

    // ===========================================================
    // Methods
    // ===========================================================

    private static native void nativeSetApkPath(final String pApkPath);

    private static native void nativeSetEditTextDialogResult(final byte[] pBytes);

    private static native void nativeSetContext(final Context pContext, final AssetManager pAssetManager);

    private static native void nativeSetAudioDeviceInfo(boolean isSupportLowLatency, int deviceSampleRate, int audioBufferSizeInFames);

    public static String getCocos2dxPackageName() {
        return Cocos2dxHelper.sPackageName;
    }

    public static String getCocos2dxWritablePath() {
        return Cocos2dxHelper.sFileDirectory;
    }

    public static String getCurrentLanguage() {
        return Locale.getDefault().getLanguage();
    }

    public static String getDeviceModel(){
        return Build.MODEL;
    }

    public static AssetManager getAssetManager() {
        return Cocos2dxHelper.sAssetManager;
    }

    public static void enableAccelerometer() {
        Cocos2dxHelper.sAccelerometerEnabled = true;
        Cocos2dxHelper.sCocos2dxAccelerometer.enable();
    }


    public static void setAccelerometerInterval(float interval) {
        Cocos2dxHelper.sCocos2dxAccelerometer.setInterval(interval);
    }

    public static void disableAccelerometer() {
        Cocos2dxHelper.sAccelerometerEnabled = false;
        Cocos2dxHelper.sCocos2dxAccelerometer.disable();
    }

    public static void preloadBackgroundMusic(final String pPath) {
        Cocos2dxHelper.sCocos2dMusic.preloadBackgroundMusic(pPath);
    }

    public static void playBackgroundMusic(final String pPath, final boolean isLoop) {
        Cocos2dxHelper.sCocos2dMusic.playBackgroundMusic(pPath, isLoop);
    }

    public static void playVoice(final String pPath, final boolean isLoop) {
        Cocos2dxHelper.sCocos2dMusic.playVoice(pPath, isLoop);
    }

    public static void resumeBackgroundMusic() {
        Cocos2dxHelper.sCocos2dMusic.resumeBackgroundMusic();
    }

    public static void pauseBackgroundMusic() {
        Cocos2dxHelper.sCocos2dMusic.pauseBackgroundMusic();
    }

    public static void stopBackgroundMusic() {
        Cocos2dxHelper.sCocos2dMusic.stopBackgroundMusic();
    }

    public static void stopVoice() {
        Cocos2dxHelper.sCocos2dMusic.stopVoice();
    }

    public static void rewindBackgroundMusic() {
        Cocos2dxHelper.sCocos2dMusic.rewindBackgroundMusic();
    }

    public static boolean willPlayBackgroundMusic() {
        return Cocos2dxHelper.sCocos2dMusic.willPlayBackgroundMusic();
    }

    public static boolean isBackgroundMusicPlaying() {
        return Cocos2dxHelper.sCocos2dMusic.isBackgroundMusicPlaying();
    }

    public static float getBackgroundMusicVolume() {
        return Cocos2dxHelper.sCocos2dMusic.getBackgroundVolume();
    }

    public static void setBackgroundMusicVolume(final float volume) {
        Cocos2dxHelper.sCocos2dMusic.setBackgroundVolume(volume);
    }

    public static void preloadEffect(final String path) {
        Cocos2dxHelper.sCocos2dSound.preloadEffect(path);
    }

    public static int playEffect(final String path, final boolean isLoop, final float pitch, final float pan, final float gain) {
        return Cocos2dxHelper.sCocos2dSound.playEffect(path, isLoop, pitch, pan, gain);
    }

    public static void resumeEffect(final int soundId) {
        Cocos2dxHelper.sCocos2dSound.resumeEffect(soundId);
    }

    public static void pauseEffect(final int soundId) {
        Cocos2dxHelper.sCocos2dSound.pauseEffect(soundId);
    }

    public static void stopEffect(final int soundId) {
        Cocos2dxHelper.sCocos2dSound.stopEffect(soundId);
    }

    public static float getEffectsVolume() {
        return Cocos2dxHelper.sCocos2dSound.getEffectsVolume();
    }

    public static void setEffectsVolume(final float volume) {
        Cocos2dxHelper.sCocos2dSound.setEffectsVolume(volume);
    }

    public static void unloadEffect(final String path) {
        Cocos2dxHelper.sCocos2dSound.unloadEffect(path);
    }

    public static void playVibrate(final long millisecond) {
        Cocos2dxHelper.sCocos2dSound.playVibrate(millisecond);
    }

    public static void cancelVibrate() {
        Cocos2dxHelper.sCocos2dSound.cancelVibrate();
    }

    public static void pauseAllEffects() {
        Cocos2dxHelper.sCocos2dSound.pauseAllEffects();
    }

    public static void resumeAllEffects() {
        Cocos2dxHelper.sCocos2dSound.resumeAllEffects();
    }

    public static void stopAllEffects() {
        Cocos2dxHelper.sCocos2dSound.stopAllEffects();
    }

    public static void end() {
        Cocos2dxHelper.sCocos2dMusic.end();
        Cocos2dxHelper.sCocos2dSound.end();
    }

    public static void onResume() {
        sActivityVisible = true;
        if (Cocos2dxHelper.sAccelerometerEnabled) {
            Cocos2dxHelper.sCocos2dxAccelerometer.enable();
        }
    }

    public static void onPause() {
        sActivityVisible = false;
        if (Cocos2dxHelper.sAccelerometerEnabled) {
            Cocos2dxHelper.sCocos2dxAccelerometer.disable();
        }
    }

    public static void onEnterBackground() {
        sCocos2dSound.onEnterBackground();
        sCocos2dMusic.onEnterBackground();
    }

    public static void onEnterForeground() {
        sCocos2dSound.onEnterForeground();
        sCocos2dMusic.onEnterForeground();
    }

    public static void terminateProcess() {
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    private static void showDialog(final String pTitle, final String pMessage) {
        Cocos2dxHelper.sCocos2dxHelperListener.showDialog(pTitle, pMessage);
    }

    private static void showEditTextDialog(final String pTitle, final String pMessage, final int pInputMode, final int pInputFlag, final int pReturnType, final int pMaxLength) {
        Cocos2dxHelper.sCocos2dxHelperListener.showEditTextDialog(pTitle, pMessage, pInputMode, pInputFlag, pReturnType, pMaxLength);
    }

    public static void setEditTextDialogResult(final String pResult) {
        try {
            final byte[] bytesUTF8 = pResult.getBytes("UTF8");

            Cocos2dxHelper.sCocos2dxHelperListener.runOnGLThread(new Runnable() {
                @Override
                public void run() {
                    Cocos2dxHelper.nativeSetEditTextDialogResult(bytesUTF8);
                }
            });
        } catch (UnsupportedEncodingException pUnsupportedEncodingException) {
            /* Nothing. */
        }
    }

    public static int getDPI()
    {
        if (sActivity != null)
        {
            DisplayMetrics metrics = new DisplayMetrics();
            WindowManager wm = sActivity.getWindowManager();
            if (wm != null)
            {
                Display d = wm.getDefaultDisplay();
                if (d != null)
                {
                    d.getMetrics(metrics);
                    return (int)(metrics.density*160.0f);
                }
            }
        }
        return -1;
    }

    public static void setIdleTimerDisabled(final boolean disabled) {
        Cocos2dxHelper.sCocos2dxHelperListener.setWakeLock(disabled);
    }

    public static boolean isIdleTimerDisabled() {
        return Cocos2dxHelper.sCocos2dxHelperListener.isWakeLock();
    }

    // ===========================================================
    // Functions for CCUserDefault
    // ===========================================================

    public static boolean getBoolForKey(String key, boolean defaultValue) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        return settings.getBoolean(key, defaultValue);
    }

    public static int getIntegerForKey(String key, int defaultValue) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        return settings.getInt(key, defaultValue);
    }

    public static float getFloatForKey(String key, float defaultValue) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        return settings.getFloat(key, defaultValue);
    }

    public static double getDoubleForKey(String key, double defaultValue) {
        // SharedPreferences doesn't support saving double value
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        return settings.getFloat(key, (float)defaultValue);
    }

    public static String getStringForKey(String key, String defaultValue) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        return settings.getString(key, defaultValue);
    }

    public static void setBoolForKey(String key, boolean value) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean(key, value);
        editor.commit();
    }

    public static void setIntegerForKey(String key, int value) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putInt(key, value);
        editor.commit();
    }

    public static void setFloatForKey(String key, float value) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putFloat(key, value);
        editor.commit();
    }

    public static void setDoubleForKey(String key, double value) {
        // SharedPreferences doesn't support recording double value
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putFloat(key, (float)value);
        editor.commit();
    }

    public static void setStringForKey(String key, String value) {
        SharedPreferences settings = sActivity.getSharedPreferences(Cocos2dxHelper.PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(key, value);
        editor.commit();
    }

    // ===========================================================
    // Inner and Anonymous Classes
    // ===========================================================

    public static interface Cocos2dxHelperListener {
        public void showDialog(final String pTitle, final String pMessage);
        public void showEditTextDialog(final String pTitle, final String pMessage, final int pInputMode, final int pInputFlag, final int pReturnType, final int pMaxLength);

        public void runOnGLThread(final Runnable pRunnable);
        public void setWakeLock(boolean bLock);
        public boolean isWakeLock();
    }
}
