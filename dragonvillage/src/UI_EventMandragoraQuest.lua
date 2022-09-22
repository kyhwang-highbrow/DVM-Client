local PARENT = UI

-------------------------------------
-- class UI_EventMandragoraQuest
-------------------------------------
UI_EventMandragoraQuest = class(PARENT,{
        m_itemUiList = '',

        m_container = '',
        m_containerTopPosY = '',

        --m_goalUi = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMandragoraQuest:init()
    local vars = self:load('event_mandragora.ui')
    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventMandragoraQuest:initUI()
    local vars = self.vars

    -- 종료 시간
    local end_text = g_mandragoraQuest:getStatusText()
    vars['timeLabel']:setString(end_text)

    -- 최종 보상을 받기 위한 퀘스트 수
    local last_reward_condition = g_mandragoraQuest:getLastRewardCondition()
    vars['infoLabel']:setString(Str('{1}일차 클리어 시 스페셜 보상 획득!', last_reward_condition))

    -- 시작 UI
    --do
        --local ui = UI_EventMandragoraQuestListItem()
        --ui.vars['startNode']:setVisible(true)
        --vars['node1']:addChild(ui.root)
    --end

    -- 퀘스트 UI
    self.m_itemUiList = {}
    local quest_info = g_mandragoraQuest.m_questInfo
    for i, v in ipairs(quest_info) do
        local ui = UI_EventMandragoraQuestListItem(v)
        ui.m_refreshFunc = function()
            self:refresh()
        end

        local node = vars['node'.. i]
        if (node) then
            node:addChild(ui.root)
            table.insert(self.m_itemUiList, ui)
        end
    end

    -- 종료 UI
    --local total_cnt = #quest_info 
    --local node = vars['node'..total_cnt + 2]
    --if (node) then
        --local ui = UI_EventMandragoraQuestListItem()
        --ui.vars['goalNode']:setVisible(true)
        --node:addChild(ui.root)
--
        --self.m_goalUi = ui
    --end

    -- 최종 보상 UI
    do
        local last_reward_info = g_mandragoraQuest:getLastRewardInfo()

        for idx, v in ipairs(last_reward_info) do
            local node_name = 'itemNode' .. idx

            if (vars[node_name] == nil) then
                if (idx == 1) then
                    node_name = 'itemNode'
                else
                    break
                end
            end

            local item_card_ui = UI_ItemCard(v['item_id'], v['count'])
            local item_id = v['item_id']
            local did = tonumber(TableItem:getDidByItemId(item_id))
            if did and (0 < did) then
                item_card_ui.vars['clickBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true) end)
            end

            vars[node_name]:addChild(item_card_ui.root)
        end
    end

    --[[
    -- 캐릭터 페어 보상은 한국서버만 노출
    if (g_localData:isKoreaServer()) then
        vars['eventMenu']:setVisible(true)

         -- 캐릭터 페어 보상 안내 (네이버 sdk 링크)
        NaverCafeManager:setPluginInfoBtn(vars['plugBtn'], 'chrpair_notice')
    end
    --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMandragoraQuest:initButton()
    local vars = self.vars

    -- 최종 보상
    vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn() end)

    -- 캐릭터 페어
    -- vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMandragoraQuest:refresh()
    if (not g_mandragoraQuest.m_bDirty) then
        return
    end
    g_mandragoraQuest.m_bDirty = false

    local vars = self.vars
    
    -- 모두 클리어시 최종 보상
    vars['RewardVisual']:setVisible(false)
    vars['completeSprite']:setVisible(false)
    vars['receiveSprite']:setVisible(false)
    vars['receiveBtn']:setVisible(false)
    vars['receiveBtn']:setEnabled(false)

    local avail_get_last_reward = g_mandragoraQuest:availGetLastReward()
    if (avail_get_last_reward) then
    
        local already_get_last_reward = g_mandragoraQuest:alreadyGetLastReward()

        if (already_get_last_reward) then
            vars['completeSprite']:setVisible(true)
            vars['RewardVisual']:setVisible(false)

        else
            vars['receiveSprite']:setVisible(true)
            vars['receiveBtn']:setVisible(true)
            vars['receiveBtn']:setEnabled(true)
            vars['RewardVisual']:setVisible(true)
        end

    else
        vars['receiveBtn']:setVisible(true)
        vars['RewardVisual']:setVisible(true)
    end

    if (vars['receiveBtn']:isEnabled()) then
        vars['receiveLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
   
    else
        vars['receiveLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
    end

    --[[
    -- 캐릭터 페어 보상
    local is_available = g_mandragoraQuest:isAvailable_SpecialReward()
    vars['eventBtn']:setVisible(is_available)
    --]]
    self:refresh_containerPos()
    self:refresh_items()
end

-------------------------------------
-- function refresh_containerPos
-- @brief 진행단계에 따라 스크롤 포커싱 변경
-------------------------------------
function UI_EventMandragoraQuest:refresh_containerPos()
    local curr_qid = g_mandragoraQuest:getCurrentQid()
    local container_node = self.m_container
    if (not container_node) then
        return
    end

    local is_all_clear = g_mandragoraQuest:isAllClear()
    local avail_get_last_reward = g_mandragoraQuest:availGetLastReward()
    if (is_all_clear or avail_get_last_reward) then
        container_node:setPositionY(self.m_containerTopPosY)
        return
    end

    --if (curr_qid < 6) then
        --container_node:setPositionY((self.m_containerTopPosY/2) - 200)
--
    --elseif (curr_qid < 10) then
        --container_node:setPositionY((self.m_containerTopPosY/2) + 100)
--
    --else
        --container_node:setPositionY(0)
    --end
end

-------------------------------------
-- function refresh_items
-- @brief 퀘스트 UI 변경
-------------------------------------
function UI_EventMandragoraQuest:refresh_items()
    local quest_info = g_mandragoraQuest.m_questInfo

    for i, ui in ipairs(self.m_itemUiList) do
        -- 데이터 갱신 
        ui.m_questInfo = quest_info[i]
        ui:refresh()
    end
end

-------------------------------------
-- function setContainerAndPosY
-------------------------------------
function UI_EventMandragoraQuest:setContainerAndPosY(container, pos_y)
    self.m_container = container
    self.m_containerTopPosY = pos_y
end

-------------------------------------
-- function click_eventBtn
-- @brief 캐릭터페어 보상 받기
-------------------------------------
function UI_EventMandragoraQuest:click_eventBtn()
    local confirm_popup_func_1
    local confirm_popup_func_2
    local request_reward

    confirm_popup_func_1 = function()
        local msg = StrForDev('2018 캐릭터·라이선싱 페어 드래곤 빌리지 부스 직원 전용 메뉴입니다.')
        local sub_msg = StrForDev('직원이 아닌 경우 취소 버튼을 눌러주세요.')
        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, sub_msg, confirm_popup_func_2)
    end
        
    confirm_popup_func_2 = function()
        local msg = StrForDev('!!경고!!\n담당 직원이 직접 확인하지 않을 경우 선물을 받으실수 없습니다!')
        local sub_msg = StrForDev('직원이 아닌 경우 취소 버튼을 눌러주세요.')
        local popup = MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, sub_msg, request_reward)
        local vars = popup.vars
        vars['okBtn']:setEnabled(false)
        vars['cancelBtn']:setEnabled(false)

        local delay_time = 1.0
        cca.reserveFunc(popup.root, delay_time, function()
            vars['okBtn']:setEnabled(true)
            vars['cancelBtn']:setEnabled(true)
        end)
    end

    request_reward = function()
        g_mandragoraQuest:request_specialReward(function()
            self:refresh()
        end)
    end

    confirm_popup_func_1()
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_EventMandragoraQuest:click_receiveBtn()
    local function refresh_cb()
        self:refresh()
    end
    
    g_mandragoraQuest:request_clearLastReward(refresh_cb)
end