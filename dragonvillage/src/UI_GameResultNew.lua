-------------------------------------
-- class UI_GameResultNew
-------------------------------------
UI_GameResultNew = class(UI, {
        m_stageID = 'number',
        m_bSuccess = 'boolean',
        m_time = 'number',
        m_gold = 'number',
        m_tTamerLevelupData = 'table',
        m_lDragonList = 'list',
        m_boxGrade = 'string', -- 's', 'a', 'b', 'c'
        m_lDropItemList = 'list',

        m_lNumberLabel = 'list',
        m_lLevelupDirector = 'list',

        m_directionStep = 'number',
        m_lDirectionList = 'list',


        m_lWorkList = 'list',
        m_workIdx = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResultNew:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list)
    self.m_bSuccess = is_success
    self.m_time = time
    self.m_gold = gold
    self.m_tTamerLevelupData = t_tamer_levelup_data
    self.m_lDragonList = l_dragon_list
    self.m_boxGrade = box_grade
    self.m_lDropItemList = l_drop_item_list


    local vars = self:load('ingame_result_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    vars['homeBtn']:registerScriptTapHandler(function() self:click_homeBtn() end)
    vars['againBtn']:registerScriptTapHandler(function() self:click_retryBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)

    vars['retryBtn']:registerScriptTapHandler(function() self:click_retryBtn() end)
    vars['returnBtn']:registerScriptTapHandler(function() self:click_backBtn() end)

    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)

    do -- NumberLabel 초기화, 게임 플레이 시간, 획득 골드
        self.m_lNumberLabel = {}
        self.m_lNumberLabel['time'] = NumberLabel(vars['timeLabel'], 0, 1)
        self.m_lNumberLabel['gold'] = NumberLabel(vars['goldLabel'], 0, 1)
    end

    do
        -- 스테이지 이름
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        local chapter_name = chapterName(chapter)
        local str = chapter_name .. Str(' {1}-{2}', chapter, stage)
        vars['titleLabel']:setString(str)

        -- 난이도
        if (difficulty == 1) then
            vars['gradeLabel']:setString(Str('쉬움'))
        elseif (difficulty == 2) then
            vars['gradeLabel']:setString(Str('보통'))
        elseif (difficulty == 3) then
            vars['gradeLabel']:setString(Str('어려움'))
        end
    end
    
    do -- 유저 레벨, 경험치
        vars['userExpLabel']:setString(Str('경험치 +{1}', t_tamer_levelup_data['add_exp']))
        vars['userLvLabel']:setString(Str('레벨{1}', t_tamer_levelup_data['curr_lv']))
        vars['userExpGg']:setPercentage(t_tamer_levelup_data['curr_exp'] / t_tamer_levelup_data['curr_max_exp'] * 100)
    end


    -- 레벨업 연출 클래스 리스트
    self.m_lLevelupDirector = {}

    -- 드래곤 리스트
    self:initDragonList(t_tamer_levelup_data, l_dragon_list)    

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_GameResultNew')

    -- @brief work초기화 용도로 사용함
    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_GameResultNew:setWorkList()
    self.m_workIdx = 0

    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
    table.insert(self.m_lWorkList, 'direction_showBox')
    table.insert(self.m_lWorkList, 'direction_openBox')
    table.insert(self.m_lWorkList, 'direction_dropItem')
    
    
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_GameResultNew:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        --cclog('\n')
        --cclog('############################################################')
        --cclog('# idx : ' .. self.m_workIdx .. ', func_name : ' .. func_name)
        --cclog('############################################################')
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_GameResultNew:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end


-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_GameResultNew:direction_start()
    local is_success = self.m_bSuccess
    local vars = self.vars

    vars['successVisual']:setVisible(true)

    -- 성공 or 실패
    if (is_success == true) then
        SoundMgr:playBGM('result_success', false)    
        vars['successVisual']:changeAni('success_03', false)
        vars['successVisual']:addAniHandler(function()
            vars['successVisual']:changeAni('success_idle_03', true)
        end)
    else
        SoundMgr:playBGM('result_fail', false)
        vars['successVisual']:changeAni('fail')
    end

    vars['homeBtn']:setVisible(false)
    vars['againBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)

    vars['skipLabel']:setVisible(false)
    vars['retryBtn']:setVisible(false)

    -- 플레이 시간, 획득 골드
    self.m_lNumberLabel['time']:setNumber(self.m_time)
    self.m_lNumberLabel['gold']:setNumber(self.m_gold)

    -- 레벨업 연출 시작
    self:startLevelUpDirector()

    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function direction_start_click
-------------------------------------
function UI_GameResultNew:direction_start_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출 (성공했을 시에만 들어옴)
-------------------------------------
function UI_GameResultNew:direction_end()
    local is_success = self.m_bSuccess
    local vars = self.vars

    -- 플레이 시간, 획득 골드
    self.m_lNumberLabel['time']:setNumber(self.m_time, true)
    self.m_lNumberLabel['gold']:setNumber(self.m_gold, true)

    -- 레벨업 연출 종료
    self:stopLevelUpDirector()

    self.root:stopAllActions()
    if (is_success == true) then
        -- 2초 후 자동으로 이동
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
                self:doNextWork()
            end)))
    else
        vars['skipLabel']:setVisible(false)
        vars['skipBtn']:setVisible(false)

        vars['retryBtn']:setVisible(true)
        vars['returnBtn']:setVisible(true)
    end
