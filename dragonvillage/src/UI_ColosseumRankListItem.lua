local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumRankListItem
-------------------------------------
UI_ColosseumRankListItem = class(PARENT, {
        m_colosseumUserInfo = 'ColosseumUserInfo',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRankListItem:init(t_item_data)
    self.m_colosseumUserInfo = t_item_data

    local vars = self:load('colosseum_rank_list.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRankListItem:initUI()
    local vars = self.vars

    vars['previousNode']:setSwallowTouch(false)
    vars['nextNode']:setSwallowTouch(false)
    vars['rankNode']:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRankListItem:initButton()
    local vars = self.vars
    vars['userButton']:registerScriptTapHandler(function() self:click_userButton() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRankListItem:refresh()
    local vars = self.vars
    local user_info = self.m_colosseumUserInfo


    if (user_info.m_rank == 'prev') then
        vars['rankNode']:setVisible(false)
        vars['previousNode']:setVisible(true)
        return
    elseif (user_info.m_rank == 'next') then
        vars['rankNode']:setVisible(false)
        vars['nextNode']:setVisible(true)
        return
    end

    -- 유저 닉네임
    vars['userNameLabel']:setString(user_info.m_nickname)

    -- 길드
    vars['guildLabel']:setString('')

    -- 드래곤
    local dragon_card = user_info:getLeaderDragonCard()
    dragon_card.root:setSwallowTouch(false)
    vars['userNode']:addChild(dragon_card.root)

    -- 랭킹
    local simple = true
    vars['rankLabel']:setString(user_info:getRankText(simple))
    --vars['rankIconNode']

    -- 랭킹 포인트
    vars['pointLabel']:setString(user_info:getRPText())
   
    -- 티어 아이콘 
    local icon = user_info:getTierIcon('small')
    vars['tierNode']:addChild(icon)
end

-------------------------------------
-- function click_userButton
-------------------------------------
function UI_ColosseumRankListItem:click_userButton()

    local colosseum_user_info = self.m_colosseumUserInfo
    local t_user_info = {}
    t_user_info['uid'] = colosseum_user_info.m_uid
    t_user_info['guild'] = ''
    t_user_info['nick'] = colosseum_user_info.m_nickname
    t_user_info['lv'] = colosseum_user_info.m_lv
    t_user_info['leader'] = clone(colosseum_user_info.m_leaderDragonData)

    UI_LobbyUserInfoPopup(t_user_info)
end