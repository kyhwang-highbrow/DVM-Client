local PARENT = UI

-------------------------------------
-- class UI_NotificationFullInventoryPopup
-------------------------------------
UI_NotificationFullInventoryPopup = class(PARENT, {
        m_notiType = 'string', -- 'dragon' or 'inventory'
        m_ignoreFunc = 'function',
        m_manageFunc = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NotificationFullInventoryPopup:init(noti_type, curr_cnt, max_cnt, ignore_func, manage_func)
    self.m_notiType = noti_type
    self.m_ignoreFunc = ignore_func
    self.m_manageFunc = manage_func

    local vars = self:load('popup_inventory_noti.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_NotificationFullInventoryPopup')

    self:initUI(noti_type, curr_cnt, max_cnt)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NotificationFullInventoryPopup:initUI(noti_type, curr_cnt, max_cnt)
    local vars = self.vars

    if (noti_type == 'dragon') then
        vars['dscLabel']:setString(Str('드래곤이 가득 차 더 이상 드래곤을 획득 할 수 없습니다.\n계속 진행하시겠습니까?'))
        vars['titleLabel']:setString(Str('보유 드래곤'))
        vars['inventoryLabel']:setString(Str('드래곤 관리'))

    elseif (noti_type == 'inventory') then
        vars['dscLabel']:setString(Str('인벤토리가 가득 차 더 이상 아이템을 획득 할 수 없습니다.\n계속 진행하시겠습니까?'))
        vars['titleLabel']:setString(Str('보유 아이템'))
        vars['inventoryLabel']:setString(Str('인벤토리'))

    else
        error('# noti_type : ' .. noti_type)
    end

    vars['numberLabel']:setString(Str('{1}/{2}', comma_value(curr_cnt), comma_value(max_cnt)))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NotificationFullInventoryPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['okBtn']:registerScriptTapHandler(function() self.m_ignoreFunc() self:close() end)
    vars['inventoryBtn']:registerScriptTapHandler(function() self.m_manageFunc() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NotificationFullInventoryPopup:refresh()
end