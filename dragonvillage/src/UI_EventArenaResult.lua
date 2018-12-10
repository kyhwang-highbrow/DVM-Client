-------------------------------------
-- class UI_EventArenaResult
-------------------------------------
UI_EventArenaResult = class(UI, {
        m_isWin = 'boolean',
        m_resultData = '',

        m_workIdx = 'number',
        m_lWorkList = 'list',

        m_autoCount = 'boolean',
     })

local ACTION_MOVE_Y = 700

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_EventArenaResult:init(is_win, t_data)
    self.m_isWin = is_win
    self.m_resultData = t_data
    self.m_autoCount = false

    local vars = self:load('grand_arena_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_EventArenaResult')

    self:initUI()
    self:initButton()

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventArenaResult:initUI()
    local vars = self.vars
    vars['resultVisual']:setVisible(false)
    vars['resultMenu']:setVisible(false)
    local ori_y = vars['resultMenu']:getPositionY()
    vars['resultMenu']:setPositionY(ori_y - ACTION_MOVE_Y)

	vars['colosseumNode']:setVisible(true)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventArenaResult:initButton()
    local vars = self.vars
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    vars['homeBtn']:registerScriptTapHandler(function() self:click_homeBtn() end)
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_EventArenaResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_end')
    table.insert(self.m_lWorkList, 'direction_masterRoad')
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_EventArenaResult:direction_start()
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
function UI_EventArenaResult:direction_start_click()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_EventArenaResult:direction_end()
    local vars = self.vars
    local resultMenu = vars['resultMenu']
    resultMenu:setVisible(true)

    -- 연출 준비
    local t_data = self.m_resultData
    local numbering_time = 0.5
    local score_label1 = NumberLabel(vars['scoreLabel1'], 0, numbering_time)
    local score_label2 = vars['scoreLabel2']
    local gold_label1 = NumberLabel(vars['goldLabel1'], 0, numbering_time)
    local gold_label2 = vars['goldLabel2']

    -- 연출 액션들
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
        local rp = g_grandArena:getPlayerGrandArenaUserInfo().m_rp
        score_label1:setNumber(rp)

        -- 획득 점수
        score_label2:setString(Str('{1}점', comma_value(t_data['added_rp'])))
        compare_func(t_data['added_rp'], vars['scoreArrowSprite1'], vars['scoreArrowSprite2'], score_label2)

        -- 현재 골드
        local gold = g_userData:get('gold')
        gold_label1:setNumber(gold)

        -- 획득 명예
        gold_label2:setString(Str('{1}', comma_value(t_data['added_gold'])))
        compare_func(t_data['added_gold'], vars['goldArrowSprite1'], vars['goldArrowSprite2'], gold_label2)
    end)

    resultMenu:runAction(cc.Sequence:create(show_act, number_act))

    self:doNextWorkWithDelayTime(0.5)
end

-------------------------------------
-- function direction_end
-------------------------------------
function UI_EventArenaResult:direction_end_click()
end


-------------------------------------
-- function direction_masterRoad
-------------------------------------
function UI_EventArenaResult:direction_masterRoad()    
    UI_GameResultNew.checkAutoPlay(self)
end

-------------------------------------
-- function direction_masterRoad_click
-------------------------------------
function UI_EventArenaResult:direction_masterRoad_click()
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_EventArenaResult:doNextWork()
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
function UI_EventArenaResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_EventArenaResult:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_EventArenaResult:click_okBtn()
	UINavigator:goTo('grand_arena')
end

-------------------------------------
-- function click_quickBtn
-- @brief 바로재시작 버튼
-------------------------------------
function UI_EventArenaResult:click_quickBtn()
    local start_func = function()
        self:startGame()
    end

    local cancel_func = function()
        -- 자동 전투 off
        g_autoPlaySetting:setAutoPlay(false)
    end

    -- 콜로세움에선 룬 획득, 드래곤 획득 없으므로 입장권만 체크
    local need_cash = 50 -- 유료 입장 다이아 개수

    -- 기본 입장권 부족시
    if (not g_staminasData:checkStageStamina(ARENA_STAGE_ID)) then
        -- 유료 입장권 체크
        local is_enough, insufficient_num = g_staminasData:hasStaminaCount('arena_ext', 1)
        if (is_enough) then
            is_cash = true
            local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', need_cash)
            MakeSimplePopup_Confirm('cash', need_cash, msg, start_func, cancel_func)

        -- 유료 입장권도 부족시 입장 불가 
        else
            local msg = Str('입장권을 모두 소모하였습니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg, cancel_func)
        end
    else
        is_cash = false
        start_func()
    end
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_EventArenaResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        if (UI_GameResultNew.checkAutoPlayRelease(self)) then return end
        self[func_name](self)
    end
end

-------------------------------------
-- function countAutoPlay
-- @brief 연속 전투일 경우 재시작 하기전 카운트 해줌
-------------------------------------
function UI_EventArenaResult:countAutoPlay()
    UI_GameResultNew.countAutoPlay(self)
end

-------------------------------------
-- function checkAutoPlayCondition
-- @brief 콜로세움 연속 전투 멈추는 조건
-------------------------------------
function UI_EventArenaResult:checkAutoPlayCondition()
    local auto_play_stop = false
    local msg = nil
    
    -- 패배 시 연속 전투 종료
    if g_autoPlaySetting:get('stop_condition_lose') then
        if (self.m_isWin == false) then
            auto_play_stop = true
            msg = Str('패배로 인해 연속 전투가 종료되었습니다.')
        end
    end

	return auto_play_stop, msg
end

-------------------------------------
-- function startGame
-------------------------------------
function UI_EventArenaResult:startGame()
    local function cb(ret)
        -- 시작이 두번 되지 않도록 하기 위함
        UI_BlockPopup()

        -- 연속 전투일 경우 횟수 증가
		if (g_autoPlaySetting:isAutoPlay()) then
			g_autoPlaySetting.m_autoPlayCnt = (g_autoPlaySetting.m_autoPlayCnt + 1)
		end

        local scene = SceneGameArena()
        scene:runScene()
    end

    g_arenaData:request_arenaStart(is_cash, nil, cb)
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_EventArenaResult:click_homeBtn()
	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local block_ui = UI_BlockPopup()

	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end