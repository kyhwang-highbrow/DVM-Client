local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_SecretDungeonListItem
-------------------------------------
UI_SecretDungeonListItem = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_SecretDungeonListItem:init()
    local vars = self:load('dungeon_item.ui')

    self:initUI(t_data)
    self:initButton()
    self:refresh()

    self.root:setDockPoint(cc.p(0, 0))
    self.root:setAnchorPoint(cc.p(0, 0))
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_SecretDungeonListItem:initUI(t_data)
    local vars = self.vars

    -- 리스트 아이템 이미지 지정
    local animator = MakeAnimator('res/ui/a2d/dungeon_relation/dungeon_relation.vrp')
    animator:changeAni('relation', true)
    vars['dungeonImgNode']:addChild(animator.m_node)

    vars['dayLabel']:setString('')

    vars['titleLabel']:setString(Str('인연 던전'))
    vars['timeLabel']:setString('')

    -- 보상 설명
    local desc = UI_BattleMenuItem_Dungeon:getDescStr('secret_relation')
    vars['rewardLabel']:setString(desc)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SecretDungeonListItem:initButton()
end