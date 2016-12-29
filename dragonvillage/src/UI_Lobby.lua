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
    local vars = self:load('lobby.ui')
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

    self:initCamera()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Lobby:initUI()
end

-------------------------------------
-- function initCamera
-------------------------------------
function UI_Lobby:initCamera()
    local vars = self.vars
    local camera = LobbyMap(vars['cameraNode'])
    camera:setContainerSize(1280*3, 720)
    
    camera:addLayer(self:makeLobbyLayer(4), 0.7)
    camera:addLayer(self:makeLobbyLayer(3), 0.8)
    camera:addLayer(self:makeLobbyLayer(2), 0.9)

    local lobby_ground = self:makeLobbyLayer(1)
    camera:addLayer(lobby_ground, 1)

    do
        local tamer = LobbyTamer()
        tamer:initAnimator('character/tamer/leon/leon.spine')
        tamer:initState()
        tamer:changeState('idle')
        tamer:initSchedule()
        tamer:setPosition(0, -150)
        tamer:initShadow(lobby_ground, 0)
        lobby_ground:addChild(tamer.m_rootNode, 1)

        camera.m_groudNode = lobby_ground
        camera.m_targetTamer = tamer
    end

end

-------------------------------------
-- function makeLobbyLayer
-------------------------------------
function UI_Lobby:makeLobbyLayer(idx)
    local node = cc.Node:create()
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    local sprite = cc.Sprite:create(string.format('res/lobby/lobby_layer_%.2d_left.png', idx))
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    sprite:setPositionX(-1280)
    node:addChild(sprite)

    local sprite = cc.Sprite:create(string.format('res/lobby/lobby_layer_%.2d_center.png', idx))
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(sprite)

    local sprite = cc.Sprite:create(string.format('res/lobby/lobby_layer_%.2d_right.png', idx))
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    sprite:setPositionX(1280)
    node:addChild(sprite)

    return node
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Lobby:initButton()
    local vars = self.vars
    
    vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)
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
-- @brief 모험 버튼
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
-- @brief 네스트 던전 버튼
-------------------------------------
function UI_Lobby:click_nestBtn()
    local request_nest_dungeon_info
    local request_nest_dungeon_stage_list
    local replace_scene

    -- 네스트 던전 리스트 정보 얻어옴
    request_nest_dungeon_info = function()
        g_nestDungeonData:requestNestDungeonInfo(request_nest_dungeon_stage_list)
    end

    -- 네스트 던전 스테이지 리스트 얻어옴
    request_nest_dungeon_stage_list = function()
        g_nestDungeonData:requestNestDungeonStageList(replace_scene)
    end

    -- 네스트 던전 씬으로 전환
    replace_scene = function()
        local scene = SceneNestDungeon()
        scene:runScene()
    end

    request_nest_dungeon_info()
end

-------------------------------------
-- function click_dragonManageBtn
-- @brief 드래곤 관리 버튼
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
-- @brief 상점 버튼
-------------------------------------
function UI_Lobby:click_shopBtn()
    UI_ShopPopup()
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_Lobby:click_exitBtn()
    local function yes_cb()
        cc.Director:getInstance():endToLua()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('종료하시겠습니까?'), yes_cb)
end

--@CHECK
UI:checkCompileError(UI_Lobby)
