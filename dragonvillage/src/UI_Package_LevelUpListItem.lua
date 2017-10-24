local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Package_LevelUpListItem
-------------------------------------
UI_Package_LevelUpListItem = class(PARENT, {
        m_data = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUpListItem:init(data)
    self.m_data = data
    local vars = self:load('package_levelup_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_LevelUpListItem:initUI()
    local vars = self.vars

    --[[
    -- 날짜
    local t_data = self.m_data
    local day = t_data['day']
    vars['infoLabel']:setString(Str('{1}일차', day))

    -- 보상 수령 여부
    if t_data['received'] then
        vars['receiveSprite1']:setVisible(false)
        vars['receiveSprite2']:setVisible(true)
    else
        vars['receiveSprite1']:setVisible(true)
        vars['receiveSprite2']:setVisible(false)
    end

    -- 보상 아이템 아이콘 표시
    for i,v in ipairs(t_data['login_items']) do
        local parent = vars['itemNode' .. i]
        if parent then
            local item_id = v['item_id']
            local item_cnt = v['count']
            local item_card = UI_ItemCard(item_id, item_cnt)
            parent:addChild(item_card.root)
            item_card.root:setSwallowTouch(false)
        end
    end
    --]]

    -- t_data 2017-07-28 sgkim
    --{
    --        ['day']=4;
    --        ['daily_items']={
    --        };
    --        ['received']=false;
    --        ['login_items']={
    --                {
    --                        ['count']=100;
    --                        ['oids']={
    --                        };
    --                        ['item_id']=700001;
    --                };
    --                {
    --                        ['count']=100;
    --                        ['oids']={
    --                        };
    --                        ['item_id']=700101;
    --                };
    --        };
    --}
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_LevelUpListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_LevelUpListItem:refresh()
end
