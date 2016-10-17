/**
 * Copyright 2014 Daum Kakao Corp.
 *
 * Redistribution and modification in source or binary forms are not permitted without specific prior written permission. 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.kakao.network.multipart;

import java.io.IOException;
import java.io.OutputStream;

/**
 * Created by leoshin on 15. 8. 28..
 */
public class StringPart extends Part {
    private final String fieldName;
    private final String value;
    private byte[] content;

    public StringPart(String fieldName, String value) {
        this.fieldName = fieldName;
        this.value = value;
    }

    @Override
    protected void sendData(OutputStream out) throws IOException {
        out.write(this.getContent());
    }

    @Override
    protected String getName() {
        return fieldName;
    }

    @Override
    public String getCharSet() {
        return "US-ASCII";
    }

    @Override
    public String getTransferEncoding() {
        return "8bit";
    }

    @Override
    public String getContentType() {
        return "text/plain";
    }

    @Override
    protected long lengthOfData() {
        return (long)this.getContent().length;
    }

    private byte[] getContent() {
        if(this.content == null) {
            this.content = MultipartRequestEntity.getBytes(this.value, this.getCharSet());
        }

        return this.content;
    }
}
