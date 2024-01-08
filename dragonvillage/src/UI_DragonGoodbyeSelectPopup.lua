local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyeSelectPopup
-------------------------------------
UI_DragonGoodbyeSelectPopup = class(PARENT,{
		m_doids = 'string',
        m_expSum = 'number',
        m_cbFunc = 'function',
        m_isUncheckLock = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelectPopup:init(doids, exp_sum, is_uncheck_lock, cb_func)
    self.m_doids = doids
    self.m_expSum = exp_sum
    self.m_cbFunc = cb_func
    self.m_isUncheckLock = is_uncheck_lock

    local vars = self:load('dragon_goodbye_select_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeSelectPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    -- self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelectPopup:initUI()
	local vars = self.vars
    
    local doids = self.m_doids
    local dragon_count = pl.stringx.count(doids, ',') + 1
   	vars['infoLabel']:setString(Str('{1} 마리의 드래곤이 드래곤 경험치로 변경됩니다.', dragon_count))

    -- 경험치 카드 생성
    do
        local exp_sum = self.m_expSum
        local exp_card = UI_ItemCard(700017, exp_sum)
        vars['itemNode']:addChild(exp_card.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeSelectPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelectPopup:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonGoodbyeSelectPopup:click_okBtn()
    local doids = self.m_doids

    local function cb_func(ret)
        if self.m_cbFunc then
            self.m_cbFunc(ret)
        end
    end

    g_dragonsData:request_goodbye('exp', doids, cb_func, self.m_isUncheckLock) -- params : target, doids, cb_func

    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeSelectPopup)
