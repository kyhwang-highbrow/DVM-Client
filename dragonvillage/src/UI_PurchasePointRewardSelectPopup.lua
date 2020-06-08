local PARENT = UI

-------------------------------------
-- class UI_PurchasePointRewardSelectPopup
-------------------------------------
UI_PurchasePointRewardSelectPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointRewardSelectPopup:init(event_version, reward_idx)
    local vars = self:load('event_purchase_point_popup_receive_01.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_PurchasePointRewardSelectPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(event_version, reward_idx)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_PurchasePointRewardSelectPopup:initUI(event_version)
    local vars = self.vars

    local version = event_version
    local step = 4
    for reward_idx = 1, 3 do
        local item_id, item_count = self:getRewardInfoByStep(version, step, reward_idx)

        do -- 아이템 아이콘
            local ui_card = UI_ItemCard(item_id, item_count)
            vars['itemNode' .. reward_idx]:addChild(ui_card.root)
        end

        do -- 아이템 이름 (수량)
            local item_name = TableItem:getItemName(item_id)
            if (item_count <= 1) then
                vars['itemLabel' .. reward_idx]:setString(item_name)
            else
                local str =  Str('{1} {2}개', item_name, comma_value(item_count))
                vars['itemLabel' .. reward_idx]:setString(str)
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PurchasePointRewardSelectPopup:initButton()
    local vars = self.vars
    vars['selectBtn1']:registerScriptTapHandler(function() self:click_selectRewardIdx(1) end)
    vars['selectBtn2']:registerScriptTapHandler(function() self:click_selectRewardIdx(2) end)
    vars['selectBtn3']:registerScriptTapHandler(function() self:click_selectRewardIdx(3) end)

    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PurchasePointRewardSelectPopup:refresh()
end

-------------------------------------
-- function getRewardInfoByStep
-------------------------------------
function UI_PurchasePointRewardSelectPopup:getRewardInfoByStep(version, step, reward_idx)
    local reward_idx = (reward_idx or 1)

    local t_step, reward_state = g_purchasePointData:getPurchasePoint_rewardStepInfo(version, step)
    local package_item_str = t_step['item']
    if (reward_idx ~= 1) then
        package_item_str = t_step['item_' .. tostring(reward_idx)]
    end
    local l_reward = ServerData_Item:parsePackageItemStr(package_item_str)
    
    -- 구조상 다중 보상 지급이 가능하나, 현재로선 하나만 처리 중 sgkim 2018.10.17
    local first_item = l_reward[1]
    local item_id = first_item['item_id']
    local count = first_item['count']

    return item_id, count
end

-------------------------------------
-- function click_selectRewardIdx
-------------------------------------
function UI_PurchasePointRewardSelectPopup:click_selectRewardIdx(reward_idx)

end

--@CHECK
UI:checkCompileError(UI_PurchasePointRewardSelectPopup)
