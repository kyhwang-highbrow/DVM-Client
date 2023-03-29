local PARENT = UI--class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_EventPopupTab_StoryDungeonGacha
-------------------------------------
UI_EventPopupTab_StoryDungeonGacha = class(PARENT,{
        m_eventVersion = '',
        m_seasonId = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:init(season_id)
    self.m_eventVersion = nil
    self.m_seasonId = season_id
    self.m_uiName = 'UI_EventPopupTab_StoryDungeonGacha'
    local code = TableStoryDungeonEvent:getStoryDungeonSeasonCode(season_id)
    self:load(string.format('story_dungeon_%s_event.ui', code))
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_StoryDungeonEventShop')

    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:initParentVariable()
    self.m_uiName = 'UI_EventPopupTab_StoryDungeonGacha'
    self.m_titleStr = TableStoryDungeonEvent:getStoryDungeonEventName(self.m_seasonId)
    self.m_subCurrency = TableStoryDungeonEvent:getStoryDungeonEventTicketKey(self.m_seasonId)
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:initUI()
    local vars = self.vars

    local did =  TableStoryDungeonEvent:getStoryDungeonEventDid(self.m_seasonId)
    local table_dragon = TableDragon()

    local attr = table_dragon:getDragonAttr(did)
    local role_type = table_dragon:getDragonRole(did)
    local rarity_type = 'legend'
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    do -- 이름
        local dragon_name = table_dragon:getDragonName(did)
        vars['ceilingLabel']:setStringArg(dragon_name, 1)
    end

    do -- 드래곤 스파인
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(did, 3)
        dragon_animator:setTalkEnable(false)
        vars['dragonNode']:addChild(dragon_animator.m_node)
    end

    do -- 드래곤 카드
        local dragon_card = MakeSimpleDragonCard(did, {})
        dragon_card.root:setScale(100/150)
        vars['ceilingIconNode']:removeAllChildren()
        vars['ceilingIconNode']:addChild(dragon_card.root)
--[[         -- 이벤트 소환 바로 가기
        dragon_card.vars['clickBtn']:registerScriptTapHandler(function() 
            self:click_gachaBtn()
        end) ]]
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:initButton()
    local vars = self.vars
    vars['summonBtn_1']:registerScriptTapHandler(function() self:click_summonBtn(1) end)
    vars['summonBtn_10']:registerScriptTapHandler(function() self:click_summonBtn(10) end)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:refresh()
    local vars = self.vars
    --local version = self.m_eventVersion

    local goods_type = TableStoryDungeonEvent:getStoryDungeonEventTicketKey(self.m_seasonId)
    local value = g_userData:get(goods_type) or 0

    vars['ticketLabel_txt_10']:setStringArg(math_clamp(value, 2, 10))
    vars['ticketLabel_10']:setStringArg(math_clamp(value, 2, 10))

    vars['summonBtn_1']:setEnabled( value > 0 )
    vars['summonBtn_10']:setEnabled( value > 1 )
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_helpBtn
-- @brief 도움말
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:click_helpBtn()
    UI_GuidePopup_PurchasePoint()
end

-------------------------------------
-- function click_summonBtn
-- @brief 소환
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:click_summonBtn(count)
    local success_cb = function (ret)
    end

    local season_id = self.m_seasonId
    local draw_cnt = count

    g_eventDragonStoryDungeon:requestStoryDungeonGacha(season_id, draw_cnt, success_cb)
end

-------------------------------------
-- function UI_StoryDungeonEventShop.open()
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha.open(season_id)
    UI_EventPopupTab_StoryDungeonGacha(season_id)
 end