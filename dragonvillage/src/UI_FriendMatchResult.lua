-------------------------------------
-- class UI_FriendMatchResult
-------------------------------------
UI_FriendMatchResult = class(UI, {
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
function UI_FriendMatchResult:init(is_win, t_data)
    self.m_isWin = is_win
    self.m_resultData = t_data

    local vars = self:load('colosseum_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_FriendMatchResult')

    self:initUI()
    self:initButton()

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendMatchResult:initUI()
    local vars = self.vars
    vars['resultVisual']:setVisible(false)
    vars['resultMenu']:setVisible(false)
    local ori_y = vars['resultMenu']:getPositionY()
    vars['resultMenu']:setPositionY(ori_y - ACTION_MOVE_Y)
    vars['colosseumNode']:setVisible(false)
    vars['friendshipNode']:setVisible(true)

	-- 이벤트 재화
	vars['eventNode1']:setVisible(false)
    vars['eventNode2']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendMatchResult:initButton()
    local vars = self.vars
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    if (vars['infoBtn']) then
        vars['infoBtn']:registerScriptTapHandler(function() self:click_statusInfo() end)
        vars['infoBtn']:setVisible(true)
    end
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_FriendMatchResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
--    table.insert(self.m_lWorkList, 'direction_showTamer')
--    table.insert(self.m_lWorkList, 'direction_hideTamer')
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
    table.insert(self.m_lWorkList, 'direction_masterRoad')
end

-------------------------------------
-- function direction_showTamer
-------------------------------------
function UI_FriendMatchResult:direction_showTamer()
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
function UI_FriendMatchResult:direction_showTamer_click()
    self:doNextWork()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_FriendMatchResult:direction_hideTamer()
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
function UI_FriendMatchResult:direction_hideTamer_click()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_FriendMatchResult:direction_start()
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
function UI_FriendMatchResult:direction_start_click()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_FriendMatchResult:direction_end()
    local vars = self.vars
    local resultMenu = vars['resultMenu']
    resultMenu:setVisible(true)

    local show_act = cc.EaseExponentialOut:create(cc.MoveBy:create(0.3, cc.p(0, ACTION_MOVE_Y)))
    resultMenu:runAction(show_act)

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_end
-------------------------------------
function UI_FriendMatchResult:direction_end_click()
end

-------------------------------------
-- function direction_masterRoad
-------------------------------------
function UI_FriendMatchResult:direction_masterRoad()
    -- @ MASTER ROAD
    local t_data = {game_mode = GAME_MODE_COLOSSEUM}
    g_masterRoadData:updateMasterRoad(t_data)

    -- @ GOOGLE ACHIEVEMENT
    GoogleHelper.updateAchievement(t_data)
end

-------------------------------------
-- function direction_masterRoad_click
-------------------------------------
function UI_FriendMatchResult:direction_masterRoad_click()
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_FriendMatchResult:doNextWork()
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
function UI_FriendMatchResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_FriendMatchResult:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_statusInfo
-------------------------------------
function UI_FriendMatchResult:click_statusInfo()
    UI_HelpStatus()
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_FriendMatchResult:click_okBtn()
	UINavigator:goTo('friend')
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_FriendMatchResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end
