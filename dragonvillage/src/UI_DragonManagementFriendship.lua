local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManagementFriendship
-------------------------------------
UI_DragonManagementFriendship = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_currAttrTab = 'string',
        m_prevFriendshipData = 'table', -- 친밀도 상승 연출을 위한 데이터 저장용
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManagementFriendship:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManagementFriendship'
    self.m_bVisible = true or false
    self.m_titleStr = Str('친밀도') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManagementFriendship:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false
    self.m_currAttrTab = nil

    local vars = self:load('dragon_management_friendship.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManagementFriendship')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr(b_ascending_sort, sort_type)

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManagementFriendship:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    --self:setDefaultSelectDragon()

    -- 최초 탭 설정
    self:changeAttrTab('global')

    vars['expGauge']:setPercentage(0)
    vars['hpGauge']:setPercentage(0)
    vars['defGauge']:setPercentage(0)
    vars['atkGauge']:setPercentage(0)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManagementFriendship:initButton()
    local vars = self.vars

    vars['fireBtn']:registerScriptTapHandler(function() self:changeAttrTab('fire') end)
    vars['waterBtn']:registerScriptTapHandler(function() self:changeAttrTab('water') end)
    vars['earthBtn']:registerScriptTapHandler(function() self:changeAttrTab('earth') end)
    vars['lightBtn']:registerScriptTapHandler(function() self:changeAttrTab('light') end)
    vars['darkBtn']:registerScriptTapHandler(function() self:changeAttrTab('dark') end)
    vars['globalBtn']:registerScriptTapHandler(function() self:changeAttrTab('global') end)
    vars['resetBtn']:registerScriptTapHandler(function() self:changeAttrTab('reset') end)

    -- 망각의 열매 사용 버튼
    vars['resetUseBtn']:registerScriptTapHandler(function() self:click_resetUseBtn() end)
end

-------------------------------------
-- function refresh
-- @brief 선택된 드래곤이 변경되었을 때 호출
-------------------------------------
function UI_DragonManagementFriendship:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 드래곤 친밀도 정보 (왼쪽 정보)
    self:refresh_dragonFriendshipInfo()

    -- 보너스 아이콘 변경
    self:refresh_bonusIcon(t_dragon['attr'])

    -- 망각의 열매 정보 변경
    self:refresh_resetFruit()
end

-------------------------------------
-- function refresh_dragonFriendshipInfo
-- @brief 드래곤 친밀도 정보 (왼쪽 정보)
-------------------------------------
function UI_DragonManagementFriendship:refresh_dragonFriendshipInfo()
    local vars = self.vars

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    local flv = t_dragon_data['flv']
    local fexp = t_dragon_data['fexp']

    local table_friendship = TABLE:get('friendship')
    local t_friendship = table_friendship[flv]

    
    do -- 친밀도 상태 텍스트 출력
        -- 친밀도 단계명
        vars['conditionLabel']:setString(Str(t_friendship['t_name']))

        -- 친밀도 단계 설명
        local nickname = g_serverData:get('local', 'idfa')
        vars['conditionInfoLabel']:setString(string.format('[%s]', nickname) .. Str(t_friendship['t_desc']))
    end

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
    end

    do -- 친밀도 경험치 표시
        local req_exp = t_friendship['req_exp']
        local cur_exp = fexp

        vars['expLabel']:setString(Str('{1} / {2}', cur_exp, req_exp))
        local percentage = (cur_exp / req_exp) * 100
        vars['expGauge']:stopAllActions()
        vars['expGauge']:runAction(cc.ProgressTo:create(0.3, percentage))
    end

    local table_friendship_variables = TABLE:get('friendship_variables')
    do -- 친밀도에 의한 체력 상승 표시
        local hp_cap = table_friendship_variables['hp_cap']['value']
        local hp_cur = t_dragon_data['hp']

        vars['hpLabel']:setString(Str('{1} / {2}', hp_cur, hp_cap))
        local percentage = (hp_cur / hp_cap) * 100
        vars['hpGauge']:stopAllActions()
        vars['hpGauge']:runAction(cc.ProgressTo:create(0.3, percentage))
    end

    do -- 친밀도에 의한 방어력 상승 표시
        local def_cap = table_friendship_variables['def_cap']['value']
        local def_cur = t_dragon_data['def']

        vars['defLabel']:setString(Str('{1} / {2}', def_cur, def_cap))
        local percentage = (def_cur / def_cap) * 100
        vars['defGauge']:stopAllActions()
        vars['defGauge']:runAction(cc.ProgressTo:create(0.3, percentage))
    end

    do -- 친밀도에 의한 공격력 상승 표시
        local atk_cap = table_friendship_variables['atk_cap']['value']
        local atk_cur = t_dragon_data['atk']

        vars['atkLabel']:setString(Str('{1} / {2}', atk_cur, atk_cap))
        local percentage = (atk_cur / atk_cap) * 100
        vars['atkGauge']:stopAllActions()
        vars['atkGauge']:runAction(cc.ProgressTo:create(0.3, percentage))
    end
