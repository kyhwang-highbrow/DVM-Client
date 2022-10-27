-- @inherit UI
local PARENT = UI

-------------------------------------
-- Class UI_HighbrowAds
-- @brief 하이브로 자체 광고 팝업
--        동영상 광고 재생이 불가능할 때 대신해서 재생
-------------------------------------
UI_HighbrowAds = class(PARENT, {
    m_successCB = 'function',
    m_cancelCB = 'function',
    m_timer = 'number',

    m_currImgIdx = 'number',
    m_imgList = 'table',
})

-- 관련 Admob 문구
-- {1}seconds remaining / {1}초 남았습니다.
-- Close Video? 동영상을 닫을까요?
-- You will lose your reward / 리워드를 잃게 됩니니다.
-- CLOSE VIDEO / 동영상 닫기
-- RESUME VIDEO / 동영상 재시작
-- 설치하기 / Register

-------------------------------------
-- function init
-------------------------------------
function UI_HighbrowAds:init(success_cb, cancel_cb)
    self.m_uiName = 'UI_HighbrowAds'
    self.m_successCB = success_cb
    self.m_cancelCB = cancel_cb
    self.m_timer = 10

    local vars = self:load('highbrow_ads.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_HighbrowAds')

    UIC_Node:createUpdateNode(self.root, function(dt) self:update(dt) end)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HighbrowAds:initUI()
    local vars = self.vars

    self.m_currImgIdx = nil
    self.m_imgList = {}
    vars['screenShotNode']:removeAllChildren()
    for i=1, 5 do
        local animator = MakeAnimator('res/ui/ads/self_ad_dvm_730x410_en_0' .. i .. '.png')
        vars['screenShotNode']:addChild(animator.m_node)
        animator:setVisible(false)
        table.insert(self.m_imgList, animator)
    end
    self:imageOverlap()

    --vars['soundBtn']:setVisible(false) -- 별도의 사운드가 없음
    vars['countSprite']:setVisible(true)
    vars['skipBtn']:setVisible(false)
    --vars['pageMenu']:setVisible(false)

    -- 영어일 경우 분기 처리 (Admob에서 사용하는 문구)
    if (Translate:getGameLang() == 'en') then
        vars['downloadBtnLabel']:setString('Register')
    else
        vars['downloadBtnLabel']:setString(Str('설치하기'))
    end
end

-------------------------------------
-- function imageOverlap
-------------------------------------
function UI_HighbrowAds:imageOverlap()
    local prev_idx = self.m_currImgIdx

    if (self.m_currImgIdx == nil) then
        self.m_currImgIdx = math_random(1, #self.m_imgList)
    else
        self.m_currImgIdx = (self.m_currImgIdx + 1)
        if (#self.m_imgList < self.m_currImgIdx) then
            self.m_currImgIdx = 1
        end
    end
    local next_idx = self.m_currImgIdx

    local prev_animator = self.m_imgList[prev_idx]
    if prev_animator then
        prev_animator:stopAllActions()
        prev_animator:setVisible(false)
    end

    local next_animator = self.m_imgList[next_idx]
    if next_animator then
        next_animator:stopAllActions()
        next_animator:setVisible(true)

        cca.reserveFunc(next_animator.m_node, 4, function() self:imageOverlap() end)
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HighbrowAds:initButton()
    local vars = self.vars

    vars['skipBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['downloadBtn']:registerScriptTapHandler(function() self:click_downloadBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HighbrowAds:refresh()
    local vars = self.vars
end

-------------------------------------
-- function update
-------------------------------------
function UI_HighbrowAds:update(dt)
    local vars = self.vars

    if (0 < self.m_timer) then
        self.m_timer = (self.m_timer - dt)
        local sec = math_ceil(self.m_timer)
        vars['countLabel']:setString(tostring(sec))

        if (sec <= 0) then
            vars['countSprite']:setVisible(false)
            vars['skipBtn']:setVisible(true)
        end
    end
end

-------------------------------------
-- function click_downloadBtn
-------------------------------------
function UI_HighbrowAds:click_downloadBtn()
    if isIOS() == true then
        Functions.goToWeb('https://apps.apple.com/app/id1281873988')
    else
        Functions.goToWeb('https://play.google.com/store/apps/details?id=com.perplelab.dragonvillagem.kr')
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_HighbrowAds:click_closeBtn()
    if (0 < self.m_timer) then
        -- 개발 모드일 땐 무시
        if (IS_TEST_MODE() == true) then
            UIManager:toastNotificationGreen(StrForDev('개발 모드에서는 광고 스킵 처리합니다.'))
        else
            return
        end
    end

    if (self.m_successCB) then
        self.m_successCB()
    end
    self:close()
end

--@CHECK
UI:checkCompileError(UI_HighbrowAds)