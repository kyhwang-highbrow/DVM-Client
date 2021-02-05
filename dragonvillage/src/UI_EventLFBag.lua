local PARENT = UI

-------------------------------------
-- class UI_EventLFBag
-------------------------------------
UI_EventLFBag = class(PARENT,{
        m_structLFBag = 'structEventLFBag',

        m_cellUIList = 'table',

        m_toastUI = 'cc.Node',
        m_scrollView = 'cc.ScrollView',
        m_rewardHistoryView = 'cc.Node', -- 보상획득 히스토리 노드
        m_rewardHistoryLabel = 'UIC_ScrollLabel',

        m_lastAniLevel = 'number',

        m_tableParticles = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBag:init()
    local vars = self:load('event_lucky_fortune_bag.ui')

    self.m_structLFBag = g_eventLFBagData:getLFBag()

    if (self.m_structLFBag:isMax()) then
        self:setSelebrateAni()
    else
        self.m_lastAniLevel = self.m_structLFBag:getLv()
        self:playNormalAni()
    end

    self.m_toastUI = self:makeToast()
    self.m_toastUI.root:setPosition(-136, -30)
    self.m_cellUIList = {}

    self:initUI()
    self:initButton()
    self:refresh()
    self:updateCumulativeRewardList()

    -- UI 설정
    self:setOpacityChildren(true)
    self:setSwallowTouch()
    self:startUpdate(function(dt) self:update(dt) end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBag:initUI()
    local vars = self.vars
    self.m_rewardHistoryView = vars['textNode']
    self:makeScrollView()
end

-------------------------------------
-- function initLobbyParticles
-- @brief confetti 파티클을 생성한다.
-------------------------------------
function UI_EventLFBag:createLobbyParticles()
    local root = self.root
    
    self:removeAllParticles()

    self.m_tableParticles = {}

    -- 축하종이
    self:makeParticle(root, 'confetti/particle_confetti_0301')
    self:makeParticle(root, 'confetti/particle_confetti_0302')
    self:makeParticle(root, 'confetti/particle_confetti_0303')
    self:makeParticle(root, 'confetti/particle_confetti_0401')
    self:makeParticle(root, 'confetti/particle_confetti_0402')
    self:makeParticle(root, 'confetti/particle_confetti_0301')
    self:makeParticle(root, 'confetti/particle_confetti_0302')
    self:makeParticle(root, 'confetti/particle_confetti_0303')
    self:makeParticle(root, 'confetti/particle_confetti_0401')
    self:makeParticle(root, 'confetti/particle_confetti_0402')
end

-------------------------------------
-- function makeParticle
-- @brief 파티클을 생성한다.
-------------------------------------
function UI_EventLFBag:makeParticle(node, name)
    local particle_res = string.format('res/ui/particle/%s.plist', name)
	local particle = cc.ParticleSystemQuad:create(particle_res)
	particle:setAnchorPoint(CENTER_POINT)
	particle:setDockPoint(CENTER_POINT)
	node:addChild(particle)
    particle:setSpeed(140)
    particle:setScale(1.1)
    table.insert(self.m_tableParticles, particle)
end

-------------------------------------
-- function setParticleEnable
-- @brief 파티클을 생성한다.
-------------------------------------
function UI_EventLFBag:removeAllParticles()
    if (not self.m_tableParticles) then return end

    for i,v in ipairs(self.m_tableParticles) do
        if (v) then self.root:removeChild(v) end
    end
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBag:initButton()
    local vars = self.vars

    vars['openBtn']:registerScriptTapHandler(function() self:click_openBtn() end)
    vars['stopBtn']:registerScriptTapHandler(function() self:click_stopBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)

    vars['packageBtn']:registerScriptTapHandler(function() self:click_packageBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBag:refresh()
    local vars = self.vars

    -- 보유 수
    local count_str = self.m_structLFBag:getCount()
    vars['numberLabel']:setString(comma_value(count_str))
    
    -- 레벨
    local lv = self.m_structLFBag:getLv()
    vars['levelLabel']:setString(Str('소원 구슬 {1}단계', lv))
    vars['levelLabel']:stopAllActions()

    vars['scoreLabel']:setString(tostring(comma_value(self.m_structLFBag:getScore())))

    cca.uiReactionSlow(vars['levelLabel'], 1, 1, 1.2)

    -- 최대 레벨 처리 .. 열기 버튼으로 보상을 수령한다.
    if self.m_structLFBag:isMax() then
        vars['openLabel']:setString(Str('수령하기'))
        vars['openLabel']:setScale(1.5)
        vars['openLabel']:setPosition(-17, 0)

        vars['percentageLabel']:setString('')
        vars['percentageLabel2']:setString('축하합니다!')

        self:createLobbyParticles()
    else
        self:removeAllParticles()
        vars['openLabel']:setString(Str('{1}단계 열기', lv))
        vars['openLabel']:setScale(1)
        vars['openLabel']:setPosition(-17, -12)

        vars['percentageLabel']:setString(Str('성공 확률 {1}%', self.m_structLFBag:getSuccessProb()))
        vars['percentageLabel']:stopAllActions()
        cca.uiReactionSlow(vars['percentageLabel'], 1, 1, 1.2)
        vars['percentageLabel2']:setString(Str('성공 확률 {1}%', self.m_structLFBag:getSuccessProb()))
        vars['percentageLabel2']:stopAllActions()
        cca.uiReactionSlow(vars['percentageLabel'], 1, 1, 1.2)
    end

    local isStopBtnEnabled = (self.m_structLFBag:isMax() == false) and (lv ~= 1)
    vars['stopBtn']:setEnabled(isStopBtnEnabled)
    vars['stopBtnLabel']:setColor(isStopBtnEnabled and COLOR['white'] or cc.c3b(200, 200, 200))
    
    -- 현재 레벨의 보상 목록
    self:updateScrollView()

    self:updateRewardHistory()
end


-------------------------------------
-- function getAniScale
-------------------------------------
function UI_EventLFBag:updateCumulativeRewardList()
    local vars = self.vars

    -- 누적 보상 목록
    local l_cum_reward_list = self.m_structLFBag:getCumulativeRewardList()
    local last_node = nil
    for i = 1, 5 do
        vars['itemNode' .. i]:removeAllChildren()

        local t_item = l_cum_reward_list[i]
        if (t_item) then
            local card_ui = MakeItemCard(t_item)
            card_ui.root:setScale(0.8)
            vars['itemNode' .. i]:addChild(card_ui.root)
            last_node = card_ui.root
        end
    end
    if last_node then
        cca.uiReactionSlow(last_node,0.8, 0.8, 1.5)
    end
end


-------------------------------------
-- function getAniScale
-------------------------------------
function UI_EventLFBag:playOpenAnimation(aniType, level, loop)
    local aniObj = self.vars['luckyFortuneBagVisual']

    aniObj:changeAni(string.format('bag_%.2d' .. '_' .. aniType, tostring(level)), loop)
end

-------------------------------------
-- function update
-------------------------------------
function UI_EventLFBag:update(dt)
    if (self.m_structLFBag == nil) then
        time_label:setString('')
    end
    
    -- 남은 시간
    local time_label = self.vars['timeLabel']
    if time_label then
        local curr_time = Timer:getServerTime()
        local end_time = self.m_structLFBag:getEndTime()
        if (0 < end_time) and (curr_time < end_time) then
            local remain_time = (end_time - curr_time)
            local str = Str('{1} 남음', datetime.makeTimeDesc(remain_time, true))
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventLFBag:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function reset
-------------------------------------
function UI_EventLFBag:reset()

end

-------------------------------------
-- function showCurrntReward
-------------------------------------
function UI_EventLFBag:showCurrntReward(item_str)
    local vars = self.m_toastUI.vars
    
    -- 현재 보상 정보 파싱
    local l_item_list = g_itemData:parsePackageItemStr(item_str)
    local t_item = l_item_list[1]

    -- 정보 입력
    local item_id = t_item['item_id']
    local itemIcon = IconHelper:getItemIcon(item_id)

    vars['itemNode']:removeAllChildren(true)
    vars['itemNode']:addChild(itemIcon)
    local item_count_str = string.format('%s x%s', TableItem:getItemName(item_id), comma_value(t_item['count']))
    vars['itemLabel']:setString(item_count_str)

    self.m_toastUI:setOpacityChildren(true)

    -- 등장 연출
	cca.fadeInDelayOut(self.m_toastUI.root, 0.1, 0.5, 0.3)
end

-------------------------------------
-- function makeScrollView
-- @brief 안정성을 위해 스크롤뷰를 직접 생성하여 사용함
-------------------------------------
function UI_EventLFBag:makeScrollView()
    local scroll_view = cc.ScrollView:create()
    self.m_scrollView = scroll_view

    -- 스크롤뷰에서 사용할 사이즈
    local interval = 55
    local cell_count = 5
    local normal_size = self.vars['rewardListNode']:getContentSize()
    local content_size = cc.size(296, interval * cell_count)

    -- 스크롤뷰 설정
    scroll_view:setDockPoint(TOP_CENTER)
    scroll_view:setAnchorPoint(TOP_CENTER)
    scroll_view:setPosition(TOP_CENTER)
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    scroll_view:setNormalSize(normal_size)
    scroll_view:setContentSize(content_size)
    scroll_view:setTouchEnabled(true)

    self.vars['rewardListNode']:addChild(scroll_view)

    local height_half = content_size['height'] / 2

    -- 컨테이너 상단 이동
    local container_node = scroll_view:getContainer()
    container_node:setPositionY(-height_half + interval)

    -- 셀 미리 생성
    for i = 1, cell_count do
        local cell_ui = self.makeCellUI()
        scroll_view:getContainer():addChild(cell_ui.root)
        cell_ui.root:setPositionY(height_half + interval/2 + -interval * i)
        table.insert(self.m_cellUIList, cell_ui)
    end
end

-------------------------------------
-- function updateScrollView
-- @brief 획득 가능 보상 업데이트
-------------------------------------
function UI_EventLFBag:updateScrollView()
    local l_reward_list = self.m_structLFBag:getRewardList()
    local reverseList = {}

    for i=#l_reward_list, 1, -1 do
	    reverseList[#reverseList+1] = l_reward_list[i]
    end

    for i, cell_ui in ipairs(self.m_cellUIList) do
        self.updateCellUI(cell_ui, reverseList[i])
    end
end

-------------------------------------
-- function makeToast
-------------------------------------
function UI_EventLFBag:makeToast()
    local ui = UI()   
    ui:load('popup_toast_with_icon.ui')
    self.root:addChild(ui.root)

    ui.root:setOpacity(0)
    ui.root:setPositionY(100)

    return ui
end

-------------------------------------
-- function click_openBtn
-------------------------------------
function UI_EventLFBag:click_openBtn()
    local vars = self.vars
    if (self.m_structLFBag:isMax()) then
        self:receiveMaxReward()
        self.m_lastAniLevel = 1
        self:playNormalAni()
        return
    end

    -- 조건 체크
    if (not g_eventLFBagData:canPlay()) then
        UIManager:toastNotificationRed(Str('이벤트가 종료되었습니다.'))
        return

    elseif (not self.m_structLFBag:canStart()) then
        self:click_packageBtn()
        UIManager:toastNotificationRed(Str('소원 구슬이 부족합니다.'))
        return
    end

    -- 레벨
    local lv = self.m_structLFBag:getLv()

    -- 소원 구슬 열기
    local function do_open()
        self.m_lastAniLevel = lv
        self:playOpenAnimation('effect', self.m_lastAniLevel, false)

        local function finish_cb(ret)
            -- 성공
            if (ret['is_success']) then
                SoundMgr:playEffect('UI', 'ui_in_item_get')
                
                -- 이번 성공으로 획득한 보상
                local function toast_cb()
                    if (ret['item_info']) then
                        self:showCurrntReward(ret['item_info'])
                        self:updateCumulativeRewardList()

                        if(self.m_structLFBag:isMax()) then 
                            local msg = Str('{1}단계', 5) .. ' ' .. Str('성공')
                            local submsg = ''
                            submsg = Str('이전 단계까지 누적된 보상을 획득합니다.\n소원 구슬의 단계가 초기화됩니다.')

                            local score = ret['score'] ~= nil and ret['score'] or self:getCurrentEndScore()
                            local scoreMsg = ''

                            if (score > 50) then
                                scoreMsg = Str('대박 점수: {1}점', score)
                            else
                                scoreMsg = Str('점수: {1}점', score)
                            end

                            UI_EventLFBagNoticePopup(POPUP_TYPE.OK, msg, scoreMsg, submsg, ok_cb)

                            self:setSelebrateAni()
                        end
                    end
                end

                self.root:stopAllActions()

                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1.02), cc.CallFunc:create(toast_cb)))

                self:onActOpen()

                g_serverData:receiveReward(ret)
            -- 실패
            else
                self.m_lastAniLevel = 1
                SoundMgr:playEffect('UI', 'ui_eat')
                
                local function ok_cb()
                    if (self.m_structLFBag:canStart() == false) then
                        self:click_packageBtn()
                    end
                end

                local msg = Str('열기 실패')
                local submsg = ''
                if (lv < 3) then
                    submsg = Str('이전 단계까지 누적된 보상을 획득합니다.\n소원 구슬의 단계가 초기화됩니다.')
                else
                    submsg = Str('이전 단계까지 누적된 보상을 받지 못했습니다.\n소원 구슬의 단계가 초기화됩니다.')
                end

                local scoreMsg = Str('점수: {1}점', comma_value(ret['score']))

                UI_EventLFBagNoticePopup(POPUP_TYPE.OK, msg, scoreMsg, submsg, ok_cb)

                -- 보상 수령
                if (ret['new_mail']) then
                    self:reset()
                end

                self:updateCumulativeRewardList()
                self:playNormalAni()

                if (lv < 3) then 
                    g_serverData:receiveReward(ret)
                end
            end

            self:refresh()
        end    
        g_eventLFBagData:request_eventLFBagOpen(finish_cb)
    end

    -- 누적보상 받지 못할 리스크가 있는 경우
    -- 3단계 한번만 안내한다
    if (self.m_structLFBag:getLv() == 3) then
        local msg = Str('소원 구슬을 여시겠습니까?')
        local submsg = Str('{1} 단계 이상에서 열기에 실패하면,\n이전 단계까지 누적된 보상을 받을 수 없으니 신중하세요!', 3)
        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, do_open)
    else
        do_open()
    end
end

-------------------------------------
-- function receiveMaxReward
-- @brief 별다른 처리는 없고 분기 처리용
-------------------------------------
function UI_EventLFBag:receiveMaxReward()
    local function finish_cb(ret)
        -- 보상 수령
        if (ret['new_mail']) then
            self:reset()
        end

        self:refresh()
    end
    g_eventLFBagData:request_eventLFBagReward(finish_cb)
end

-------------------------------------
-- function click_stopBtn
-------------------------------------
function UI_EventLFBag:click_stopBtn()
    local vars = self.vars
    if (self.m_structLFBag:isMax()) then
        self:receiveMaxReward()
        self.m_lastAniLevel = 1
        self:playOpenAnimation('normal', self.m_lastAniLevel, true)
        return
    end

    -- 조건 체크
    if (not g_eventLFBagData:canPlay()) then
        UIManager:toastNotificationRed(Str('이벤트가 종료되었습니다.'))
        return
    
    elseif (self.m_structLFBag:getLv() == 1) then
        self:click_packageBtn()
        UIManager:toastNotificationRed(Str('수령할 누적 보상이 없습니다.'))
        return
    end

    local msg = Str('열기를 중단하시겠습니까?')
    local submsg = Str('이전 단계까지 누적된 보상을 획득합니다.\n소원 구슬의 단계가 초기화됩니다.')
    local function ok_btn_cb()
        self:playOpenAnimation('effect', self.m_lastAniLevel, false)

        local function finish_cb(ret)
            self:onActOpen()
            -- 보상 수령
            if (ret['new_mail']) then
                self:reset()
            end

            self:updateCumulativeRewardList()
            self:refresh()
        end
        g_eventLFBagData:request_eventLFBagReward(finish_cb)
    end

    local scoreMsg = Str('점수: {1}점', self:getCurrentEndScore())

    UI_EventLFBagNoticePopup(POPUP_TYPE.YES_NO, msg, scoreMsg, submsg, ok_btn_cb)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventLFBag:click_infoBtn()
    local ui = MakePopup('event_lucky_fortune_bag_info_popup.ui')
    local vars = ui.vars
    vars['descLabel01']:setString(Str('소원 구슬을 열 때, 성공하거나 실패할 수 있습니다.'))
    vars['descLabel02']:setString(Str('성공하면 보상이 누적되며 다음 단계의 소원 구슬이 나옵니다.'))
    vars['descLabel03']:setString(Str('{1}단계 이하에서 실패하면 이 전 단계까지의 누적 보상을 받고 소원 구슬의 단계가 초기화됩니다.', 2))
    vars['descLabel04']:setString(Str('{@yellow}{1}단계 이상의 소원 구슬의 경우, 실패 시 누적 보상을 받을 수 없습니다.', 3))
    vars['descLabel05']:setString(Str('중단을 선택하면 확보한 누적 보상을 우편으로 받을 수 있으며, 구슬의  단계가 초기화됩니다.'))
    vars['descLabel06']:setString(Str('소원 구슬은 주사위 이벤트와 소원 구슬 패키지를 통해 획득할 수 있습니다.'))
    vars['descLabel07']:setString(Str('소원 구슬을 통해 획득한 점수에 따라 일일 랭킹, 종합 랭킹 보상을 지급합니다.'))

end

-------------------------------------
-- function click_packageBtn
-------------------------------------
function UI_EventLFBag:click_packageBtn()
    local ui = UI_Package_Bundle('package_lucky_fortune_bag', true)

    local function buy_cb()
        UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.ITEM, function() self:refresh() end)
    end
    ui:setBuyCB(buy_cb)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventLFBag:click_rankBtn()
    --UI_EventLFBagRankingPopup()
    -- 일일랭킹 때문에 여기서도 매번 보상을 요청한다.
    g_eventLFBagData:openRankingPopupForLobby()
