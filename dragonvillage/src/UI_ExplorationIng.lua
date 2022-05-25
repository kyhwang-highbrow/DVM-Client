local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ExplorationIng
-------------------------------------
UI_ExplorationIng = class(PARENT,{
        m_eprID = '',
        m_status = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ExplorationIng:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ExplorationIng'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationIng:init(epr_id)
    self.m_eprID = epr_id

    local vars = self:load('exploration_ing.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationIng')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationIng:initUI()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 지역 이름
    vars['locationLabel']:setString(Str(location_info['t_name']))

    -- 탐험 시간
    local sec = location_info['clear_time']
    local time_str = datetime.makeTimeDesc(sec, true)
    vars['timeLabel']:setString(Str('탐험 소요 : {1}', time_str))

    -- 탐험 시간
    local sec = location_info['item_cnt']
    local hours = (sec / 3600)
    vars['timeLabel2']:setString(Str('{1} 시간', hours))

    -- 획득하는 아이템 리스트
    local reward_items_str = location_info['reward_items']
    local reward_items_list = g_itemData:parsePackageItemStr(reward_items_str)
    --vars['rewardNode']:removeAllChildren()

    local scale = 0.53
    local l_pos = getSortPosList(150 * scale + 3, #reward_items_list)

    for i,v in ipairs(reward_items_list) do
        local ui = UI_ItemCard(v['item_id'], v['count'])
        vars['rewardNode']:addChild(ui.root)
        ui.root:setScale(0)
        ui.root:setPosition(l_pos[i], 0)
        ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.ScaleTo:create(0.25, scale)))
    end

    do -- 드래곤
        for i,doid in ipairs(my_location_info['doid_list'] ) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
            
            if t_dragon_data then
                local ui = UI_DragonCard(t_dragon_data)
                ui:setReadySpriteVisible(false)
                self.vars['slotNode' .. i]:addChild(ui.root)
            end
        end
    end

    do -- 즉시 완료
        local cash = location_info['complete_cash']
        vars['priceLabel']:setString(comma_value(cash))
    end

    -- 모험의 order가 모험모드의 chapter로 간주한다
    local chapter = location_info['order']

    do -- 배경 이미지 생성
        local bg_node = vars['bgNode']
        ResHelper:makeUIAdventureChapterBG(bg_node, chapter)
    end

    -- 모험의 order가 모험모드의 chapter로 간주한다
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)
    local chapter = location_info['order']

    local res = string.format('res/ui/icons/adventure_map/chapter_01%.2d.png', chapter)
    local icon = cc.Sprite:create(res)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    vars['stageNode']:addChild(icon)

    self:init_tamer()
end

-------------------------------------
-- function init_tamer
-------------------------------------
function UI_ExplorationIng:init_tamer()
    local vars = self.vars

    vars['tamerNode']:removeAllChildren()

    local table_tamer = TableTamer()
    local tamer_id = g_tamerData:getCurrTamerID()
    local costume_data = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)
    local tamer_res = costume_data:getResSD()
    local animator = MakeAnimator(tamer_res)
	if (animator) then
		animator:setDockPoint(0.5, 0.5)
		animator:setAnchorPoint(0.5, 0.5)
		--animator:setScale(2)
		--animator:setPosition(0, 50)
        animator:changeAni('move', true)
		vars['tamerNode']:addChild(animator.m_node)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationIng:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['completeBtn']:registerScriptTapHandler(function() self:click_completeBtn() end)
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationIng:refresh()
    local vars = self.vars

    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)
    self.m_status = status

    self.root:unscheduleUpdate()

    -- 시간 업데이트
    if (status == 'exploration_ing') then
        local function update(dt)
            self:update(dt)
        end
        self.root:scheduleUpdateWithPriorityLua(update, 0)
        self:update(0)

        vars['cancelBtn']:setVisible(true)
        vars['completeBtn']:setVisible(true)
        vars['rewardBtn']:setVisible(false)

        vars['stateLabel']:setString(Str('탐험 중'))

    elseif (status == 'exploration_complete') then
        -- 탐험 시간
        vars['timeLabel2']:setString('')

        vars['cancelBtn']:setVisible(false)
        vars['completeBtn']:setVisible(false)
        vars['rewardBtn']:setVisible(true)

        vars['stateLabel']:setString(Str('탐험 완료'))
    end

end

-------------------------------------
-- function update
-- @brief exploration_ing 상태에서만 업데이트됨
-------------------------------------
function UI_ExplorationIng:update(dt)
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    local end_time = (my_location_info['end_time'] / 1000)
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local remain_time = (end_time - server_time)

    if remain_time > 0 then
        -- 탐험 시간
        local time_str = datetime.makeTimeDesc(remain_time, true)
        vars['timeLabel2']:setString(Str('{1} 남음', time_str))
    else
        self:refresh()
    end
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_ExplorationIng:click_cancelBtn()
    local function request()
        local function finish_cb(ret)
            UIManager:toastNotificationGreen(Str('탐험을 취소하였습니다.'))
            self:close()
        end

        local epr_id = self.m_eprID
        g_explorationData:request_explorationCancel(epr_id, finish_cb)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('정말 탐험을 취소하시겠습니까?'), request)
end

-------------------------------------
-- function click_completeBtn
-------------------------------------
function UI_ExplorationIng:click_completeBtn()
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    local function request()
        local function finish_cb(ret)
            local close_cb = self.m_closeCB
            self:setCloseCB(nil)
            self:close()

            local ui = UI_ExplorationResultPopup(self.m_eprID, ret)
            ui:setCloseCB(close_cb)
        end

        local epr_id = self.m_eprID
        g_explorationData:request_explorationImmediatelyComplete(epr_id, finish_cb)
    end
    
    local cash = location_info['complete_cash']

    local msg = Str('{1}다이아몬드를 사용하여 즉시 완료를 하시겠습니까?', cash)
    MakeSimplePopup_Confirm('cash', cash, msg, request)
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_ExplorationIng:click_rewardBtn()
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    local function finish_cb(ret)
        local close_cb = self.m_closeCB
        self:setCloseCB(nil)
        self:close()

        local ui = UI_ExplorationResultPopup(self.m_eprID, ret)
        ui:setCloseCB(close_cb)
    end

    local epr_id = self.m_eprID
    g_explorationData:request_explorationReward(epr_id, finish_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationIng:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ExplorationIng)
