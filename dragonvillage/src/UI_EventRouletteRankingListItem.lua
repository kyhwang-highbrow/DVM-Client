


local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_EventRouletteRankingListItem
-------------------------------------
UI_EventRouletteRankingListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventRouletteRankingListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('event_lucky_fortune_bag_ranking_popup_item_02.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventRouletteRankingListItem:initUI()
    local vars = self.vars
    local struct_rank = self.m_rankInfo
    local rank = struct_rank.m_rank

    local tag = struct_rank.m_tag

    -- 다음 랭킹 보기 
    if (tag == 'next') then
        vars['nextBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return
    end

    -- 이전 랭킹 보기 
    if (tag == 'prev') then
        vars['prevBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return
    end

    -- 점수 표시
    local score_str = struct_rank:getScoreStr()
    vars['scoreLabel']:setString(score_str)
    -- 순위 표시
    local rank_str = struct_rank:getRankStr()
    vars['rankingLabel']:setString(rank_str)

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(struct_rank:getUserText())

    do -- 리더 드래곤 아이콘
        local ui = struct_rank:getLeaderDragonCard()
        if ui then
            vars['profileNode']:addChild(ui.root)
            
			ui.vars['clickBtn']:registerScriptTapHandler(function() 
				local is_visit = true
				UI_UserInfoDetailPopup:open(struct_rank, is_visit, nil)
			end)
        end
    end

    do -- 내 순위 UI일 경우
        local uid = g_userData:get('uid')
        local is_my_rank = (uid == struct_rank.m_uid)
        vars['meSprite']:setVisible(is_my_rank)
    end

    -- 공통의 정보
    self:initRankInfo(vars, struct_rank)
end

