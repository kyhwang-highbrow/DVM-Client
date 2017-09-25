-------------------------------------
-- class UI_ColosseumResult
-------------------------------------
UI_ColosseumResult = class(UI, {
        m_isWin = 'boolean',
        m_resultData = '',

        m_workIdx = 'number',
        m_lWorkList = 'list',
     })

local ACTION_MOVE_Y = 700

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_ColosseumResult:init(is_win, t_data)
    self.m_isWin = is_win
    self.m_resultData = t_data

    local vars = self:load('colosseum_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_ColosseumResult')

    self:initUI()
    self:initButton()

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumResult:initUI()
    local vars = self.vars
    vars['resultVisual']:setVisible(false)
    vars['resultMenu']:setVisible(false)
    local ori_y = vars['resultMenu']:getPositionY()
    vars['resultMenu']:setPositionY(ori_y - ACTION_MOVE_Y)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumResult:initButton()
    local vars = self.vars
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_ColosseumResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_showTamer')
    table.insert(self.m_lWorkList, 'direction_hideTamer')
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
    table.insert(self.m_lWorkList, 'direction_masterRoad')
end

-------------------------------------
-- function direction_showTamer
-------------------------------------
function UI_ColosseumResult:direction_showTamer()
    local is_win = self.m_isWin
    local vars = self.vars

	local t_tamer =  g_tamerData:getCurrTamerTable()
    local tamer_node = vars['tamerNode']
    local talk_node = vars['talkLabel']

    local tamer_res = t_tamer['res']
    local animator = MakeAnimator(tamer_res)
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    tamer_node:addChild(animator.m_node)
    tamer_node:setVisible(true)
    talk_node:setVisible(is_win)

	local face_ani = TableTamer:getTamerFace(t_tamer['type'], is_win)
	animator:changeAni(face_ani, true)

    self:doNextWorkWithDelayTime(2.5)
end

-------------------------------------
-- function direction_showTamer_click
-------------------------------------
function UI_ColosseumResult:direction_showTamer_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_ColosseumResult:direction_hideTamer()
    local vars = self.vars
    local tamer_node = vars['tamerNode']
    local hide_act = cc.EaseExponentialOut:create(cc.MoveTo:create(1, cc.p(0, -1000)))
    local after_act = cc.CallFunc:create(function()
		tamer_node:setVisible(false)
        self:doNextWork()
	end)

    tamer_node:runAction(cc.Sequence:create(hide_act, after_act))
end

-------------------------------------
-- function direction_hideTamer_click
-------------------------------------
function UI_ColosseumResult:direction_hideTamer_click()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_ColosseumResult:direction_start()
    local is_win = self.m_isWin
    local vars = self.vars
    local visual_node = vars['resultVisual']
    visual_node:setVisible(true)

    -- 성공 or 실패
    if (is_win == true) then
        SoundMgr:playBGM('bgm_dungeon_victory', false)    
        visual_node:changeAni('victory_appear', false)
        visual_node:addAniHandler(function()
            visual_node:changeAni('victory_idle', true)
        end)
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        visual_node:changeAni('defeat_appear', false)
        visual_node:addAniHandler(function()
            visual_node:changeAni('defeat_idle', true)
        end)
    end

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_start_click
-------------------------------------
function UI_ColosseumResult:direction_start_click()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_ColosseumResult:direction_end()
    local vars = self.vars
    local resultMenu = vars['resultMenu']
    resultMenu:setVisible(true)

    local t_data = self.m_resultData
    local numbering_time = 0.5
    local score_label1 = NumberLabel(vars['scoreLabel1'], 0, numbering_time)
    local score_label2 = vars['scoreLabel2']
    local honer_label1 = NumberLabel(vars['honorLabel1'], 0, numbering_time)
    local honer_label2 = vars['honorLabel2']

    local function compare_func(data, up_arrow, down_arrow, label)
        up_arrow:setVisible(data > 0)
        down_arrow:setVisible(data < 0)

        if (data == 0) then 
            label:setString('') 
        else
            up_arrow:runAction(cc.JumpBy:create(0.3, cc.p(0, 0), 20, 1))
            down_arrow:runAction(cc.JumpBy:create(0.3, cc.p(0, 0), 20, 1))
        end
    end

    local show_act = cc.EaseExponentialOut:create(cc.MoveBy:create(0.3, cc.p(0, ACTION_MOVE_Y)))
    local number_act = cc.CallFunc:create(function()
      
        -- 현재 점수
        local rp = g_colosseumData.m_playerUserInfo.m_rp
        score_label1:setNumber(rp)

        -- 획득 점수
        score_label2:setString(Str('{1}점', comma_value(t_data['added_rp'])))
        compare_func(t_data['added_rp'], vars['scoreArrowSprite1'], vars['scoreArrowSprite2'], score_label2)

        -- 현재 명예
        local honor = g_userData:get('honor')
        honer_label1:setNumber(honor)

        -- 획득 명예
        honer_label2:setString(Str('{1}', comma_value(t_data['added_honor'])))
        compare_func(t_data['added_honor'], vars['honorArrowSprite1'], vars['honorArrowSprite2'], honer_label2)
    end)

    -- 이벤트 아이템 표시
    local event_act = cc.CallFunc:create(function()
        local drop_list = t_data['added_items']['items_list'] or {}
        for _, item in ipairs(drop_list) do
            if (item['from'] == 'event') then
                local cnt = item['count']
                vars['eventNode']:setVisible(true)
                vars['eventLabel']:setString(comma_value(cnt))
                break
            end
        end
    end)

    resultMenu:runAction(cc.Sequence:create(show_act, number_act, event_act))

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_end
-------------------------------------
function UI_ColosseumResult:direction_end_click()
end

-------------------------------------
-- function direction_masterRoad
-------------------------------------
function UI_ColosseumResult:direction_masterRoad()
    -- @ MASTER ROAD
    local t_data = {game_mode = GAME_MODE_COLOSSEUM}
    g_masterRoadData:updateMasterRoad(t_data)

    -- @ GOOGLE ACHIEVEMENT
    GoogleHelper.updateAchievement(t_data)
end

-------------------------------------
-- function direction_masterRoad_click
-------------------------------------
function UI_ColosseumResult:direction_masterRoad_click()
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_ColosseumResult:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function doNextWorkWithDelayTime
-------------------------------------
function UI_ColosseumResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_ColosseumResult:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_ColosseumResult:click_okBtn()
	UINavigator:goTo('colosseum')
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_ColosseumResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end
