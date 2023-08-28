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
    --self:doActionReset()
    --self:doAction(nil, false)

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
-- function showLabelEffect
-------------------------------------
function UI_DragonLairBlessingPopupItem:showLabelEffect()
    local vars = self.vars
    local find_node = vars['optionLabel']
    cca.stampShakeActionLabel(find_node, 1.1, 0.1, 0, 0)

    vars['effectVisual']:setVisible(true)
    vars['effectVisual']:changeAni('grind_2')
    vars['effectVisual']:addAniHandler(function()
        vars['effectVisual']:setVisible(false)
    end)
    --cca.reserveFunc(find_node, 0.1, onFinish)
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairBlessingPopupItem:refresh()
    local vars = self.vars
    local is_exist = self.m_isExist

    vars['progressNode']:removeAllChildren()
    vars['perLabel']:setVisible(false)
    if is_exist == false then
        vars['optionLabel']:setString(Str('{@deep_gray}추후 업데이트 예정{@}'))
        return
    end

    local struct_lair_stat = g_lairData:getLairStatInfo(self.m_lairId)
    local req_count = TableLair:getInstance():getLairRequireCount(self.m_lairId)
    local stat_id = struct_lair_stat:getStatId()
    local reg_count = g_lairData:getLairSlotCompleteCount()
    local is_available = reg_count >= req_count
    local level = struct_lair_stat:getStatOptionLevel(stat_id)
    local max_level = struct_lair_stat:getStatOptionMaxLevel()
    local is_max_level = max_level == level

    do  -- 잠금 처리
        local str = Str('{@Y}드래곤 {1}마리 이상 등록 시 오픈 [{2}/{3}]{@}', req_count, reg_count, req_count)
        if is_available == true then
            str = Str('축복 효과 없음')
            if stat_id > 0 then
                str = TableLairBuffStatus:getInstance():getLairStatStrByIds({stat_id})
                if is_max_level == true then
                    str = string.format('{@green}%s [MAX]{@}', str)
                end
            end
        end

        vars['optionLabel']:setString(str)
    end

    do
        is_available = is_available and stat_id ~= 0
        vars['refreshBtn']:setBlockMsg(is_available == false and '' or nil)
        vars['refreshBtn']:setEnabled(is_available)
    end

    do
        vars['perLabel']:setVisible(false)
        if is_available == true then
            -- 진행도 프로그레스
            self:refreshProgress(level, max_level)

            --진행도 텍스트
            local str = string.format('(%d/%d)', level, max_level)
            vars['perLabel']:setString(str)
            vars['perLabel']:setVisible(true)
        end
    end

    do
        local is_lock = struct_lair_stat:isStatLock()
        vars['lockBtn']:setChecked(is_lock)
    end
end

-------------------------------------
-- function refreshProgress
-------------------------------------
function UI_DragonLairBlessingPopupItem:refreshProgress(curr_count, max_count)
    local vars = self.vars
    local res = 'res/ui/gauges/battle_pass_level_gg.png'
    local board_size = vars['progressNode']:getContentSize()['width']
    local cell_size = board_size/max_count
    local start_pos = board_size/2
    local l_horizontal_pos_list = getSortPosList(cell_size, max_count)

    for i = 1, curr_count do
        local animator = MakeAnimator(res)
        local interval = 5
        local org_cell_size = animator:getContentSize()
        local org_cell_width_size = (org_cell_size['width'] + interval)
        local scale_ratio = cell_size/org_cell_width_size

        vars['progressNode']:addChild(animator.m_node)

        --animator:setDockPoint(cc.p(0.0, 0.5))
        --animator:setAnchorPoint(cc.p(0.0, 0.5))
        animator:setPositionX(l_horizontal_pos_list[i])
        animator:setScaleX(scale_ratio)
        animator:setScaleY(0.5)
    end
end