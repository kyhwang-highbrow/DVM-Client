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

    vars['lockBtn'] = UIC_CheckBox(vars['lockBtn'].m_node, vars['lockSprite'], false)

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

    local struct_lair_stat = g_lairData:getLairStatInfo(self.m_lairId)
    local req_count = TableLair:getInstance():getLairRequireCount(self.m_lairId)
    local stat_id = struct_lair_stat:getStatId()
    local is_available = g_lairData:getLairSlotCompleteCount() >= req_count

    do  -- 잠금 처리
        local str 
        if is_available == true then
            if stat_id == 0 then
                str = Str('축복 효과 없음')
            else
                str = TableLairStatus:getInstance():getLairStatStrByIds({stat_id})
            end

        else
            str = Str('{@Y}드래곤 {1}마리 이상 등록 시 오픈{@}', req_count)
        end

        vars['optionLabel']:setString(str)
    end

    do
        is_available = is_available and stat_id ~= 0
        vars['refreshBtn']:setBlockMsg(is_available == false and '' or nil)
        vars['refreshBtn']:setEnabled(is_available)
    end

    do
        local is_lock = struct_lair_stat:isStatLock()
        vars['lockBtn']:setChecked(is_lock)
    end
end

--[[ -------------------------------------
-- function change_lockBtn
-------------------------------------
function UI_DragonLairBlessingPopupItem:change_lockBtn(is_checked)
    local vars = self.vars
    local is_lock = vars['lockBtn']:isChecked()

    local struct_lair_stat = g_lairData:getLairStatInfo(self.m_lairId)
    local stat_id = struct_lair_stat:getStatId()

    local req_count = TableLair:getInstance():getLairRequireCount(self.m_lairId)
    local is_available = g_lairData:getLairSlotCompleteCount() >= req_count
    is_available = is_available and stat_id ~= 0

    if is_available == false then
        UIManager:toastNotificationRed(Str('아직 이용할 수 없습니다.'))
        vars['lockBtn']:setChecked(not is_lock)
        return
    end

    local success_cb = function ()
        self:refresh()
    end
    
    g_lairData:request_lairStatLock(self.m_lairId, is_lock, success_cb)
end ]]