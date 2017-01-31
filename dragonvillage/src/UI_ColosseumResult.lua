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
function UI_ColosseumResult:init(is_win)
    local vars = self:load('colosseum_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ColosseumResult')

    self:initUI(is_win)
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumResult:initUI(is_win)
    local vars = self.vars

    if is_win then
        vars['victroyNode']:setVisible(true)
        vars['failedNode']:setVisible(false)
    else
        vars['victroyNode']:setVisible(false)
        vars['failedNode']:setVisible(true)
    end
    
    do -- 테이머
        local animator = MakeAnimator('res/character/tamer/goni_i/goni_i.spine')
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:setDockPoint(cc.p(0.5, 0.5))
        vars['tamerNode']:addChild(animator.m_node)
    end

    vars['fightScoreLabel']:setString('')
    vars['getScoreLabel']:setString('')
    vars['bonusScoreLabel']:setString('')
    vars['honorLabel']:setString('')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumResult:initButton()
    local vars = self.vars
    vars['exitBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['retryBtn']:registerScriptTapHandler(function() self:click_retryBtn() end)
    vars['fastStartBtn']:registerScriptTapHandler(function() self:click_fastStartBtn() end)
end

-------------------------------------
-- function click_exitBtn
-- @brief "나가기" 버튼
-------------------------------------
function UI_ColosseumResult:click_exitBtn()
    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function click_retryBtn
-- @brief "다시 하기" 버튼
-------------------------------------
function UI_ColosseumResult:click_retryBtn()
    g_colosseumData:goToColosseumScene()
end


-------------------------------------
-- function click_fastStartBtn
-- @brief "빠른 시작" 버튼
-------------------------------------
function UI_ColosseumResult:click_fastStartBtn()
    local function cb(ret)
        local scene = SceneGameColosseum()
        scene:runScene()
    end

    g_colosseumData:request_colosseumStart(cb)
end
