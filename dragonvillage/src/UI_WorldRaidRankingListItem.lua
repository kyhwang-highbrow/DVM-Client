local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
--- @class UI_WorldRaidRankingListItem 
-------------------------------------
UI_WorldRaidRankingListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidRankingListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('world_raid_scene_new_rank.ui')

    -- 닉네임 정보가 없다면, 다음/이전 버튼 데이터
    if (not self.m_rankInfo['nick']) then
        return
    end

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidRankingListItem:initUI()
    local vars = self.vars
    local t_rank_info = StructUserInfoArena:create_forRanking(self.m_rankInfo)

    -- 점수 표시
    vars['scoreLabel']:setString(t_rank_info:getRPText())

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(t_rank_info:getUserText())

    -- 순위 표시
    vars['rankingLabel']:setString(t_rank_info:getRankText())

    do -- 리더 드래곤 아이콘
        local ui = t_rank_info:getLeaderDragonCard()
        if ui then
            ui.root:setSwallowTouch(false)
            vars['profileNode']:addChild(ui.root)
            
			ui.vars['clickBtn']:registerScriptTapHandler(function() 
				local is_visit = true
				UI_UserInfoDetailPopup:open(t_rank_info, is_visit, nil)
			end)
        end
    end

    do -- 티어 아이콘
        local icon = t_rank_info:makeTierIcon(nil)
        if (icon) then
            vars['tierNode']:addChild(icon)
        end
        vars['tierLabel']:setString(t_rank_info:getTierName())
    end


    local struct_clan = t_rank_info:getStructClan()
    if (struct_clan) then
        -- 클랜 이름
        local clan_name = struct_clan:getClanName()
        vars['clanLabel']:setString(clan_name)
        
        -- 클랜 마크
        local icon = struct_clan:makeClanMarkIcon()
        if (icon) then
            vars['markNode']:addChild(icon)
        end
    else
        vars['clanLabel']:setVisible(false)
    end

    vars['itemMenu']:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidRankingListItem:initButton()
    local vars = self.vars
    local t_rank_info = self.m_rankInfo
    local t_clan_info = t_rank_info['clan_info']
    if (t_clan_info) then
	    vars['clanBtn']:registerScriptTapHandler(function()
            g_clanData:requestClanInfoDetailPopup(t_clan_info['id'])
        end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidRankingListItem:refresh()
end
