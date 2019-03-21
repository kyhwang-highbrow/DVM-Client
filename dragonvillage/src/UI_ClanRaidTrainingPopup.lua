local PARENT = UI

-------------------------------------
-- class UI_ClanRaidTrainingPopup
-------------------------------------
UI_ClanRaidTrainingPopup = class(PARENT, {
        m_cur_stage_id = 'number',
        m_select_stage_id = 'number',
     })

local STAGE_MAX = 150

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidTrainingPopup:init(stage_id)
    local vars = self:load('clan_raid_training.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_cur_stage_id = stage_id

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanRaidTrainingPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initSlideBar()
    self:refresh(true)
    self:setCurrCount(stage_id, true)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidTrainingPopup:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidTrainingPopup:initButton()
    local vars = self.vars
    for i=1,5 do
        vars['attrBtn'..i]:registerScriptTapHandler(function() self:click_attrBtn(i) end)
    end

    vars['okBtn']:registerScriptTapHandler(function() self:click_applyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['quantityBtn3']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['quantityBtn4']:registerScriptTapHandler(function() self:click_maxBtn() end)
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
    
    if (self.m_select_stage_id == count) then
        return
    end

    self.m_select_stage_id = count

    -- 지원 레벨
    vars['quantityLabel']:setString(comma_value(self.m_cur_stage_id))

    -- 퍼센트 지정
    if (not ignore_slider_bar) then
        local percentage = (self.m_select_stage_id / STAGE_MAX) * 100
        vars['quantityGuage']:stopAllActions()
        vars['quantityGuage']:runAction(cc.ProgressTo:create(0.2, percentage))
    
        local pos_x = 230 * (self.m_select_stage_id / STAGE_MAX)
        vars['quantityBtn2']:stopAllActions()
        vars['quantityBtn2']:runAction(cc.MoveTo:create(0.2, cc.p(pos_x, 0)))
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ClanRaidTrainingPopup:onTouchEnded(touch, event)
    self:refreshBoss('light') -- 임의로
end

-------------------------------------
-- function refreshBoss
-------------------------------------
function UI_ClanRaidTrainingPopup:refreshBoss(attr)
    local vars = self.vars
    local cur_attr
    local is_boss_dirty = false
    if (attr) then
        is_boss_dirty = true
        cur_attr = attr
    else
        cur_attr = g_clanData:getCurSeasonBossAttr()
    end
    vars['lvLabel']:setString('')
    vars['hpLabel2']:setString('')
    vars['hpLabel1']:setString('') -- 퍼센트
    
    local icon = IconHelper:getAttributeIcon(cur_attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    if (is_boss_dirty) then
        vars['bossNode']:removeAllChildren()

        local l_monster = g_stageData:getMonsterIDList(self.m_cur_stage_id)
        for _, mid in ipairs(l_monster) do
            local res, attr, evolution = TableMonster:getMonsterRes(mid)
            local animator = AnimatorHelper:makeMonsterAnimator(res, cur_attr, evolution)
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


    vars['hpGauge']:runAction(cc.ProgressTo:create(0.2, 5))

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidTrainingPopup:refresh(force)
    
end

-------------------------------------
-- function click_attrBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_attrBtn(ind)
    
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_minusBtn()
    self:setCurrCount(self.m_select_stage_id - 1)
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_plusBtn()
    self:setCurrCount(self.m_select_stage_id + 1)
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_maxBtn()
    self:setCurrCount(STAGE_MAX)
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_applyBtn()
    local training_info = {}
    training_info['type'] = 'training'
    training_info['attr'] = 'earth'
    training_info['stage_id'] = self.m_select_stage_id
    UI_ReadySceneNew(self.m_cur_stage_id, nil, training_info) 
end

--@CHECK
UI:checkCompileError(UI_ClanRaidTrainingPopup)







