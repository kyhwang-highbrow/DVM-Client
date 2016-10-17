package com.kakao.game.request;

import com.kakao.auth.Session;
import com.kakao.auth.StringSet;
import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.network.multipart.FilePart;
import com.kakao.network.multipart.Part;
import com.kakao.network.multipart.StringPart;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Created by house.dr on 15. 9. 4..
 */
public class GameImageUploadRequest extends ApiRequest {
    private final List<Part> partList;

    public GameImageUploadRequest(List<File> fileList) {
        this.partList = new ArrayList<Part>();
        if (fileList != null) {
            for (int i = 0; i < fileList.size(); i++) {
                partList.add(new FilePart(StringSet.file + "_" + String.valueOf(i + 1), fileList.get(i)));
            }
        }
        partList.add(new StringPart("kapi_token", Session.getCurrentSession().getAccessToken()));
    }

    @Override
    public String getMethod() {
        return POST;
    }

    @Override
    public String getUrl() {
        return GameServerProtocol.KAGE_API_AUTHORITY + GameServerProtocol.IMAGE_UPLOAD_PATH;
    }

    @Override
    public Map<String, String> getParams() {
        return Collections.emptyMap();
    }

    @Override
    public List<Part> getMultiPartList() {
        return partList;
    }
}
