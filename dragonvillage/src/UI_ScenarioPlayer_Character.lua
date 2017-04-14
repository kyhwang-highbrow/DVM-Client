local T_CHAR_RES = {}
T_CHAR_RES['queenssnake'] = 134011
T_CHAR_RES['owl'] = 131031
T_CHAR_RES['drak_robe'] = 132062
T_CHAR_RES['drak_robe_executive'] = 132062

local T_TAMER_I_RES = {}
T_TAMER_I_RES['dale_i'] = 'res/character/tamer/dale_i/dale_i.spine'


-------------------------------------
-- class UI_ScenarioPlayer_Character
-------------------------------------
UI_ScenarioPlayer_Character = class({
        m_posName = 'string',

        m_charKey = '',
        m_charAnimator = 'Animator',

        m_bCharFlip = '',

        m_charNode = '',
        m_charNameNode = '',
        m_charNameLabel = '',
        m_charTalkSprite = '',
        m_charTalkLabel = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioPlayer_Character:init(pos_name, char_node, name_node, name_label, talk_sprite, talk_label)
    self.m_posName = pos_name

    self.m_charNode = char_node
    self.m_charNameNode = name_node
    self.m_charNameLabel = name_label
    self.m_charTalkSprite = talk_sprite
    self.m_charTalkLabel = talk_label

    self.m_bCharFlip = false
end

-------------------------------------
-- function hide
-------------------------------------
function UI_ScenarioPlayer_Character:hide(duration)
    if (not duration) then
        self.m_charNode:setVisible(false)
        self.m_charNameNode:setVisible(false)
        self.m_charNameLabel:setVisible(false)
        self.m_charTalkSprite:setVisible(false)
        self.m_charTalkLabel:setVisible(false)
    end
end

-------------------------------------
-- function show
-------------------------------------
function UI_ScenarioPlayer_Character:show(duration)
    if (not duration) then
        self.m_charNode:setVisible(true)
        self.m_charNameNode:setVisible(true)
        self.m_charNameLabel:setVisible(true)
        self.m_charTalkSprite:setVisible(true)
        self.m_charTalkLabel:setVisible(true)
    end
end

-------------------------------------
-- function getCharacterResType
-------------------------------------
function UI_ScenarioPlayer_Character:getCharacterResType(key)
    
end

-------------------------------------
-- function setCharacter
-------------------------------------
function UI_ScenarioPlayer_Character:setCharacter(key)
   if (self.m_charKey == key) then
        return
   end

   self.m_charKey = key

   if (self.m_charAnimator) then
    self.m_charAnimator:release()
   end

    key = tostring(key)
    
    if T_CHAR_RES[key] then
        self.m_charAnimator = MakeAnimator(res)
        self.m_charAnimator:setAlpha(0)
        self.m_charAnimator:runAction(cc.FadeIn:create(0.3))
        self.m_charNode:addChild(self.m_charAnimator.m_node)
        self.m_charAnimator:setPositionY(200)

        self.m_charAnimator:setFlip(self.m_bCharFlip)

        self:show()
    end



    local is_number = false
    do       
        local temp = string.match(key, '%d+[.]?%d*')
        if temp then
            temp = tostring(tonumber(key))
        end
        ccdump(temp)
        if (key == temp) then
            is_number = true
        end
    end

    if is_number then
        local monster_id = tonumber(key)
        local res, attr = TableMonster:getMonsterRes(monster_id)
        self.m_charAnimator = AnimatorHelper:makeMonsterAnimator(res, attr)
        self.m_charAnimator:setAlpha(0)
        self.m_charAnimator:runAction(cc.FadeIn:create(0.3))
        self.m_charNode:addChild(self.m_charAnimator.m_node)
        self.m_charAnimator:setPositionY(200)
        self.m_charAnimator:setScale(1.3)
    else
        local res = string.format('res/character/tamer/%s/%s.spine', key, key)
        self.m_charAnimator = MakeAnimator(res)
        self.m_charAnimator:setAlpha(0)
        self.m_charAnimator:runAction(cc.FadeIn:create(0.3))
        self.m_charNode:addChild(self.m_charAnimator.m_node)
    end




   self.m_charAnimator:setFlip(self.m_bCharFlip)

   self:show()
end

-------------------------------------
-- function setCharText
-------------------------------------
function UI_ScenarioPlayer_Character:setCharText(text)
    self.m_charTalkSprite:setVisible(true)
    self.m_charTalkSprite:stopAllActions()
    cca.uiReaction(self.m_charTalkSprite)
    self.m_charTalkLabel:setVisible(true)
    self.m_charTalkLabel:setString(text)
end

-------------------------------------
-- function hideCharText
-------------------------------------
function UI_ScenarioPlayer_Character:hideCharText()
    self.m_charTalkSprite:setVisible(false)
    self.m_charTalkLabel:setVisible(false)
end

-------------------------------------
-- function setCharName
-------------------------------------
function UI_ScenarioPlayer_Character:setCharName(name)
    self.m_charNameLabel:setString(name)
end