local PARENT = UI

-------------------------------------
-- class UI_AdventureFirstRewardPopup
-------------------------------------
UI_AdventureFirstRewardPopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
        m_stageID = 'number',
        m_cbRefresh = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureFirstRewardPopup:init(stage_id, cb_refresh)
    self.m_stageID = stage_id
    self.m_cbRefresh = cb_refresh

    local vars = self:load('adventure_first_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    

    local drop_helper = DropHelper(stage_id)
    local l_icon = drop_helper:getDisplayItemIconList_firstReward()
    local l_pos = getSortPosList(150, #l_icon)

    for i,icon in ipairs(l_icon) do
        vars['itemNode']:addChild(icon)
        icon:setPositionX(l_pos[i])
    end

    self:refreshUI()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_AdventureFirstRewardPopup')
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureFirstRewardPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureFirstRewardPopup'
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function refreshUI
-- @brief
-------------------------------------
function UI_AdventureFirstRewardPopup:refreshUI()
    local stage_id = self.m_stageID
    local vars = self.vars

    local difficulty, chapter, stage = parseAdventureID(stage_id)
    local first_reward_state = g_adventureData:getFirstRewardInfo(stage_id)

    if (first_reward_state == 'lock') then
        vars['descLabel']:setString(Str('{1}-{2} 통과시 수령 가능', chapter, stage))
        vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
        vars['receiveLabel']:setString('닫기')

    elseif (first_reward_state == 'open') then
        vars['descLabel']:setString(Str('{1}-{2} 보상 수령 가능', chapter, stage))
        vars['okBtn']:registerScriptTapHandler(function() self:click_receiveBtn() end)
        vars['receiveLabel']:setString('수령')

    elseif (first_reward_state == 'finish') then
        vars['descLabel']:setString(Str('{1}-{2} 보상 수령 완료', chapter, stage))
        vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
        vars['receiveLabel']:setString('닫기')

    else
        error('first_reward_state : ' .. first_reward_state)
    end  
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_AdventureFirstRewardPopup:click_receiveBtn()
    SoundMgr:playEffect('EFFECT', 'reward')

    local l_reward_item = DropHelper:getFirstRewardItemList(self.m_stageID)

    local function finish_cb()
        g_adventureData:optainFirstReward(self.m_stageID)
        g_topUserInfo:refreshData()

        if self.m_cbRefresh then
            self.m_cbRefresh()
        end
        self:close()
        MakeSimplePopup(POPUP_TYPE.OK, Str('{@BLACK}' ..'보상을 수령하였습니다.'))
    end

    self:dropItem_network(l_reward_item, finish_cb)

    --[[
    g_adventureData:optainFirstReward(self.m_stageID)

    if self.m_cbRefresh then
        self.m_cbRefresh()
    end

    MakeSimplePopup(POPUP_TYPE.OK, Str('{@BLACK}' ..'보상을 수령하였습니다.'), function()
            self:refreshUI()
        end)
    --]]
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AdventureFirstRewardPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function dropItem_network
-------------------------------------
function UI_AdventureFirstRewardPopup:dropItem_network(l_drop_item, finish_cb)
    local uid = g_userData:get('uid')
    local l_drop_item = clone(l_drop_item)

    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)

    do_work = function(ret)
        self:dropItem_networkResponse(ret)

        ui_network:softReset()

        local t_drop_data = l_drop_item[1]
        if t_drop_data then
            table.remove(l_drop_item, 1)

            local item_id = t_drop_data[1]
            local count = t_drop_data[2]

            self:dropItem_networkSetRequest(ui_network, item_id, count)
            ui_network:request()
        else
            ui_network:close()
            finish_cb()
        end
    end

    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function dropItem_networkSetRequest
-------------------------------------
function UI_AdventureFirstRewardPopup:dropItem_networkSetRequest(ui_network, item_id, count)
    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]

    local type = t_item['type']
    local val_1 = t_item['val_1']
    local uid = g_userData:get('uid')

    if (type == 'gold') then
        ui_network:setUrl('/users/update')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('gold', (count * val_1))

    elseif (type == 'cash') then
        ui_network:setUrl('/users/update')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('cash', (count * val_1))

    elseif (type == 'dragon') then
        local did = t_item['val_1']
        local evolution = t_item['rarity']
        ui_network:setUrl('/dragons/add')
        ui_network:setParam('uid', uid)
        ui_network:setParam('did', did)
        ui_network:setParam('evolution', evolution or 1)

    elseif (type == 'fruit') then
        local fruit_id = t_item['item']
        ui_network:setUrl('/users/manage')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('key', 'fruits')
        ui_network:setParam('value', tostring(fruit_id) .. ',' .. (count * val_1))

    elseif (type == 'evolution_stone') then
        local evolution_stone_id = t_item['item']
        ui_network:setUrl('/users/manage')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('key', 'evolution_stones')
        ui_network:setParam('value', tostring(evolution_stone_id) .. ',' .. (count * val_1))
    end
end

-------------------------------------
-- function dropItem_networkResponse
-------------------------------------
function UI_AdventureFirstRewardPopup:dropItem_networkResponse(ret)
    if (not ret) then
        return
    end

    -- 획득한 재화 추가 (골드, 캐시, 열매, 진화석)
    if ret['user'] then
        g_serverData:applyServerData(ret['user'], 'user')
    end

    -- 획득한 드래곤 추가
    if (ret['dragons']) then
        for _,t_dragon in pairs(ret['dragons']) do
            g_dragonsData:applyDragonData(t_dragon)
        end
    end

    g_topUserInfo:refreshData()
end