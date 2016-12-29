local PARENT = UI

local T_VIEW_LIST = {}
T_VIEW_LIST['center'] = {name='center', x=0, y=0, alias='lobby', open=true} -- 로비
T_VIEW_LIST['top'] = {name='top', x=0, y=-792, alias='combat', open=true}   -- 전투
T_VIEW_LIST['bottom'] = {name='bottom', x=0, y=792, alias='guild', open=false}   -- 길드
T_VIEW_LIST['right'] = {name='right', x=-484, y=0, alias='none1', open=false}
T_VIEW_LIST['left'] = {name='left', x=484, y=0, alias='none2', open=false}

-- swipe 제스쳐에 반응하는 뷰
T_VIEW_LIST['top']['swipe_gesture'] = {down=nil, up='center', right='left', left='right'}
T_VIEW_LIST['center']['swipe_gesture'] = {down='top', up='bottom', right='left', left='right'}
T_VIEW_LIST['bottom']['swipe_gesture'] = {down='center', up=nil, right='left', left='right'}
T_VIEW_LIST['left']['swipe_gesture'] = {down='top', up='bottom', right=nil, left='center'}
T_VIEW_LIST['right']['swipe_gesture'] = {down='top', up='bottom', right='center', left=nil}

-------------------------------------
-- class UI_LobbyNew
-------------------------------------
UI_LobbyNew = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
        m_camera = 'Camera',
        m_currViewName = 'string',
        m_buttonMenu = 'UI',
        m_tamerAnimator = 'Animator',
        m_tamerAnimatorRepeatCnt = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyNew:init()
    self.m_tamerAnimatorRepeatCnt = 0

    local vars = self:load('lobby_scene.ui', true)
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LobbyNew')

	--@UI_ACTION
    self:doActionReset()
    self:doAction()

	-- start to set ui
	self:initUI()
	self:initButton()
	self:refresh()

    self:initUserInfoNew()

    self.m_camera:setPosition(0, (-792/2), true)
    self:changeView('center')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LobbyNew:initUI()
    local function cb_swipe_event(type)
        self:swipeEvent(type)
    end

    local camera = Camera_Lobby(self.vars['cameraNode'], cb_swipe_event)
    self.m_camera = camera
    camera:setContainerSize(2048 + 200, 2048 + 256)
    --camera:setContainerSize(2048 + 512, 1152)

    self:addCameraLayer(0, 'res/lobby/00.png', 0.00, nil, 0, 0)

    self:addCameraLayer(1, 'res/lobby/01.png', 0.10, nil, 0, 0)   -- 네스트
    self:addCameraLayer(2, 'res/lobby/02.png', 0.15, nil, 0, 0)  -- 콜로세움
    self:addCameraLayer(3, 'res/lobby/03.png', 0.20, nil, 0, 0)  -- 숲

    self:addCameraLayer(4, 'res/lobby/04.png', 0.25, nil, 0, 0, 1) -- 모험(배)

    self:addCameraLayer(5, 'res/lobby/05.png', 0.60, nil, 0, 0)
    self:addCameraLayer(6, 'res/lobby/06.png', 0.80, nil, 0, 0)
    local node = self:addCameraLayer(7, 'res/lobby/07.png', 1.00, nil, 0, 0)
    do
        local tamer = MakeAnimator('res/character/tamer/leon_i/leon_i.spine')
        tamer:changeAni('idle', false)
        tamer:addAniHandler(function() self:cbTamerAnimation() end)
        tamer:setPosition(-400, -100)
        node:addChild(tamer.m_node)
        tamer.m_node:setMix('idle', 'pose_1', 0.2)
        tamer.m_node:setMix('pose_1', 'pose_1', 0.2)
        tamer.m_node:setMix('pose_1', 'idle', 0.2)
        tamer.m_node:setMix('select', 'select', 0.2)
        tamer.m_node:setMix('select', 'idle', 0.2)
        tamer.m_node:setMix('idle', 'select', 0.2)
        tamer.m_node:setMix('pose_1', 'select', 0.2)
        tamer.m_node:setMix('select', 'pose_1', 0.2)
        self.m_tamerAnimator = tamer
    end

    --[[
    self:addCameraLayer('res/lobby/00.png', 0)
    self:addCameraLayer('res/lobby/01.png', 0.01)
    self:addCameraLayer('res/lobby/02.png', 0.1)
    self:addCameraLayer('res/lobby/03.png', 0.15)
    self:addCameraLayer('res/lobby/04.png', 0.2)
    self:addCameraLayer('res/lobby/05.png', 0.9)
    self:addCameraLayer('res/lobby/06.png', 1)
    --]]
    --self:addCameraLayer('res/lobby/07.png', -0.75, 1)

    do -- 버튼 메뉴 UI 생성
        self.m_buttonMenu = UI()
        local vars = self.m_buttonMenu:load('lobby_buttons.ui')
        self.root:addChild(self.m_buttonMenu.root)

        -- 하위 UI에서 swipe를 체크하기 위해
        vars['lobbyMenu']:setSwallowTouch(false)
        vars['combatMenu']:setSwallowTouch(false)
        
        -- 콜로세움
        vars['colosseumBtn']:registerScriptTapHandler(function() self:click_colosseumBtn() end)
        vars['colosseumQuickBtn']:registerScriptTapHandler(function() self:click_colosseumBtn() end)

        -- 네스트던전
        vars['dungeonBtn']:registerScriptTapHandler(function() self:click_dungeonBtn() end)
        vars['dungeonQuickBtn']:registerScriptTapHandler(function() self:click_dungeonBtn() end)

        -- 모험
        vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)
        vars['adventureQuickBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)

        -- 테이머 관리
        vars['tamerManageBtn']:registerScriptTapHandler(function() self:click_tamerManageBtn() end)
        vars['tamerManageQuickBtn']:registerScriptTapHandler(function() self:click_tamerManageBtn() end)
        
        -- 드래곤 관리
        vars['dragonManageBtn']:registerScriptTapHandler(function() self:click_dragonManageBtn() end)
        vars['dragonManageQuickBtn']:registerScriptTapHandler(function() self:click_dragonManageBtn() end)
        
        -- 상점
        vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end)
        vars['shopQuickBtn']:registerScriptTapHandler(function() self:click_shopBtn() end)
    end
