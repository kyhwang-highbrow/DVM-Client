local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonUpgradeResult
-------------------------------------
UI_DragonUpgradeResult = class(PARENT,{
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_DragonUpgradeResult:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonUpgradeResult'
    self.m_bVisible = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgradeResult:init(dragon_id)
    local vars = self:load('upgrade_result.ui')
    UIManager:open(self, UIManager.POPUP)

    SoundMgr:playEffect('EFFECT', 'dragon_upgrade')

    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    -- 드래곤의 데이터를 얻어옴
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    do -- 드래곤 에니메이터
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:removeAllChildren()
        vars['dragonNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
    end
    
    do -- 드래곤 이름
        local evolution_lv = t_dragon_data['evolution']
        vars['dragonNameLabel']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(evolution_lv))
    end

    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_res = 'res/ui/star020' .. t_dragon_data['grade'] .. '.png'
        local star_icon = cc.Sprite:create(star_res)
        star_icon:setDockPoint(cc.p(0.5, 0.5))
        star_icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['starNode']:addChild(star_icon)
    end

    self:init_skillInfo(dragon_id)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_DragonUpgradeResult')
end

-------------------------------------
-- function init_skillInfo
-------------------------------------
function UI_DragonUpgradeResult:init_skillInfo(dragon_id)
    local vars = self.vars

    -- 드래곤의 데이터를 얻어옴
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]


    local grade = t_dragon_data['grade']
    local skill_id = t_dragon['skill_' .. grade]
    local skill_type = t_dragon['skill_type_' .. grade]


    local table_skill = TABLE:get('dragon_skill')
    local t_skill = table_skill[skill_id]

    -- 스킬 아이콘
    local icon = UI_SkillCard('dragon', skill_id, skill_type)
    vars['skillNode']:addChild(icon.root)

    -- 스킬 이름
    local str = icon:getSkillName(skill_id, skill_type)
    vars['skillNameLabel']:setString(str)

    -- 스킬 설명
    local str = icon:getSkillDescStrPure(skill_id, skill_type)
    vars['skillInfoLabel']:setString(str)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonUpgradeResult:click_exitBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:close()
end