local PARENT = UI

-------------------------------------
-- class UI_LoadingGuide_Patch
-------------------------------------
UI_LoadingGuide_Patch = class(PARENT,{
		m_lPatchGuideTable = 'list<table>',
		m_currIdx = 'num',
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
	self.m_currIdx = 1 
	self.m_patchTimer = 0
	self.m_getNextTime = 10

	-- init 함수
	self:initUI()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingGuide_Patch:initUI()
	local vars = self.vars

	-- 미사용 cocos object
	vars['loadingLabel']:setVisible(false)
	vars['loadingGauge']:setVisible(false)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingGuide_Patch:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoadingGuide_Patch:refresh()
    local vars = self.vars
	local t_loading = self:getNextGuideTable()
	
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
-- function refresh
-------------------------------------
function UI_LoadingGuide_Patch:getNextGuideTable()
	local ret_data = TableLoadingGuide:getGuideData_Order(self.m_lPatchGuideTable, self.m_currIdx)
	if (ret_data) then
		self.m_currIdx = self.m_currIdx + 1
	else
		ret_data = TableLoadingGuide:getGuideData_Order(self.m_lPatchGuideTable, 1)
		self.m_currIdx = 2
	end
	
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

--@CHECK
UI:checkCompileError(UI_LoadingGuide_Patch)
