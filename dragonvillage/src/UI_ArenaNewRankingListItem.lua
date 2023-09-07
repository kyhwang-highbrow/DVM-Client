local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewRankingListItem
-- @praram
--[[
        ['lv']=57;
        ['tier']='master_3';
        ['clan_info']={
                ['mark']='';
                ['name']='신규클랜서버';
                ['id']='59fc0797019add5c7aa0f5ea';
        };
        ['tamer']=110003;
        ['ancient_score']=0;
        ['rp']=936;
        ['challenge_score']=0;
        ['rate']=1;
        ['arena_score']=0;
        ['score']=0;
        ['un']=1287386;
        ['total']=4;
        ['uid']='wduik8wNHPd1y05sIoPxyZnemdl1';
        ['nick']='fanfan';
        ['leader']={
                ['lv']=60;
                ['mastery_lv']=0;
                ['grade']=6;
                ['rlv']=1;
                ['eclv']=0;
                ['did']=121131;
                ['transform']=3;
                ['mastery_skills']={
                };
                ['evolution']=3;
                ['mastery_point']=0;
        };
        ['costume']=730300;
        ['rank']=4;
        ['beginner']=false;
}
--]]
-------------------------------------
UI_ArenaNewRankingListItem = class(PARENT, {
        m_rankInfo = '',
        m_matchUserRanking = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRankingListItem:init(t_rank_info, ui_res)
    self.m_rankInfo = t_rank_info
    self.m_matchUserRanking = g_arenaNewData:makeMatchUserInfo(t_rank_info)
    local vars = self:load(ui_res or 'arena_new_rank_popup_item_user_ranking.ui')

    -- 닉네임 정보가 없다면, 다음/이전 버튼 데이터
    if (not self.m_rankInfo['nick']) then
        return    
    end

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewRankingListItem:initUI()
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

    do -- 아레나 덱 드래곤 리스트
        if vars['dragonNode1'] ~= nil then
            local t_deck_dragon_list = self.m_matchUserRanking.m_dragonsObject
            local dragonSlotIndex = 1

            for i,v in pairs(t_deck_dragon_list) do
                local node_str = 'dragonNode' .. dragonSlotIndex
                if vars[node_str] ~= nil then
                    local icon = UI_DragonCard(v)
                    icon.root:setSwallowTouch(false)

                    vars[node_str]:addChild(icon.root)
                    dragonSlotIndex =  dragonSlotIndex + 1
                end
            end
        end
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
function UI_ArenaNewRankingListItem:initButton()
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
function UI_ArenaNewRankingListItem:refresh()
end
