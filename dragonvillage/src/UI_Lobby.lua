local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Lobby
-------------------------------------
UI_Lobby = class(PARENT,{
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Lobby:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Lobby'
    self.m_bVisible = true
    self.m_titleStr = nil
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_Lobby:init()
    local vars = self:load('lobby_temp.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Lobby')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Lobby:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Lobby:initButton()
    local vars = self.vars
    vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)
    vars['dragonManageBtn']:registerScriptTapHandler(function() self:click_dragonManageBtn() end)
    vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Lobby:refresh()

    -- 유저 정보 갱신
    self:refresh_userInfo()
end

-------------------------------------
-- function refresh_userInfo
-- @brief 유저 정보 갱신
-------------------------------------
function UI_Lobby:refresh_userInfo()
   local vars = self.vars

    -- TODO 어떤 기준으로 출력??
    vars['userTitleLabel']:setString(Str('수습테이머'))

    -- 닉네임
    local nickname = g_userData:get('nickname') or g_serverData:get('local', 'idfa')
    vars['userNameLabel']:setString(nickname)

    -- 레벨
    local lv = g_userData:get('lv')
    vars['userLvLabel']:setString(Str('레벨 {1}', lv))

    -- 경헙치
    local function getTamerExpPercentage(lv, exp)
        local table_exp_tamer = TABLE:get('exp_tamer')
        local t_exp_tamer = table_exp_tamer[lv]
        local max_exp = t_exp_tamer['exp_t']
        local percentage = (exp / max_exp)
        return math_floor(percentage * 100)
    end
    local exp = g_userData:get('exp')
    local exp_percentage = getTamerExpPercentage(lv, exp)
    vars['userExpLabel']:setString(Str('{1}%', exp_percentage))
    vars['userExpGg']:setPercentage(exp_percentage)
end

-------------------------------------
-- function click_adventureBtn
-------------------------------------
function UI_Lobby:click_adventureBtn()
    local func = function()
        local scene = SceneAdventure()
        scene:runScene()
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_dragonManageBtn
-------------------------------------
function UI_Lobby:click_dragonManageBtn()
    local func = function()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_shopBtn
-------------------------------------
function UI_Lobby:click_shopBtn()
    UI_ShopPopup()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Lobby:click_exitBtn()
    local function yes_cb()
        cc.Director:getInstance():endToLua()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('종료하시겠습니까?'), yes_cb)
end


--@CHECK
UI:checkCompileError(UI_Lobby)
