local PARENT = UI

-------------------------------------
-- class UI_DragonBoardPopup_Write
-------------------------------------
UI_DragonBoardPopup_Write = class(PARENT,{
		m_did = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardPopup_Write:init(did)
    local vars = self:load('dragon_board_write.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_DragonBoardPopup_Write')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_did = did

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonBoardPopup_Write:initUI()
	local vars = self.vars

	local REVIEW_MAX_LENGTH = 200
	vars['editBox']:setMaxLength(REVIEW_MAX_LENGTH)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardPopup_Write:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
	vars['writeBtn']:registerScriptTapHandler(function() self:click_writeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardPopup_Write:refresh()
	local vars = self.vars
end

-------------------------------------
-- function click_writeBtn
-------------------------------------
function UI_DragonBoardPopup_Write:click_writeBtn()
	local vars = self.vars

	local context = vars['editBox']:getText()
	ccdisplay(context)

	if (context) then
		local did = self.m_did
		local function cb_func()
			self:closeWithAction()
		end
		g_boardData:request_writeBoard(did, context, cb_func)
	end
end

--@CHECK
UI:checkCompileError(UI_DragonBoardPopup_Write)
