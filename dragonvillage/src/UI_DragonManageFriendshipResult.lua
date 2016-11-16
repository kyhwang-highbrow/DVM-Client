local PARENT = UI

-------------------------------------
-- class UI_DragonManageFriendshipResult
-------------------------------------
UI_DragonManageFriendshipResult = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageFriendshipResult:init(grade, t_prev_dragon_data, t_curr_dragon_data)
    local vars = self:load('dragon_management_friendship_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageFriendshipResult')

    self:initUI(grade, t_prev_dragon_data, t_curr_dragon_data)
    self:initButton()
    self:refresh()

    SoundMgr:playEffect('EFFECT', 'success_friendship')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageFriendshipResult:initUI(grade, t_prev_dragon_data, t_curr_dragon_data)
    local vars = self.vars

    local t_dragon_data = t_curr_dragon_data

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

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

        do -- 친밀도 경험치 표시
        local req_exp = t_friendship['req_exp']
        local cur_exp = fexp

        vars['expLabel']:setString(Str('{1} / {2}', cur_exp, req_exp))
        vars['expGauge']:setPercentage((cur_exp / req_exp) * 100)
    end

    local table_friendship_variables = TABLE:get('friendship_variables')
    do -- 친밀도에 의한 체력 상승 표시
        local hp_cap = table_friendship_variables['hp_cap']['value']
        local hp_cur = t_dragon_data['hp']

        vars['hpLabel']:setString('+ ' .. comma_value(hp_cur - t_prev_dragon_data['hp']))
        vars['hpGauge']:setPercentage((hp_cur / hp_cap) * 100)
    end

    do -- 친밀도에 의한 방어력 상승 표시
        local def_cap = table_friendship_variables['def_cap']['value']
        local def_cur = t_dragon_data['def']

        vars['defLabel']:setString('+ ' .. comma_value(def_cur - t_prev_dragon_data['def']))
        vars['defGauge']:setPercentage((def_cur / def_cap) * 100)
    end

    do -- 친밀도에 의한 공격력 상승 표시
        local atk_cap = table_friendship_variables['atk_cap']['value']
        local atk_cur = t_dragon_data['atk']

        vars['atkLabel']:setString('+ ' .. comma_value(atk_cur - t_prev_dragon_data['atk']))
        vars['atkGauge']:setPercentage((atk_cur / atk_cap) * 100)
    end

    -- 비주얼 연출
    vars['rankVisual']:setVisible(true)
    vars['rankVisual']:changeAni('rank_' .. grade, false)

    -- 비주얼 연출
    vars['frindshipFxVisual']:setVisible(true)
    vars['frindshipFxVisual']:changeAni('friendship_fx', false)

    vars['rankUpVisual']:setVisible(true)
    vars['rankUpVisual']:changeAni('friendship_up', false)
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonManageFriendshipResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageFriendshipResult:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonManageFriendshipResult)
