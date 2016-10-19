local PARENT = UI

-------------------------------------
-- class UI_DragonFriendshipPopup
-------------------------------------
UI_DragonFriendshipPopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
        m_friendshipDragonID = 'number',
        m_friendshipDragonAnimator = 'Animator',
        m_selectStatusCategory = 'string', -- 선택된 능력치 카테고리 (tactic, def, atk)
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonFriendshipPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonFriendshipPopup'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonFriendshipPopup:init(dragon_id)
    self.m_friendshipDragonID = dragon_id

    local vars = self:load('friendship_scene.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonFriendshipPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh(dragon_id)
    self:refresh_fruit()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonFriendshipPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonFriendshipPopup:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)
    vars['fruitBtn']:registerScriptTapHandler(function() self:click_fruitBtn() end)

    -- 능력치 카테고리 버튼
    vars['tacticBtn']:registerScriptTapHandler(function() self:click_statusCategory('tactic') end)
    vars['defBtn']:registerScriptTapHandler(function() self:click_statusCategory('def') end)
    vars['atkBtn']:registerScriptTapHandler(function() self:click_statusCategory('atk') end)

    -- 열매 버튼들 초기화
    self:init_fruitButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonFriendshipPopup:refresh()
    local dragon_id = self.m_friendshipDragonID

    local vars = self.vars

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 드래곤 정보 갱신
    self:refresh_dragonInfo(dragon_id)

    -- 친밀도 정보 갱신
    self:refresh_friendshipInfo(dragon_id)
end

-------------------------------------
-- function init_fruitButton
-------------------------------------
function UI_DragonFriendshipPopup:init_fruitButton()
    -- 열매 이름 리스트 작성 (망강의 열매 reset은 제외)
    local t_data = g_fruitData.m_tData
    local l_fruit_full_type = {}
    for rarity,t in pairs(t_data) do
        for detailed_stats_type, value in pairs(t) do
            if (detailed_stats_type ~= 'reset') then
                local fruit_full_type = DataFruit:makeFruitFullType(rarity, detailed_stats_type)
                table.insert(l_fruit_full_type, fruit_full_type)
            end
        end
    end

    for _,fruit_full_type in ipairs(l_fruit_full_type) do
        -- 열매 버튼
        local button = self:getFruitButton(fruit_full_type)
        button:registerScriptTapHandler(function() self:click_fruitListItem(fruit_full_type) end)
    end
end

-------------------------------------
-- function refresh_fruit
-------------------------------------
function UI_DragonFriendshipPopup:refresh_fruit()
    -- 열매 이름 리스트 작성 (망강의 열매 reset은 제외)
    local t_data = g_fruitData.m_tData
    local l_fruit_full_type = {}
    for rarity,t in pairs(t_data) do
        for detailed_stats_type, value in pairs(t) do
            if (detailed_stats_type ~= 'reset') then
                local fruit_full_type = DataFruit:makeFruitFullType(rarity, detailed_stats_type)
                table.insert(l_fruit_full_type, fruit_full_type)
            end
        end
    end

    for _,fruit_full_type in ipairs(l_fruit_full_type) do
        -- 열매 갯수 갱신
        local label = self:getFruitLabelRefresh(fruit_full_type)
    end
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보 갱신
-------------------------------------
function UI_DragonFriendshipPopup:refresh_dragonInfo(dragon_id)
    local vars = self.vars
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 드래곤 명칭
    vars['nameLabel']:setString(Str(t_dragon['t_name']) .. ' ' .. evolutionName(t_dragon_data['evolution']))

    -- 레벨 표기
    vars['lvLabel']:setString(Str('레벨{1}/{2}', t_dragon_data['lv'], 60))

    do -- 등급 표기
        local grade = t_dragon_data['grade']
        local res = string.format('res/ui/star020%d.png', grade)
        local sprite = cc.Sprite:create(res)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['starNode']:removeAllChildren()
        vars['starNode']:addChild(sprite)
    end

    -- 드래곤 에니메이션
    if (not self.m_friendshipDragonAnimator) then
        vars['dragonNode']:removeAllChildren()

        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:addChild(animator.m_node)
        animator:changeAni('idle', true)

        self.m_friendshipDragonAnimator = animator
    end
end

-------------------------------------
-- function refresh_friendshipInfo
-- @brief 친밀도 정보 갱신
-------------------------------------
function UI_DragonFriendshipPopup:refresh_friendshipInfo(dragon_id)
    local vars = self.vars

    local t_friendship_data, t_friendship = g_friendshipData:getFriendship(dragon_id)

    -- 친밀도 대사
    local nickname = '"' .. g_userData.m_userData['nickname'] .. '"'
    vars['conditionLabel']:setString(Str(t_friendship['t_desc'], nickname))

    do -- 친밀도 레벨
        -- label
        local friendship_lv = t_friendship_data['lv']
        local friendship_max_lv = 200
        local percentage = math_floor((friendship_lv / friendship_max_lv) * 100)
        vars['friendshipPercentLabel']:setString(tostring(percentage))

        -- progress
        vars['friendshipGg']:stopAllActions()
        vars['friendshipGg']:setPercentage(0)
        vars['friendshipGg']:runAction(cc.ProgressTo:create(0.2, percentage)) 
    end

    -- 친밀도 명칭
    local name = t_friendship['t_name']
    vars['friendshipConditionLabel']:setString(Str(name))
    
    -- 성장률 (능력치 stat)
    --self.m_statsGraph:setGraph(dragon_id)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonFriendshipPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_infoBtn
