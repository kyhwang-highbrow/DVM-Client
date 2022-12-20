-- @inherit UI
local PARENT = UI

-------------------------------------
---@class UI_AdsRoulettePopup:UI
-- ---@field m_lRewardItems StructItem[]
---@field m_rewardItems table
---@field m_expTime ExperationTime
-------------------------------------
UI_AdsRoulettePopup = class(PARENT, {
    -- m_lRewardItems = 'list<StructItem>',
    m_rewardItems = 'table',
    m_bIsCanSpin = 'boolean',

    m_expTime = 'ExperationTime',
    m_dailyRemainCount = 'number',
    m_dailyMaxCount = 'number',
    m_spinTerm = 'number',

    m_itemMaxCount = 'number',
    m_targetIdx = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_AdsRoulettePopup:init()
    self.m_uiName = 'UI_AdsRoulettePopup'
    self:load('ad_roulette_popup.ui')
    self.m_rewardItems = {}
    self.m_bIsCanSpin   = true
    self.m_expTime      = ExperationTime()
    self.m_targetIdx    = 1
    self.m_itemMaxCount = 0
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initDevPanel()
    self:refresh()
end

--#region UI Inherit Override Functions

-------------------------------------
-- virtual function initUI override
-------------------------------------
function UI_AdsRoulettePopup:initUI()
    local vars = self.vars
    self.m_rewardItems = {}
    self.m_spinTerm = g_advRouletteData:getRouletteTerm()
    self.m_dailyRemainCount = g_advRouletteData:getDailyCount()
    self.m_dailyMaxCount = g_advRouletteData:getDailyMaxCount()

    vars['numberLabel']:setString(string.format('일일 남은 횟수 %d/%d', self.m_dailyRemainCount, self.m_dailyMaxCount))

    self:setExpTime()

    local exp_time = self.m_expTime
    local exp_at = exp_time:getExperationTime()
    local now = ServerTime:getInstance():getCurrentTimestampMilliseconds()

    if (exp_at <= now) then
        vars['badgeNode']:setVisible(true)
    else
        vars['badgeNode']:setVisible(false)
    end

    local function setting_reward_info(ret)
        local ret_adv_lobby = ret['adv_lobby']

        for _,v in ipairs(ret_adv_lobby) do
            local item_id = v['item_id']
            local cnt = v['count']
            local pick_weight = v['pick_weight']

            table.insert(self.m_rewardItems, {['item_id'] = item_id, ['count'] = cnt, ['pick_weight'] = pick_weight})
        end

        self:initItemIcon()
        self:calibrateItemAngle()
    end

    g_advRouletteData:request_rouletteInfo(setting_reward_info)
end

-------------------------------------
-- virtual function initButton override
-------------------------------------
function UI_AdsRoulettePopup:initButton()
    local vars = self.vars
    -- 닫기
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    -- 룰렛 돌리기rateBtn
    vars['adBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    -- 확률 팝업
    vars['infoBtn']:registerScriptTapHandler(function() self:click_rateBtn() end)

end

-------------------------------------
-- virtual function refresh override
-------------------------------------
function UI_AdsRoulettePopup:refresh()
    local vars = self.vars
    local daily_roll_count = g_advRouletteData:getDailyCount()
    local exp_time = self.m_expTime
    local exp_at = exp_time:getExperationTime()
    local now = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local is_can_spin = exp_at <= now
    
    -- 횟수 모두 소진
    local is_end = 0 >= daily_roll_count

    vars['numberLabel']:setString(string.format('일일 남은 횟수 %d/%d', self.m_dailyRemainCount, self.m_dailyMaxCount))

    if (is_end == true) then
        vars['badgeNode']:setVisible(false)
        vars['adsNode']:setVisible(false)
        vars['spinLabel']:setVisible(true)
        vars['lockSprite']:setVisible(true)
    else
        vars['lockSprite']:setVisible(not is_can_spin)
        if (is_can_spin) then
            vars['badgeNode']:setVisible(true)
            vars['adsNode']:setVisible(true)
            vars['spinLabel']:setVisible(false)
        else
            vars['badgeNode']:setVisible(false)
            vars['adsNode']:setVisible(false)
            vars['spinLabel']:setVisible(false)
        end
    end
end

--#endregion UI Inherit Override Functions

--#region Button Functions

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_AdsRoulettePopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_AdsRoulettePopup:click_rewardBtn()
    local vars = self.vars
    local daily_roll_count = g_advRouletteData:getDailyCount()
    local exp_time = self.m_expTime
    local exp_at = exp_time:getExperationTime()
    local now = ServerTime:getInstance():getCurrentTimestampMilliseconds()

    if (self.m_bIsCanSpin == false) then
        return
    end

    if (0 >= daily_roll_count) then
        MakeSimplePopup(POPUP_TYPE.OK, '일일 사용 가능한 횟수를 모두 소모하셨습니다.')
        return
    end

    if (not (exp_at <= now)) then
        UIManager:toastNotification(Str('아직 사용할 수 없습니다.'))
        return
    end
    -- 중복 진입 방지
    self.m_bIsCanSpin = false

    local function success_cb(ret)

        -- UIC_Button:setGlobalClickFunc(function()
        --     return true
        -- end)

        local rewarded_result =  ret['added_items']['items_list']
        if (rewarded_result == nil) then
            return
        end

        local reward = rewarded_result[1]

        local r_id = reward['item_id']
        local r_count = reward['count']

        self.m_targetIdx = 1
        for i, v in ipairs(self.m_rewardItems) do
            local id = v['item_id']
            local count = v['count']
            if (id == r_id and count == r_count) then
                self.m_targetIdx = i
                break
            end
        end

        --@temp dhkim - 22.12.20 현재 연출에 투명도가 적용되지 않아 이펙트를 제외함. 추후에 적용 가능 
        self:simpleSpin(self.m_targetIdx, function()
            vars['finishSpineNode']:removeAllChildren()
            -- local animator = MakeAnimator('res/effect/up_eff/up_eff.json')
            -- animator:setScale(1)
            -- animator:changeAni('up_eff', false)
            -- vars['finishSpineNode']:addChild(animator.m_node)

            -- print('end_animation start')
            -- animator:setVisible(false)

            local item_info = ret['added_items']['items_list'][1]

            -- 아이템 정보가 있다면 팝업 처리
            if (item_info) then
                self.m_dailyRemainCount = ret['adv_lobby_remain_count']
                g_advRouletteData:setLastRollTimestamp(ret['last_adv_lobby_at'])
                g_advRouletteData:setDailyCount(ret['adv_lobby_remain_count'])
                vars['badgeNode']:setVisible(false)
                self:setExpTime()
                local ui = UI_AdRewardPopup(item_info)
                ui:setCloseCB(function()
                    self.m_bIsCanSpin = true
                    self:refresh()
                end)
            -- 없다면 노티
            else
                local msg = Str('광고 보상을 받았습니다.')
                UIManager:toastNotificationGreen(msg)
            end


            -- local function end_animation()
            --     print('end_animation start')
            --     animator:setVisible(false)

            --     local item_info = ret['added_items']['items_list'][1]

            --     -- local msg = Str('광고 보상을 받았습니다.')
            --     -- UIManager:toastNotificationGreen(msg)

            --     -- 아이템 정보가 있다면 팝업 처리
            --     if (item_info) then
            --         local ui = UI_AdRewardPopup(item_info)
            --         ui:setCloseCB(function()
            --             self.m_bIsCanSpin = true
            --         end)
            --     -- 없다면 노티
            --     else
            --         local msg = Str('광고 보상을 받았습니다.')
            --         UIManager:toastNotificationGreen(msg)
            --     end
            -- end
    
            -- -- animator:addAniHandler(function()
            -- --     print('idle ani start')
            -- --     animator:changeAni('idle', false)
            -- --     animator:addAniHandler(function()
            -- --         if (animator:hasAni('end')) then
            -- --             animator:changeAni('end', false)

            -- --         end
            -- --     end)
            -- -- end)

            -- animator:addAniHandler(function()
            --     print('next ani start')
            --     animator:stopAllActions()
            --     end_animation()
            --     -- require('UI_RewardPopup')
            --     -- local reward_ui = UI_RewardPopup:open(struct_item_list)
            --     -- reward_ui:setCloseCB(function()
            --     --     self.m_bIsCanSpin = true
            --     -- end)
            -- end)
        end)
    end

    local function ads_callback(ret, ad_network, log)
        if (ret == 'success') then
            g_advRouletteData:request_rouletteRoll(ad_network, log, success_cb)
        end
    end

    AdManager:getInstance():showRewardAd_Common(ads_callback)
end

-------------------------------------
-- function showRewardResult
-------------------------------------
function UI_AdsRoulettePopup:showRewardResult(ret)
    local item_info = ret['item_info']

    -- 아이템 정보가 있다면 팝업 처리
    if (item_info) then
        UI_MailRewardPopup(item_info)

    -- 없다면 노티
    else
        local msg = Str('광고 보상을 받았습니다.')
        UIManager:toastNotificationGreen(msg)
    end
end

-------------------------------------
-- function click_rateBtn
-------------------------------------
function UI_AdsRoulettePopup:click_rateBtn()
    require('UI_AdsRouletteInfoPopup')
    local info_ui = UI_AdsRouletteInfoPopup()
end

--#endregion Button Functions

-------------------------------------
-- function update
-------------------------------------
function UI_AdsRoulettePopup:update(dt)
    local vars = self.vars
    local exp_time = self.m_expTime
    local exp_at = exp_time:getExperationTime()
    local now = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local daily_roll_count = g_advRouletteData:getDailyCount()

    local is_end = 0 >= daily_roll_count

    self:refresh()

    if ((exp_at <= now) or exp_at == nil or is_end == true) then
        vars['timeLabel']:setVisible(false)
        self.root:unscheduleUpdate()
        return
    end

    vars['adsNode']:setVisible(false)
    vars['timeLabel']:setVisible(true)

    local time_desc = datetime.makeTimeDesc_timer((exp_at - now), false)
    vars['timeLabel']:setString(time_desc)
end

-------------------------------------
-- function setExpTime
-------------------------------------
function UI_AdsRoulettePopup:setExpTime()
    local exp_time = self.m_expTime
    local last_timestamp = g_advRouletteData:getLastRollTimestamp()
    exp_time:setUpdatedAt(last_timestamp)

    -- local term_sec = TableBalanceConfig:getInstance():getBalanceConfigValue('roulette_term')
    local term_min = g_advRouletteData:getRouletteTerm()
    local term_mmss = term_min * 60000
    exp_time:applyExperationTime(last_timestamp + term_mmss)

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initItemIcon
-------------------------------------
function UI_AdsRoulettePopup:initItemIcon()
    print('initItemIcon Enter')

    for idx, value in ipairs(self.m_rewardItems) do
        local result = self:createItem(idx, value['item_id'], value['count'])
        if (result == true) then
            self.m_itemMaxCount = idx
        end
    end
end

-------------------------------------
-- function calibrateItemAngle
-------------------------------------
function UI_AdsRoulettePopup:calibrateItemAngle()
    local vars = self.vars
    local max_count = self.m_itemMaxCount
    local delta_angle = 360 / max_count
    for i = 1, max_count do
        -- 룰렛 첫번째 아이템이 0도 라고 가정하고 i-1 을 곱한다.
        vars['spinNode' .. i]:setRotation(delta_angle * (i - 1))
    end
end

-------------------------------------
-- function creatItem
---@param idx number
---@param struct_item StructItem
-------------------------------------
function UI_AdsRoulettePopup:createItem(idx, item_id, item_count)
    local vars = self.vars

    local name = TableItem():getItemName(item_id)

    local item_node = vars['itemNode' .. idx]
    local item_label = vars['itemLabel' .. idx]
    if (item_node ~= nil) then
        -- local animator = struct_item:getIcon()
        local item_icon_res = self:getIconRes(item_id, item_count)
        local animator = MakeAnimator(item_icon_res)

        item_node:removeAllChildren()
        item_node:addChild(animator.m_node)

        item_label:setString('x' .. item_count)
        return true
    end
    return false
end

-------------------------------------
-- function getIconRes
-- @return icon sprite resource name
-------------------------------------
function UI_AdsRoulettePopup:getIconRes(item_id, item_count)
    if (TableItem():get(item_id) == nil) then
        error('## 존재하지 않는 ITEM ID : ' .. item_id)
    end

    local res = ""

    if item_count <= 800 then
        res = string.format('res/ui/icons/item/cash.png')
    elseif item_count <= 1500 then
        res = string.format('res/ui/icons/item/shop_cash_03.png')
    elseif item_count <= 3000 then
        res = string.format('res/ui/icons/item/shop_cash_05.png')
    elseif item_count <= 6000 then
        res = string.format('res/ui/icons/item/shop_cash_07.png')
    end
    -- if res == nil then
    --     res = string.format('res/temp/DEV.png', item_id)
    -- else
    --     res = string.format('res/ui/icons/item/%s.png', res)
    -- end

    -- 없는 경우
    if (cc.FileUtils:getInstance():isFileExist(res) == false) then
        error('## 존재하지 않는 Resource : ' .. res)
    end
    
    return res
end

-------------------------------------
-- function createDummyItems
-------------------------------------
function UI_AdsRoulettePopup:createDummyItems()
    -- local start_item_id = ITEM_ID_MAP['jewel']
    -- for i = 1, 6 do

    --     local struct_item = StructItem:createSimple(start_item_id + i, 311)
    --     table.insert(self.m_rRewardItems, struct_item)

    -- end
    self:initItemIcon()
end

-------------------------------------
-- function start
---comment
---@param result_idx number
---@param finish_cb? function
-------------------------------------
function UI_AdsRoulettePopup:simpleSpin(result_idx, finish_cb)
    if (result_idx == nil) then
        return
    end

    local vars = self.vars

    -- @sound effect
    -- SoundMgr:playEffectByKey('sfx_skillup_spin') -- 룰렛 돌아가는 소리

    -- 아이템 갯수에 맞춰 각도 세팅
    local per_angle = 360 / self.m_itemMaxCount
    local result_rotate = (-(result_idx - 1) * per_angle) + 360
    -- 열 바퀴 돈다.
    result_rotate = result_rotate + 360 * 10
    -- 랜덤 포지션 생성을 위한 여유 각도
    local spare_angle = per_angle / 2.5
    result_rotate = result_rotate + math_random(-spare_angle, spare_angle)

    -- 기본 회전 이동은 10초
    local function tween_func(value)
        local rotate = value % 360
        vars['wheelMenu']:setRotation(rotate)
    end

    local duration = 4
    local rotate_tween = cc.ActionTweenForLua:create(duration, 0, result_rotate, tween_func)
    local ease_rotate = cc.EaseCircleActionOut:create(rotate_tween)

    -- local function highlight_func()
    --     -- @sound effect
    --     SoundMgr:playEffectByKey('sfx_skillup_spin') -- 룰렛 돌아가는 소리

    --     -- 하이라이트 처리
    --     vars['pickSprite' .. result_idx]:setVisible(true)
    -- end

    local function _finish_cb()
        SafeFuncCall(finish_cb)
    end

    -- local highlight_on = cc.CallFunc:create(highlight_func)
    local delay_time = cc.DelayTime:create(0.3)
    local finish_func = cc.CallFunc:create(_finish_cb)
    local sequence = cc.Sequence:create(ease_rotate, delay_time, finish_func)

    self.root:runAction(sequence)
end

-------------------------------------
-- function initDevPanel
-------------------------------------
function UI_AdsRoulettePopup:initDevPanel()
    -- ---@type UI_DevPanel
    -- local dev_panel = UI_DevPanel()

    -- if (IS_TEST_MODE() == true) then
    --     self.root:addChild(dev_panel.root)
    --     self:addAction(dev_panel.root, UI_ACTION_TYPE_LEFT, 0, 0.5)
    --     do -- 스핀 테스트
    --         local t_component = StructDevPanelComponent:create('spin_test')
    --         local function func(text)
    --             text      = text or 1
    --             local idx = tonumber(text)
    --             self:simpleSpin(idx)
    --             dev_panel:showDebugUI(false)
    --         end

    --         t_component['edit_cb'] = func
    --         t_component['str'] = '테스트 스핀'
    --         dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
    --     end
    --     do -- 일일 제한 초기화
    --         local t_component = StructDevPanelComponent:create('init_daily')
    --         local function func(text)
    --             g_advRouletteData:request_resetRouletteInfo(0, 0, function()
    --                 self:refresh()
    --                 self:setExpTime()
    --             end)
    --         end

    --         t_component['cb1'] = func
    --         t_component['str'] = '일일 제한 초기화'
    --         dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
    --     end
    --     do -- 스핀 횟수 지정
    --         local t_component = StructDevPanelComponent:create('set_daily')
    --         local function func(text)
    --             text = text or 0
    --             text = tonumber(text)
    --             g_advRouletteData:request_resetRouletteInfo(text, nil, function()
    --                 self:refresh()
    --                 self:setExpTime()
    --             end)
    --         end

    --         t_component['edit_cb'] = func
    --         t_component['str'] = '횟수 지정'
    --         dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
    --     end
    --     do -- 쿨타임 초기화
    --         local t_component = StructDevPanelComponent:create('init_term')
    --         local function func(text)
    --             local time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    --             time = time - 100000
    --             local count = g_advRouletteData:getDailyCount()
    --             g_advRouletteData:request_resetRouletteInfo(count, 0, function()
    --                 self:refresh()
    --                 self:setExpTime()
    --             end)

    --         end

    --         t_component['cb1'] = func
    --         t_component['str'] = '쿨타임 초기화'
    --         dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
    --     end

    -- end
end

-------------------------------------
-- function open
-------------------------------------
function UI_AdsRoulettePopup.open()
    local ui = UI_AdsRoulettePopup()
    return ui
end

--@CHECK
UI:checkCompileError(UI_AdsRoulettePopup)
