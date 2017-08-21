local PARENT = UI

-------------------------------------
-- class UI_LoadingGuide
-------------------------------------
UI_LoadingGuide = class(PARENT,{
		m_lLoadingStrList = 'List<string>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingGuide:init(curr_scene)
    local vars = self:load('loading_tip.ui')

	local guide_type = curr_scene.m_loadingGuideType
	if (guide_type) then
		self.m_lLoadingStrList = table.sortRandom(g_constant:get('UI', 'LOADING_TEXT'))
	end

	self:initUI(guide_type)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingGuide:initUI(guide_type)
    local vars = self.vars

	local t_loading = TableLoadingGuide():getGuideDataByWeight(guide_type)
	
	if (t_loading) then
		-- 로딩 팁 이미지
		local tip_icon = IconHelper:getIcon(t_loading['res'])
		vars['tipNode']:addChild(tip_icon)

		-- 로딩 팁 문구
		local tip_str = Str(t_loading['t_desc'])
		vars['tipLabel']:setString(tip_str)

	else
		vars['tipLabel']:setString('로딩 중')

	end

	-- 로딩 게이지 초기화
	if (vars['loadingGauge']) then
		vars['loadingLabel']:setString('')
		vars['loadingGauge']:setPercentage(0)
	end

    -- 일반 로딩 간에는 dragon 사용하지 않는중
    vars['dragonMenu']:setVisible(false)
    vars['tipMenu']:setVisible(true)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingGuide:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoadingGuide:refresh()
end

-------------------------------------
-- function setNextLoadingStr
-------------------------------------
function UI_LoadingGuide:setNextLoadingStr()
	if (not self.m_lLoadingStrList) then
		return
	end

	local random_str = self.m_lLoadingStrList[1]
	if (random_str) then
		self.vars['loadingLabel']:setString(random_str)
		table.remove(self.m_lLoadingStrList, 1)
	end
end

-------------------------------------
-- function setLoadingGauge
-------------------------------------
function UI_LoadingGuide:setLoadingGauge(percent, is_not_use_label)
	local vars = self.vars

	vars['loadingGauge']:setPercentage(percent)
	if (not is_not_use_label) then
		self:setNextLoadingStr()
	end
end

-------------------------------------
-- function getLoadingGauge
-------------------------------------
function UI_LoadingGuide:getLoadingGauge()
	return self.vars['loadingGauge']:getPercentage()
end

--@CHECK
UI:checkCompileError(UI_LoadingGuide)
