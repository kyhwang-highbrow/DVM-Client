PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_DragonLairBlessingPopupItem
-------------------------------------
UI_DragonLairBlessingPopupItem = class(PARENT, {
    m_lairId = 'number',
    m_isExist = 'boolean',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingPopupItem:init(data)
    self.m_lairId = data
    self.m_isExist = TableLair:getInstance():exists(self.m_lairId)

    self:load('dragon_lair_blessing_item.ui')

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)


    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingPopupItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingPopupItem:initButton()
    local vars = self.vars

    vars['refreshBtn']:setVisible(self.m_isExist)
    vars['lockBtn']:setVisible(self.m_isExist)
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingPopupItem:refresh()
    local vars = self.vars
    local is_exist = self.m_isExist

    if is_exist == false then
        vars['optionLabel']:setString(Str('{@deep_gray}추후 업데이트 예정{@}'))
        return
    end

    local str = TableLairStatus:getInstance():getLairStatStrByIds({10004})
    local req_count = TableLair:getInstance():getLairRequireCount(self.m_lairId)

    do
        if req_count > 0 then
            str = str .. ' ' .. Str('{@Y}(컬렉션 {1}회 이상 완성 시 오픈){@}', req_count)
        end
    end

    vars['optionLabel']:setString(str)
end