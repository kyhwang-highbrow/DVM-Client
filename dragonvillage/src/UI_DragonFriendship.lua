local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonFriendship
-------------------------------------
UI_DragonFriendship = class(PARENT,{
        m_fruitFeedPressHelper = 'UI_FruitFeedPress',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonFriendship:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonFriendship'
    self.m_bVisible = true or false
    self.m_titleStr = Str('친밀도') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonFriendship:init(doid)
    local vars = self:load('dragon_friendship.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonFriendship')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonFriendship:initUI()
    local vars = self.vars
    self:init_dragonTableView()

    vars['heartNumberLabel'] = NumberLabel_Percent(vars['heartLabel'])

    vars['fruitNumberLabel1'] = NumberLabel(vars['fruitLabel1'], 0, 0.3)
    vars['fruitNumberLabel2'] = NumberLabel(vars['fruitLabel2'], 0, 0.3)
    vars['fruitNumberLabel3'] = NumberLabel(vars['fruitLabel3'], 0, 0.3)
    vars['fruitNumberLabel4'] = NumberLabel(vars['fruitLabel4'], 0, 0.3)

    self.m_fruitFeedPressHelper = UI_FruitFeedPress(self)

    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        self.m_dragonAnimator.vars['dragonNode']:setScale(1)
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonFriendship:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief 선택된 드래곤이 변경되었을 때 호출
-------------------------------------
function UI_DragonFriendship:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]
    local did = t_dragon_data['did']

    -- 배경
    local attr = TableDragon:getDragonAttr(did)
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 드래곤 실리소스
    if self.m_dragonAnimator then
        self.m_dragonAnimator:setDragonAnimator(t_dragon['did'], t_dragon_data['evolution'], t_dragon_data['friendship']['flv'])
    end

    self:refreshFruits(attr)

    self:refreshFriendship()
end

-------------------------------------
-- function refreshFriendship
-- @brief
-------------------------------------
function UI_DragonFriendship:refreshFriendship()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    local friendship_obj = t_dragon_data:getFriendshipObject()
    local t_friendship_info = friendship_obj:getFriendshipInfo()

    -- 친밀도 이름
    if self:checkVarsKey('conditionLabel', t_friendship_info['name']) then
        vars['conditionLabel']:setString(t_friendship_info['name'])
    end

    -- 대사
    if self:checkVarsKey('conditionInfoLabel', t_friendship_info['desc']) then
        vars['conditionInfoLabel']:setString(t_friendship_info['desc'])
    end
    
    -- 경험치 게이지
    if self:checkVarsKey('expGauge', t_friendship_info['exp_percent']) then
        vars['expGauge']:stopAllActions()
        vars['expGauge']:runAction(cc.ProgressTo:create(0.3, t_friendship_info['exp_percent']))

        if friendship_obj:isMaxFriendshipLevel() then
            vars['expLabel']:setString(Str('최대 친밀도'))
        else
            vars['expLabel']:setString(Str('{1}/{2}', friendship_obj['fexp'], t_friendship_info['max_exp']))
        end
    end

    local percent = (friendship_obj['fatk'] / t_friendship_info['atk_max']) * 100
    if self:checkVarsKey('atkGauge', percent) then
        vars['atkGauge']:stopAllActions()
        vars['atkGauge']:runAction(cc.ProgressTo:create(0.3, percent))

        vars['atkLabel']:setString(Str('{1}/{2}', friendship_obj['fatk'], t_friendship_info['atk_max']))
    end

    local percent = (friendship_obj['fdef'] / t_friendship_info['def_max']) * 100
    if self:checkVarsKey('defGauge', percent) then
        vars['defGauge']:stopAllActions()
        vars['defGauge']:runAction(cc.ProgressTo:create(0.3, percent))

        vars['defLabel']:setString(Str('{1}/{2}', friendship_obj['fdef'], t_friendship_info['def_max']))
    end

    local percent = (friendship_obj['fhp'] / t_friendship_info['hp_max']) * 100
    if self:checkVarsKey('hpGauge', percent) then
        vars['hpGauge']:stopAllActions()
        vars['hpGauge']:runAction(cc.ProgressTo:create(0.3, percent))

        vars['hpLabel']:setString(Str('{1}/{2}', friendship_obj['fhp'], t_friendship_info['hp_max']))
    end

    -- 기분 게이지
    if friendship_obj:isMaxFriendshipLevel() then
        self:setHeartGauge(100)
    else
        self:setHeartGauge(t_friendship_info['feel_percent'])
    end
    
end

-------------------------------------
-- function setHeartGauge
-- @brief
-------------------------------------
function UI_DragonFriendship:setHeartGauge(percentage, b_init)
    local vars = self.vars
    if b_init then
        vars['heartNumberLabel']:setNumber(0, true)
        vars['heartGauge']:setPercentage(0)
    end
    vars['heartNumberLabel']:setNumber(percentage)
    vars['heartGauge']:stopAllActions()
    vars['heartGauge']:runAction(cc.EaseElasticOut:create(cc.ProgressTo:create(1, percentage), 1.5))
end

-------------------------------------
-- function refreshFruits
-- @brief
-------------------------------------
function UI_DragonFriendship:refreshFruits(attr)
    local vars = self.vars

    local l_fruit_list = TableItem:getFruitsListByAttr(attr)

    for i=1, 4 do
        local fid = l_fruit_list[i]['item']
        vars['fruitNode' .. i]:removeAllChildren()
        local icon = IconHelper:getItemIcon(fid)
        vars['fruitNode' .. i]:addChild(icon)

        icon:setScale(0)
        icon:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1, 1), 0.3)))


        local count = g_userData:getFruitCount(fid)
        vars['fruitNumberLabel' .. i]:setNumber(count)


        local fruit_button = vars['fruitBtn' .. i]
        fruit_button:registerScriptTapHandler(function() self:click_fruitBtn(fid, fruit_button) end)
        fruit_button:registerScriptPressHandler(function() self:press_fruitBtn(fid, fruit_button, vars['fruitNumberLabel' .. i]) end)
    end
    --[[
    fruitBtn1

    fruitNode1
    fruitNode1
    fruitNode1
    fruitNode1

    fruitLabel1
    fruitLabel2
    fruitLabel3
    fruitLabel4
    --]]
