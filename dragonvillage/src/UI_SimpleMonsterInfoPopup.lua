local PARENT = UI

-------------------------------------
-- class UI_SimpleMonsterInfoPopup
-------------------------------------
UI_SimpleMonsterInfoPopup = class(PARENT, {
        m_nMonsterLv = 'number',
        m_tMonsterData = 'table',
        m_idx = 'number',
        m_monsterInfoBoardUI = 'UI_MonsterInfoBoard',
        m_bDragonMonster = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SimpleMonsterInfoPopup:init(monster_id, monster_lv)
    local t_monster, is_dragon = TableMonster():getMonsterInfoWithDragon(monster_id)
    self.m_nMonsterLv = monster_lv
    self.m_tMonsterData = t_monster
    self.m_bDragonMonster = is_dragon 

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
    local monster_id = (self.m_bDragonMonster) and  self.m_tMonsterData['did'] or  self.m_tMonsterData['mid']

    -- 몬스터 정보 보드 생성
    self.m_monsterInfoBoardUI = UI_MonsterInfoBoard(self)
    self.vars['infoMenu']:addChild(self.m_monsterInfoBoardUI.root)

    local res =  (self.m_bDragonMonster) and TableDragon():getDragonRes(monster_id)
                                         or TableMonster():getMonsterRes(monster_id)

    local attr = (self.m_bDragonMonster) and TableDragon():getDragonAttr(monster_id)
                                         or TableMonster():getValue(monster_id, 'attr')
 
    -- 몬스터
    do
        local animator = (self.m_bDragonMonster) and AnimatorHelper:makeDragonAnimator_usingDid(monster_id, 3)
                                                 or AnimatorHelper:makeMonsterAnimator(res, attr)
        animator:changeAni('idle', true)
        vars['monsterNode']:addChild(animator.m_node)

        -- 도굴꾼 싸이즈 임시로 0.5 미래에는 몬스터 스케일 조정 가능하게 뭔가 조치를 취해야 한다
        if (138000 <= monster_id) and (monster_id < 139000) then
            animator.m_node:setScale(0.5)
        end
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




