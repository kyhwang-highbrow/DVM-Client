local PARENT = UI
 
-------------------------------------
-- class UI_SkillDetailPopupListItem_Tamer
-------------------------------------
UI_SkillDetailPopupListItem_Tamer = class(PARENT, {
        m_tableTamer = 'Table',
        m_skillMgr = 'class',
        m_skillIdx = 'num',
		m_maxSkillLevel = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:init(t_tamer, skill_mgr, skill_idx)
    local vars = self:load('tamer_skill_detail_popup_item.ui')
    
	self.m_tableTamer = t_tamer
    self.m_skillMgr = skill_mgr
    self.m_skillIdx = skill_idx
	self.m_maxSkillLevel = g_userData:get('lv')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:initUI()
    local vars = self.vars
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)

    do -- 스킬 타입
        local skill_idx = self.m_skillIdx
        local str = getSkillType_Tamer(skill_idx)
        vars['skillTypeLabel']:setString(str)
    end

    do -- 스킬 아이콘
		local char_type = skill_indivisual_info.m_charType
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon(char_type, skill_id)
        vars['skillNode']:addChild(icon)
    end

    do -- 스킬 이름
        local name = skill_indivisual_info:getSkillName()
        vars['skillNameLabel']:setString(name)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:initButton()
    local vars = self.vars
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:refresh()
    local vars = self.vars
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)
    local skill_level = skill_indivisual_info:getSkillLevel()
    local max_skill_lv = self.m_maxSkillLevel

    do -- 레벨 표시
		vars['skillEnhanceLabel']:setString(Str('Lv.{1}/{2}', skill_level, max_skill_lv))
    end

    do -- 스킬 설명
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
    end

	do	-- 강화 버튼
		vars['lockSprite']:setVisible(false)
		vars['maxSprite']:setVisible(false)
		vars['enhanceBtn']:setVisible(false)

		-- 미습득 상황
		if (skill_level <= 0) then
			vars['lockSprite']:setVisible(true)

		-- 최대 레벨
		elseif (max_skill_lv <= skill_level) then
			vars['maxSprite']:setVisible(true)

		-- 강화가 가능한 상태
		else
			vars['enhanceBtn']:setVisible(true)
			vars['enhanceBtnLabel']:setString(Str('강화'))
		end
	end
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:click_enhanceBtn()
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)

	UI_SkillEnhance(self.m_tableTamer, skill_indivisual_info)
end


-------------------------------------
-- function request_skillEnhance
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:request_skillEnhance()
    local uid = g_userData:get('uid')
    local tid = self.m_tableTamer['tid']
    local skill = self.m_skillIdx
	local level = 1

    local function success_cb(ret)
        -- 정보 갱신

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        self:refresh_enhance()

        self.vars['EnhanceVisual']:setVisible(true)
        self.vars['EnhanceVisual']:changeAni('slot_fx_01', false)
        self.vars['EnhanceVisual']:addAniHandler(function() self.vars['EnhanceVisual']:setVisible(false) end)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/lvup/tamer')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tid', tid)
    ui_network:setParam('skill', skill)
	ui_network:setParam('level', level)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function refresh_enhance
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:refresh_enhance()
    local old_dragon_data = self.m_tableTamer
    local new_dragon_data = g_dragonsData:getDragonDataFromUid(old_dragon_data['id'])

    if (old_dragon_data['updated_at'] == new_dragon_data['updated_at']) then
        return
    end

    self.m_tableTamer = new_dragon_data
    self.m_skillMgr = MakeDragonSkillFromDragonData(self.m_tableTamer)

    self:refresh()
end