end

-------------------------------------
-- function direction_end_click
-------------------------------------
function UI_GameResultNew:direction_end_click()
    self.root:stopAllActions()
    self:doNextWork()
end

-------------------------------------
-- function direction_showBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResultNew:direction_showBox()
    local vars = self.vars

    -- 드래곤 레벨업 연출 node 끄기
    vars['dragonResultNode']:setVisible(false)

    vars['boxVisual']:setVisible(true)
    local visual_name = self:getBoxVisualName(self.m_boxGrade, 'idle')
    vars['boxVisual']:changeAni(visual_name, true)
end

-------------------------------------
-- function direction_showBox_click
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResultNew:direction_showBox_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_openBox
-- @brief 상자 연출 시작
-------------------------------------
function UI_GameResultNew:direction_openBox()
    local vars = self.vars
    local visual_name = self:getBoxVisualName(self.m_boxGrade, 'open')
    vars['boxVisual']:changeAni(visual_name, false)
    vars['boxVisual']:addAniHandler(function()
        vars['boxVisual']:setVisible(false) 
        self:doNextWork()
    end)
end

-------------------------------------
-- function direction_openBox_click
-- @brief
-------------------------------------
function UI_GameResultNew:direction_openBox_click()
end

-------------------------------------
-- function direction_dropItem
-- @brief
-------------------------------------
function UI_GameResultNew:direction_dropItem()
    local vars = self.vars

    for i,v in ipairs(self.m_lDropItemList) do
        self:makeRewardItem(i, v)
    end

    SoundMgr:playEffect('EFFECT', 'reward')

    vars['skipLabel']:setVisible(false)

    vars['homeBtn']:setVisible(true)
    vars['againBtn']:setVisible(true)
    vars['nextBtn']:setVisible(true)
end

-------------------------------------
-- function direction_dropItem
-- @brief
-------------------------------------
function UI_GameResultNew:direction_dropItem_click()

end



-------------------------------------
-- function addLevelUpDirector
-- @brief 레벨업 연출 클래스 추가
-------------------------------------
function UI_GameResultNew:addLevelUpDirector(level_up_director)
    table.insert(self.m_lLevelupDirector, level_up_director)
end

-------------------------------------
-- function startLevelUpDirector
-- @brief 레벨업 연출 클래스 시작
-------------------------------------
function UI_GameResultNew:startLevelUpDirector()
    for i,v in ipairs(self.m_lLevelupDirector) do
        v:start()
    end
end

-------------------------------------
-- function stopLevelUpDirector
-- @brief 레벨업 연출 클래스 종료
-------------------------------------
function UI_GameResultNew:stopLevelUpDirector()
    for i,v in ipairs(self.m_lLevelupDirector) do
        v:stop(true)
    end
end

-------------------------------------
-- function initDragonList
-- @brief 드래곤 정보 설정
-------------------------------------
function UI_GameResultNew:initDragonList(t_tamer_levelup_data, l_dragon_list)
    local dragon_cnt = #l_dragon_list
    local vars = self.vars

    -- 드래곤 노드(테이머 포함) 정렬
    self:sortDragonNode(dragon_cnt)

    --[[
    -- 테이머 리소스 생성
    local tamer = MakeAnimator('res/character/tamer/leon/leon.spine')
    tamer.m_node:setDockPoint(cc.p(0.5, 0.5))
    tamer.m_node:setAnchorPoint(cc.p(0.5, 0.5))
    tamer.m_node:setScale(0.5)
    vars['tamerNode']:addChild(tamer.m_node)

    do -- 테이머 레벨, 경험치
        local lv_label      = vars['tamerLvLabel']
        local exp_label     = vars['tamerExpLabel']
        local max_icon      = vars['tamerMaxSprite']
        local exp_gauge     = vars['tamerExpGauge']
        local level_up_vrp  = vars['tamerLvUpVisual']
        local levelup_director = LevelupDirector_GameResult(lv_label, exp_label, max_icon, exp_gauge, level_up_vrp)

        local src_lv        = t_tamer_levelup_data['prev_lv']
        local src_exp       = t_tamer_levelup_data['prev_exp']
        local dest_lv       = t_tamer_levelup_data['curr_lv']
        local dest_exp      = t_tamer_levelup_data['curr_exp']
        local type          = 'tamer'
        levelup_director:initLevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type)
        self:addLevelUpDirector(levelup_director)
    end
    --]]

    -- 드래곤 리소스 생성
    for i,v in ipairs(l_dragon_list) do
        local user_data = v['user_data']
        local table_data = v['table_data']
        local res_name = table_data['res']
        local evolution = user_data['evolution']
		local attr = table_data['attr']

        local animaotr = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
        animaotr.m_node:setDockPoint(cc.p(0.5, 0.5))
        animaotr.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        --animaotr.m_node:setScale(0.5)
        vars['dragonNode' .. i]:addChild(animaotr.m_node)

        do -- 드래곤 레벨, 경험치
            local lv_label      = vars['lvLabel' .. i]
            local exp_label     = vars['expLabel' .. i]
            local max_icon      = vars['maxSprite' .. i]
            local exp_gauge     = vars['expGauge' .. i]
            local level_up_vrp  = vars['lvUpVisual' .. i]
            local levelup_director = LevelupDirector_GameResult(lv_label, exp_label, max_icon, exp_gauge, level_up_vrp)

            -- 최초 레벨업 시 포즈
            levelup_director.m_cbFirstLevelup = function()
                animaotr:changeAni('pose_1', false)
                animaotr:addAniHandler(function() animaotr:changeAni('idle', true) end)
            end

            local t_levelup_data = v['levelup_data']
            local src_lv        = t_levelup_data['prev_lv']
            local src_exp       = t_levelup_data['prev_exp']
            local dest_lv       = t_levelup_data['curr_lv']
            local dest_exp      = t_levelup_data['curr_exp']
            local type          = 'dragon'
            levelup_director:initLevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type)
            self:addLevelUpDirector(levelup_director)

            do -- 등급
                local grade_res = 'res/ui/icon/star010' .. user_data['grade'] .. '.png'
                local sprite = cc.Sprite:create(grade_res)
                sprite:setAnchorPoint(cc.p(0.5, 0.5))
                sprite:setDockPoint(cc.p(0.5, 0.5))
                vars['starNode' .. i]:removeAllChildren()
                vars['starNode' .. i]:addChild(sprite)
            end
        end
    end
