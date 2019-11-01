local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem
-------------------------------------
UI_ClanWarMatchingSceneListItem = class(PARENT,{

    })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingSceneListItem:init(data)
    local is_me = false
    if (data['is_me']) then
        is_me = data['is_me']
    end

    local vars
    if (is_me) then
        vars = self:load('clan_war_match_scene_item_me.ui')
    else
        vars = self:load('clan_war_match_scene_item_rival.ui')
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingSceneListItem:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_ClanWarMatchingSceneListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarMatchingSceneListItem:refresh()

end
