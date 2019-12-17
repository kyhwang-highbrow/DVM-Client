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

--@jhakiim 20191219 업데이트에서 테이머 레벨 99 확장, but 진형 테이머 스킬 레벨은 70으로 제한
local MAX_LEVEL = 70

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:init(t_tamer, skill_mgr, skill_idx)
    local vars = self:load('tamer_skill_detail_popup_item.ui')
    
	self.m_tableTamer = t_tamer
    self.m_skillMgr = skill_mgr
    self.m_skillIdx = skill_idx
	self.m_maxSkillLevel = math.min(g_userData:get('lv'), MAX_LEVEL)

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
    local skill_type = skill_indivisual_info:getSkillTypeForUI()

    do -- 스킬 타입
        local str, color = getSkillTypeStr_Tamer(skill_type)
        vars['typeLabel']:setString(str)
        vars['typeLabel']:setColor(color)
    end

    do -- 스킬 아이콘
        local char_type = skill_indivisual_info.m_charType
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon(char_type, skill_id)
        if (icon) then
            vars['skillNode']:addChild(icon)
        end
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

    do -- 스킬 아이콘
        local char_type = skill_indivisual_info.m_charType
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon(char_type, skill_id)
        if (icon) then
            vars['skillNode']:addChild(icon)
        end
    end

    do -- 레벨 표시
        if (skill_level == 0) then
            vars['lvLabel']:setVisible(false)
            vars['typeLabel']:setPositionX(110)
        else
            vars['lvLabel']:setVisible(true)
            vars['lvLabel']:setString(Str('Lv.{1}', skill_level))
        end
    end

    do -- 스킬 설명
        local desc = skill_indivisual_info:getSkillDesc()
        vars['skillDscLabel']:setString(desc)
    end

	do	-- 강화 버튼
		vars['lockSprite']:setVisible(false)
		vars['maxSprite']:setVisible(false)
		vars['enhanceBtn']:setVisible(false)

        local user_lv = g_userData:get('lv')
		-- 미습득 상황
		if (skill_level <= 0) then
			vars['lockSprite']:setVisible(true)

		-- 최대 레벨 (유저 레벨이 max인 경우에만 max 표시)
		elseif (max_skill_lv <= skill_level) and (user_lv >= 70) then
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
-- @breif 스킬 강화 버큰
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:click_enhanceBtn()
    local skill_indivisual_info = self.m_skillMgr:getSkillIndivisualInfo_usingIdx(self.m_skillIdx)

	local ui = UI_SkillEnhance(self.m_tableTamer, skill_indivisual_info, self.m_skillIdx)
	local function close_cb()
		self:refresh_enhance()
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function refresh_enhance
-------------------------------------
function UI_SkillDetailPopupListItem_Tamer:refresh_enhance()
    self.vars['EnhanceVisual']:setVisible(true)
    self.vars['EnhanceVisual']:changeAni('slot_fx_01', false)
    self.vars['EnhanceVisual']:addAniHandler(function() self.vars['EnhanceVisual']:setVisible(false) end)

	local t_tamer_data = g_tamerData:getTamerServerInfo(self.m_tableTamer['tid'])
    self.m_skillMgr = MakeTamerSkillManager(t_tamer_data)

    self:refresh()
end