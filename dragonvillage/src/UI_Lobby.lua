local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Lobby
-------------------------------------
UI_Lobby = class(PARENT,{
        m_tamerAnimator = 'Animator',
        m_tamerIdleAniCount = 'number',
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
    self:makeTamerAnimator()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Lobby:initButton()
    local vars = self.vars
    
    vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)
    vars['nestButton']:registerScriptTapHandler(function()
            local scene = SceneGame(nil, 21301, 'stage_21301', false)
            scene:runScene()
        end)
    vars['nestUIBtn']:registerScriptTapHandler(function() self:click_nestBtn() end)
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
    local table_user_level = TableUserLevel()
    local exp = g_userData:get('exp')
    local exp_percentage = table_user_level:getUserLevelExpPercentage(lv, exp)
    vars['userExpLabel']:setString(Str('{1}%', exp_percentage))
    vars['userExpGg']:setPercentage(exp_percentage)

    -- 대표 드래곤 아이콘
    --[[
    local t_leader_dragon_data = g_dragonsData:getLeaderDragon()
    if t_leader_dragon_data then
        local dragon_id = t_leader_dragon_data['did']
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[dragon_id]

        local sprite = IconHelper:getHeroIcon(t_dragon['icon'], t_leader_dragon_data['evolution'], t_dragon['attr'])
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['userNode']:removeAllChildren()
        vars['userNode']:addChild(sprite)
    end
    --]]
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
-- function click_nestBtn
-------------------------------------
function UI_Lobby:click_nestBtn()
    local function cb_func()
        local scene = SceneNestDungeon()
        scene:runScene()
    end

    g_nestDungeonData:requestNestDungeonInfo(cb_func)
end

-------------------------------------
-- function click_dragonManageBtn
-------------------------------------
function UI_Lobby:click_dragonManageBtn()
    local func = function()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            self:sceneFadeInAction()
            self:refresh_userInfo()
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


---------------------------------------------------------------------

-------------------------------------
-- function makeTamerAnimator
-------------------------------------
function UI_Lobby:makeTamerAnimator()
    local vars = self.vars
    if vars['tamerSprite'] then
        vars['tamerSprite']:setVisible(false)
    end

    do
        local tamer = MakeAnimator('res/character/tamer/goni_i/goni_i.spine')
        tamer:changeAni('lobby_pose', false)
        --tamer:addAniHandler(function() self:cbTamerAnimation() end)
        --tamer:setPosition(-400, -100)
        tamer:setDockPoint(cc.p(0.5, 0.5))
        tamer:setAnchorPoint(cc.p(0.5, 0.5))
        --tamer:setPosition(320, 90)
        tamer:setPosition(-320, -250)
        self.root:addChild(tamer.m_node)
        tamer:setScale(1.3)
        tamer.m_node:setMix('lobby_idle', 'lobby_pose', 0.2)
        tamer.m_node:setMix('lobby_pose', 'lobby_idle', 0.2)

        self.m_tamerAnimator = tamer
        self.m_tamerIdleAniCount = 0

        tamer:addAniHandler(function() self:changeTamerAniHandler() end)
    end
end

-------------------------------------
-- function changeTamerAniHandler
-------------------------------------
function UI_Lobby:changeTamerAniHandler()
    if (self.m_tamerIdleAniCount <= 0) then
        self.m_tamerAnimator:changeAni('lobby_pose', false)
        self.m_tamerIdleAniCount = math_random(3, 4)
    else
        self.m_tamerIdleAniCount = (self.m_tamerIdleAniCount - 1)
        self.m_tamerAnimator:changeAni('lobby_idle', false)
    end

    self.m_tamerAnimator:addAniHandler(function() self:changeTamerAniHandler() end)
end

---------------------------------------------------------------------

--@CHECK
UI:checkCompileError(UI_Lobby)
