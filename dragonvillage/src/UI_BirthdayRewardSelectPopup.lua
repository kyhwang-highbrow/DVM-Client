local PARENT = UI

-------------------------------------
-- class UI_BirthdayRewardSelectPopup
-------------------------------------
UI_BirthdayRewardSelectPopup = class(PARENT,{
        m_dragonType = 'number',
        m_selectedDid = 'number',
        m_tableView = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BirthdayRewardSelectPopup:init(dragon_type)
    self.m_dragonType = dragon_type
    self.m_selectedDid = nil

    local vars = self:load('event_birthday_reward_select_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BirthdayRewardSelectPopup')

    self:initUI()
    self:initButton()
    self:refresh()

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BirthdayRewardSelectPopup:initUI()
    local dragon_type = self.m_dragonType
    local t_birth_data = TableDragonType():get(dragon_type)

    local table_dragon = TableDragon()
    local l_dragons = table_dragon:filterTable('type', dragon_type)

    self:init_tableView(l_dragons)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BirthdayRewardSelectPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['selectBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BirthdayRewardSelectPopup:refresh()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_BirthdayRewardSelectPopup:init_tableView(l_dragons)
    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = l_dragons

    -- 생성 콜백
    local function create_func(ui, data)
        local did = data['did']
        ui.vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn(did) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(180 + 10, 340)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setCellUIClass(UI_BirthdayRewardSelectListItem, create_func)
    table_view:setItemList(l_item_list)

    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬

    self.m_tableView = table_view
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_BirthdayRewardSelectPopup:click_selectBtn(did)
    if self.m_selectedDid then
        local item = self.m_tableView:getItem(self.m_selectedDid)
        if item['ui'] then
            item['ui'].vars['selectSprite']:setVisible(false)
        end
    end

    self.m_selectedDid = did
    local item = self.m_tableView:getItem(self.m_selectedDid)
    if item['ui'] then
        item['ui'].vars['selectSprite']:setVisible(true)
    end
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_BirthdayRewardSelectPopup:click_rewardBtn()
    if (not self.m_selectedDid) then
        cca.uiReactionSlow(self.vars['listNode'])
        UIManager:toastNotificationRed(Str('드래곤의 속성을 선택해주세요.'))
        return
    end

    local function finish_cb(ret)
        do -- 결과 팝업
            local item_id, count, t_sub_data = g_itemData:parseAddedItems_firstItem(ret['added_items'] or ret['add_items'])
            local ui = MakeSimpleRewarPopup(Str('생일 보상'), item_id, count, t_sub_data)
            ui:setCloseCB(self.m_closeCB)
        end

        self:setCloseCB(nil)
        self:close()
    end

    local dragon_type = self.m_dragonType
    local itemid = getRelationItemId(self.m_selectedDid)
    g_birthdayData:request_birthdayReward(dragon_type, itemid, finish_cb, fail_cb)
end
