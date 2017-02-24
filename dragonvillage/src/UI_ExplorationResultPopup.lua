local PARENT = UI

-------------------------------------
-- class UI_ExplorationResultPopup
-------------------------------------
UI_ExplorationResultPopup = class(PARENT,{
        m_eprID = '',
        m_hours = '',
        m_data = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationResultPopup:init(epr_id, hours, data)
    self.m_eprID = epr_id
    self.m_hours = hours
    self.m_data = data

    local vars = self:load('exploration_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationResultPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationResultPopup:initUI()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 지역 이름 & 탐험 시간
    local location = Str(location_info['t_name'])
    local hours = self.m_hours
    vars['locationTimeLabel']:setString(Str('{1} {2} 시간', location, hours))

    do -- 보상 아이템 갯수
        local l_item_list = self.m_data['added_items']['items_list']
        local item_cnt = #l_item_list
        vars['rewardLabel']:setString(Str('탐험 보상으로 {1}개의 아이템을 얻었습니다.', item_cnt))
    end

    do
        -- 획득하는 아이템 리스트
        local l_item_list = self.m_data['added_items']['items_list']
        vars['rewardNode']:removeAllChildren()

        local scale = 0.53
        local l_pos = getSortPosList(150 * scale + 3, #l_item_list)

        for i,v in ipairs(l_item_list) do
            local ui = UI_ItemCard(v['item_id'], v['count'])
            vars['rewardNode']:addChild(ui.root)
            ui.root:setScale(0)
            ui.root:setPosition(l_pos[i], 0)
            ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.ScaleTo:create(0.25, scale)))
        end
    end
    

    -- 획득 경험치
    local exp = location_info[tostring(hours) .. '_hours_exp']
    vars['expLabel']:setString(comma_value(exp))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationResultPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationResultPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationResultPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ExplorationResultPopup)
