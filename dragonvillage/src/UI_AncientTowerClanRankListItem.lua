local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerClanRankListItem
-------------------------------------
UI_AncientTowerClanRankListItem = class(PARENT, {
        m_structRank = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerClanRankListItem:init(stuct_data)
    self.m_structRank = stuct_data
    local vars = self:load('tower_clan_rank_item.ui')

    if (stuct_data == 'next') or (stuct_data == 'prev') then
        return
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerClanRankListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerClanRankListItem:initButton()
    local vars = self.vars
    --[[
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = self.m_structRank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)
    --]]
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerClanRankListItem:refresh()
    local vars = self.vars
    local struct_clan_rank = self.m_structRank

    if (not struct_clan_rank) then
        return
    end

    -- 클랜 마크
    local icon = struct_clan_rank:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan_rank:getClanLvWithName()
    vars['clanLabel']:setString(clan_name)

    -- 클랜 마스터
    local clan_master = struct_clan_rank:getMasterNick()
    vars['masterLabel']:setString(clan_master)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 등수 
    local clan_rank = struct_clan_rank:getClanRank()
    if (vars['rankingLabel']) then
        vars['rankingLabel']:setString(clan_rank)
    end

    -- 내클랜
    if (struct_clan_rank:isMyClan()) then
        vars['meSprite']:setVisible(true)
        --vars['infoBtn']:setVisible(false)
    end
end
