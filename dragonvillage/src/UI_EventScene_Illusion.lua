local PARENT = UI


-------------------------------------
-- class UI_EventScene_Illusion
-------------------------------------
UI_EventScene_Illusion = class(PARENT, {
       
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_EventScene_Illusion:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_EventScene_Illusion'
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_dungeon_ready'
end

-------------------------------------
-- function init
-------------------------------------
function UI_EventScene_Illusion:init()
	local vars = self:load('event_illusion_dungeon_scene.ui')

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventScene_Illusion')

	self:initUI()
	self:initButton()
	self:refresh()

    self:sceneFadeInAction(function() self:appearDone() end)
end

-------------------------------------
-- function appearDone
-- @brief UI전환 종료 시점
-------------------------------------
function UI_EventScene_Illusion:appearDone()
    local last_info = g_illusionDungeonData.m_lastInfo
    local reward_info = g_illusionDungeonData.m_rewardInfo

    if (last_info and reward_info) then
        UI_IllusionRewardPopup(last_info, reward_info)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventScene_Illusion:initUI()
    local vars = self.vars

    local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
    local l_illusion_dragon = struct_illusion:getIllusionDragonList()
    local illusion_dragon_did = tonumber(l_illusion_dragon[1])

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(illusion_dragon_did, 3)
    dragon_animator:setTalkEnable(false)
    dragon_animator:setIdle()
    dragon_animator.vars['dragonButton']:setEnabled(false)
    vars['dragonNode']:addChild(dragon_animator.m_node)

    local state = g_illusionDungeonData:getIllusionState()
    local state_text = g_illusionDungeonData:getIllusionExchanageStatusText()
    if (state ~= Serverdata_IllusionDungeon.STATE['OPEN']) then
        vars['exchangeSprite']:setVisible(true)
        vars['exchangeLabel']:setString(Str('교환 기간: {1}', state_text))
    else
        vars['exchangeSprite']:setVisible(false)
    end

    local table_dragon = TableDragon()
    
    -- 이름
    local dragon_name = table_dragon:getDragonName(illusion_dragon_did)
    vars['nameLabel']:setString(Str(dragon_name))
    
    -- 속성 ex) dark
    local dragon_attr = table_dragon:getDragonAttr(illusion_dragon_did)
    local attr_icon = IconHelper:getAttributeIcon(dragon_attr)
    vars['attrNode']:addChild(attr_icon)
    vars['attrLabel']:setString(dragonAttributeName(dragon_attr))

    -- 역할 ex) healer
    local role_type = table_dragon:getDragonRole(illusion_dragon_did)
    local role_icon = IconHelper:getRoleIcon(role_type)
    vars['typeNode']:addChild(role_icon)
    vars['typeLabel']:setString(dragonRoleTypeName(role_type))

    -- 희귀도 ex) legend
    local rarity_str = table_dragon:getDragonRarity(illusion_dragon_did)
    local rarity_icon = IconHelper:getRarityIcon(rarity_str)
    vars['rarityNode']:addChild(rarity_icon)
    vars['rarityLabel']:setString(dragonRarityName(rarity_str))

    -- 남은 시간 출력
    local time_text = ''
    if (g_illusionDungeonData:getIllusionState() == Serverdata_IllusionDungeon.STATE['OPEN']) then
        time_text = Str('이벤트 기간') .. ' ' .. g_illusionDungeonData:getIllusionStatusText()
    else
        time_text = Str('교환소 이용 가능 기간') .. ' ' .. g_illusionDungeonData:getIllusionExchanageStatusText()
    end
    vars['timeLabel']:setString(time_text)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventScene_Illusion:initButton()
    local vars = self.vars

    local state = g_illusionDungeonData:getIllusionState()
    if (state == Serverdata_IllusionDungeon.STATE['OPEN']) then
        vars['stageBtn01']:setEnabled(true)
        vars['lockBtn']:setVisible(false)
    else
        vars['stageBtn01']:setEnabled(false)
        vars['lockBtn']:setVisible(true)
    end 

    vars['stageBtn01']:registerScriptTapHandler(function() self:gotoDungeon() end)
    vars['dragonInfoBtn']:registerScriptTapHandler(function() self:showDragonInfo() end)
    vars['exchangeShopBtn']:registerScriptTapHandler(function() self:gotoExchangeShop() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:showRankInfo() end)
end

-------------------------------------
-- function gotoDungeon
-------------------------------------
function UI_EventScene_Illusion:gotoDungeon()
    UI_IllusionScene()
end

-------------------------------------
-- function showDragonInfo
-------------------------------------
function UI_EventScene_Illusion:showDragonInfo()
    local l_illusion_dragon_data = g_illusionDungeonData:getIllusionDragonList()
    local dragon_info_popup = UI_SimpleDragonInfoPopup(l_illusion_dragon_data[1], true)
    dragon_info_popup:showClickRuneInfoPopup(true)
    dragon_info_popup:showIllusionLabel()
end

-------------------------------------
-- function showRankInfo
-------------------------------------
function UI_EventScene_Illusion:showRankInfo()
    UI_IllusionRank()
end

-------------------------------------
-- function gotoExchangeShop
-------------------------------------
function UI_EventScene_Illusion:gotoExchangeShop()
    UI_IllusionShop()
end
    



