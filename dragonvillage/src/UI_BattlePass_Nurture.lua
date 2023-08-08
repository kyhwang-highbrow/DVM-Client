local PARENT = UI_Package

--------------------------------------------------------------------------
-- @classmod UI_BattlePass_Nurture
-- @brief 
--------------------------------------------------------------------------
UI_BattlePass_Nurture = class(PARENT, {
    m_passId = 'number',
    m_passLevelList = 'List<>',
    m_passData = 'StructIndivPass',    
    m_passLastExp = 'number',
    m_tableView = 'UIC_TableView',      -- 스크롤뷰 (횡스크롤)
})

UI_BattlePass_Nurture.START_TYPE_IDX = 0
UI_BattlePass_Nurture.END_TYPE_IDX = 2

--------------------------------------------------------------------------
-- @function initUI 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initUI()
    local vars = self.vars

    local struct_indiv_pass = self.m_structProduct
    self.m_passId = struct_indiv_pass.pass_id
    self.m_passData = g_indivPassData:getIndivPass(self.m_passId)
    self.m_passLevelList = TableIndivPassReward:getInstance():getIndivPassLevelDataList(self.m_passId)
    self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)

    self:initTableView()
    self:update()
end

--------------------------------------------------------------------------
-- @function getPassLevel
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:getPassLevel()
    local struct_indv_pass = self.m_passData
    return struct_indv_pass:getIndivPassUserLevel()
end

--------------------------------------------------------------------------
-- @function initButton 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initButton()
    local vars = self.vars
    vars['questBtn']:registerScriptTapHandler(function() self:click_questBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)

    for type_id = UI_BattlePass_Nurture.START_TYPE_IDX, UI_BattlePass_Nurture.END_TYPE_IDX do
        local reward_btn_str = string.format('passRewardBtn%d', type_id)
        if vars[reward_btn_str] ~= nil then
            vars[reward_btn_str]:registerScriptTapHandler(function() self:click_rewardBtn(type_id) end)
        end

        local buy_btn_str = string.format('buyBtn%d', type_id)
        if vars[buy_btn_str] ~= nil then
            vars[buy_btn_str]:registerScriptTapHandler(function() self:click_buyBtn(type_id) end)
        end
    end
end

--------------------------------------------------------------------------
-- @function refresh 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refresh()
    self:refreshLevel()
    self:refreshButtons()
    self:refreshTableList()
end

-------------------------------------
-- function refreshTableList
-------------------------------------
function UI_BattlePass_Nurture:refreshTableList()
    for i,v in pairs(self.m_tableView.m_itemList) do
        local ui = v['ui']
        if ui ~= nil then
            ui:refresh()
        end
    end
end

--------------------------------------------------------------------------
-- @function refreshLevel 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refreshLevel()
    local vars =  self.vars
    local user_level = self:getPassLevel()

    do -- 유저 레벨
        vars['levelLabel']:setString(user_level == 0 and Str('없음') or user_level)
    end

    do -- 다음 레벨
        local max_level = #self.m_passLevelList
        local next_level = math_min(user_level + 1, max_level)

        local user_exp = self.m_passData:getIndivPassExp()
        local prev_exp = user_level == 0 and 0 or self.m_passLevelList[user_level]['exp']
        local next_exp = self.m_passLevelList[next_level]['exp']

        local need_exp = math_max(next_exp - prev_exp, 1)
        local exp = user_exp - prev_exp

        vars['nextLevelLabel']:setString(next_level)

        if user_level >= max_level then
            vars['nextPointLabel']:setString(Str('최대 레벨'))
            vars['nextLevelGauge']:setPercentage(100)
        else
            vars['nextPointLabel']:setStringArg(comma_value(exp), comma_value(need_exp))
            vars['nextLevelGauge']:setPercentage((exp/need_exp) * 100)
        end


        self.m_passLastExp = user_exp
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_BattlePass_Nurture:update()
    local vars =  self.vars
    
    local struct_indiv_pass = g_indivPassData:getIndivPass(self.m_passId)
    vars['timeLabel']:setString(struct_indiv_pass:getRemainTimeText())

    if struct_indiv_pass:getIndivPassExp() ~= self.m_passLastExp then
        self:refresh()
    end
end

--------------------------------------------------------------------------
-- @function refreshButtons 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refreshButtons()
    local vars = self.vars
    local struct_indiv_pass = self.m_passData
    local curreny_buy_type = struct_indiv_pass:getIndivPassCurrentBuyType()

    for type_id = UI_BattlePass_Nurture.START_TYPE_IDX, UI_BattlePass_Nurture.END_TYPE_IDX do
        -- 구매 버튼 처리
        local is_buyable = type_id > 0 and curreny_buy_type < type_id
        local buy_btn_str = string.format('buyBtn%d', type_id)
        if vars[buy_btn_str] ~= nil then
            vars[buy_btn_str]:setVisible(is_buyable)
        end

        -- 보상 버튼 처리
        local is_available_reward = struct_indiv_pass:isIndivPassAvailableReward(type_id)
        local reward_btn_str = string.format('passRewardBtn%d', type_id)
        if vars[reward_btn_str] ~= nil then
            vars[reward_btn_str]:setVisible(not is_buyable)

            if is_available_reward == false then 
                vars[reward_btn_str]:setBlockMsg(Str('수령할 수 있는 아이템이 없습니다.'))
            else
                vars[reward_btn_str]:setBlockMsg(nil)
            end
        end

        -- 보상 버튼 레드닷
        local reward_btn_noti_str = string.format('passNotiSprite%d', type_id)
        if vars[reward_btn_noti_str] ~= nil then
            vars[reward_btn_noti_str]:setVisible(is_available_reward)
        end
    end
