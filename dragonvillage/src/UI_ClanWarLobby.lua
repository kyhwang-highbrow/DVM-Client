local PARENT = UI

-------------------------------------
-- class UI_ClanWarLobby
-------------------------------------
UI_ClanWarLobby = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLobby:init()
    local vars = self:load('clan_war_lobby.ui')
    UIManager:open(self, UIManager.SCENE)


    -- �� ��ȯ ȿ��
    self:sceneFadeInAction()

    -- backkey ����
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanWarLobby')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- �ʱ�ȭ
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLobby:initUI()
    local vars = self.vars
    
    UI_ClanWarLeague(vars)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarLobby:click_exitBtn()
    local scene = SceneLobby()
    scene:runScene()
end
