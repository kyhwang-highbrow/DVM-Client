local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumClanRankListItem
-------------------------------------
UI_ColosseumClanRankListItem = class(PARENT, {
        m_stuctClanRank = 'StuctClanRank',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumClanRankListItem:init(stuct_data)
    self.m_stuctClanRank = stuct_data
    local vars = self:load('colosseum_scene_ranking_item_clan.ui')

    -- 다음 랭킹 보기 
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
function UI_ColosseumClanRankListItem:initUI()
    local vars = self.vars
    local struct_clan_rank = self.m_stuctClanRank

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
    vars['rankLabel']:setString(clan_rank)
    
    -- 내클랜
    if (struct_clan_rank:isMyClan()) then
        vars['mySprite']:setVisible(true)
        vars['infoBtn']:setVisible(false)
    end

    -- 정보 보기 버튼
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = struct_clan_rank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumClanRankListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumClanRankListItem:refresh()
end
