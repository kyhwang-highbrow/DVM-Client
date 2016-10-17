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
package com.kakao.auth;

import android.app.Activity;
import android.content.Context;

/**
 * Created by leoshin on 15. 8. 17..
 */
public interface IApplicationConfig {
    /**
     * 현재 최상단에 위치하고 있는 Activity의 값을 return.
     * @return 최상단의 Activity instance.
     */
    Activity getTopActivity();

    Context getApplicationContext();
}
