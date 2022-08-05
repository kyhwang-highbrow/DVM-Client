local PARENT = UI


-------------------------------------
-- class UI_EventBingoRewardListItem
-------------------------------------
UI_EventBingoRewardListItem = class(PARENT,{ 
        m_rewardInd = 'number',
        m_rewardItemStr = 'string',
        m_click_cb = 'function',
        m_item_card = 'UI_ItemCard',
        m_sub_data = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventBingoRewardListItem:init(reward_ind, reward_item_str, click_cb, is_bingo_reward_cnt, sub_data)
    local vars
    if (not is_bingo_reward_cnt) then
        vars = self:load('event_bingo_item_02.ui')
    else
        vars = self:load('event_bingo_item_03.ui')
    end
    self.m_rewardInd = reward_ind
    self.m_rewardItemStr = reward_item_str
    self.m_click_cb = click_cb
    self.m_sub_data = sub_data
    
    if (not reward_ind) or (not reward_ind) then
        return
    end
    
    if (not is_bingo_reward_cnt) then
        self:initUI()
    else
        self:initUI_cntReward()
    end

    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventBingoRewardListItem:initUI()
    local vars = self.vars
    
    local item_str = self.m_rewardItemStr
    local node_ind = self.m_rewardInd
    local l_item_str = pl.stringx.split(item_str, ';')
    local item_id = l_item_str[1]
    local item_cnt = l_item_str[2]
    local node = vars['itemNode'..node_ind]

    local reward_card = UI_ItemCard(tonumber(item_id), tonumber(item_cnt))
    reward_card.root:setSwallowTouch(false)

    -- 아이템 카드의 경우 : 뒷 배경 끔
    if (reward_card.vars['bgSprite']) then
        reward_card.vars['bgSprite']:setVisible(false)
    end
    if (reward_card.vars['commonSprite']) then
        reward_card.vars['commonSprite']:setVisible(false)
    end

    -- -- 드래곤 카드의 경우: 속성, 프레임 끔
    -- if (reward_card.vars['attrNode']) then
    --     reward_card.vars['attrNode']:setVisible(false)
    -- end

    -- if (reward_card.vars['frameNode']) then
    --     reward_card.vars['frameNode']:setVisible(false)
    -- end

    -- if (reward_card.vars['bgNode']) then
    --     reward_card.vars['bgNode']:setVisible(false)
    -- end

    if (reward_card) then
        vars['iconNode']:addChild(reward_card.root)
    end
    self.m_item_card = reward_card

    vars['receiveVisual']:setIgnoreLowEndMode(true)
end


-------------------------------------
-- function initUI_cntReward
-------------------------------------
function UI_EventBingoRewardListItem:initUI_cntReward()
    local vars = self.vars
    local struct_bingo = g_eventBingoData.m_structBingo
    vars['rewardLabel']:setString(Str('{1} 칸', self.m_sub_data))
    self.root:setScale(1.2)

    -- 누적 보상 아이템 카드 (임시 하드코딩)
    local reward_cnt = struct_bingo:getBingoRewardListCnt()
    local start_pos = -407
    local list_item_width = 163

    local item_str = self.m_rewardItemStr
    local node_ind = self.m_rewardInd
    local l_item_str = pl.stringx.split(item_str, ';')
    local item_id = l_item_str[1]
    local item_cnt = l_item_str[2]

    local reward_card = UI_ItemCard(tonumber(item_id), tonumber(item_cnt))
    vars['receiveBtn']:registerScriptTapHandler(function() self.m_click_cb(node_ind) end)
    reward_card.root:setScale(0.6)
    reward_card.root:setSwallowTouch(false)
    if (reward_card) then
        vars['iconNode']:addChild(reward_card.root)
        self.m_item_card = reward_card
    end

    self.root:setPositionX(start_pos + list_item_width*(node_ind))

    self:setBtnEnabled(false)
end

-------------------------------------
-- function setBtnEnabled
-------------------------------------
function UI_EventBingoRewardListItem:setBtnEnabled(is_enabled)
    local vars = self.vars

    if (self.m_item_card) then
        -- 보상 버튼 활성화 되면, 아이템 설명 툴팁 -> 콜백 함수 호출
        if (is_enabled) then
            self.m_item_card.vars['clickBtn']:registerScriptTapHandler(function() self.m_click_cb(self.m_rewardInd) end)
        end
    end

    if (vars['receiveBtn']) then
        vars['receiveBtn']:setEnabled(is_enabled)
    end

end
