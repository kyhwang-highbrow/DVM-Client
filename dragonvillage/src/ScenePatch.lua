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
    self.m_vars['messageLabel']:setVisible(true)
    self.m_vars['messageLabel']:setString(Str('패치 확인 중...'))
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
        local animator = MakeAnimator('res/ui/spine/title/title.spine')
        self.m_vars['animatorNode']:addChild(animator.m_node)
        self.m_vars['animator'] = animator
        self.m_vars['animator']:changeAni('01_patch')
    end

	self.m_scene:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    self:refreshPatchIdxLabel()

    -- 패치 시작
    self:runPatchCore()
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
-- function checkPermission
-- @brief aos 퍼미션 체크
-------------------------------------
function ScenePatch:checkPermission()
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
        ccog('## 1. 퍼미션이 필요한지 확인')
        SDKManager:app_checkPermission('android.permission.READ_EXTERNAL_STORAGE', check_cb)
    end

    -- 퍼미션 확인 결과
    check_cb = function(result)
        ccog('## 2. 퍼미션 확인 결과')
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
        ccog('## 3. 퍼미션 안내 팝업')
        local msg = Str("게임 실행에 필요한 추가 파일를 읽기 위해 '사진/미디어/파일 액세스' 접근 권한이 필요합니다.")
        local submsg =  Str("권한 요청을 거부할 경우 정상적인 게임 실행이 불가능하며\n앱을 삭제한 후 다시 설치하셔야 합니다.")
        MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, request)
    end

    -- 퍼미션 요청
    request = function()
        ccog('## 4. 퍼미션 요청')
        SDKManager:app_requestPermission('android.permission.READ_EXTERNAL_STORAGE', request_cb)
    end

    -- 퍼미션 요청 결과
    request_cb = function(result)
        ccog('## 5. 퍼미션 요청 결과' .. tostring(result))
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
        ccog('## 6. 퍼미션을 수락하지 않은 경우')
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

    local app_ver = getAppVer()

    -- APK 확장 파일 다운로드 스킵 체크
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

    local file = t_apk_extension['file'] -- ex) 'main.8.com.perplelab.dragonvillagem.kr.obb'
    local version_code = t_apk_extension['version_code'] -- ex) 8
    local file_size = t_apk_extension['size'] -- ex) 268371750
    local md5 = t_apk_extension['md5'] -- ex) ''

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