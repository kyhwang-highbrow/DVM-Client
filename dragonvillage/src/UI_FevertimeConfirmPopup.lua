local PARENT = UI

-------------------------------------
-- class UI_ConfirmPopup
-------------------------------------
UI_FevertimeConfirmPopup = class(PARENT,{
		m_fevertimeName = 'string',
		m_fevertimePeriod = 'string',
        m_fevertimeInfo = 'string',
        m_fevertimeValue = 'number',
        m_fevertimeType = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeConfirmPopup:init(fevertime_name, fevertime_period, fevertime_info, fevertime_value, fevertime_type, ok_btn_cb, cancel_btn_cb)
	self.m_fevertimeName = fevertime_name
	self.m_fevertimePeriod = fevertime_period
    self.m_fevertimeInfo = fevertime_info
    self.m_fevertimeValue = fevertime_value
    self.m_fevertimeType = fevertime_type
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb

    local vars = self:load('event_fevertime_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_FevertimeConfirmPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FevertimeConfirmPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeConfirmPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeConfirmPopup:refresh()
	local vars = self.vars

    vars['timeLabel']:setString(self.m_fevertimePeriod)

    vars['hotTimeInfoLabel']:setString(self.m_fevertimeInfo)
    
    vars['hotTimeNameLabel']:setString(self.m_fevertimeName)

    local value = tostring(self.m_fevertimeValue * 100) .. '%'
    vars['hotTimePerLabel']:setString(value)

    local sprite = self:makeFevertimeIcon(self.m_fevertimeType)
    vars['hotTimeIconNode']:addChild(sprite, -1)
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_FevertimeConfirmPopup:click_backKey()
    self:click_cancelBtn()
end

-------------------------------------
-- function setFevertimeIcon
-------------------------------------
function UI_FevertimeConfirmPopup:makeFevertimeIcon(fevertime_type)
    local vars = self.vars
    local path = 'res/ui/icons/hot_time/'

    if(fevertime_type == 'exp_up') then
        path = path .. 'hot_time_exp_up.png'

    elseif(fevertime_type == 'gold_up') then
        path = path .. 'hot_time_gold_up.png'

    elseif(fevertime_type == 'rune_lvup_dc') then
        path = path .. 'hot_time_rune_lvup_dc.png'

    elseif(fevertime_type == 'rune_dc') then
        path = path .. 'hot_time_rune_dc.png'

    elseif(fevertime_type == 'reinforce_dc') then
        path = path .. 'hot_time_reinforce_dc.png'

    elseif(fevertime_type == 'skill_move_dc') then
        path = path .. 'hot_time_skill_move_dc.png'

    elseif(fevertime_type == 'sm_legend_up') then
        path = path .. 'hot_time_sm_legend_up.png'

    elseif(fevertime_type == 'dg_rune_legend_up') then
        path = path .. 'hot_time_dg_rune_legend_up.png'

    elseif(fevertime_type == 'pvp_honor_up') then
        path = path .. 'hot_time_pvp_honor_up.png'

    elseif(fevertime_type == 'dg_rune_up') then
        path = path .. 'hot_time_dg_rune_up.png'

    elseif(fevertime_type == 'dg_gt_item_up') then
        path = path .. 'dg_gt_item_up.png'

    elseif(fevertime_type == 'dg_gd_item_up') then
        path = path .. 'dg_gd_item_up.png'

    elseif(fevertime_type == 'mastery_dc') then
        path = path .. 'hot_time_mastery_dc.png'

    elseif(fevertime_type == 'ad_st_dc') then
        path = path .. 'hot_time_ad_st_dc.png'

    elseif(fevertime_type == 'dg_gt_st_dc') then
        path = path .. 'hot_time_dg_gt_st_dc.png'

    elseif(fevertime_type == 'dg_gd_st_dc') then
        path = path .. 'hot_time_dg_gd_st_dc.png'

    elseif(fevertime_type == 'dg_nm_st_dc') then
        path = path .. 'hot_time_dg_nm_st_dc.png'

    elseif(fevertime_type == 'dg_ar_st_dc') then
        path = path .. 'hot_time_dg_ar_st_dc.png'

    elseif(fevertime_type == 'dg_rg_st_dc') then
        path = path .. 'hot_time_dg_rg_st_dc.png'
    else
        path = path .. 'hot_time_noti.png'
    end

    local sprite = cc.Sprite:create(path)
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    
    return sprite
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_FevertimeConfirmPopup:click_okBtn()
    if self.m_cbOKBtn then
        if self.m_cbOKBtn() then
            return
        end
    end

    self:close()
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_FevertimeConfirmPopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    self:close()
end

-------------------------------------
-- function click_linkBtn
-------------------------------------
function UI_FevertimeConfirmPopup:click_linkBtn()
    UI_LoginPopup2()
end

--@CHECK
UI:checkCompileError(UI_FevertimeConfirmPopup)
