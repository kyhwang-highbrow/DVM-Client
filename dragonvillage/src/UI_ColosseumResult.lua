-------------------------------------
-- class UI_ColosseumResult
-------------------------------------
UI_ColosseumResult = class(UI, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_ColosseumResult:init(is_win, t_data)
    local vars = self:load('colosseum_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ColosseumResult')

    self:initUI(is_win, t_data)
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumResult:initUI(is_win, t_data)
    local vars = self.vars

    if is_win then
        SoundMgr:playBGM('bgm_dungeon_victory', false)    
        vars['victroyNode']:setVisible(true)
        vars['failedNode']:setVisible(false)
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        vars['victroyNode']:setVisible(false)
        vars['failedNode']:setVisible(true)
    end
    
    do -- 테이머
		local t_tamer =  g_tamerData:getCurrTamerTable()

        local tamer_res = t_tamer['res']
		local animator = MakeAnimator(tamer_res)
		if (animator) then
			animator:setAnchorPoint(cc.p(0.5, 0.5))
			animator:setDockPoint(cc.p(0.5, 0.5))
			vars['tamerNode']:addChild(animator.m_node)
		end

		-- 표정 적용
		local face_ani = TableTamer:getTamerFace(t_tamer['type'], is_win)
		animator:changeAni(face_ani, true)
    end

    -- 현재 점수
    local rp = g_colosseumData.m_playerUserInfo.m_rp
    vars['fightScoreLabel']:setString(comma_value(rp))

    -- 획득 점수
    local added_rp_str
    if t_data['added_rp'] >= 0 then
        added_rp_str = Str('+{1}', comma_value(t_data['added_rp']))
    else
        added_rp_str = Str('{1}', comma_value(t_data['added_rp']))
    end
    vars['getScoreLabel']:setString(added_rp_str)

    -- 사용안함
    vars['bonusScoreLabel']:setString('')

    -- 획득 명예
    local added_honor_str
    if t_data['added_honor'] >= 0 then
        added_honor_str = Str('+{1}', comma_value(t_data['added_honor']))
    else
        added_honor_str = Str('{1}', comma_value(t_data['added_honor']))
    end
    vars['honorLabel']:setString(added_honor_str)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumResult:initButton()
    local vars = self.vars
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['retryBtn']:registerScriptTapHandler(function() self:click_retryBtn() end)
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_ColosseumResult:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_exitBtn
-- @brief "나가기" 버튼
-------------------------------------
function UI_ColosseumResult:click_exitBtn()
	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_retryBtn
-- @brief "다시 하기" 버튼
-------------------------------------
function UI_ColosseumResult:click_retryBtn()
    local use_scene = true
    g_colosseumData:goToColosseum(use_scene)
end