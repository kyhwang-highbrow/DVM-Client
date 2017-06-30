local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumRankListItem
-------------------------------------
UI_ColosseumRankListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRankListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('colosseum_scene_ranking_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRankListItem:initUI()
    local vars = self.vars
    local t_rank_info = self.m_rankInfo
    local rank = t_rank_info.m_rank

    local tag = t_rank_info.m_tag

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
    vars['scoreLabel']:setString(t_rank_info:getRPText())

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(t_rank_info:getUserText())

    -- 순위 표시
    vars['rankingLabel']:setString(t_rank_info:getRankText())

    do -- 리더 드래곤 아이콘
        local ui = t_rank_info:getLeaderDragonCard()
        if ui then
            ui.vars['clickBtn']:registerScriptTapHandler(function() UI_UserInfoMini:open(t_rank_info) end)
            ui.root:setSwallowTouch(false)
            vars['profileNode']:addChild(ui.root)
        end
    end

    do -- 티어 아이콘
        local icon = t_rank_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)

        vars['tierLabel']:setString(t_rank_info:getTierName())
    end

    do -- 내 순위 UI일 경우
        local uid = g_userData:get('uid')
        local is_my_rank = (uid == t_rank_info.m_uid)
        vars['meSprite']:setVisible(is_my_rank)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRankListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRankListItem:refresh()
end