end

--------------------------------------------------------------------------
-- @function initTableView 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initTableView()
    local vars = self.vars

    -- 생성 콜백
    local function create_func(ui, data)
        local finish_cb = function()
            ui:refresh()
        end

        -- 보상 리스트
        for idx = UI_BattlePass_Nurture.START_TYPE_IDX, UI_BattlePass_Nurture.END_TYPE_IDX do
            -- 보상 버튼 표시
            local reward_btn_str = string.format('%dRewardBtn', idx + 1)
            if ui.vars[reward_btn_str] ~= nil then
                --ui.vars[reward_btn_str].m_node:setSwallowTouch(false)
                ui.vars[reward_btn_str]:registerScriptTapHandler(function ()
                    self:click_rewardLevelBtn(idx, data['level'], finish_cb)
                end)
            end
        end
    end

    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(120, 480)
    table_view:setCellUIClass(UI_BattlePass_NurtureCell, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setCellCreateDirecting(nil)
    table_view:setItemList(self.m_passLevelList)

    self.m_tableView = table_view
    self.m_tableView:update(0)
    self.m_tableView:relocateContainerFromIndex(self:getPassLevel())
end

--------------------------------------------------------------------------
-- @function click_infoBtn 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_infoBtn()
    UI_BattlePassInfoPopup('battle_pass_3step_info_popup.ui')
end

--------------------------------------------------------------------------
-- @function click_questBtn 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_questBtn() 
    UINavigator:goTo('quest')
end

--------------------------------------------------------------------------
-- @function click_buyBtn 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_buyBtn(type_id)
    local struct_indiv_pass = self.m_passData
    if struct_indiv_pass:isIndivPassValidTime() == false then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'))
        return
    end

    local curreny_buy_type = struct_indiv_pass:getIndivPassCurrentBuyType()
    local diff = type_id - curreny_buy_type

    if diff >= 2 then
        UIManager:toastNotificationRed(Str('이전 단계의 패스 상품을 먼저 구매해주세요.'))
        return
    elseif diff <= 0 then
        UIManager:toastNotificationRed(Str('구매가 불가능한 상태입니다.'))
        return
    end

    local product_map = g_shopDataNew:getProductList('indiv_pass')
    local pid_list = {0, struct_indiv_pass:getAdvancePassPid(), struct_indiv_pass:getPremiumPassPid()}

    local pid = pid_list[type_id + 1]        
    local struct_product = product_map[pid]
    local is_buyable = struct_product ~= nil and struct_product:isItBuyable()

    if is_buyable == false then
        return
    end

    local cb_func = function(ret)
        g_indivPassData:applyPassData(ret)
        self.m_passData = g_indivPassData:getIndivPass(self.m_passId)
        self:refresh()
	end

    struct_product:buy(cb_func)
end

--------------------------------------------------------------------------
-- @function click_rewardBtn 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_rewardBtn(type_id, level)
    local struct_indiv_pass = self.m_passData
    if struct_indiv_pass:isIndivPassValidTime() == false then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'))
        return
    end

    local reward_id_list = struct_indiv_pass:getIndivPassAvailableRewardIdList(type_id)
    if #reward_id_list == 0 then
        UIManager:toastNotificationRed(Str('수령할 수 있는 아이템이 없습니다.'))
        return
    end

    local reward_ids = table.concat(reward_id_list, ',')
    local pass_id = self.m_passId

    local cb_func = function(ret)
        g_indivPassData:applyPassData(ret)
        self.m_passData = g_indivPassData:getIndivPass(self.m_passId)
        self:refresh()

        ItemObtainResult(ret)
	end

    g_indivPassData:request_reward(pass_id, reward_ids, cb_func)
end

--------------------------------------------------------------------------
-- @function click_rewardLevelBtn 
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_rewardLevelBtn(type_id, level, finish_cb)
    local struct_indiv_pass = self.m_passData
    if struct_indiv_pass:isIndivPassValidTime() == false then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'))
        return
    end

    local pass_id = self.m_passId
    local reward_id = (pass_id * 10000) + (type_id * 100) + level
    
    local cb_func = function(ret)
        self.m_passData = g_indivPassData:getIndivPass(pass_id)
        self:refresh()

        if finish_cb ~= nil then
            finish_cb()
        end

        ItemObtainResult(ret)
        UI_ToastPopup(Str('보상을 수령하였습니다.'))
	end

    g_indivPassData:request_reward(pass_id, tostring(reward_id), cb_func)
end
