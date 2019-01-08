package org.cocos2dx.lua;

import com.google.android.vending.expansion.downloader.impl.DownloaderService;
import com.perplelab.PerpleConfig;

/**
 * This class demonstrates the minimal client implementation of the
 * DownloaderService from the Downloader library.
 */
public class APKExpansionDownloaderService extends DownloaderService {

    // used by the preference obfuscater
    private static final byte[] SALT = new byte[] {
        37, -45, -125, 21, 43, 20, -81, 70, 36, -92, -72, -69, -34, -107, -54, 5, 50, 91, 33, 102
    };

    /**
     * This public key comes from your Android Market publisher account, and it
     * used by the LVL to validate responses from Market on your behalf.
     */
    @Override
    public String getPublicKey() {
        return PerpleConfig.BASE64_PUBLIC_KEY;
    }

    /**
     * This is used by the preference obfuscater to make sure that your
     * obfuscated preferences are different than the ones used by other
     * applications.
     */
    @Override
    public byte[] getSALT() {
        return SALT;
    }

    /**
     * Fill this in with the class name for your alarm receiver. We do this
     * because receivers must be unique across all of Android (it's a good idea
     * to make sure that your receiver is in your unique package)
     */
    @Override
    public String getAlarmReceiverClassName() {
        return APKExpansionAlarmReceiver.class.getName();
    }

}
