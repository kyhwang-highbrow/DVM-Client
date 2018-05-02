local PARENT = UI

-------------------------------------
-- class UI_DragonBoardPopup_Evaluate
-------------------------------------
UI_DragonBoardPopup_Evaluate = class(PARENT,{
		m_reviewFunc = 'UI_DragonBoardPopup',

		m_did = 'number',
		m_myRate = 'number',
		m_targetRate = 'number'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardPopup_Evaluate:init(did, my_rate, reveiw_func)
    local vars = self:load('dragon_board_assess.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonBoardPopup_Evaluate')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_did = did
	self.m_myRate = my_rate
	self.m_reviewFunc = reveiw_func

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonBoardPopup_Evaluate:initUI()
	local vars = self.vars

	if (self.m_myRate) then
		self:click_assessBtn(self.m_myRate)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardPopup_Evaluate:initButton()
	local vars = self.vars
	for i = 1, 5 do
		vars['assessBtn' .. i]:registerScriptTapHandler(function() self:click_assessBtn(i) end)
	end
	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['reviewBtn']:registerScriptTapHandler(function() self:click_reviewBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardPopup_Evaluate:refresh()
end

-------------------------------------
-- function click_assessBtn
-------------------------------------
function UI_DragonBoardPopup_Evaluate:click_assessBtn(idx)
	local vars = self.vars
	self.m_targetRate = idx

	-- 전부 끄고
	for i = 1, 5 do
		vars['starSprite' .. i]:setVisible(false)
	end
	-- idx까지 전부 킨다.
	for i = 1, idx do
		vars['starSprite' .. i]:setVisible(true)
	end
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonBoardPopup_Evaluate:click_okBtn()
	-- 별점 선택 안했을 시  -> 다시 선택 유도
	if not (self.m_targetRate) then
		UIManager:toastNotificationGreen(Str('평점을 입력해주세요!'))
		return
	end
	-- 현재 별점과 선택한 별점이 같을 시 -> 조용히 닫고 갱신하지 않음
	if (self.m_targetRate == self.m_myRate) then
		self:close()
		return
	end

	local did = self.m_did
	local rate = self.m_targetRate
	local function cb_func(ret)
		self:close()
	end
	g_boardData:request_rateBoard(did, rate, cb_func)
end

-------------------------------------
-- function click_reviewBtn
-------------------------------------
function UI_DragonBoardPopup_Evaluate:click_reviewBtn()
	self:doActionReverse(function() 
		self:close() 
		self.m_reviewFunc()
	end, 0.5, false)
end

--@CHECK
UI:checkCompileError(UI_DragonBoardPopup_Evaluate)
