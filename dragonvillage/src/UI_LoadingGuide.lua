local PARENT = UI

-------------------------------------
-- class UI_LoadingGuide
-------------------------------------
UI_LoadingGuide = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingGuide:init()
    local vars = self:load('loading_tip.ui')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingGuide:initUI()
    local vars = self.vars
	local table_loading = TableLoadingGuide()
	local gid = 9000 + math_random(5)
	
	-- 로딩 팁 이미지
	local tip_icon = table_loading:getLoadingImg(gid)
	vars['tipNode']:addChild(tip_icon)

	-- 로딩 팁 문구
	local tip_str = table_loading:getLoadingDesc(gid)
	vars['tipLabel']:setString(tip_str)
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

--@CHECK
UI:checkCompileError(UI_LoadingGuide)
