local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ChallengeModeListItem
-------------------------------------
UI_ChallengeModeListItem = class(PARENT, {
        m_userData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeListItem:init(t_data)
    local vars = self:load('challenge_mode_list_item_01.ui')

    self.m_userData = t_data

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_cellSize = cc.size(330, 129)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModeListItem:initUI()
    local vars = self.vars

    local t_data = self.m_userData
    local stage = t_data['stage']
    local nick = t_data['nick']
    vars['stageNumberLabel']:setString(Str('스테이지 {1}', stage))
    vars['userNameLabel']:setString(nick)

    -- 아이콘
    local struct_dragon_obj = StructDragonObject:parseDragonStringData(t_data['leader'])
    local card = UI_DragonCard(struct_dragon_obj)
    card:setButtonEnabled(false)
    vars['stageNode']:addChild(card.root)


    if true then
        return
    end

    local stage_id = self.m_stageTable['stage']
    local floor = g_ancientTowerData:getFloorFromStageID(stage_id)
    local clear_floor = g_ancientTowerData.m_clearFloor

    -- 층 수 표시
    vars['floorLabel']:setString(Str('{1}층', floor))

    -- 클리어시 보상 표시
    local t_info = TABLE:get('anc_floor_reward')[stage_id]
    if (t_info) then
        local l_str = (floor > clear_floor) and seperate(t_info['reward_first'], ';') or seperate(t_info['reward_repeat'], ';')
        local item_type = l_str[1]
        local item_id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
        local item_count = tonumber(l_str[2])

        local item_card = UI_ItemCard(item_id, item_count)
        item_card.vars['clickBtn']:setEnabled(false)
        vars['rewardNode']:addChild(item_card.root)
    end
    vars['towerVisual']:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    vars['towerVisual']:changeAni('normal', true)

    local is_open = g_ancientTowerData:isOpenStage(stage_id)
    vars['lockSprite']:setVisible(not is_open)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeListItem:initButton()
    local vars = self.vars
    
    if true then
        return
    end
    vars['floorBtn']:getParent():setSwallowTouch(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeListItem:refresh()
end