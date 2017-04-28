local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_AncientTowerScene
-------------------------------------
UI_AncientTowerScene = class(PARENT, {
        m_tableView = 'UIC_TableView', -- 탑 층 리스트
        
		m_curFloor = 'num',     -- 현재 진행중인 층
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerScene:init()
    local vars = self:load('tower_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AncientTowerScene')

    self.m_curFloor = 1
	
    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_AncientTowerScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AncientTowerScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('고대의 탑')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerScene:initUI()
    local vars = self.vars
	
	do -- 테이블 뷰 생성
        local node = vars['floorNode']
        node:removeAllChildren()

		-- 층 생성
		local t_floor = g_ancientTowerData:getAcientTower_stageList()
                
		-- 셀 아이템 생성 콜백
		local create_func = function(ui, data)
			return true
        end
		
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view._vordering = VerticalFillOrder['BOTTOM_UP']
        table_view.m_defaultCellSize = cc.size(500, 130 + 10)
        table_view:setCellUIClass(UI_AncientTowerListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(t_floor)
        table_view:makeAllItemUI()

        self.m_tableView = table_view
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerScene:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AncientTowerScene:click_exitBtn()
    local scene = SceneLobby()
	scene:runScene()
end


--@CHECK
UI:checkCompileError(UI_AncientTowerScene)
