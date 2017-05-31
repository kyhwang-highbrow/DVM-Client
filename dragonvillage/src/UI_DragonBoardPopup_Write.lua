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

	-- editbox 관련 설정
	--[[
	게시판 최대 글자수는 200자이고 editbox는 글자 처리에 제한이 있어
	editbox는 텍스트 입력용도로만 사용하고 handler와 ui 표시는 
	각각 editBtn, editLabel을 사용하는 구조이다.
	]]
	local REVIEW_MAX_LENGTH = 600
	vars['editBox']:setMaxLength(REVIEW_MAX_LENGTH)
	vars['editBox']:setInputMode(0) -- enum class InputMode : ANY
	vars['editLabel']:setString('')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardPopup_Write:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
	vars['writeBtn']:registerScriptTapHandler(function() self:click_writeBtn() end)
	vars['editBtn']:registerScriptTapHandler(function() self:click_editBtn() end)

	-- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
		cclog(strEventName, pSender)
        if (strEventName == "return") then
			-- editLabel에 글자를 찍어준다.
            local context = vars['editBox']:getText()
			vars['editLabel']:setString(context)
        end
    end
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardPopup_Write:refresh()
	local vars = self.vars
end

-------------------------------------
-- function click_editBtn
-- @brief editBtn 클릭시 editBox를 통해 키보드를 open한다.
-------------------------------------
function UI_DragonBoardPopup_Write:click_editBtn()
	self.vars['editBox']:openKeyboard()
end

-------------------------------------
-- function click_writeBtn
-------------------------------------
function UI_DragonBoardPopup_Write:click_writeBtn()
	local vars = self.vars
	local context = vars['editBox']:getText()

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
