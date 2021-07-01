local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_HallOfFameRankListItem
-------------------------------------
UI_HallOfFameRankListItem = class(PARENT,{
		m_tRankInfo = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameRankListItem:init(data)
    local vars = self:load('hall_of_fame_rank_popup_item.ui')
	self.m_tRankInfo = data
    
	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    if (not self.m_tRankInfo) then
        return
    end

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameRankListItem:initUI()
    local vars = self.vars

	-- 랭킹
    local rank = self.m_tRankInfo['rank']
    rank = tonumber(rank) or 0
    if (rank < 1) then
        vars['rankingLabel']:setString('-')
    else
        vars['rankingLabel']:setString(Str('{1}위', comma_value(rank)))
    end
    
    if (self.m_tRankInfo['leader']) then
	    -- 리더 드래곤 아이콘
	    local dragon_icon = UI_DragonCard(self.m_tRankInfo['leader'])
	    vars['profileNode']:addChild(dragon_icon.root)
	    dragon_icon.root:setSwallowTouch(false)
    end

	-- 유저 이름
	local user_name = self.m_tRankInfo['nick']
	vars['userLabel']:setString(user_name)

    if (self.m_tRankInfo['clan_info']) then
        -- 클랜 이름
        local t_clan_info = self.m_tRankInfo['clan_info']
        local clan_name = t_clan_info['name']
        vars['clanLabel']:setString(clan_name)
        
        -- 클랜 마크
        local clan_mark = StructClanMark:create(t_clan_info['mark'])
        local icon = clan_mark:makeClanMarkIcon()
        if (icon) then
            vars['markNode']:addChild(icon)
        end
    else
        vars['clanLabel']:setVisible(false)
    end

    vars['itemMenu']:setSwallowTouch(false)
    
	-- 스코어
    local ancient_score = self:setScoreDesc(self.m_tRankInfo['ancient_score'])
    --local challenge_score = self:setScoreDesc(self.m_tRankInfo['challenge_score'])
    local arena_score = self:setScoreDesc(self.m_tRankInfo['arena_score'])
    local score = self:setScoreDesc(self.m_tRankInfo['score'])

    -- 그림자, 콜로, 탑 점수 출력하는 것이 기본
    vars['hall_of_fameScoreMenu']:setVisible(true)

    --vars['challengeModeScoreLabel']:setString(Str('{1}점', challenge_score))
    vars['towerScoreLabel']:setString(Str('{1}점', ancient_score))
    vars['arenaScoreLabel']:setString(Str('{1}점', arena_score))
    
    -- 총점 수 출력
    vars['sumScoreLabel']:setString(Str('{1}점', score))
    vars['scoreLabel']:setVisible(false)

	vars['meSprite']:setVisible(false)
end

-------------------------------------
-- function setNormalRank
-------------------------------------
function UI_HallOfFameRankListItem:setNormalRank()
    local vars = self.vars
    local score = self:setScoreDesc(self.m_tRankInfo['rp'])

    -- 도감, 퀘스트의 경우 점수라벨을 다른 것을 사용
    vars['scoreLabel']:setString(Str('{1}점', score))
    vars['hall_of_fameScoreMenu']:setVisible(false)
    vars['scoreLabel']:setVisible(true)
end

-------------------------------------
-- function setScoreDesc
-------------------------------------
function UI_HallOfFameRankListItem:setScoreDesc(score)
    local score = tonumber(score)
    if (not score) then
        return 0
    end

    if (score < 0) then
        return 0
    end

    return comma_value(score)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameRankListItem:initButton()
    local vars = self.vars
    if (self.m_tRankInfo['clan_info']) then
	    vars['clanBtn']:registerScriptTapHandler(function()
		    local struct_clan = StructClan(self.m_tRankInfo['clan_info'])
            local clan_object_id = struct_clan:getClanObjectID()
            g_clanData:requestClanInfoDetailPopup(clan_object_id)
        end)
    end
end