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
package com.kakao.auth.callback;

import com.kakao.auth.AuthService.AgeAuthStatus;

public class AccountErrorResult {
    final private AgeAuthStatus status;
    final private String errorMessage;

    public AccountErrorResult(int statusCode) {
        this.status = AgeAuthStatus.valueOf(statusCode);
        this.errorMessage = "Age Authentication failure";
    }

    public AccountErrorResult(int statusCode, String errorMessage) {
        this.status = AgeAuthStatus.valueOf(statusCode);
        this.errorMessage = errorMessage;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public AgeAuthStatus getStatus() {
        return status;
    }

    @Override
    public String toString() {
        return "AccountErrorResult{" +
                "status=" + status +
                ", errorMessage='" + errorMessage + '\'' +
                '}';
    }
}
