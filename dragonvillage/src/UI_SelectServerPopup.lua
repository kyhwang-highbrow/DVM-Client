local PARENT = UI

-------------------------------------
-- class UI_SelectServerPopup
-------------------------------------
UI_SelectServerPopup = class(PARENT, {
        m_radioButton = 'UIC_RadioBtn',
		m_finishFunc = 'function',
        m_tServerInfo = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SelectServerPopup:init(tServerInfo, cbFinish)
    local vars = self:load('popup_server.ui')
    UIManager:open(self, UIManager.POPUP)
	
    self.m_uiName = 'UI_SelectServerPopup'
    self.m_finishFunc = cbFinish
    self.m_tServerInfo = clone(tServerInfo)
    --[[ sample
    ['state']=0;
    ['recentlyServer']=5;
    ['recommandedServer']=5;
    ['servers']={
            {
                    ['server_name']='DEV';
                    ['newOne']=0;
                    ['api_server_ip']='dv-test.perplelab.com:9003';
                    ['server_num']=5;
                    ['clan_chat_server']='dv-test.perplelab.com:9014';
                    ['chat_server']='dv-test.perplelab.com:9013';
                    ['db_server_ip']='';
            };
    };
    --]]

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SelectServerPopup')

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

    --넘어온 서버목록에 개발이나 qa가 아닌데 개발,qa서버 들어있으면 삭제
    if CppFunctionsClass:isTestMode() == false then
        local tserverList = self.m_tServerInfo['servers']
        local tremove = {}
        for i, server in pairs(tserverList) do
            if server.server_name == SERVER_NAME.DEV or server['server_name'] == SERVER_NAME.QA then
                table.insert(tremove, i)
            end
        end

        for i,v in ipairs(tremove) do
            table.remove(tserverList, v)
        end
    end

    --넘어오지 않은 서버목록 ui는 visible false    
    local function isExistServer(name)
        local tserverList = self.m_tServerInfo['servers']
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
        local recentlyServerNum = self.m_tServerInfo['recentlyServer']
        local recentServerName
        local recommandedServerNum = self.m_tServerInfo['recommandedServer']
        local recommandedServerName
		-- 서버 버튼 등록
        local tserverList = self.m_tServerInfo['servers']
		for _, server in pairs(tserverList) do
            local serverName = server['server_name']
            local serverNum = server['server_num']
			radio_button:addButtonAuto(serverName, vars)
            if serverNum == recentlyServerNum then
                recentServerName = serverName
            end

            if serverNum == recommandedServerNum then
                recommandedServerName = serverName
            end
		end

		-- 최신 선택 서버 or 추천 서버		
		if recentServerName then
			radio_button:setSelectedButton(recentServerName)
        elseif recommandedServerName then
            radio_button:setSelectedButton(recommandedServerName)
		end
        		
		self.m_radioButton = radio_button
	end
    
    vars['closeBtn']:setVisible( false )
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
    local function onSelect()         
        g_localData:lockSaveData()
        g_localData:setServerName(selectServer)
        g_localData:unlockSaveData()

        cclog( 'selectServer : ' .. selectServer )
        local servers = self.m_tServerInfo['servers']
        if servers then
            for _, server in pairs( servers ) do
                if server['server_name'] == selectServer then                        
                    cclog( 'api_server_ip : ' .. server['api_server_ip'] )
                    cclog( 'chat_server : ' .. server['chat_server'] )
                    cclog( 'clan_chat_server : ' .. server['clan_chat_server'] )
                    SetApiUrl(server['api_server_ip'])
                    SetChatServerUrl(server['chat_server'])
                    SetClanChatServerUrl(server['clan_chat_server'])

                    if self.m_finishFunc then
                        self.m_finishFunc()
                    end

                    break
                end
            end
                                
        end

        self:close()
    end

    --테스트모드인데 라이브로 접속하려고 하면 한번더 물어보기
    if CppFunctionsClass:isTestMode() and ( selectServer ~=  SERVER_NAME.DEV and selectServer ~= SERVER_NAME.QA ) then
        MakeSimplePopup(POPUP_TYPE.YES_NO, '테스트모드인데 라이브로 접속하십니까?? 정말로?? 문제없을 자신있습니까??', onSelect)
    else
        onSelect();
    end


    
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SelectServerPopup:click_closeBtn()
	

    --self:close()
end

--@CHECK
UI:checkCompileError(UI_SelectServerPopup)
