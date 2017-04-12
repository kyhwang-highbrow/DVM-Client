local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonSummon
-------------------------------------
UI_DragonSummon = class(PARENT,{
        m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSummon:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSummon'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 소환') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSummon:init()
    local vars = self:load('dragon_summon.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonSummon')

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
function UI_DragonSummon:initUI()
    local vars = self.vars

    vars['mileageGuage']:setPercentage(0)

    self:init_tableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSummon:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['rewardBtn20']:registerScriptTapHandler(function() self:click_rewardPopupBtn(20) end)
    vars['rewardBtn50']:registerScriptTapHandler(function() self:click_rewardPopupBtn(50) end)
    vars['rewardBtn150']:registerScriptTapHandler(function() self:click_rewardPopupBtn(150) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSummon:refresh()
    local vars = self.vars    

    local l_item_list = g_dragonSummonData:getDisplaySummonList()
    
    local function refresh_func(item, new_data)
        item['data'] = new_data
        if item['ui'] then
            item['ui']:refresh_tableViewCell(new_data)
        end
    end

    self.m_tableView:mergeItemList(l_item_list, refresh_func)

    -- 마일리지 정보
    local mileage = g_dragonSummonData.m_mileage
    vars['mileageLabel']:setString(Str('{1}', mileage))

    local percentage = (mileage / 150) * 100
    vars['mileageGuage']:stopAllActions()
    vars['mileageGuage']:runAction(cc.ProgressTo:create(0.2, percentage))

    local decided = false
    for i,v in ipairs(g_dragonSummonData.m_mileageRewardInfo) do
        local mileage_ = v['mileage']

        if (not decided) and (mileage_ <= mileage) then
            decided = true
            vars['receiveVisual' .. mileage_]:setVisible(true)
        else
            vars['receiveVisual' .. mileage_]:setVisible(false)
        end
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_DragonSummon:init_tableView()
    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = g_dragonSummonData:getDisplaySummonList()

    -- 생성 콜백
    local function create_func(ui, data)
        ui.m_refreshCB = function() self:refresh() end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(584 + 10, 604)
    table_view:setCellUIClass(UI_DragonSummonListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    local make_item = false
    table_view:setItemList(l_item_list, make_item)
    --table_view_td:makeDefaultEmptyDescLabel(Str(''))

    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        return a_data['ui_order'] > b_data['ui_order']
    end

    table.sort(table_view.m_itemList, sort_func)

    self.m_tableView = table_view
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonSummon:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_DragonSummon:click_rewardBtn()
    local function finish_cb(ret)
        self:refresh()

        for i,v in ipairs(ret['sent_item_list']) do
            local item_id = v['item_id']
            local item_name = TableItem():getValue(item_id, 't_name')
            UIManager:toastNotificationGreen(Str('[{1}]이(가) 우편함으로 발송되었습니다.', Str(item_name)))
        end
        
    end
    g_dragonSummonData:request_mileageReward(finish_cb)
end

-------------------------------------
-- function click_rewardPopupBtn
-------------------------------------
function UI_DragonSummon:click_rewardPopupBtn(mileage)
    local ui = UI_RewardListPopup()
    ui:initButton()
    ui:refresh()
    ui:setTitleText(Str('보상 정보'))
    ui:setDescText(Str('{1}마일리지', mileage))

    local t_mileage_reward_info = g_dragonSummonData:getMileageRewardInfo(mileage)

    ui:setRewardItemList(t_mileage_reward_info['reward'])
end




--@CHECK
UI:checkCompileError(UI_DragonSummon)