-- @brief "친밀도 도움말" 버튼
-------------------------------------
function UI_DragonFriendshipPopup:click_infoBtn()
    UIManager:toastNotificationRed(Str('"친밀도 도움말" 미구현'))
end

-------------------------------------
-- function click_detailBtn
-- @brief "능력치 상세보기" 버튼
-------------------------------------
function UI_DragonFriendshipPopup:click_detailBtn()
    local dragon_id = self.m_friendshipDragonID
    UI_DragonDetailPopup(dragon_id)
end

-------------------------------------
-- function click_fruitBtn
-- @brief "보유 열매" 버튼
-------------------------------------
function UI_DragonFriendshipPopup:click_fruitBtn()
    UI_InventoryFruitPopup()
end

-------------------------------------
-- function click_statusCategory
-- @brief 능력치 카테고리 버튼
-------------------------------------
function UI_DragonFriendshipPopup:click_statusCategory(status_category)
    self:setStatusCategory(status_category)
end

-------------------------------------
-- function click_fruitListItem
-- @brief 능력치 카테고리 버튼
-------------------------------------
function UI_DragonFriendshipPopup:click_fruitListItem(fruit_full_type)
    local table_fruit = TABLE:get('fruit')
    local t_fruit = table_fruit[fruit_full_type]

    local rarity = t_fruit['rarity']
    local detailed_stats_type = t_fruit['type']

    -- 열매가 부족한 경우 리턴
    local fruit_count = g_fruitData:getFruitCount(rarity, detailed_stats_type)
    if (fruit_count <= 0) then
        return
    end

    -- 먹이주기
    local dragon_id = self.m_friendshipDragonID
    local ret, ret_msg = g_friendshipData:feedFruit(dragon_id, rarity, detailed_stats_type)

    if ret then 
        UIManager:toastNotificationGreen(ret_msg)
        g_fruitData:useFruit(rarity, detailed_stats_type, 1)
        self:refresh()
        self:refresh_fruit()

        -- 드래곤 포즈
        self.m_friendshipDragonAnimator:changeAni('pose_1', false)
        self.m_friendshipDragonAnimator:addAniHandler(function() self.m_friendshipDragonAnimator:changeAni('idle', true) end)
    else
        UIManager:toastNotificationRed(ret_msg)
    end

end

-------------------------------------
-- function setStatusCategory
-- @brief 능력치 카테고리 설정
-------------------------------------
function UI_DragonFriendshipPopup:setStatusCategory(status_category)
    if (self.m_selectStatusCategory == status_category) then
        return
    end

    self.m_selectStatusCategory = status_category

    local vars = self.vars
    vars['atkPlusNode']:setVisible(false)
    vars['defPlusNode']:setVisible(false)
    vars['tacticPlusNode']:setVisible(false)

    vars[status_category .. 'PlusNode']:setVisible(true)

    -- 설명 보드 숨김
    vars['descBoard']:setVisible(false)

    do-- 배경 보드 크기 조절
        local width, height = vars['statusBoard']:getNormalSize()
        vars['statusBoard']:setContentSize(width, 530)
    end

    local gap = 296 + 20
    if (status_category == 'atk') then
        vars['atkNode']:setPositionY(-20)
        vars['defNode']:setPositionY(-80 - gap)
        vars['tacticNode']:setPositionY(-140 - gap)
    elseif (status_category == 'def') then
        vars['atkNode']:setPositionY(-20)
        vars['defNode']:setPositionY(-80)
        vars['tacticNode']:setPositionY(-140 - gap)
    elseif (status_category == 'tactic') then
        vars['atkNode']:setPositionY(-20)
        vars['defNode']:setPositionY(-80)
        vars['tacticNode']:setPositionY(-140)
    end
end

-------------------------------------
-- function getFruitButton
-- @breif 열매 타입으로 해당 열매 버튼 리턴
-------------------------------------
function UI_DragonFriendshipPopup:getFruitButton(fruit_full_type)
    local vars = self.vars
    local luaname = (string.gsub(fruit_full_type, 'fruit_', '') .. '_btn')
    return vars[luaname]
end

-------------------------------------
-- function getFruitLabel
-- @breif 열매 타입으로 해당 열매 라벨 리턴
-------------------------------------
function UI_DragonFriendshipPopup:getFruitLabel(fruit_full_type)
    local vars = self.vars
    local luaname = (string.gsub(fruit_full_type, 'fruit_', '') .. '_label')
    return vars[luaname]
end

-------------------------------------
-- function getFruitLabelRefresh
-- @breif 열매 타입으로 해당 열매 갯수 갱신
-------------------------------------
function UI_DragonFriendshipPopup:getFruitLabelRefresh(fruit_full_type)
    local cnt = g_fruitData:getFruitCount(fruit_full_type)
    local label = self:getFruitLabel(fruit_full_type)
    label:setString(tostring(cnt))
end

--@CHECK
UI:checkCompileError(UI_DragonFriendshipPopup)
