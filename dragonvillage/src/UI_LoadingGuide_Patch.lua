local PARENT = UI

-------------------------------------
-- class UI_LoadingGuide_Patch
-------------------------------------
UI_LoadingGuide_Patch = class(PARENT,{
		m_lPatchGuideTable = 'list<table>',
		m_numberLoop = 'NumberLoop',
		m_patchTimer = 'num',
		m_getNextTime = 'num',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingGuide_Patch:init()
    local vars = self:load('loading_tip.ui')
	local guide_type = 'patch'

	-- 멤버 변수
	self.m_lPatchGuideTable = TableLoadingGuide():getGuideList(guide_type)
	self.m_numberLoop = NumberLoop(10)
	self.m_patchTimer = 0
	self.m_getNextTime = 5

	-- init 함수
	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingGuide_Patch:initUI()
	local vars = self.vars

	vars['prevBtn']:setVisible(true)
	vars['nextBtn']:setVisible(true)
	vars['loadingGauge']:setPercentage(0)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingGuide_Patch:initButton()
	local vars = self.vars
	
	vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
	vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoadingGuide_Patch:refresh(is_prev)
    local vars = self.vars
	local tar_idx = (is_prev) and self.m_numberLoop:prev() or self.m_numberLoop:next()
	local t_loading = self:getNextGuideTable(tar_idx)
	
	if (t_loading) then
		-- 로딩 팁 이미지
		local tip_icon = IconHelper:getIcon(t_loading['res'])
		vars['tipNode']:removeAllChildren()
		vars['tipNode']:addChild(tip_icon)

		-- 로딩 팁 문구
		local tip_str = Str(t_loading['t_desc'])
		vars['tipLabel']:setString(tip_str)

	else
		vars['tipLabel']:setString('')
	end
end

-------------------------------------
-- function getNextGuideTable
-------------------------------------
function UI_LoadingGuide_Patch:getNextGuideTable(idx)
	local ret_data = TableLoadingGuide:getGuideData_Order(self.m_lPatchGuideTable, idx)
	
	return ret_data
end

-------------------------------------
-- function update
-------------------------------------
function UI_LoadingGuide_Patch:update(dt)
	self.m_patchTimer = self.m_patchTimer + dt
	if (self.m_patchTimer > self.m_getNextTime) then
		self:refresh()
		self.m_patchTimer = self.m_patchTimer - self.m_getNextTime
	end
end


-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_LoadingGuide_Patch:click_prevBtn()
	self:refresh(true)
	self.m_patchTimer = 0
end


-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_LoadingGuide_Patch:click_nextBtn()
	self:refresh()
	self.m_patchTimer = 0
end

--@CHECK
UI:checkCompileError(UI_LoadingGuide_Patch)