end


-------------------------------------
-- function makeCellUI
-------------------------------------
function UI_EventLFBag.makeCellUI()
    local cell_ui = class(UI, ITableViewCell:getCloneTable())()
    cell_ui:load('event_lucky_fortune_bag_item.ui')
    cell_ui.vars['countLabel']:setString(math_random(1, 100))
    cell_ui.root:setDockPoint(TOP_CENTER)
    cell_ui.root:setAnchorPoint(TOP_CENTER)

    return cell_ui
end

-------------------------------------
-- function updateCellUI
-------------------------------------
function UI_EventLFBag.updateCellUI(cell_ui, t_data)
    -- 데이터가 없는 경우 숨김 처리
    if (t_data == nil) then
        cell_ui.root:setVisible(false)
        return
    end

    -- update cell
    cell_ui.root:setVisible(true)
    local vars = cell_ui.vars
    vars['itemNode']:removeAllChildren(true)
    local icon = IconHelper:getItemIcon(t_data['item_id'])
    icon:setScale(1.1) -- 아이콘 크기 확대
    vars['itemNode']:addChild(icon)
    vars['probLabel']:setString(string.format('%s%%', t_data['pick_percent']))
    vars['countLabel']:setString(comma_value(t_data['val']))
end


-------------------------------------
-- function updateRewardHistory
-------------------------------------
function UI_EventLFBag:updateRewardHistory()
    if (self.m_rewardHistoryView == nil) then
        return
    end

    if (self.m_rewardHistoryLabel) then
        self:setHistoryText()
        return
    end

    local nodeWidth, nodeHeight = self.m_rewardHistoryView:getNormalSize()

    -- rich_label 생성
	local rich_label = UIC_RichLabel()
	rich_label:setDimension(nodeWidth, nodeHeight)
	rich_label:setFontSize(16)
	--rich_label:enableOutline(cc.c4b(0, 0, 0, 127), 1)
    rich_label:setDefualtColor(COLOR['white'])
    rich_label.m_root:setSwallowTouch(false)
    rich_label.m_lineHeight = 1.4
    rich_label.m_wordSpacing = 1.5

    local width, height = rich_label:getNormalSize()
    local verticalAlignment = cc.VERTICAL_TEXT_ALIGNMENT_CENTER

    rich_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, verticalAlignment)

	-- scroll label  생성
	self.m_rewardHistoryLabel = UIC_ScrollLabel:create(rich_label)
	self.m_rewardHistoryLabel:setDockPoint(CENTER_POINT)
	self.m_rewardHistoryLabel:setAnchorPoint(CENTER_POINT)

	self.m_rewardHistoryView:addChild(self.m_rewardHistoryLabel.m_node)

    self:setHistoryText()
