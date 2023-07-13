local PARENT = UI_BattleMenuItem

-------------------------------------
-- class UI_BattleMenuItem_Dungeon
-------------------------------------
UI_BattleMenuItem_Dungeon = class(PARENT, {})

local THIS = UI_BattleMenuItem_Dungeon

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem_Dungeon:init(content_type, count)
    local res = 'battle_menu_dungeon_item.ui'
    if (count < 3) then
        res = 'battle_menu_dungeon_item.ui'
    elseif (count == 4)  then
        res = 'battle_menu_dungeon_item_02.ui'
    elseif (count >= 5) then
        res = 'battle_menu_dungeon_item_03.ui'
    else
        res = 'battle_menu_dungeon_item_03.ui'
    end

    local vars = self:load(res)

    self:initUI(content_type)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenuItem_Dungeon:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    --content_type = (content_type or self.m_contentType)

    vars['dscLabel']:setString(self:getDescStr(content_type))

    -- 차원문 컨텐츠 오픈 띠지
    if (self.m_contentType == 'dmgate') 
        and g_dmgateData:isShowLobbyBanner()
        and (not g_contentLockData:isContentLock(self.m_contentType)) then
            local node = self.vars['newSprite']
            if node then
                node:setVisible(true)
                self.root:setLocalZOrder(self.root:getLocalZOrder() + 1)
            end
    end

    local content_type = self.m_contentType
    local clear_sweep_type_list = {'nest_tree', 'nest_evo_stone', 'ancient_ruin', 'nest_nightmare'}
    if table.find(clear_sweep_type_list, content_type) ~= nil then
        vars['speechSprite']:setVisible(true)
    end
end

-------------------------------------
-- function getDescStr
-------------------------------------
function UI_BattleMenuItem_Dungeon:getDescStr(content_type)
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

    -- 차원문
    elseif (content_type == 'dmgate') then
        desc = Str('차원문 토큰 획득 가능')
    end
    return desc
end

function UI_BattleMenuItem_Dungeon:notifiyNewContent()
    
        -- 차원문 컨텐츠 오픈 띠지
        if (self.m_contentType == 'dmgate') and g_dmgateData:isShowLobbyBanner() then
            local node = self.vars['newSprite']
            if node then
                node:setVisible(true)
            end
        end
end