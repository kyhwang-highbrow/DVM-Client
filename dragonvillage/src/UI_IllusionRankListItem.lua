local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_IllusionRankListItem
-------------------------------------
UI_IllusionRankListItem = class(PARENT, {
        m_data = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionRankListItem:init(data, show_rank_rate)
    local vars = self:load('event_dungeon_ranking_rank_item.ui')
    self.m_data = data

    self:initUI(show_rank_rate)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IllusionRankListItem:initUI(show_rank_rate)
    local vars = self.vars
    local data = self.m_data

    -- 랭킹
    local struct_rank = StructUserInfoArena:create_forRanking(data)
    local rank = struct_rank:getRankText_noTier(show_rank_rate)
    vars['rankingLabel']:setString(rank)
    
    -- 리더 드래곤
    local profile_sprite = struct_rank:getLeaderDragonCard()
    profile_sprite.root:setSwallowTouch(false)
    vars['profileNode']:addChild(profile_sprite.root)

    -- 점수
    if (data['score'] and data['score'] >= 0) then
        vars['scoreLabel']:setString(Str('{1}점', comma_value(data['score'])))
    else
        vars['scoreLabel']:setString('-')
    end
    
    -- 유저 정보
    local user_text = struct_rank:getUserText()
    vars['userLabel']:setString(user_text)

    -- 클랜 이름
    local struct_clan = struct_rank:getStructClan()
    if (struct_clan) then
        local clan_name = struct_clan:getClanName()
        local clan_mark = struct_clan:makeClanMarkIcon()
        vars['clanLabel']:setString(clan_name)
        vars['markNode']:addChild(clan_mark)
    else
        vars['clanLabel']:setString('')
    end

    vars['clanBtn']:getParent():setSwallowTouch(false)
end