end

-------------------------------------
-- function sortDragonNode
-- @brief 드래곤 노드(테이머 포함) 정렬
-------------------------------------
function UI_GameResultNew:sortDragonNode(dragon_cnt)
    local interval = 179
    local vars = self.vars

    -- 테이머 노드 하나 추가
    --local cnt = dragon_cnt + 1
    local cnt = dragon_cnt -- 테이머 제거
    local idx = 0

    if (cnt % 2) == 0 then
        idx = -((cnt / 2) - 0.5)
    else
        idx = -((cnt - 1) / 2)
    end

    local start_x = (idx * interval)

    for i=1, 5 do
        local node = vars['dragonBoard' .. i]
        
        if (i <= cnt) then
            node:setPositionX(start_x)
            start_x = (start_x + interval)    
        else
            node:setVisible(false)
        end
    end
end




-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_GameResultNew:click_backBtn()
    local scene = SceneAdventure()
    scene:runScene()
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResultNew:click_homeBtn()
    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function click_retryBtn
-------------------------------------
function UI_GameResultNew:click_retryBtn()
    -- 현재 g_currScene은 SceneGame이어야 한다
    local stage_name = g_currScene.m_stageName

    local scene = SceneGame(g_currScene.m_stageID, stage_name)
    scene:runScene()
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResultNew:click_nextBtn()
    local scene = SceneAdventure()
    scene:runScene()
end

-------------------------------------
-- function makeRewardItem
-------------------------------------
function UI_GameResultNew:makeRewardItem(i, v)
    local vars = self.vars

    local item_id = v[1]
    local count = v[2]

    local item_card = UI_ItemCard(item_id, 0)
    item_card:setRarityVisibled(true)

    local icon = item_card.root--DropHelper:getItemIconFromIID(item_id)
    vars['rewardNode' .. i]:setVisible(true)
    vars['rewardIconNode' .. i]:addChild(icon)

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    
    vars['rewardLabel' .. i]:setString(t_item['t_name'] .. '\nX ' .. count)

    do -- 상자의 등급에 따라 아이템 카드 프레임 변경
        local lua_name = 'legendSprite'
        if (self.m_boxGrade == 's') then
            lua_name = 'legendSprite'
        elseif (self.m_boxGrade == 'a') then
            lua_name = 'heroSprite'
        elseif (self.m_boxGrade == 'b') then
            lua_name = 'rareSprite'
        elseif (self.m_boxGrade == 'c') then
            lua_name = 'commonSprite'
        end
        item_card.vars[lua_name]:setVisible(true)
    end
end

-------------------------------------
-- function getBoxVisualName
-- @brief
-------------------------------------
function UI_GameResultNew:getBoxVisualName(grade, type)
    local grade_str
    if (grade == 's') then
        grade_str = 'rainbow'
    elseif (grade == 'a') then
        grade_str = 'gold'
    elseif (grade == 'b') then
        grade_str = 'silver'
    elseif (grade == 'c') then
        grade_str = 'wood'
    else
        error('grade : ' .. grade)
    end

    local ret_str = ''
    if (type == 'open') then
        ret_str = string.format('ui_box_%s_open', grade_str)
    elseif (type == 'idle') then
        ret_str = string.format('ui_box_%s_idle', grade_str)
    else
        error('type : ' .. type)
    end

    return ret_str
end
