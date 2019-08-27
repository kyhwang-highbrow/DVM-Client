local PARENT = UI

-------------------------------------
-- class UI_HallOfFame
-------------------------------------
UI_HallOfFame = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFame:init()
    local vars = self:load('hall_of_fame_scene.ui')
    UIManager:open(self, UIManager.SCENE)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFame')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    --self:initUI()
    self:request_temp()
	self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFame:initUI(data)
    local vars = self.vars
    for i=1, 5 do
        local ui = UI_HallOfFameListItem(data)
		vars['itemNode' .. i]:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFame:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
	vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_HallOfFame:click_infoBtn()
    UI_HallOfFameHelp()
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_HallOfFame:click_rankBtn()
    UI_HallOfFameRank()
end

-------------------------------------
-- function request_temp
-------------------------------------
function UI_HallOfFame:request_temp(cb_func)

	-- 임시 통신
    local uid = g_userData:get('uid')
	local peer_uid = peer_uid

    local function success_cb(ret)
		self:initUI(ret['user_info'])
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/get/user_info')
	ui_network:setParam('uid', uid)
    ui_network:setParam('peer', 'test1')
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end
