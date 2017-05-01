local PARENT = UI

-------------------------------------
-- class UI_AncientTowerSweepReward
-------------------------------------
UI_AncientTowerSweepReward = class(PARENT, {
		m_floor = 'number',
        m_rewardList = 'table'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerSweepReward:init(floor, t_data)
    local vars = self:load('tower_sweep_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

	-- 멤버 변수 할당
    self.m_floor = floor
    self.m_rewardList = t_data
	  
   -- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AncientTowerSweepReward')

    self:initUI()
    self:initButton()
    self:refresh()
    
    -- 하위 UI가 모두 opacity값을 적용되도록
    self:setOpacityChildren(true)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AncientTowerSweepReward:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerSweepReward:initUI()
    local vars = self.vars

    -- 층
	vars['floorLabel']:setString(Str('고대의 탑 {1}층', self.m_floor))

	do -- 보상 리스트
        
        -- 생성 콜백
        local function create_func(ui, data)
            ui.root:setScale(0.6)
        end

        local make_func = function(data)
            local item_id = data['item_id']
            local count = data['count']
            
            return UI_ItemCard(item_id, count)
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(vars['rewardNode'])
        table_view.m_defaultCellSize = cc.size(94, 98)
        table_view:setCellUIClass(make_func, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        table_view:setItemList(self.m_rewardList)
        table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerSweepReward:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerSweepReward:refresh()
end

--@CHECK
UI:checkCompileError(UI_AncientTowerSweepReward)
