-------------------------------------
-- class ScenePatch
-------------------------------------
ScenePatch = class(PerpleScene, {
        m_bFinishPatch = 'boolean',
        m_vars = '',
		m_patch_core = 'Patch_Core',
        m_apkExpansion = 'ApkExpansion',
    })

-------------------------------------
-- function init
-------------------------------------
function ScenePatch:init()
    self.m_bShowTopUserInfo = false
    self.m_bFinishPatch = false
	self.m_sceneName = 'ScenePatch'
end

-------------------------------------
-- function onEnter
-------------------------------------
function ScenePatch:onEnter()
    PerpleScene.onEnter(self)

    local ui = UI()
    self.m_vars = ui:load('title.ui')
    UIManager:open(ui, UIManager.SCENE)

    self.m_vars['okButton']:registerScriptTapHandler(function() self:click_screenBtn() end)

	self.m_vars['downloadGauge']:setPercentage(0)

    do -- 깜빡임 액션 지정
        local node = self.m_vars['messageLabel']
        node:setOpacity(255)
        local sequence = cc.Sequence:create(cc.FadeOut:create(1), cc.FadeIn:create(0.2))
        node:stopAllActions()
        node:runAction(cc.RepeatForever:create(sequence))
    end

    self:refreshPatchIdxLabel()

    local patch_data = PatchData:getInstance()
    patch_data:load()

    local app_ver = getAppVer()

    -- 앱 버전이 변경되었을 경우 체크
    if (app_ver ~= patch_data:get('latest_app_ver')) then
        patch_data:set('latest_app_ver', app_ver)
        patch_data:set('patch_ver', 0)
        patch_data:save()
    end

    do -- spine으로 리소스 변경
        -- 패치씬에서는 디폴트 배경을 노출하기 위해 파라미터 전달
        -- is_first_enter
        local animator = AnimatorHelper:getTitleAnimator(true)
        self.m_vars['animatorNode']:addChild(animator.m_node)
        self.m_vars['animator'] = animator
        self.m_vars['animator']:changeAni('01_patch')
    end

	self:refreshPatchIdxLabel()

	-- 패치 시작
	local function start_patch()
		self.m_vars['messageLabel']:setVisible(true)
		self.m_vars['messageLabel']:setString(Str('패치 확인 중...'))

		self.m_scene:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
		self:runPatchCore()
	end

	-- 선택된 언어가 없다면 언어 선택 후 패치 시작
    -- 2018.01.17 sgkim 어플 최초 실행 시 디바이스의 언어로 game언어를 설정하도록 처리함
	--if (g_localData:getLang() == nil) then
	--	UI_SelectLanguagePopup(start_patch)
	--else
		start_patch()
	--end
end

-------------------------------------
-- function runPatchCore
-- @brief 패치 파일 다운로드
-------------------------------------
function ScenePatch:runPatchCore()
    local app_ver = getAppVer()

    -- 추가 리소스 다운로드
    local patch_core = PatchCore(self, 'patch', app_ver)
	self.m_patch_core = patch_core
    local function finish_cb()
        self.m_patch_core = nil
        self:checkPermission()
    end
    patch_core:setFinishCB(finish_cb)
    patch_core:doStep()
end

-------------------------------------
-- function checkPermission_iOS
-- @brief iOS 퍼미션 체크
-------------------------------------
function ScenePatch:checkPermission_iOS()
    -- 1.2.9 부터 ATT 대응이 되어있다.
    if (getAppVerNum() < 1002009) then
        self:runApkExpansion()
        return
    end

    local function cb_func(result)
        if (result == 'success') then
            -- not determined true
            SDKManager:requestTrackingAuthorization(function() self:runApkExpansion() end)
        else
            self:runApkExpansion()
        end
    end

    SDKManager:isTrackingNotDetermined(cb_func)
end