end

-------------------------------------
-- function addCameraLayer
-------------------------------------
function UI_LobbyNew:addCameraLayer(layer_idx, res, perspective_ratio, perspective_ratio_y, offset_x, offset_y, scale)
    local node = cc.Node:create()

    local sprite = cc.Sprite:create(res)
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(sprite)
    sprite:setPosition(offset_x or 0, offset_y or 0)

    if scale then
        sprite:setScale(scale)
    end

    self.m_camera:addLayer(node, perspective_ratio, perspective_ratio_y)

    -- 네스트 던전
    if (layer_idx == 1) then
        
    end

    return node
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LobbyNew:initButton()
	local vars = self.vars    
    vars['swipeTopBtn']:registerScriptTapHandler(function() self:swipeEvent('down') end)
    vars['swipeBottomBtn']:registerScriptTapHandler(function() self:swipeEvent('up') end)
    vars['swipeLeftBtn']:registerScriptTapHandler(function() self:swipeEvent('right') end)
    vars['swipeRightBtn']:registerScriptTapHandler(function() self:swipeEvent('left') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LobbyNew:refresh()
   -- NOTHING
end

-------------------------------------
-- function initParentVariable
-------------------------------------
function UI_LobbyNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_LobbyNew'
    self.m_bUseExitBtn = false
    self.m_titleStr = nil
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_LobbyNew:click_exitBtn()    
    local function yes_cb()
        cc.Director:getInstance():endToLua()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('종료하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function click_colosseumBtn
-------------------------------------
function UI_LobbyNew:click_colosseumBtn()
    local function run()
        UIManager:toastNotificationRed('"콜로세움" 미구현')
    end
    
    self:changeView('top', run)
end

-------------------------------------
-- function click_dungeonBtn
-------------------------------------
function UI_LobbyNew:click_dungeonBtn()
    local func_change_view = nil
    local func_zoom_and_move = nil
    local func_run = nil

    -- 뷰 지정(center or top)
    func_change_view = function()
        self:changeView('top', func_zoom_and_move)
    end

    -- 선택한 버튼으로 zoom, move
    func_zoom_and_move = function()
        --[[
        local menuitem = self.m_buttonMenu.vars['dungeonBtn']
        local pos_x, pos_y = menuitem:getPosition()
        pos_x, pos_y = -pos_x/1, -pos_y/1
        self:zoomActionAfterFunc(pos_x, pos_y, 1.7, func_run)
        --]]
        UIManager:toastNotificationRed('"네스트 던전" 미구현')
    end

    -- 실행
    func_run = function()
        local scene = SceneCommon(UI_NestDungeonScene)
        scene:runScene()
    end

    func_change_view()
end

-------------------------------------
-- function click_adventureBtn
-- @breif 모험
-------------------------------------
function UI_LobbyNew:click_adventureBtn()
    local func_change_view = nil
    local func_zoom_and_move = nil
    local func_run = nil

    -- 뷰 지정(center or top)
    func_change_view = function()
        self:changeView('top', func_zoom_and_move)
    end

    -- 선택한 버튼으로 zoom, move
    func_zoom_and_move = function()
        local menuitem = self.m_buttonMenu.vars['adventureBtn']
        local pos_x, pos_y = menuitem:getPosition()
        pos_x, pos_y = -pos_x/1, -pos_y/1
        self:zoomActionAfterFunc(pos_x, pos_y, 1.3, func_run)
    end

    -- 실행
    func_run = function()
        local scene = SceneAdventure()
        scene:runScene()
    end

    func_change_view()
end

-------------------------------------
-- function click_tamerManageBtn
-------------------------------------
function UI_LobbyNew:click_tamerManageBtn()
    self.m_tamerAnimator:changeAni('select', false)
    self.m_tamerAnimator:addAniHandler(function() self:cbTamerAnimation() end)
    
    local function run()
        UIManager:toastNotificationRed('"테이머 관리" 미구현')
    end
    
    self:changeView('center', run)
end

-------------------------------------
-- function cbTamerAnimation
-------------------------------------
function UI_LobbyNew:cbTamerAnimation()
    self.m_tamerAnimatorRepeatCnt = (self.m_tamerAnimatorRepeatCnt + 1)

    if (self.m_tamerAnimatorRepeatCnt >= 3) then
     self.m_tamerAnimatorRepeatCnt = 0
    end

    local animation
    if (self.m_tamerAnimatorRepeatCnt == 0) then
        animation = 'pose_1'
    else
        animation = 'idle'
    end

    self.m_tamerAnimator:changeAni(animation, false)
    self.m_tamerAnimator:addAniHandler(function() self:cbTamerAnimation() end)
end

-------------------------------------
-- function click_dragonManageBtn
-- @brief 드래곤 관리
-------------------------------------
function UI_LobbyNew:click_dragonManageBtn()
    local func_change_view = nil
    local func_zoom_and_move = nil
    local func_run = nil

    -- 뷰 지정(center or top)
    func_change_view = function()
        self:changeView('center', func_zoom_and_move)
    end

    -- 선택한 버튼으로 zoom, move
    func_zoom_and_move = function()
        local menuitem = self.m_buttonMenu.vars['dragonManageBtn']
        local pos_x, pos_y = menuitem:getPosition()
        pos_x, pos_y = -pos_x/1, -pos_y/1
        self:zoomActionAfterFunc(pos_x, pos_y, 1.5, func_run)
    end

    -- 실행
    func_run = function()
        local t_data = nil
        local close_cb = function()
            local scene = SceneLobby()
            scene:runScene()
        end
        local scene = SceneCommon(UI_DragonManageInfo, t_data, close_cb)
        scene:runScene()
    end

    func_change_view()
end

-------------------------------------
-- function click_shopBtn
-- @brief 상점 구현
-------------------------------------
function UI_LobbyNew:click_shopBtn()    
    local func_change_view = nil
    local func_zoom_and_move = nil
    local func_run = nil

    -- 뷰 지정(center or top)
    func_change_view = function()
        self:changeView('center', func_zoom_and_move)
    end

    -- 선택한 버튼으로 zoom, move
    func_zoom_and_move = function()
        local menuitem = self.m_buttonMenu.vars['shopBtn']
        local pos_x, pos_y = menuitem:getPosition()
        pos_x, pos_y = -pos_x/1, -pos_y/1
        self:zoomActionAfterFunc(pos_x, pos_y, 1.4, func_run)
    end

    -- 실행
    func_run = function()
        local shop = UI_ShopPopup()
        shop:setCloseCB(function() self:resetLayout() end)
    end

    func_change_view()
end

-------------------------------------
-- function zoomActionAfterFunc
-------------------------------------
function UI_LobbyNew:zoomActionAfterFunc(x, y, scale, func)
    self.m_buttonMenu:doActionReverse()

    local spawn = cc.Spawn:create(cc.ScaleTo:create(0.8, scale), cc.MoveTo:create(0.8, cc.p(x, y)))
    local ease = cc.EaseInOut:create(spawn, 2)
    local sequence = cc.Sequence:create(ease, cc.CallFunc:create(func))

    self.vars['cameraNode']:stopAllActions()
    self.vars['cameraNode']:runAction(sequence)
end

-------------------------------------
-- function resetLayout
-------------------------------------
function UI_LobbyNew:resetLayout()
    local spawn = cc.Spawn:create(cc.ScaleTo:create(0.5, 1), cc.MoveTo:create(0.5, cc.p(1, 1)))
    local ease = cc.EaseInOut:create(spawn, 2)
    self.vars['cameraNode']:stopAllActions()
    self.vars['cameraNode']:runAction(ease)

    self.m_buttonMenu:doAction()
end

-------------------------------------
-- function getViewInfo
-------------------------------------
function UI_LobbyNew:getViewInfo(view_name)
    for i,v in pairs(T_VIEW_LIST) do
        if (v['name'] == view_name) or (v['alias'] == view_name) then
            return v
        end
    end
end

-------------------------------------
-- function changeView
-------------------------------------
function UI_LobbyNew:changeView(view_name, finish_cb)
    if (self.m_currViewName == view_name) then
        if finish_cb then
            finish_cb()
        end
        return
    end 

    local t_view_info = self:getViewInfo(view_name)
    if (not t_view_info) then
        error()
        return
    end

    if (false == t_view_info['open']) then
        return
    end

    self.m_currViewName = view_name

    self.m_camera:actionMoveAndZoom(0.5, t_view_info['x'], t_view_info['y'], 1, finish_cb)
    self:refreshSwipeButton(t_view_info)

    -- 페이지가 변경되는 순간 메뉴 버튼 변경
    self:refreshMenuButton(t_view_info)
end

-------------------------------------
-- function refreshSwipeButton
-------------------------------------
function UI_LobbyNew:refreshSwipeButton(t_view_info)
    do
        local is_active = false
        local target = t_view_info['swipe_gesture']['down']
        if target then
            local t_target_view_info = self:getViewInfo(target)
            if t_target_view_info then
                is_active = t_target_view_info['open']
            end
        end
        self.vars['swipeTopBtn']:setVisible(is_active)
    end

    do
        local is_active = false
        local target = t_view_info['swipe_gesture']['up']
        if target then
            local t_target_view_info = self:getViewInfo(target)
            if t_target_view_info then
                is_active = t_target_view_info['open']
            end
        end
        self.vars['swipeBottomBtn']:setVisible(is_active)
    end

    do
        local is_active = false
        local target = t_view_info['swipe_gesture']['left']
        if target then
            local t_target_view_info = self:getViewInfo(target)
            if t_target_view_info then
                is_active = t_target_view_info['open']
            end
        end
        self.vars['swipeRightBtn']:setVisible(is_active)
    end

    do
        local is_active = false
        local target = t_view_info['swipe_gesture']['right']
        if target then
            local t_target_view_info = self:getViewInfo(target)
            if t_target_view_info then
                is_active = t_target_view_info['open']
            end
        end
        self.vars['swipeLeftBtn']:setVisible(is_active)
    end
end

-------------------------------------
-- function refreshMenuButton
-- @brief 스와이프로 로비 배경이 변경되는 순간 버튼들 정렬
-------------------------------------
function UI_LobbyNew:refreshMenuButton(t_view_info)
    local alias = t_view_info['alias']

    local vars = self.m_buttonMenu.vars

    if (alias == 'lobby') then
        vars['combatMenu']:setVisible(false)
        vars['lobbyMenu']:setVisible(true)
    else--if (alias == 'combat') then
        vars['combatMenu']:setVisible(true)
        vars['lobbyMenu']:setVisible(false)
    end

    --@UI_ACTION
    self.m_buttonMenu:doActionReset()
    self.m_buttonMenu:doAction()
end

-------------------------------------
-- function swipeEvent
-------------------------------------
function UI_LobbyNew:swipeEvent(type)
    local t_view_info = self:getViewInfo(self.m_currViewName)
    if (not t_view_info) then
        return
    end
    
    local next_view = t_view_info['swipe_gesture'][type]

    if next_view then
        self:changeView(next_view)
    end
end

-------------------------------------
-- function initUserInfoNew
-- @brief 유저 정보 초기화
-------------------------------------
function UI_LobbyNew:initUserInfoNew()
    local vars = self.vars

    -- TODO 어떤 기준으로 출력??
    vars['userTitleLabel']:setString(Str('수습테이머'))

    -- 닉네임
    local nickname = g_userData:get('nick')
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

-- @CHECK
UI:checkCompileError(UI_LobbyNew)