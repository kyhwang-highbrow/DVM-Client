local PARENT = UI_ColosseumRankListItem

-------------------------------------
-- class UI_ColosseumFriendRankListItem
-------------------------------------
UI_ColosseumFriendRankListItem = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumFriendRankListItem:init(t_item_data)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumFriendRankListItem:refresh()
    local vars = self.vars
    local user_info = self.m_colosseumUserInfo

    -- 유저 닉네임
    vars['userNameLabel']:setString(user_info.m_nickname)

    -- 길드
    vars['guildLabel']:setString('')

    -- 드래곤
    local dragon_card = user_info:getLeaderDragonCard()
    dragon_card.root:setSwallowTouch(false)
    vars['userNode']:addChild(dragon_card.root)

    -- 랭킹
    vars['rankLabel']:setString(user_info:getFriendRankText())
    --vars['rankIconNode']

    -- 랭킹 포인트
    vars['pointLabel']:setString(user_info:getRPText())
   
    -- 티어 아이콘 
    local icon = user_info:getTierIcon('small')
    vars['tierNode']:addChild(icon)
end