local PARENT = UI_DragonManage_Base
local MAX_DRAGON_UPGRADE_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_DragonManagementEvolution
-------------------------------------
UI_DragonManagementEvolution = class(PARENT,{
        m_bChangeDragonList = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManagementEvolution:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManagementEvolution'
    self.m_bVisible = true or false
    self.m_titleStr = Str('진화') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManagementEvolution:init()
    self.m_bChangeDragonList = true

    local vars = self:load('dragon_management_evolution.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManagementEvolution')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManagementEvolution:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManagementEvolution:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManagementEvolution:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 최대 진화도인지 여부
    local is_max_evolution = (t_dragon_data['evolution'] >= MAX_DRAGON_EVOLUTION)

    if is_max_evolution then
        UIManager:toastNotificationGreen(Str('최대 진화단계의 드래곤입니다.'))
    end

    do -- 왼쪽 정보(현재 진화 단계)
        -- 드래곤 이름
        vars['nameLabel']:setString(Str(t_dragon['t_name']))

        -- 진화도 (해치, 해츨링, 성룡)
        local evolution = t_dragon_data['evolution']
        local evolution_name = evolutionName(evolution)
        vars['beforeLabel']:setString(evolution_name)

        do -- 드래곤 리소스
            local evolution = t_dragon_data['evolution']
            vars['beforeNode']:removeAllChildren()
            local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
            animator.m_node:setDockPoint(cc.p(0.5, 0.5))
            animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
            vars['beforeNode']:addChild(animator.m_node)

            animator:changeAni('pose_1', false)
            animator:addAniHandler(function() animator:changeAni('idle', true) end)
        end
    end

    do -- 가운데 정보(다음 진화 단계)
        if is_max_evolution then
            vars['afterLabel']:setString('')
            vars['afterNode']:removeAllChildren()
        else
             -- 진화도 (해치, 해츨링, 성룡)
            local evolution = t_dragon_data['evolution'] + 1
            local evolution_name = evolutionName(evolution)
            vars['afterLabel']:setString(evolution_name)

            do -- 드래곤 리소스
                local evolution = t_dragon_data['evolution'] + 1
                vars['afterNode']:removeAllChildren()
                local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
                animator.m_node:setDockPoint(cc.p(0.5, 0.5))
                animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
                vars['afterNode']:addChild(animator.m_node)

                animator:changeAni('pose_1', false)
                animator:addAniHandler(function() animator:changeAni('idle', true) end)
            end
        end
    end

    do -- 오른쪽 정보(스킬)
        local table_skill = TABLE:get('dragon_skill')
            
        vars['skillNode']:removeAllChildren()
        vars['skillNameLabel']:setString('')
        vars['skillTypeLabel']:setString('')
        vars['skillInfoLabel']:setString('')

        if is_max_evolution then
            
        else
            local evolution = t_dragon_data['evolution'] + 1
            local skill_id = t_dragon['skill_' .. evolution]
            local skill_type = t_dragon['skill_type_' .. evolution]

            if (skill_id == 'x') then
                vars['skillInfoLabel']:setString('스킬이 지정되지 않았습니다.')
            else
                -- 스킬 아이콘
                local icon = UI_SkillCard('dragon', skill_id, skill_type)
                vars['skillNode']:addChild(icon.root)

                -- 스킬 이름
                local str = icon:getSkillNameStr(skill_id)
                vars['skillNameLabel']:setString(str)

                -- 스킬 타입
                local str = icon:getSkillTypeStr(skill_type)
                vars['skillTypeLabel']:setString(str)

                -- 스킬 설명
                local str = icon:getSkillDescStrPure(skill_id, skill_type)
                vars['skillInfoLabel']:setString(str)
            end
        end
    end    
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManagementEvolution:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_DragonManagementEvolution)
