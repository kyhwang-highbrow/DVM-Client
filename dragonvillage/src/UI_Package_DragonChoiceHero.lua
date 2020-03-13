local PARENT = UI_Package_Bundle

-------------------------------------
-- class UI_Package_DragonChoiceHero
-------------------------------------
UI_Package_DragonChoiceHero = class(PARENT,{
        m_recommendUI = '',
    })


-------------------------------------
-- function init
-- @param package_name (string) : package_dragon_choice_hero
-- @param is_popup (boolean)
-------------------------------------
function UI_Package_DragonChoiceHero:init(package_name, is_popup)
    -- 부모 클래스 init에서 package_dragon_choice_hero.self.m_recommendUI파일을 생성함

    self:createRecommendUI()

    local vars = self.vars
    if vars['infoBtn'] then
        vars['infoBtn']:registerScriptTapHandler(function() self:createRecommendUI() end)
    end
end

-------------------------------------
-- function createRecommendUI
-------------------------------------
function UI_Package_DragonChoiceHero:createRecommendUI()
    if self.m_recommendUI then
        return
    end

    self.m_recommendUI = UI()
    self.m_recommendUI:load('package_dragon_choice_hero_popup.ui')
    self.root:addChild(self.m_recommendUI.root)
    local vars = self.m_recommendUI.vars

    do
        require('TableDragonRecommend')
        local t_dragon_recommend = TableDragonRecommend:getRecommendHeroDragonData()
        if (not t_dragon_recommend) then
            return
        end
        local did = t_dragon_recommend['did']
        local dragon_animator = UIC_DragonAnimator()

        dragon_animator:setDragonAnimator(did, 3) -- did, evolution, flv
        dragon_animator:setTalkEnable(false)
        --dragon_animator:setIdle()
        vars['dragonNode']:addChild(dragon_animator.m_node)

        local table_dragon = TableDragon()
        local attr = table_dragon:getDragonAttr(did)
        local role = table_dragon:getDragonRole(did)
        local rarity = table_dragon:getDragonRarity(did)

        local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role, rarity)

        do -- 희귀도 
            vars['rarityNode']:removeAllChildren()
            DragonInfoIconHelper.setDragonRarityBtn(rarity, vars['rarityNode'], vars['rarityLabel'], t_info)
        end

        do -- 드래곤 속성
            vars['attrNode']:removeAllChildren()
            DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
        end

        do -- 드래곤 역할(role)
            vars['typeNode']:removeAllChildren()
            DragonInfoIconHelper.setDragonRoleBtn(role, vars['typeNode'], vars['typeLabel'], t_info)
        end

        -- 드래곤 이름
        if vars['dragonNameLabel'] then
            local dragon_name = table_dragon:getDragonName(did)
            vars['dragonNameLabel']:setString(dragon_name)
        end

        -- 드래곤 설명
        if vars['characterdLabel'] then
            vars['characterdLabel']:setString(Str(t_dragon_recommend['t_desc']))
        end
    end

    local function func_close()
        if (not self.m_recommendUI) then
            return
        end
        self.m_recommendUI.root:removeFromParent()
        self.m_recommendUI = nil
    end

    local function func_click_close()
        if (not self.m_recommendUI) then
            return
        end

        self.m_recommendUI:doActionReverse(func_close)
    end

    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(func_click_close)
    end
    if vars['okBtn'] then
        vars['okBtn']:registerScriptTapHandler(func_click_close)
    end
    self.m_recommendUI:doActionReset()
    self.m_recommendUI:doAction()
end