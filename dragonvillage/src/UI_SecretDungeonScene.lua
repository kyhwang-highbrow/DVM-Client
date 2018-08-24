local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_SecretDungeonScene
-------------------------------------
UI_SecretDungeonScene = class(PARENT, {
        m_bDirtyDungeonList = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SecretDungeonScene:init(dungeon_id)
    local vars = self:load('dungeon_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_SecretDungeonScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)
    
    self:initUI(dungeon_id)
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_SecretDungeonScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_SecretDungeonScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('인연 던전')
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SecretDungeonScene:initUI(dungeon_id)
    local vars = self.vars

    --
    self:makeSecretTitle()
    self:makeSecretModeTableView(dungeon_id)

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
end

-------------------------------------
-- function makeSecretTitle
-- @brief 왼쪽에 나오는 UI
-------------------------------------
function UI_SecretDungeonScene:makeSecretTitle()
    local vars = self.vars
    local ui = UI_SecretDungeonListItem()
    ui.root:setDockPoint(cc.p(0.5, 0.5))
    ui.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:addChild(ui.root)
    
    -- 첫 위치 잡아주기
    local pos_y = vars['dungeonNode']:getPositionY()
    ui.root:setPositionY(pos_y)

    local target_pos = convertToAnoterNodeSpace(ui.root, vars['dungeonNode'])
    ui:cellMoveTo(0.5, target_pos)
end

-------------------------------------
-- function makeSecretModeTableView
-- @brief 오른쪽에 나오는 세부 리스트
-------------------------------------
function UI_SecretDungeonScene:makeSecretModeTableView(dungeon_id)
    local node = self.vars['detailTableViewNode']
    node:removeAllChildren()

    local stage_list = g_secretDungeonData:getSecretDungeonInfo()

    -- 던전이 하나도 없을 경우 알림 표시
    self.vars['emptySprite']:setVisible(#stage_list == 0)

    -- 셀 아이템 생성 콜백
    local function create_func(ui, data)
        return true
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(886, 152)
    table_view:setCellUIClass(UI_SecretDungeonStageListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(stage_list)

    local content_size = node:getContentSize()
    table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_x = x + content_size['width']
        ui.root:setPosition(new_x, y)

        ui:cellMoveTo(0.25, cc.p(x, y))
    end

    -- 발견 직후 바로가기를 통해서 들어왔다면 테이블뷰 셀 위치를 변경
    if (dungeon_id) then
        local idx

        for i, v in ipairs(stage_list) do
            if (v['id'] == dungeon_id) then
                idx = i
                return
            end
        end
        
        if (idx ) then
            table_view:updateCellAtIndex(idx)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SecretDungeonScene:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SecretDungeonScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_SecretDungeonScene:click_exitBtn()
	if (g_currScene.m_sceneName == 'SceneSecretDungeon') then
		local is_use_loading = false
		local scene = SceneLobby(is_use_loading)
		scene:runScene()
	else
		self:close()
	end
end

-------------------------------------
-- function update
-------------------------------------
function UI_SecretDungeonScene:update(dt)
    if (not self.root:isVisible()) then
        return
    end

    if (not self.m_bDirtyDungeonList) then
        local dirty_dungeon_list = g_secretDungeonData:checkNeedUpdateSecretDungeonInfo()
        if (dirty_dungeon_list) then
            self.m_bDirtyDungeonList = true
            self:refreshDungeonList()
        end
    end
    
end

-------------------------------------
-- function refreshDungeonList
-------------------------------------
function UI_SecretDungeonScene:refreshDungeonList()
    -- 새로운 정보로 리스트뷰 새로 생성
    local function cb_func()
        self:initUI()
        self.m_bDirtyDungeonList = false

        UIManager:toastNotificationGreen(Str('인연 던전 항목이 갱신되었습니다.'))
    end

    -- 새로운 던전 정보 요청
    g_secretDungeonData:requestSecretDungeonInfo(cb_func)
end


--@CHECK
UI:checkCompileError(UI_SecretDungeonScene)
