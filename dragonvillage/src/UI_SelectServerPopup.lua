local PARENT = UI

-------------------------------------
-- class UI_SelectServerPopup
-------------------------------------
UI_SelectServerPopup = class(PARENT, {
        m_radioButton = 'UIC_RadioBtn',
		m_finishFunc = 'function',        
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SelectServerPopup:init(cbFinish)
    local vars = self:load('popup_server.ui')
    UIManager:open(self, UIManager.POPUP)
	
    self.m_uiName = 'UI_SelectServerPopup'
    self.m_finishFunc = cbFinish    
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SelectServerPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SelectServerPopup:initUI()
    local vars = self.vars
    --넘어오지 않은 서버목록 ui는 visible false    
    local function isExistServer(name)
        local tserverList = ServerListData:getInstance():getServerList()
        for _, server in pairs(tserverList) do
            if server['server_name'] == name then
                return true
            end
        end

        return false
    end

    for i, name in pairs(SERVER_NAME) do
        local menu = vars[name .. 'Menu']
        if menu then
            menu:setVisible( isExistServer(name) )
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SelectServerPopup:initButton()
    local vars = self.vars

	-- radio btn
	do
		local radio_button = UIC_RadioButton()        
        local selectServerName = ServerListData:getInstance():getSelectServer()
		-- 서버 버튼 등록
        local tserverList = ServerListData:getInstance():getServerList()
		for _, server in pairs(tserverList) do
            local serverName = server['server_name']
            local serverNum = server['server_num']			
            radio_button:addButton(serverName, vars[serverName .. 'RadioBtn'], vars[serverName .. 'RadioSprite'])
		end

		-- 선택 서버
		if selectServerName then
            radio_button:setSelectedButton(selectServerName)            
        end
        		
		self.m_radioButton = radio_button
	end
        
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)	
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SelectServerPopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_SelectServerPopup:click_okBtn()
    local selectServer = self.m_radioButton.m_selectedButton   
    cclog( 'selectServer : ' .. selectServer )

    if self.m_finishFunc then
        self.m_finishFunc( selectServer )
    end
    
    self:close()
end

-------------------------------------
-- function getSelectedServerName
-- @brief 선택된 게임 서버 이름 리턴
-- @return string : 'DEV', 'QA', 'Korea' ...
-------------------------------------
function UI_SelectServerPopup:getSelectedServerName()
    if (not self.m_radioButton) then
        return nil
    end

    local selected_server_name = self.m_radioButton.m_selectedButton
    return selected_server_name
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SelectServerPopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_SelectServerPopup)
