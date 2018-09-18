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

    -- 스테이지
    --vars['stageNumberLabel']:setString(Str('스테이지 {1}', stage))
    vars['stageNumberLabel']:setString(Str('{1}위', t_data['rank']))

    -- 닉네임
    vars['userNameLabel']:setString(nick)

    -- 아이콘
    local struct_dragon_obj = StructDragonObject:parseDragonStringData(t_data['leader'])
    local card = UI_DragonCard(struct_dragon_obj)
    card:setButtonEnabled(false)
    vars['dragonNode']:addChild(card.root)

    -- 잠금 여부
    local is_open = g_challengeMode:isOpenStage_challengeMode(t_data['stage'])
    vars['lockSprite']:setVisible(not is_open)

    -- 클리어 여부
    local is_clear = g_challengeMode:isClearStage_challengeMode(t_data['stage'])
    vars['clearSprite']:setVisible(is_clear)
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