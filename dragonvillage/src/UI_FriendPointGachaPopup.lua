local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_FriendPointGachaPopup
-------------------------------------
UI_FriendPointGachaPopup = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPointGachaPopup:init()
    local vars = self:load('friend_draw.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_FriendPointGachaPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_FriendPointGachaPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_FriendPointGachaPopup'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendPointGachaPopup:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendPointGachaPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendPointGachaPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_FriendPointGachaPopup:refresh()
    local vars = self.vars

    local t_gacha_info = g_gachaData:getGachaInfo('friend_normal')

    -- 보유 우정포인트
    local fp = g_userData:get('fp')
    vars['haveCloverLabel']:setString(comma_value(fp))

    -- 뽑기 가격(우정포인트)
    vars['useCloverLabel']:setString(comma_value(t_gacha_info['price_value']))

    -- 설명은 UI에 있는 내용 그대로 사용
    --vars['drawDscLabel']:setString()
end

-------------------------------------
-- function click_drawBtn
-------------------------------------
function UI_FriendPointGachaPopup:click_drawBtn()
    local function finish_cb(ret)
        self:refresh()
    end

    g_gachaData:request_friendPointGacha(finish_cb)
end

--@CHECK
UI:checkCompileError(UI_FriendPointGachaPopup)
