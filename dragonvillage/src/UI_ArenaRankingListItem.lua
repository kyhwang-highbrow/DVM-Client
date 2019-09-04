local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaRankingListItem
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
UI_ArenaRankingListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRankingListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('arena_rank_popup_item_user_ranking.ui')

    self:initUI()
    --self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankingListItem:initUI()
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
        --vars['tierLabel']:setString(t_rank_info:getTierName())
    end
    --[[
    vars['tierNode']
    vars['markNode']
    vars['clanLabel']

    vars['rankingLabel']
    vars['scoreLabel']
    vars['userLabel']
    vars['profileNode']
--]]

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankingListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRankingListItem:refresh()
end
