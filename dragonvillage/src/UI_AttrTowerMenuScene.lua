local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_AttrTowerMenuScene
-------------------------------------
UI_AttrTowerMenuScene = class(PARENT, {
    m_selAttr = 'string',
    m_selStage = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTowerMenuScene:init(attr, stage)
    self.m_selAttr = attr 
    self.m_selStage = stage

    local vars = self:load('attr_tower_menu.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AttrTowerMenuScene')

    self:initUI()
    self:initButton()
    self:refresh()

    -- 메뉴 씬 진입 후 속성탑 바로 진입할 경우 fade in time 늘려줌 (중간에 씬 화면 보이지 않게)
    local duration = self.m_selAttr and 1.5 or 0.25
    self:sceneFadeInAction(nil, nil, duration)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_AttrTowerMenuScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AttrTowerMenuScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('시험의 탑')
    self.m_staminaType = 'tower'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttrTowerMenuScene:initUI()
    local vars = self.vars
	
    do -- 시험의 탑 확장 관련 메세지
        local msg = ''
        local max_stage_id = g_attrTowerData:getAttrMaxStageId()
        local need_floor = ATTR_TOWER_EXTEND_OPEN_FLOOR
        local clear_floor = g_attrTowerData.m_clearFloorTotalCnt

        if (max_stage_id == ServerData_AttrTower.MAXSTAGEID['DEFAULT']) then
            need_floor = ATTR_TOWER_EXTEND_OPEN_FLOOR
        elseif (max_stage_id == ServerData_AttrTower.MAXSTAGEID['EXTEND_100']) then
            need_floor = ATTR_TOWER_EXTEND_OPEN_FLOOR_150    
        elseif (max_stage_id == ServerData_AttrTower.MAXSTAGEID['EXTEND_150']) then
            need_floor = ATTR_TOWER_EXTEND_OPEN_FLOOR_200
        elseif (max_stage_id == ServerData_AttrTower.MAXSTAGEID['EXTEND_200']) then
            need_floor = ATTR_TOWER_EXTEND_OPEN_FLOOR_250
        elseif (max_stage_id == ServerData_AttrTower.MAXSTAGEID['EXTEND_250']) then
            need_floor = ATTR_TOWER_EXTEND_OPEN_FLOOR_300
        else
            need_floor = 0
        end
        
        -- 확장하는데 필요한 층 정보가 있을 때만 인포 표시
        vars['infoNode']:setVisible(need_floor > 0)
        msg = Str('속성에 상관없이 합 {1}개의 층을 클리어하면 시험의 탑 상위 층이 열립니다.', need_floor) .. string.format(' (%d/%d)', clear_floor, need_floor)
        vars['infoLabel']:setString(msg)
    end

    -- 던전은 화수목 따라서 불,물,땅 순서임..
    local l_attr = {'fire', 'water', 'earth', 'light', 'dark'}

    for i, attr in ipairs(l_attr) do
        local ui = UI_AttrTowerMenuItem(attr)
        vars['itemNode'..i]:addChild(ui.root)
    end

    if (self.m_selAttr) then
        UINavigator:goTo('attr_tower', self.m_selAttr, self.m_selStage)
    end

    
    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttrTowerMenuScene:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttrTowerMenuScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AttrTowerMenuScene:click_exitBtn()
   self:close()
end

--@CHECK
UI:checkCompileError(UI_AttrTowerMenuScene)