local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_CapsuleBox
-------------------------------------
UI_CapsuleBox = class(PARENT,{
		m_capsuleBoxData = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_CapsuleBox:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_CapsuleBox'
    self.m_bVisible = true
    self.m_titleStr = Str('캡슐 신전')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBox:init()
	local vars = self:load('capsule_box.ui')
	UIManager:open(self, UIManager.SCENE)
	
	self.m_capsuleBoxData = g_capsuleBoxData:getCapsuleBoxInfo()

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CapsuleBox')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBox:initUI()
	local vars = self.vars

	local capsulebox_data = self.m_capsuleBoxData


end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBox:initButton()
	local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBox:refresh()
	local vars = self.vars
end

-------------------------------------
-- function click_purchaseBtn
-------------------------------------
function UI_CapsuleBox:click_purchaseBtn()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_CapsuleBox:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_CapsuleBox)