end

-------------------------------------
-- function feedDirecting
-- @brief 열매 날아가는 연출
-------------------------------------
function UI_DragonFriendship:feedDirecting(fruit_id, fruit_node, finish_cb)
    finish_cb = finish_cb or function() end

    local vars = self.vars
    local pos_x = 0
    local pos_y = 0

    local dest_pos_x = 0
    local dest_pos_y = 0

    do -- 시작 위치
        local x, y = fruit_node:getPosition()
        local parent = fruit_node:getParent()
        local world_pos = parent:convertToWorldSpaceAR(cc.p(x, y))
        local local_pos = self.root:convertToNodeSpaceAR(world_pos)
        pos_x = local_pos['x']
        pos_y = local_pos['y']
    end

    do -- 도착 위치
        local x, y = vars['dragonNode']:getPosition()
        local parent = vars['dragonNode']:getParent()
        local world_pos = parent:convertToWorldSpaceAR(cc.p(x, y))
        local local_pos = self.root:convertToNodeSpaceAR(world_pos)
        dest_pos_x = local_pos['x'] + math_random(-50, 50)
        dest_pos_y = local_pos['y'] + 100 + math_random(-50, 50)
    end

    -- 아이콘 생성
    local icon = IconHelper:getItemIcon(fruit_id)
    icon:setPosition(pos_x, pos_y)
    self.root:addChild(icon)

    do -- 액션 실행
        local distance = getDistance(pos_x, pos_y, dest_pos_x, dest_pos_y)
        local duration = 0.5 + math_max(0, ((distance - 450) * 0.0001))
        local jump_height = math_random(100, 250)
        local action = cc.JumpTo:create(duration, cc.p(dest_pos_x, dest_pos_y), jump_height, 1)
		local action2 = cc.RotateTo:create(duration, -720)
        local spawn = cc.Spawn:create(cc.EaseIn:create(action, 1), action2)
        local scale_action = cc.ScaleTo:create(0.05, 0)
		icon:runAction(cc.Sequence:create(spawn, scale_action, cc.CallFunc:create(finish_cb), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function request_friendshipUp
-------------------------------------
function UI_DragonFriendship:request_friendshipUp(fid, fcnt, fcnt_120p, fcnt_150p, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID


    local function success_cb(ret)
        --[[
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

        self.m_bChangeDragonList = true
        --]]

        finish_cb(ret)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/friendshipUp')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('fid', fid)
    ui_network:setParam('fcnt', fcnt)
    ui_network:setParam('fcnt_120p', fcnt_120p)
    ui_network:setParam('fcnt_150p', fcnt_150p)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function response_friendshipUp
-------------------------------------
function UI_DragonFriendship:response_friendshipUp(ret)
    local before = self.m_selectDragonData
    local before_flv = before:getFriendshipObject()['flv']

    -- 드래곤 갱신
    if ret['dragon'] then
        g_dragonsData:applyDragonData(ret['dragon'])
    end

    -- 열매 갯수 동기화
    if ret['fruits'] then
        g_serverData:applyServerData(ret['fruits'], 'user', 'fruits')
    end

    -- is_flevelup  bool
    -- added_lactea num
    -- lactea       num

    -- UI에서 관리하는 드래곤 정보 갱신
    self:setSelectDragonDataRefresh()

    local flv = self.m_selectDragonData:getFriendshipObject()['flv']
    if (before_flv < flv) then
        UI_DragonManageFriendshipResult(self.m_selectDragonData)
    end

    self.m_bChangeDragonList = true
end

-------------------------------------
-- function click_fruitBtn
-- @brief
-------------------------------------
function UI_DragonFriendship:click_fruitBtn(fid, btn)
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local friendship_obj = t_dragon_data:getFriendshipObject()
    if friendship_obj:isMaxFriendshipLevel() then
        UIManager:toastNotificationRed(Str('최대 친밀도의 드래곤입니다.'))
        return
    end

    local count = g_userData:getFruitCount(fid)
    if (count <= 0) then
        UIManager:toastNotificationRed(Str('열매가 부족하네요!!'))
        UI_ItemInfoPopup(fid)
        return
    end

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        local fail_cb = function(ret)
            self:refresh()
        end

        -- 서버와 통신
        co:work()
        local ret_cache
        local function request_finish(ret)
            ret_cache = ret
            co.NEXT()
        end
        self:request_friendshipUp(fid, 1, 0, 0, request_finish, co.ESCAPE)
        if co:waitWork() then return end

        -- 열매 연출
        co:work()
        self:feedDirecting(fid, btn, co.NEXT)
        if co:waitWork() then return end

        self:response_friendshipUp(ret_cache)
        self:refresh()

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function pressProcess
-- @brief
-------------------------------------
function UI_DragonFriendship:pressProcess(fid, fcnt, fcnt_120p, fcnt_150p)
    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        local fail_cb = function(ret)
            self:refresh()
            co.ESCAPE()
        end

        -- 서버와 통신
        co:work()
        local ret_cache
        local function request_finish(ret)
            ret_cache = ret
            co.NEXT()
        end
        self:request_friendshipUp(fid, fcnt, fcnt_120p, fcnt_150p, request_finish, fail_cb)
        if co:waitWork() then return end


        self:response_friendshipUp(ret_cache)
        self:refresh()

        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function press_fruitBtn
-- @brief
-------------------------------------
function UI_DragonFriendship:press_fruitBtn(fid, btn, number_label)
    self.m_fruitFeedPressHelper:fruitPressHandler(fid, btn, number_label)
end

-------------------------------------
-- function showEmotionEffect
-- @brief 감정 이펙트 연출
-------------------------------------
function UI_DragonFriendship:showEmotionEffect()
    local vars = self.vars
    local animator = MakeAnimator('res/ui/a2d/emotion/emotion.vrp')

    do -- 에니메이션 지정
        local sum_random = SumRandom()
        sum_random:addItem(1, 'curious')
        sum_random:addItem(2, 'exciting')
        sum_random:addItem(2, 'like')
        sum_random:addItem(2, 'love')
        local ani_name = sum_random:getRandomValue()     
        animator:changeAni(ani_name, false)
    end

    -- 위치 지정
    animator:setPosition(-70, 200)
    
    -- 재생 후 삭제
    local duration = animator.m_node:getDuration()
    animator.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    vars['dragonNode']:addChild(animator.m_node)
end



--@CHECK
UI:checkCompileError(UI_DragonFriendship)