end

-------------------------------------
-- function refresh_bonusIcon
-- @brief 보너스 아이콘 변경
-------------------------------------
function UI_DragonManagementFriendship:refresh_bonusIcon(dragon_attr)
    local vars = self.vars
    local bonus_icon = vars['bonusSprite']
    local attr_btn = vars[dragon_attr .. 'Btn']

    bonus_icon:retain()
    bonus_icon:removeFromParent()
    attr_btn:addChild(bonus_icon)
    bonus_icon:release()
end

-------------------------------------
-- function changeAttrTab
-- @brief 속성 탭 변경
-------------------------------------
function UI_DragonManagementFriendship:changeAttrTab(attr, b_force)
    if (not b_force) and (self.m_currAttrTab == attr) then
        return
    end

    local vars = self.vars
    local prev_tab = self.m_currAttrTab
    self.m_currAttrTab = attr

    if (prev_tab and vars[prev_tab .. 'Btn']) then
        vars[prev_tab .. 'Btn']:setEnabled(true)
    end

    if (attr and vars[attr .. 'Btn']) then
        vars[attr .. 'Btn']:setEnabled(false)
    end

    if (attr == 'reset') then
        vars['resetNode']:setVisible(true)
        vars['fruitFeedNode']:setVisible(false)
        self:refresh_resetFruit()
    else
        vars['resetNode']:setVisible(false)
        vars['fruitFeedNode']:setVisible(true)
        self:refresh_fruitListTab(attr)
    end

    -- 속성 탭 이름 지정
    vars['attrTitle']:setString(self:getAttrTabName(attr))
end

-------------------------------------
-- function refresh_fruitListTab
-- @brief
-------------------------------------
function UI_DragonManagementFriendship:refresh_fruitListTab(attr)
    local attr = (attr or self.m_currAttrTab)
    local vars = self.vars
    local table_fruit_class = TableClass('fruit')

    -- attr속성의 테이블만 얻어옴
    local l_fruit_list = table_fruit_class:filterList('attr', attr)

    -- 정렬
    table.sort(l_fruit_list, function(a, b) return a['fid'] < b['fid'] end)

    -- 보너스 여부
    local bonus_active = false
    if self.m_selectDragonData then
        local t_dragon_data = self.m_selectDragonData
        local t_dragon = TableDragon():get(t_dragon_data['did'])
        local dragon_attr = t_dragon['attr']
        bonus_active = (attr == dragon_attr)
    end

    for i,t_fruit in ipairs(l_fruit_list) do 
        -- 열매 이미지
        vars['fruitNode' .. i]:removeAllChildren()
        local icon = IconHelper:getItemIcon(t_fruit['fid'])
        vars['fruitNode' .. i]:addChild(icon)

        -- 열매 보요 갯수
        local fid = t_fruit['fid']
        local count = g_userData:getFruitCount(fid)
        vars['fruitLabel' .. i]:setString(comma_value(count))

        -- 열매 경험치
        local fruit_exp = t_fruit['exp']
        if bonus_active then
            fruit_exp = fruit_exp * 1.5
        end
        vars['fruitExpLabel' .. i]:setString(comma_value(fruit_exp))

        -- 열매 사용 가격
        vars['fruitPrice' .. i]:setString(comma_value(t_fruit['req_gold']))

        -- 열매 주기 버튼
        local function click_fruitBtn()
            local fid = t_fruit['fid']
            local fruit_node = vars['fruitNode' .. i]
            self:click_fruitBtn(fid, fruit_node)
        end
        vars['fruitBtn' .. i]:registerScriptTapHandler(click_fruitBtn)

        -- 보너스 화살 아이콘
        vars['bonusUpSprite' .. i]:setVisible(bonus_active)
    end
