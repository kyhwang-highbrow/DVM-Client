----------------------------------------------------------------------
-- class UI_ClearTicketConfirm
----------------------------------------------------------------------
UI_ClearTicketConfirm = class(PARENT, {
    m_changedUserInfo = 'table',
    m_dropItems = 'table',

    m_clearNum = 'number',

    m_originalTitleLabel = 'string',

    m_levelUpDirector = 'LevelupDirector_GameResult',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_ClearTicketConfirm:init(clear_num, result_table)
    local vars = self:load('clear_ticket_popup_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    -- UI 클래스명 지정
    self.m_uiName = 'UI_ClearTicketConfirm'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClearTiUI_ClearTicketConfirmcket')


    self:initMember(clear_num, result_table)
    self:initUI()
    self:initButton()
    self:initDropItems()
    self:initUserInfo()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initMember(clear_num, result_table)
    local vars = self.vars

    self.m_clearNum = clear_num
    self.m_changedUserInfo = result_table['user_levelup_data']
    self.m_dropItems = result_table['drop_reward_list']
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initUI()
    local vars = self.vars 

    vars['resultLabel']:setString(Str(vars['resultLabel']:getString(), self.m_clearNum))


end


----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ClearTicketConfirm:refresh()
end


----------------------------------------------------------------------
-- function initUserInfo
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initUserInfo()
    local vars = self.vars

    local prev_lv = self.m_changedUserInfo['prev_lv']
    local prev_exp = self.m_changedUserInfo['prev_exp']
    local curr_lv = self.m_changedUserInfo['curr_lv']
    local curr_exp = self.m_changedUserInfo['curr_exp']

    local level_up_director = LevelupDirector_GameResult(
        vars['userLvLabel'],
        vars['userExpLabel'],
        vars['userMaxSprite'],
        vars['userExpGg'],
        vars['userLvUpVisual']
    )

    -- if (prev_lv ~= curr) then
    --     level_up_director.m_cbAniFinish = function()
    --         --self.root:stopAllActions()
            
    --         -- @ GOOGLE ACHIEVEMENT
    --         local t_data = {clear_key = 'u_lv'}
    --         GoogleHelper.updateAchievement(t_data)

    --         local ui = UI_UserLevelUp(self.m_changedUserInfo)
    --         --ui:setCloseCB(function() self:doNextWork() end)
    --     end
    -- end

    level_up_director:initLevelupDirector(prev_lv, prev_exp, curr_lv, curr_exp, 'tamer')

    self.m_levelUpDirector = level_up_director

    local function finish_cb()
        self.m_levelUpDirector:stop()  

        if (prev_lv ~= curr_lv) then
            local t_data = {clear_key = 'u_lv'}
            GoogleHelper.updateAchievement(t_data)

            local ui = UI_UserLevelUp(self.m_changedUserInfo)
        end
    end
    self.m_levelUpDirector.m_cbAniFinish = finish_cb
    self.m_levelUpDirector:start()
end



----------------------------------------------------------------------
-- function initDropItems
----------------------------------------------------------------------
function UI_ClearTicketConfirm:initDropItems()
    local vars = self.vars
    local count = #self.m_dropItems

    if (count <= 0) then
        return
    end

--[[     local interval = 95
    local pos_list = getSortPosList(interval, count)

    for index, value in ipairs(self.m_dropItems) do
        -- value = {item_id, count, from, data}
        local item_id = value[1]
        local item_num = value[2]
        local from = value[3]
        local data = value[4]

        local item_card = UI_ItemCard(item_id, item_num, data)

        if item_card then
            item_card.root:setScale(0.6)

            vars['dropRewardMenu']:addChild(item_card.root)

            item_card.root:setPositionX(pos_list[index])

            if (from =='bonus') then
                local animator = MakeAnimator('res/item/item_marble/item_marble.vrp')
                animator:setAnchorPoint(cc.p(0.5, 0.5))
                animator:setDockPoint(cc.p(1, 1))
                animator:setScale(0.85)
                animator:setPosition(-20, -20)
                item_card.vars['clickBtn']:addChild(animator.m_node)
            end
        end
    end ]]

    
    local interval = 95
    local max_cnt_per_line = 8
    local card_scale = 0.6

    -- 생성 시 함수
    local function make_func(value)
        local item_id = value[1]
        local item_num = value[2]
        local from = value[3]
        local data = value[4]
        local item_card = UI_ItemCard(item_id, item_num, data)

        if (from =='bonus') then
            local animator = MakeAnimator('res/item/item_marble/item_marble.vrp')
            animator:setAnchorPoint(cc.p(0.5, 0.5))
            animator:setDockPoint(cc.p(1, 1))
            animator:setScale(0.85)
            animator:setPosition(-20, -20)
            item_card.vars['clickBtn']:addChild(animator.m_node)
        end

        return item_card
    end

    -- 생성 시 함수
    local function create_func(ui, data)
        local scale = ui.root:getScale()
        ui.root:setScale(scale * 0.2)
        local scale_to = cc.ScaleTo:create(0.25, card_scale)
        local action = cc.EaseInOut:create(scale_to, 2)
        ui.root:runAction(action)
    end
    
    -- 테이블뷰 생성 TD
    local table_view = UIC_TableViewTD(vars['dropRewardMenu'])
    --table_view:setCellCreateDirecting(-1)
    table_view:setAlignCenter(true)
    table_view:setHorizotalCenter(true)
    table_view.m_cellSize = cc.size(interval, interval)
    table_view.m_nItemPerCell = max_cnt_per_line
    table_view:setCellUIClass(make_func, create_func)
    table_view:setItemList(self.m_dropItems, true)
    table_view:setCellCreateInterval(0.1)
    table_view:setCellCreatePerTick(10)
    --table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['scale'])
    table_view:update(0)
end