end

-------------------------------------
-- function setHistoryText
-------------------------------------
function UI_EventLFBag:setHistoryText()
    local broadcastTable = g_broadcastManager.m_tMessage

    if (broadcastTable == nil or #broadcastTable < 1) then return end
    -- 희귀 YELLOW/일반 item_highlight
    if self.m_rewardHistoryLabel then
        local finalStr = ''
        for i, v in ipairs(broadcastTable) do
            if (v['event'] == 'lkft') then
                local nickName = v['data']['nick']
                local itemName = '{@item_highlight}' .. TableItem:getItemName(v['data']['item_id']) .. '{@Default}'
                local itemCount = v['data']['count']
                local itemString = Str(itemName) .. ' ' .. Str('{1}개', tostring(comma_value(itemCount))) .. ' '
                finalStr = finalStr .. Str('{1}님이 {2}획득', nickName, itemString)

                if (i < #broadcastTable) then
                    finalStr = finalStr ..  '\n'
                end
            end
        end

        self.m_rewardHistoryLabel:setString(Str(finalStr))
    end
end

-------------------------------------
-- function getCurrentEndScore
-------------------------------------
function UI_EventLFBag:getCurrentEndScore()
    local lv = self.m_structLFBag:getCurrentLv()
    local score = 0

    if (lv == 1) then
        score = 10
    elseif (lv == 2) then
        score = 20
    elseif (lv == 3) then
        score = 30
    elseif (lv == 4) then
        score = 40
    elseif (lv == 5) then
        score = 50
    end

    return score
end

-------------------------------------
-- function playNormalAni
-------------------------------------
function UI_EventLFBag:playNormalAni()
    local vars = self.vars

    if (vars['completeNode']) then vars['completeNode']:setVisible(false) end
    if (vars['luckyFortuneBagVisual']) then vars['luckyFortuneBagVisual']:setVisible(true) end
    
    vars['luckyFortuneBagVisual']:changeAni(string.format('bag_%.2d' .. '_normal', self.m_lastAniLevel), true)
end

-------------------------------------
-- function setSelebrateAni
-------------------------------------
function UI_EventLFBag:setSelebrateAni()
    local vars = self.vars

    if (vars['luckyFortuneBagVisual']) then vars['luckyFortuneBagVisual']:setVisible(false) end

    if (vars['completeNode']) then 
        vars['completeNode']:setVisible(true) 

        if (vars['celebrateSprite']) then cca.pickMePickMe(vars['celebrateSprite'], 27) end
    end
end

-------------------------------------
-- function onActOpen
-------------------------------------
function UI_EventLFBag:onActOpen()
    local vars = self.vars

    if (vars['completeNode']) then vars['completeNode']:setVisible(false) end
    if (vars['luckyFortuneBagVisual']) then vars['luckyFortuneBagVisual']:setVisible(true) end

    -- 레벨
    local currentLevel = self.m_structLFBag:getLv()

    -- 소원 구슬 애니메이션 1, 2, 3, 4, 5
    vars['luckyFortuneBagVisual']:addAniHandler(function()
            self:playOpenAnimation('normal', currentLevel, true)
            self.m_lastAniLevel = currentLevel
        end)

    if (self.m_structLFBag:isMax()) then
        vars['luckyFortuneBagVisual']:addAniHandler(function()
            self:setSelebrateAni()
        end)
    end
end