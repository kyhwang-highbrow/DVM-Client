local PARENT = UI

-------------------------------------
-- class UI_DragonManageUpgradeResult
-------------------------------------
UI_DragonManageUpgradeResult = class(PARENT,{
        m_tDragonData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageUpgradeResult:init(t_dragon_data, t_prev_dragon_data)
    self.m_tDragonData = t_dragon_data

    local vars = self:load('upgrade_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonManageUpgradeResult')

    self:initUI()
    self:initButton()
    self:refresh()

    SoundMgr:playEffect('EFFECT', 'success_starup')

    local function finish_fun()
        UI_DragonSkillLevelUpResult:checkSkillLevelUp(t_prev_dragon_data, t_dragon_data)
    end
    self:sceneFadeInAction(nil, finish_fun, 1)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageUpgradeResult:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonManageUpgradeResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageUpgradeResult:refresh()
    local vars = self.vars

    local t_dragon_data = self.m_tDragonData
    local did = t_dragon_data['did']

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[did]
    
    do -- 드래곤 에니메이터
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator:setScale(1)
        vars['dragonNode']:removeAllChildren()
        vars['dragonNode']:addChild(animator.m_node)
    end

    do -- 등급 별 표시
        vars['starVisual']:changeAni('result' .. t_dragon_data['grade'])
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(Str(t_dragon['t_name']))
    end
    
    vars['skillInfoLabel']:setString('')
    vars['skillNameLabel']:setString('')

    --[[
    do -- 스킬 정보 표시
        local grade = t_dragon_data['evolution']
        local skill_id = t_dragon['skill_' .. evolution]
        local skill_type = t_dragon['skill_type_' .. evolution]

        local table_skill = TABLE:get('dragon_skill')

        if (skill_id == 'x') then
            vars['skillInfoLabel']:setString('')
            vars['skillNameLabel']:setString('스킬이 배정되어있지 않습니다.')
        else
            local t_skill = table_skill[skill_id]

            -- 스킬 아이콘
            local icon = UI_SkillCard('dragon', skill_id, skill_type)
            vars['skillNode']:addChild(icon.root)

            -- 스킬 이름
            local str = icon:getSkillName(skill_id, skill_type)
            vars['skillInfoLabel']:setString(str)

            -- 스킬 설명
            local str = icon:getSkillDescStrPure(skill_id, skill_type)
            vars['skillNameLabel']:setString(str)
        end
    end
    --]]
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonManageUpgradeResult:click_closeBtn()
    local function func()
        self:close()
    end
    self:sceneFadeOutAndCallFunc(func)
end

--@CHECK
UI:checkCompileError(UI_DragonManageUpgradeResult)
