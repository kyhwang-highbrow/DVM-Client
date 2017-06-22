local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerRankListItem
-------------------------------------
UI_AncientTowerRankListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerRankListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('tower_scene_ranking_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerRankListItem:initUI()
    local vars = self.vars
    local t_rank_info = self.m_rankInfo
    
    vars['scoreLabel']:setString(Str('{1}점', t_rank_info['rp'])) -- 서버에서 score로 변경해줘야함
    vars['nameLabel']:setString(t_rank_info['nick'])
    vars['rankingLabel']:setString(Str('{1}위', t_rank_info['rank']))

    do -- 리더 드래곤 아이콘
        local t_dragon_data = t_rank_info['leader']
        local ui = UI_DragonCard(StructDragonObject(t_dragon_data))
        ui.root:setSwallowTouch(false)
        vars['profileNode']:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AncientTowerRankListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AncientTowerRankListItem:refresh()
end
