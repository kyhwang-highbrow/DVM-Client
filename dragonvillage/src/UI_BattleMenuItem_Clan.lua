local PARENT = UI_BattleMenuItem

-------------------------------------
-- class UI_BattleMenuItem_Clan
-------------------------------------
UI_BattleMenuItem_Clan = class(PARENT, {})

local THIS = UI_BattleMenuItem_Clan

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem_Clan:init(content_type)
    local vars = self:load('battle_menu_clan_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenuItem_Clan:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    local content_type = self.m_contentType
    vars['dscLabel']:setString(self:getDescStr(content_type))


--[[     -- 룬 수호자 던전
    if (content_type == 'rune_guardian') then
        if (not g_nestDungeonData:isClearNightmare()) then
            vars['lockSprite']:setVisible(true)
            vars['lockLabel2']:setVisible(true)
        end
        
        vars['speechSprite']:setVisible(true)
    end ]]
end

-------------------------------------
-- function getDescStr
-------------------------------------
function UI_BattleMenuItem_Clan:getDescStr(content_type)
    local content_type = (content_type or self.m_contentType)

    local desc = ''

    -- 진화재료 던전
    if (content_type == 'nest_evo_stone') then
        desc = Str('진화재료 획득 가능')

    -- 거목 던전
    elseif (content_type == 'nest_tree') then
        desc = Str('친밀도 열매 획득 가능')

    -- 악몽 던전
    elseif (content_type == 'nest_nightmare') then
        desc = Str('룬 획득 가능')

    -- 고대 유적 던전
    elseif (content_type == 'ancient_ruin') then
        desc = Str('룬 획득 가능')

    -- 인연 던전
    elseif (content_type == 'secret_relation') then
        desc = Str('인연포인트 획득 가능')

    -- 클랜 던전
    elseif (content_type == 'clan_raid') then
        desc = Str('클랜 던전')

    -- 황금 던전
    elseif (content_type == 'gold_dungeon') then
        desc = Str('골드 획득 가능')
    end

    return desc
end