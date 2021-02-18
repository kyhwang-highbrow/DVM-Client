local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewHistoryListItem
-------------------------------------
UI_ArenaNewHistoryListItem = class(PARENT, {
        m_rivalInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewHistoryListItem:init(t_rival_info)
    self.m_rivalInfo = t_rival_info
    local vars = self:load('arena_new_popup_defense_item.ui')
    self.root:setSwallowTouch(true)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewHistoryListItem:initUI()
    local vars = self.vars
    
    local t_rival_info = self.m_rivalInfo

    -- 승패 이미지
    local isWin = t_rival_info.m_matchResult == 1

    vars['winSprite']:setVisible(isWin)
    vars['loseSprite']:setVisible(not isWin)

    vars['userScoreLabel']:setString(Str('{1}점', t_rival_info.m_rp))
    vars['scoreLabel']:setString(t_rival_info.m_matchScore)

    local time = t_rival_info.m_matchTime

    --vars['timeLabel']:setString(Str('{1}분', need_time/60)

    --vars['powerLabel']:setString(self.m_rivalInfo:getDeckCombatPower(true))

    -- 드래곤 리스트
    local t_deck_dragon_list = t_rival_info.m_dragonsObject
    local dragonMaxCount = 5
    local dragonSlotIndex = 1

    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(true)
        vars['dragonNode' .. dragonSlotIndex]:addChild(icon.root)

        dragonSlotIndex =  dragonSlotIndex + 1
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewHistoryListItem:initButton()
    local vars = self.vars 
    --vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewHistoryListItem:refresh()
end