end

-------------------------------------
-- function refresh_resetFruitTab
-- @brief 
-------------------------------------
function UI_DragonManagementFriendship:refresh_resetFruit()
    local t_dragon_data = self.m_selectDragonData

    local flv = t_dragon_data['flv']
    local table_friendship = TableClass('friendship')
    local t_friendship = table_friendship:get(flv)

    local vars = self.vars

    local reset_fruit_cnt = t_friendship['reset_fruit_cnt']

    -- 망각에 필요한 망각의 열매 갯수
    local req_price = self:getRessetFruitGold() * reset_fruit_cnt
    vars['resetPriceLabel']:setString(comma_value(req_price))

    -- 보유한 망각의 열매 갯수
    local count = g_userData:getResetFruitCount()
    vars['fruitResetLabel']:setString(Str('{1} / {2}', comma_value(reset_fruit_cnt), comma_value(count)))
end

-------------------------------------
-- function getRessetFruitGold
-- @brief 망각의 열매 가격
-------------------------------------
function UI_DragonManagementFriendship:getRessetFruitGold()
    local table_fruit = TableClass('fruit')
    local reset_fruit_id = g_userData:getResetFruitID()
    local t_fruit = table_fruit:get(reset_fruit_id)
    return t_fruit['req_gold']
end

-------------------------------------
-- function getAttrTabName
-- @brief 속성 탭 이름 리턴
-------------------------------------
function UI_DragonManagementFriendship:getAttrTabName(attr)
    local attr_str = ''
    if (attr == 'fire') then
        attr_str = Str('화속성 열매')
    elseif (attr == 'water') then
        attr_str = Str('수속성 열매')
    elseif (attr == 'earth') then
        attr_str = Str('땅속성 열매')
    elseif (attr == 'light') then
        attr_str = Str('빛속성 열매')
    elseif (attr == 'dark') then
        attr_str = Str('어둠속성 열매')
    elseif (attr == 'global') then
        attr_str = Str('공통 열매')
    elseif (attr == 'reset') then
        attr_str = Str('망각의 열매')
    else
        error('attr : ' .. attr)
    end

    return attr_str
end

-------------------------------------
-- function click_fruitBtn
-------------------------------------
function UI_DragonManagementFriendship:click_fruitBtn(fruit_id, fruit_node)
    local count = g_userData:getFruitCount(fruit_id)

    if (count <= 0) then
        UIManager:toastNotificationRed(Str('열매가 부족하네요!!'))
        return
    end

    -- 열매 날아가는 연출
    self:feedDirecting(fruit_id, fruit_node)

    SoundMgr:playEffect('EFFECT', 'eat')

    -- 네트워크 통신
    self:network_friendshipUp(fruit_id)
end

-------------------------------------
-- function network_friendshipUp
-------------------------------------
function UI_DragonManagementFriendship:network_friendshipUp(fruit_id)
    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    -- 친밀도 상승 연출을 위한 데이터 저장용
    self.m_prevFriendshipData = clone(self.m_selectDragonData)

    local function success_cb(ret)
        -- 드래곤 갱신
        if ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        -- 열매 갯수 동기화
        if ret['fruits'] then
            g_serverData:applyServerData(ret['fruits'], 'user', 'fruits')
        end

        -- 서버에서 새로 받은 드래곤 정보로 갱신
        self:setSelectDragonDataRefresh()

        -- 드래곤 정보 갱신
        self:refresh_dragonFriendshipInfo()

        -- 열매 정보 갱신
        self:refresh_fruitListTab(attr)
        
        self:friendshipDirecting(ret['is_flevelup'], ret['bonus_grade'], self.m_prevFriendshipData, ret['dragon'])
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/friendshipUp')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('fid', fruit_id)
    ui_network:setParam('fcnt', 1)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function friendshipDirecting
