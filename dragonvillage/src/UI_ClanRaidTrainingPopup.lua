local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidTrainingPopup
-------------------------------------
UI_ClanRaidTrainingPopup = class(PARENT, {
        m_curStageLv = 'number',
        m_curHp = 'number',
        m_selectStageLv = 'number',
        m_selectedAttr = 'string',
        m_selectedHp = 'number',
        m_isMaxHp = 'boolean',
     })

local STAGE_MAX = 150

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidTrainingPopup:init()
    local vars = self:load('clan_raid_training.ui')
    UIManager:open(self, UIManager.POPUP)

    local struct_clan_raid =  g_clanRaidData:getClanRaidStruct()
    self.m_curStageLv = struct_clan_raid:getLv()
    self.m_curHp = struct_clan_raid:getHp()
    
    self.m_isMaxHp = true
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanRaidTrainingPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initTab()
    self:initRadioBtn()
    self:initButton()
    self:initSlideBar()
    self:refresh(true)
    self:refreshInfo(self.m_curStageLv, self.m_curHp)
    self:setCurrCount(self.m_curStageLv, false)
    self.m_selectStageLv = self.m_curStageLv
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanRaidTrainingPopup:initTab()
    local vars = self.vars
    self:addTab('earth', vars['attrBtn1'])
    self:addTab('water', vars['attrBtn2'])
    self:addTab('fire', vars['attrBtn3'])
    self:addTab('light', vars['attrBtn4'])
    self:addTab('dark', vars['attrBtn5'])

    local cur_attr = g_clanData:getCurSeasonBossAttr()
    self:setTab(cur_attr)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidTrainingPopup:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidTrainingPopup:onChangeTab(tab, first)
    local vars = self.vars
    self.m_selectedAttr = tab
    self:refreshBoss(self.m_selectedAttr)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidTrainingPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_applyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['quantityBtn3']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['quantityBtn4']:registerScriptTapHandler(function() self:click_maxBtn() end)
    vars['resetBtn']:registerScriptTapHandler(function() self:click_resetBtn() end)
end

-------------------------------------
-- function initSlideBar
-- @brief 터치 레이어 생성
-------------------------------------
function UI_ClanRaidTrainingPopup:initSlideBar()
    local node = self.vars['sliderBar']

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_ClanRaidTrainingPopup:onTouchBegan(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)

    return is_contain
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_ClanRaidTrainingPopup:onTouchMoved(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)

    local content_size = vars['quantityBtn2']:getParent():getContentSize()

    local x = math_clamp(local_location['x'], 0, content_size['width'])
    local percentage = x / content_size['width']

    vars['quantityBtn2']:stopAllActions()
    vars['quantityBtn2']:setPositionX(x)

    vars['quantityGuage']:stopAllActions()
    vars['quantityGuage']:setPercentage(percentage * 100)

    local count = math_floor(STAGE_MAX * percentage)
    local ignore_slider_bar = true
    self:setCurrCount(count, ignore_slider_bar)
end

-------------------------------------
-- function setCurrCount
-------------------------------------
function UI_ClanRaidTrainingPopup:setCurrCount(count, ignore_slider_bar)
    local vars = self.vars
    local count = math_clamp(count, 1, STAGE_MAX)
    
    if (self.m_selectStageLv == count) then
        return
    end

    self.m_selectStageLv = count

    -- 퍼센트 지정
    if (not ignore_slider_bar) then
        local percentage = (self.m_selectStageLv / STAGE_MAX) * 100
        vars['quantityGuage']:stopAllActions()
        vars['quantityGuage']:runAction(cc.ProgressTo:create(0.2, percentage))
    
        local pos_x = (self.m_selectStageLv / STAGE_MAX) * 300
        vars['quantityBtn2']:stopAllActions()
        vars['quantityBtn2']:runAction(cc.MoveTo:create(0.2, cc.p(pos_x, 0)))
    end

    -- 지원 레벨
    vars['quantityLabel']:setString(comma_value(self.m_selectStageLv))
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ClanRaidTrainingPopup:onTouchEnded(touch, event)
    self:refreshInfo()
end

-------------------------------------
-- function getMaxHp
-------------------------------------
function UI_ClanRaidTrainingPopup:getMaxHp(stage_lv)
    local stage_id = 1500000 + stage_lv
    local table_clan_raid = TABLE:get('table_clan_dungeon')
    local max_hp = table_clan_raid[stage_id]['boss_hp']
    return max_hp
end

