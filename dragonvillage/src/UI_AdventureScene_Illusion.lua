local PARENT = UI


-------------------------------------
-- class UI_AdventureScene_Illusion
-------------------------------------
UI_AdventureScene_Illusion = class(PARENT, {
       
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureScene_Illusion:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureScene_Illusion'
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_dungeon_ready'
end

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureScene_Illusion:init()
	local vars = self:load('event_illusion_dungeon_scene.ui')

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdventureScene_Illusion')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureScene_Illusion:initUI()
    local vars = self.vars

    local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
    local l_illusion_dragon = struct_illusion:getIllusionDragonList()
    local illusion_dragon_did = tonumber(l_illusion_dragon[1])

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(illusion_dragon_did, 3)
    dragon_animator:setTalkEnable(false)
    dragon_animator:setIdle()
    vars['dragonNode']:addChild(dragon_animator.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureScene_Illusion:initButton()
    local vars = self.vars
    vars['stageBtn01']:registerScriptTapHandler(function() self:gotoDungeon() end)
    vars['dragonInfoBtn']:registerScriptTapHandler(function() self:showDragonInfo() end)
    vars['exchangeShopBtn']:registerScriptTapHandler(function() self:gotoExchangeShop() end)
    vars['rankBtn']:registerScriptTapHandler(function()  end)
end

-------------------------------------
-- function gotoDungeon
-------------------------------------
function UI_AdventureScene_Illusion:gotoDungeon()
    UI_IllusionScene()
end

-------------------------------------
-- function showDragonInfo
-------------------------------------
function UI_AdventureScene_Illusion:showDragonInfo()
    local l_illusion_dragon_data = g_illusionDungeonData:getIllusionDragonList()
    UI_SimpleDragonInfoPopup(l_illusion_dragon_data[1])
end

-------------------------------------
-- function gotoExchangeShop
-------------------------------------
function UI_AdventureScene_Illusion:gotoExchangeShop()
    UI_IllusionShop()
end
    



