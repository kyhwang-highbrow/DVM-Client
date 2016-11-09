-------------------------------------
-- class ScenePatch
-------------------------------------
ScenePatch = class(PerpleScene, {
        m_bFinishPatch = 'boolean',
        m_vars = '',
		m_patch_core = 'Patch_Core',
    })

-------------------------------------
-- function init
-------------------------------------
function ScenePatch:init()
    self.m_bShowTopUserInfo = false
    self.m_bFinishPatch = false
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

    -- 추가 리소스 다운로드
    local patch_core = PatchCore('patch', app_ver)
	self.m_patch_core = patch_core
    local finish_cb = function() self:finishPatch() end
    patch_core:setFinishCB(finish_cb)
    patch_core:doStep()

    self.m_vars['animator']:changeAni('01_patch')

	self.m_scene:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    self:refreshPatchIdxLabel()
end

-------------------------------------
-- function update
-------------------------------------
function ScenePatch:update(dt)
    if (self.m_patch_core.m_totalSize <= 0) then
        self.m_vars['downloadLabel']:setString('')
        return
    end

	local curr_size = self.m_patch_core.m_downloadedSize or 'Current Size'
	local total_size = self.m_patch_core.m_totalSize or 'Total Size'
	local down_percent = string.format('%.2f', curr_size / total_size * 100)
	self.m_vars['downloadLabel']:setString(curr_size .. ' /' .. total_size .. '\n' .. down_percent .. '%')
end


-------------------------------------
-- function finishPatch
-------------------------------------
function ScenePatch:finishPatch()
    self.m_bFinishPatch = true

    --[[
    self.m_vars['messageLabel']:setVisible(true)
    self.m_vars['messageLabel']:setString(Str('화면을 터치하세요.'))

    self.m_vars['downloadLabel']:setVisible(false)

    self:refreshPatchIdxLabel()

    -- @TODO  임시 처리
    self.m_vars['animator']:setVisual('group', '00')
    self.m_vars['animator']:registerScriptLoopHandler(function()
        -- C++ function(AppDelegate_Custom.cpp에 구현되어 있음)
        finishPatch()
    end)
    --]]

    -- C++ function(AppDelegate_Custom.cpp에 구현되어 있음)
    finishPatch()
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
    finishPatch()
end