-------------------------------------
-- function checkPermission
-- @brief aos 퍼미션 체크
-------------------------------------
function ScenePatch:checkPermission()
    if (isIos()) then
        self:checkPermission_iOS()
        return
    end

    -- sgkim 2017-08-28 안드로이드에서 APK Expansion을 사용할 때 READ_EXTERNAL_STORAGE 퍼미션을 요구하지 않는 것을 확인하고 skip함
    if true then
        self:runApkExpansion()
        return
    end

    if (not isAndroid()) then
        self:runApkExpansion()
        return
    end

    local check = nil
    local check_cb = nil
    local info_popup = nil
    local request = nil
    local request_cb = nil
    local error = nil

    -- 퍼미션이 필요한지 확인
    check = function()
        cclog('## 1. 퍼미션이 필요한지 확인')
        SDKManager:app_checkPermission('android.permission.READ_EXTERNAL_STORAGE', check_cb)
    end

    -- 퍼미션 확인 결과
    check_cb = function(result)
        cclog('## 2. 퍼미션 확인 결과')
        -- 퍼미션 필요한 경우
        if (result == 'denied') then
            info_popup()
        -- 퍼미션이 필요하지 않은 경우
        elseif (result == 'granted') then
            self:runApkExpansion()
        end
    end

    -- 퍼미션 안내 팝업
    info_popup = function()
        cclog('## 3. 퍼미션 안내 팝업')
        local msg = Str("게임 실행에 필요한 추가 파일를 읽기 위해 '사진/미디어/파일 액세스' 접근 권한이 필요합니다.")
        local submsg =  Str("권한 요청을 거부할 경우 정상적인 게임 실행이 불가능하며\n앱을 삭제한 후 다시 설치하셔야 합니다.")
        MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, request)
    end

    -- 퍼미션 요청
    request = function()
        cclog('## 4. 퍼미션 요청')
        SDKManager:app_requestPermission('android.permission.READ_EXTERNAL_STORAGE', request_cb)
    end

    -- 퍼미션 요청 결과
    request_cb = function(result)
        cclog('## 5. 퍼미션 요청 결과' .. tostring(result))
        -- 퍼미션을 거부한 경우
        if (result == 'denied') then
            error()
        -- 퍼미션을 수락한 경우
        elseif (result == 'granted') then
            self:runApkExpansion()
        end
    end

    -- 퍼미션을 수락하지 않은 경우
    error = function()
        cclog('## 6. 퍼미션을 수락하지 않은 경우')
        local msg = Str('정상적인 시작이 불가능하여 앱을 종료합니다.\n종료 후 다시 실행해 주세요.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, function()
                closeApplication()
            end)
    end

    -- call
    check()
end

-------------------------------------
-- function runApkExpansion
-- @brief google APK 확장 리소스 다운로드
-------------------------------------
function ScenePatch:runApkExpansion()
    self.m_vars['messageLabel']:setString(Str('추가 리소스 확인 중...'))
    
    -- obb 더이상 사용 안함
    if (true) then 
        self:finishPatch()
        return 
    end

    local app_ver = getAppVer()

    -- APK 확장 파일 다운로드 스킵 체크
    -- 더 이상 obb가 필요 없음
    if (not CppFunctions:useObb() == true) then
        self:finishPatch()
        return
    end

    -- 윈도우 에뮬레이터에서는 동작하지 않음
    if (isWin32() == true) then
        self:finishPatch()
        return
    end

    -- 패치 데이터에서 APK 확장파일 정보를 받아옴
    local patch_data = PatchData:getInstance()
    local t_apk_extension = patch_data:getApkExtensionInfo()

	-- 사용 안함
    local file = t_apk_extension['file'] -- ex) 'main.8.com.perplelab.dragonvillagem.kr.obb'
    local md5 = t_apk_extension['md5'] -- ex) ''
    
	-- 중요! 둘다 크리티컬하게 동작한다
	-- 참조 : https://perplelab.atlassian.net/wiki/spaces/DV/pages/408518659/Apk+expansion
	local version_code = t_apk_extension['version_code'] -- ex) 8
    local file_size = t_apk_extension['size'] -- ex) 268371750

    local apk_expansion = ApkExpansion(self, version_code, file_size)
    self.m_apkExpansion = apk_expansion
    local function finish_cb()
        self.m_apkExpansion = nil
        self:finishPatch()
    end
    apk_expansion:setFinishCB(finish_cb)
    apk_expansion:doStep()
end

-------------------------------------
-- function update
-------------------------------------
function ScenePatch:update(dt)
    if self.m_patch_core then
        self.m_patch_core:update(dt)
    end

    if self.m_apkExpansion then
        self.m_apkExpansion:update(dt)
    end
end

-------------------------------------
-- function finishPatch
-------------------------------------
function ScenePatch:finishPatch()
    self.m_bFinishPatch = true

    -- C++ function(AppDelegate_Custom.cpp에 구현되어 있음)
    CppFunctions:finishPatch()
end

-------------------------------------
-- function refreshPatchIdxLabel
-- @brief 앱버전과 패치 정보를 출력
-------------------------------------
function ScenePatch:refreshPatchIdxLabel()
    local patch_idx_str = PatchData:getInstance():getAppVersionAndPatchIdxString()
    self.m_vars['patchIdxLabel']:setString(patch_idx_str)
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function ScenePatch:click_screenBtn()
    if (not self.m_bFinishPatch) then
        return
    end

    -- C++ function(AppDelegate_Custom.cpp에 구현되어 있음)
    CppFunctions:finishPatch()
end