-- @brief 열매주기 연출
-------------------------------------
function UI_DragonManagementFriendship:friendshipDirecting(is_fevelup, bonus_grade, t_prev_dragon_data, t_curr_dragon_data)
    if (not is_fevelup) then
        self.vars['friendshipFxVisual']:setVisible(true)
        self.vars['friendshipFxVisual']:changeAni('friendship_fx', false)
        return
    end

    local block_ui = UI_BlockPopup()

    local directing_animation
    local directing_result

    -- 에니메이션 연출
    directing_animation = function()
        local vars = self.vars

        self.vars['friendshipVisual']:setVisible(true)
        self.vars['friendshipVisual']:changeAni('friendship_up', false)
        self.vars['friendshipVisual']:addAniHandler(directing_result)
    end

    -- 결과 연출
    directing_result = function()
        block_ui:close()

        -- 결과 팝업 생성
        UI_DragonManageFriendshipResult(bonus_grade, t_prev_dragon_data, t_curr_dragon_data)
    end

    directing_animation()
end

-------------------------------------
-- function fruitFeedAction
-------------------------------------
function UI_DragonManagementFriendship:fruitFeedAction(fruit_id, fruit_node, finish_cb)
    local item_icon = IconHelper:getItemIcon(fruit_id)
    item_icon:setPosition(100, 100)
end

-------------------------------------
-- function click_resetUseBtn
-- @brief 망각의 열매 사용 버튼 데이터 갱신
-------------------------------------
function UI_DragonManagementFriendship:click_resetUseBtn()
    local t_dragon_data = self.m_selectDragonData

    if (t_dragon_data['flv'] <= 1) then
        UIManager:toastNotificationRed(Str('"무관심"단계에서는 망각의 열매를 사용할 수 없습니다.'))
        return
    end

    if (t_dragon_data['can_rollback'] == false) then
        UIManager:toastNotificationRed(Str('망각의 열매는 단계별 1회만 사용할 수 있습니다.'))
        return
    end    
    
    local flv = t_dragon_data['flv']
    local table_friendship = TableClass('friendship')
    local t_friendship = table_friendship:get(flv)

    local req_count = t_friendship['reset_fruit_cnt']
    local own_count = g_userData:getResetFruitCount()

    if (own_count < req_count) then
        UIManager:toastNotificationRed(Str('망각의 열매가 부족합니다.'))
        return
    end

    do -- 팝업으로 물어봄
        local function yes_cb()
            -- 네트워크 통신
            self:network_rollback()
        end

        local msg = Str('망각의 열매를 사용하여\n친밀도의 상태와 능력치를 한단계 전으로 되돌립니다.\n\n정말 사용하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, yes_cb)
    end
end

-------------------------------------
-- function network_rollback
-------------------------------------
function UI_DragonManagementFriendship:network_rollback()
local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID

    local function success_cb(ret)

        -- 드래곤 갱신
        if ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        -- 열매 갯수 동기화
        if ret['fruits'] then
            g_serverData:applyServerData(ret['fruits'], 'user', 'fruits')
        end

        -- 서버에서 새로 받은 드래곤 정보로 갱신
        self:setSelectDragonDataRefresh()

        -- 드래곤 정보 갱신
        self:refresh_dragonFriendshipInfo()

        -- 망각의 열매 정보 갱신
        self:refresh_resetFruit()

        self.vars['friendshipVisual']:setVisible(true)
        self.vars['friendshipVisual']:changeAni('friendship_down', false)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/rollback')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('fid', g_userData:getResetFruitID())
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManagementFriendship:click_exitBtn()
    self:close()
end

-------------------------------------
-- function feedDirecting
-- @brief 열매 날아가는 연출
-------------------------------------
function UI_DragonManagementFriendship:feedDirecting(fruit_id, fruit_node)
    --local icon = IconHelper:getItemIcon(fruit_id)
    --self.root:addChild(icon)
end

--@CHECK
UI:checkCompileError(UI_DragonManagementFriendship)
