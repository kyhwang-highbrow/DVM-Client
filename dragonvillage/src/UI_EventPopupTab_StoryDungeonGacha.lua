local PARENT = UI--class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_EventPopupTab_StoryDungeonGacha
-------------------------------------
UI_EventPopupTab_StoryDungeonGacha = class(PARENT,{
        m_eventVersion = '',
        m_seasonId = 'string',
        m_ticketItemKey = 'string',
        m_gachaMap = 'table',
        m_mGoodsInfo = 'ui',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:init(season_id)
    self.m_eventVersion = nil
    self.m_seasonId = season_id
    self.m_ticketItemKey = TableStoryDungeonEvent:getStoryDungeonEventTicketKey(self.m_seasonId)
    self.m_uiName = 'UI_EventPopupTab_StoryDungeonGacha'
    self.m_gachaMap = self:makeGachaMap()
    self.m_mGoodsInfo = nil
    
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
-- function makeGachaMap
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:makeGachaMap()
    local gacha_map = {}

    local t_data_10 = {
        ['name'] = Str('고급 소환 10회'),
        ['egg_id'] = TableItem:getItemIDFromItemType(self.m_ticketItemKey),
        ['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp',
        ['ui_type'] = 'cash11',
        ['bundle'] = false,
        ['draw_cnt'] = 10,
        ['price_type'] = self.m_ticketItemKey,
        ['price'] = 10,
    }
    
    local t_data_1 = {
        ['name'] = Str('고급 소환'),
        ['egg_id'] = TableItem:getItemIDFromItemType(self.m_ticketItemKey),
        ['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp',
        ['ui_type'] = 'cash',
        ['draw_cnt'] = 1,
        ['bundle'] = false,
        ['is_ad'] = false,
        ['price_type'] = self.m_ticketItemKey,
        ['price'] = 1,
        ['free_target'] = false --무료 뽑기 대상 알
    }

    gacha_map[1] = t_data_1
    gacha_map[10] = t_data_10
    
    return gacha_map
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
        dragon_card.vars['clickBtn']:setEnabled(false)
    end

    do -- 상단 재화
        local currency = TableStoryDungeonEvent:getStoryDungeonEventTicketKey(self.m_seasonId)
        local ui = UI_GoodsInfo(currency)
        vars['ticketNode']:removeAllChildren()
        vars['ticketNode']:addChild(ui.root)
        self.m_mGoodsInfo = ui
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
    self.m_mGoodsInfo:refresh()

    do -- 이름
        local did =  TableStoryDungeonEvent:getStoryDungeonEventDid(self.m_seasonId)
        local table_dragon = TableDragon()
        local ceil_count = g_eventDragonStoryDungeon:getStoryDungeonSeasonGachaCeilCount()
        local dragon_name = table_dragon:getDragonName(did)
        vars['ceilingLabel']:setStringArg(dragon_name, ceil_count)
    end


    local goods_type = self.m_ticketItemKey
    local value = g_userData:get(goods_type) or 0

    vars['ticketLabel_txt_10']:setStringArg(10)   
    vars['ticketLabel_txt_1']:setStringArg(1)

    vars['ticketLabel_1']:setString(math_clamp(value, 0, 1))
    vars['ticketLabel_10']:setString(math_clamp(value, 2, 10))

    --vars['summonBtn_1']:setEnabled( value > 0 )
    --vars['summonBtn_10']:setEnabled( value > 1 )
end

-------------------------------------
-- function subsequentSummons
-- @brief 이어서 뽑기 설정
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha:subsequentSummons(gacha_result_ui, count)
    local vars = gacha_result_ui.vars
    if (not vars['againBtn']) then return end

	-- 다시하기 버튼 등록
    vars['againBtn']:registerScriptTapHandler(function()
        gacha_result_ui:close()
        self:click_summonBtn(count) -- is_again
    end)
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
    local t_gacha = self.m_gachaMap[count]   
    local msg = Str('"{1}" 진행하시겠습니까?', t_gacha['name'])

    local ok_cb = function ()
        local success_cb = function (ret)
            local gacha_type = self.m_ticketItemKey
            local l_dragon_list = ret['added_dragons']
            local l_slime_list = ret['added_slimes']
            local egg_id = t_gacha['egg_id']
            local egg_res = t_gacha['egg_res']
            local added_mileage = ret['added_mileage'] or 0

            local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_gacha, added_mileage, 0)
            local function close_cb()
                self:refresh()
            end
            ui:setCloseCB(close_cb)
            self:subsequentSummons(ui, count)
        end
    
        local season_id = self.m_seasonId
        local draw_cnt = count

        g_eventDragonStoryDungeon:requestStoryDungeonGacha(season_id, draw_cnt, success_cb)
    end

    MakeSimplePopup_SummonConfirm(self.m_ticketItemKey, count, msg, ok_cb)
end

-------------------------------------
-- function UI_StoryDungeonEventShop.open()
-------------------------------------
function UI_EventPopupTab_StoryDungeonGacha.open(season_id)
    UI_EventPopupTab_StoryDungeonGacha(season_id)
 end