-------------------------------------
-- function refreshInfo
-------------------------------------
function UI_ClanRaidTrainingPopup:refreshInfo(lv, hp)
    local vars = self.vars   
    
    local stage_lv = self.m_selectStageLv
    if (not self.m_selectStageLv) then
        stage_lv = self.m_curStageLv
    end

    if (lv) then
        stage_lv = lv
    end

    local stage_id = 1500000 + stage_lv
    local max_hp = self:getMaxHp(stage_lv)
    local stage_hp = max_hp

    if (self.m_isMaxHp == false) then
        stage_hp = max_hp * 0.05
    end

    if (hp) then
        stage_hp = hp
    end

    local hp_ratio = stage_hp/max_hp * 100
    self.m_selectedHp = stage_hp
    vars['lvLabel']:setString(Str('Lv.{1}', stage_lv))
    vars['hpLabel2']:setString(Str('{1}/{2}', stage_hp, max_hp))
    local hp_ratio_str = string.format('%0.2f%%', hp_ratio)
    vars['hpLabel1']:setString(hp_ratio_str, false)
    vars['hpGauge']:setPercentage(hp_ratio)
end

-------------------------------------
-- function refreshBoss
-------------------------------------
function UI_ClanRaidTrainingPopup:refreshBoss(attr)
    local vars = self.vars
    
    local icon = IconHelper:getAttributeIcon(attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    vars['bossNode']:removeAllChildren()

    local l_monster = TableStageDesc():getMonsterIDList_ClanMonster(attr)
    for _, mid in ipairs(l_monster) do
        local res, attr, evolution = TableMonster:getMonsterRes(mid)
        local animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
        if (animator) then
            local zOrder = WORLD_Z_ORDER.BOSS
            local idx = getDigit(mid, 10, 1)
            if (idx == 1) and (mid == boss_mid) then
                zOrder = WORLD_Z_ORDER.BOSS     
            elseif (idx == 1) then
                zOrder = WORLD_Z_ORDER.BOSS + 1
            elseif (idx == 7) then
                zOrder = WORLD_Z_ORDER.BOSS
            else
                zOrder = WORLD_Z_ORDER.BOSS + 1 + 7 - idx
            end
            vars['bossNode']:addChild(animator.m_node, zOrder)

            animator:changeAni('idle', true)
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidTrainingPopup:refresh(force)
    
end

-------------------------------------
-- function initRadioBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:initRadioBtn()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:setChangeCB(function(hp_type)          
        self.m_isMaxHp = (hp_type == 'maxHp')
        self:refreshInfo()
    end)

    local btn = vars['contentBtn1']
    local label = vars['contentSprite1']
	radio_button:addButton('maxHp', btn, label)

    local btn = vars['contentBtn2']
    local label = vars['contentSprite2']
	radio_button:addButton('fianlBlow', btn, label)

    -- 디폴트로 일반 강화 선택
    --radio_button:setSelectedButton('normalOpt')  
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_minusBtn()
    self:setCurrCount(self.m_selectStageLv - 1, false)
    self:refreshInfo()
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_plusBtn()
    self:setCurrCount(self.m_selectStageLv + 1, false)
    self:refreshInfo()
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_maxBtn()
    self:setCurrCount(STAGE_MAX)
    self:refreshInfo()
end

-------------------------------------
-- function click_attrBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_attrBtn(ind)
    local l_attr = getAttrOrderMap()
    self.m_selectedAttr = l_attr[ind]
end

-------------------------------------
-- function click_resetBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_resetBtn()
    local cur_attr = g_clanData:getCurSeasonBossAttr()

    self.m_selectStageLv = self.m_curStageLv
    self.m_selectedAttr = cur_attr
    
    self:setTab(cur_attr)    
    self:setCurrCount(self.m_curStageLv, false)
    self:refreshInfo(self.m_curStageLv, self.m_curHp)
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_applyBtn()
    local training_info = StructClanRaid()
    local selected_stage_id = self.m_selectStageLv + 1500000
    training_info['clan_raid_type'] = 'training'
    training_info['attr'] = self.m_selectedAttr
    training_info['hp'] = SecurityNumberClass(self.m_selectedHp)
    training_info['max_hp'] = SecurityNumberClass(self:getMaxHp(self.m_selectStageLv))
    training_info['stage'] = selected_stage_id
    UI_ReadySceneNew(selected_stage_id, nil, training_info) 
end

--@CHECK
UI:checkCompileError(UI_ClanRaidTrainingPopup)







