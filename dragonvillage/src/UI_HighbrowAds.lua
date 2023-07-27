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
        local animator = MakeAnimator('res/ui/ads/self_ad_dva_730x410_ko_0' .. i .. '.png')
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
    if (Translate:getGameLang() == 'ko') then
        vars['downloadBtnLabel']:setString('다운로드')
        vars['topLabel']:setString('모으는 내내 즐겁게!')
        vars['titleLabel']:setString('드래곤빌리지 컬렉션')
        vars['subLabel']:setString('마침내 드래곤빌리지 컬렉션! 게임, 카드, 책 모든 것을 수집해보세요! 탐험을 통해 얻은 수백가지 다양한 드래곤을 교배하면 새로운 드래곤을 더 발견할 수 있어요! 빌리지 꾸미기, 광장에서 다양한 친구와 소통! 드래곤 성격에 따라 개성을 표현해보세요!')
    else
        vars['downloadBtnLabel']:setString('Download')
        vars['topLabel']:setString('Collect! Hatch! and Breed!')
        vars['titleLabel']:setString('Dragon Village Collection')
        vars['subLabel']:setString('GAMES, CARDS, BOOKS! COLLECT EVERYTHING! Explore, find new dragons and breed to discover new species! Show off your own village and meet new friends at the square! You can build character with unique personalities!')
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
    SDKManager:goToWeb('https://play.google.com/store/apps/details?id=com.highbrow.games.dv&referrer=utm_source%3DDVM%2B%25EC%259B%2590%25EC%258A%25A4%25ED%2586%25A0%25EC%2596%25B4%2B%25EC%259D%25B8%25EA%25B2%258C%25EC%259E%2584%2B%25EA%25B4%2591%25EA%25B3%25A0_2023.07.28_DVC%2B%25EC%2584%25A4%25EC%25B9%2598%25EB%259E%259C%25EB%2594%25A9%26utm_medium%3DDVM%2B%25EC%259B%2590%25EC%258A%25A4%25ED%2586%25A0%25EC%2596%25B4%2B%25EC%259D%25B8%25EA%25B2%258C%25EC%259E%2584%2B%25EA%25B4%2591%25EA%25B3%25A0_2023.07.28_DVC%2B%25EC%2584%25A4%25EC%25B9%2598%25EB%259E%259C%25EB%2594%25A9%26utm_term%3DDVM%2B%25EC%259B%2590%25EC%258A%25A4%25ED%2586%25A0%25EC%2596%25B4%2B%25EC%259D%25B8%25EA%25B2%258C%25EC%259E%2584%2B%25EA%25B4%2591%25EA%25B3%25A0_2023.07.28_DVC%2B%25EC%2584%25A4%25EC%25B9%2598%25EB%259E%259C%25EB%2594%25A9%26utm_content%3DDVM%2B%25EC%259B%2590%25EC%258A%25A4%25ED%2586%25A0%25EC%2596%25B4%2B%25EC%259D%25B8%25EA%25B2%258C%25EC%259E%2584%2B%25EA%25B4%2591%25EA%25B3%25A0_2023.07.28_DVC%2B%25EC%2584%25A4%25EC%25B9%2598%25EB%259E%259C%25EB%2594%25A9%26utm_campaign%3DDVM%2B%25EC%259B%2590%25EC%258A%25A4%25ED%2586%25A0%25EC%2596%25B4%2B%25EC%259D%25B8%25EA%25B2%258C%25EC%259E%2584%2B%25EA%25B4%2591%25EA%25B3%25A0_2023.07.28_DVC%2B%25EC%2584%25A4%25EC%25B9%2598%25EB%259E%259C%25EB%2594%25A9')
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