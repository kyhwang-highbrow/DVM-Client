local PARENT = UI

-------------------------------------
-- class UI_SimpleMonsterInfoPopup
-------------------------------------
UI_SimpleMonsterInfoPopup = class(PARENT, {
        m_tMonsterData = 'table',
        m_tableMonster = 'TableMonster',
        m_idx = 'number',
        m_monsterInfoBoardUI = 'UI_MonsterInfoBoard',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SimpleMonsterInfoPopup:init(t_monster_data)
    self.m_tableMonster = TableMonster()
    self.m_tMonsterData = t_monster_data

    local vars = self:load('monster_info_mini.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SimpleMonsterInfoPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SimpleMonsterInfoPopup:initUI()
    local vars = self.vars
    local monster_id = self.m_tMonsterData['mid']

    -- 몬스터 정보 보드 생성
    self.m_monsterInfoBoardUI = UI_MonsterInfoBoard()
    self.vars['rightNode']:addChild(self.m_monsterInfoBoardUI.root)

    local res, attr =  self.m_tableMonster:getMonsterRes(monster_id)
    
    -- 몬스터
    do
        local animator = AnimatorHelper:makeMonsterAnimator(res, attr)
        animator:changeAni('idle', true)
        vars['monsterNode']:addChild(animator.m_node)
    end
    
    -- 배경
    if self:checkVarsKey('attrBgNode', attr) then
        vars['attrBgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['attrBgNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SimpleMonsterInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['prevBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimpleMonsterInfoPopup:refresh()
    local t_monster_data = self.m_tMonsterData
    self.m_monsterInfoBoardUI:refresh(t_monster_data)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SimpleMonsterInfoPopup:click_closeBtn()
    self:close()
end




