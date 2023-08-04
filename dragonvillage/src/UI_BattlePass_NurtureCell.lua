local PARENT = class(UI, ITableViewCell:getCloneTable())

--------------------------------------------------------------------------
-- @classmod UI_BattlePass_NurtureCell
-- @brief battle_pass_nurture_item.ui 와 관련된 item cell의 기능 동작 관리
--------------------------------------------------------------------------
UI_BattlePass_NurtureCell = class(PARENT, {
    m_passId = 'number',
    m_passLevel = 'number',
    m_passExp = 'number',

    m_card = '',
})

UI_BattlePass_NurtureCell.START_TYPE_IDX = 0
UI_BattlePass_NurtureCell.END_TYPE_IDX = 2
--------------------------------------------------------------------------
-- @function init 
-- @param 데이터 테이블   {['id']=21; ['parent_key']=121701;}
-- @brief 모든 init 함수를 실행
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:init(data)
    self.m_passId = data['pass_id']
    self.m_passLevel = data['level']
    self.m_passExp = data['exp']
    self.m_card = {}

    self:load('battle_pass_3step_item.ui')

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

--------------------------------------------------------------------------
-- @function initUI 
-- @brief UI와 관련된 변수 및 기능 초기화
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initUI()
end

--------------------------------------------------------------------------
-- @function initButton 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initButton()
    local vars = self.vars
    self.root:setSwallowTouch(false)
    vars['swallowTouchMenu']:setSwallowTouch(false)

    -- 보상 리스트
    for idx = UI_BattlePass_NurtureCell.START_TYPE_IDX, UI_BattlePass_NurtureCell.END_TYPE_IDX do
        -- 보상 버튼 표시
        local reward_btn_str = string.format('%dRewardBtn', idx + 1)
        if vars[reward_btn_str] ~= nil then
            vars[reward_btn_str]:getParent():setSwallowTouch(false)
        end
    end
end

--------------------------------------------------------------------------
-- @function refresh 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:refresh()
    local vars = self.vars
    local struct_indiv_pass = g_indivPassData:getIndivPass(self.m_passId)
    --local user_exp = struct_indiv_pass:getIndivPassExp()
    local user_level = struct_indiv_pass:getIndivPassUserLevel()

    do --레벨
        vars['levelLabel']:setString(self.m_passLevel)
    end

    do -- 경험치 게이지
        local percentage = 100
        local next_level = user_level + 1

        if next_level == self.m_passLevel then
            percentage = 50
        elseif next_level < self.m_passLevel then
            percentage = 0
        end

        vars['passGauge']:setPercentage(percentage)
    end

    -- 보상 리스트
    for idx = UI_BattlePass_NurtureCell.START_TYPE_IDX, UI_BattlePass_NurtureCell.END_TYPE_IDX do
        self:refreshReward(idx)
    end
end

--------------------------------------------------------------------------
-- @function refreshReward 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:refreshReward(type_id)
    local vars = self.vars
    local reward_id = (self.m_passId * 10000) + (type_id * 100) + self.m_passLevel
    local struct_indiv_pass = g_indivPassData:getIndivPass(self.m_passId)
    local user_exp = struct_indiv_pass:getIndivPassExp()
    local item_id, item_num = TableIndivPassReward:getInstance():getPassRewardItem(reward_id)

    local is_reached = struct_indiv_pass:getIndivPassCurrentBuyType() >= type_id
    local is_clear = (user_exp >= self.m_passExp)
    local is_rewarded = struct_indiv_pass:isIndivPassReceivedReward(reward_id)
    local is_available = is_reached == true and is_clear == true and is_rewarded == false

    type_id = type_id + 1
    
    -- 아이템 노드
    local item_node_str = string.format('%dItemNode', type_id)
    if vars[item_node_str] ~= nil and self.m_card[type_id] == nil then
        local ui = UI_ItemCard(item_id)
        self.m_card[type_id] = ui

        ui:setSwallowTouch()
        ui:SetBackgroundVisible(false)

        vars[item_node_str]:removeAllChildren()
        vars[item_node_str]:addChild(ui.root)
    end

    self.m_card[type_id]:setEnabledClickBtn(true)

    -- 아이템 수량
    local item_label_str = string.format('%dItemLabel', type_id)
    if vars[item_label_str] ~= nil then
        vars[item_label_str]:setString(Str('x{1}', comma_value(item_num)))
    end

    -- 잠금 표시
    local lock_str = string.format('%dLockSprite', type_id)
    if vars[lock_str] ~= nil then
        vars[lock_str]:setVisible(false)
    end

    -- 클리어 표시
    local clear_sprite_str = string.format('%dClearSprite', type_id)
    if vars[clear_sprite_str] ~= nil then
        vars[clear_sprite_str]:setVisible(is_rewarded)
    end

    -- 보상 버튼 표시
    local reward_btn_str = string.format('%dRewardBtn', type_id)
    if vars[reward_btn_str] ~= nil then
        vars[reward_btn_str]:setVisible(is_available)
    end
end