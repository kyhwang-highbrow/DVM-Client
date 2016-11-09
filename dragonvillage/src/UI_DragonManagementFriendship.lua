local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManagementFriendship
-------------------------------------
UI_DragonManagementFriendship = class(PARENT,{
        m_bChangeDragonList = 'boolean',
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
function UI_DragonManagementFriendship:init()
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_management_friendship.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManagementFriendship')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManagementFriendship:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManagementFriendship:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
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
    self:refresh_dragonFriendshipInfo(t_dragon_data, t_dragon)
end

-------------------------------------
-- function refresh_dragonFriendshipInfo
-- @brief 드래곤 친밀도 정보 (왼쪽 정보)
-------------------------------------
function UI_DragonManagementFriendship:refresh_dragonFriendshipInfo(t_dragon_data, t_dragon)
    local vars = self.vars

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
        vars['expGauge']:setPercentage((cur_exp / req_exp) * 100)
    end

    local table_friendship_variables = TABLE:get('friendship_variables')
    do -- 친밀도에 의한 체력 상승 표시
        local hp_cap = table_friendship_variables['hp_cap']['value']
        local hp_cur = t_dragon_data['hp']

        vars['hpLabel']:setString(Str('{1} / {2}', hp_cur, hp_cap))
        vars['hpGauge']:setPercentage((hp_cur / hp_cap) * 100)
    end

    do -- 친밀도에 의한 방어력 상승 표시
        local def_cap = table_friendship_variables['def_cap']['value']
        local def_cur = t_dragon_data['def']

        vars['defLabel']:setString(Str('{1} / {2}', def_cur, def_cap))
        vars['defGauge']:setPercentage((def_cur / def_cap) * 100)
    end

    do -- 친밀도에 의한 공격력 상승 표시
        local atk_cap = table_friendship_variables['atk_cap']['value']
        local atk_cur = t_dragon_data['atk']

        vars['atkLabel']:setString(Str('{1} / {2}', atk_cur, atk_cap))
        vars['atkGauge']:setPercentage((atk_cur / atk_cap) * 100)
    end

    -- friendshipFxVisual
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManagementFriendship:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonManagementFriendship)
