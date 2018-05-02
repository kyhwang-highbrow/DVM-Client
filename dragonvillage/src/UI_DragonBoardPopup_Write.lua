local PARENT = UI

-------------------------------------
-- class UI_DragonBoardPopup_Write
-------------------------------------
UI_DragonBoardPopup_Write = class(PARENT,{
		m_did = 'number',
    })

local REVIEW_MIN_LENGTH = 2
local REVIEW_MAX_LENGTH = 200

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardPopup_Write:init(did)
    local vars = self:load('dragon_board_write.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonBoardPopup_Write')

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
	vars['editBox']:setMaxLength(REVIEW_MAX_LENGTH)
	--vars['editBox']:setInputMode(cc.EDITBOX_INPUT_MODE_ANY) -- 2017-07-24 sgkim android ime에서 editbox 옆에 "완료"버튼이 추가되기 전까지 싱글라인으로 처리
	--vars['editLabel']:setString(Str('리뷰를 작성해 주세요'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardPopup_Write:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	vars['writeBtn']:registerScriptTapHandler(function() self:click_writeBtn() end)
	vars['editBtn']:registerScriptTapHandler(function() self:click_editBtn() end)

	-- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
			-- @TODO 키보드 입력이 종료될 때 텍스트 검증을 한다.
			local context, is_valid = self:validateEditText()

            -- editLabel에 글자를 찍어준다.
            -- vars['editLabel']:setString(context)
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
-- function validateEditText
-- @brief 글자 수, 비속어 등을 검증한다.
-------------------------------------
function UI_DragonBoardPopup_Write:validateEditText()
	local vars = self.vars
	local context = vars['editBox']:getText()
	local is_valid = true

	local str_len = uc_len(context)

	-- 최소 글자는 경고 후 invalid
	if (str_len < REVIEW_MIN_LENGTH) then
		UIManager:toastNotificationGreen(Str('최소 2글자 이상 입력해주세요!'))
		is_valid = false

	-- 최대 글자는 경고 후 넘치는 부분 삭제
	elseif (str_len > REVIEW_MAX_LENGTH) then
		UIManager:toastNotificationGreen(Str('최대 글자수(200자)를 초과했어요!'))
		context = utf8_sub(context, REVIEW_MAX_LENGTH)
		vars['editBox']:setText(context)

	end

    -- 비속어 필터링
    if (not FilterMsg(context)) then
        UIManager:toastNotificationRed(Str('사용할 수 없는 표현이 포함되어 있습니다.'))
        context = ''
        vars['editBox']:setText('')
        is_valid = false
    end

	return context, is_valid
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
	local context, is_valid = self:validateEditText()

	if (is_valid) then
		local did = self.m_did
		local function cb_func()
			self:close()
		end
		g_boardData:request_writeBoard(did, context, cb_func)
	end
end

--@CHECK
UI:checkCompileError(UI_DragonBoardPopup_Write)
