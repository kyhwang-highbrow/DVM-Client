local PARENT = class(UI, ITableViewCell:getCloneTable())

-- ['level']=2;
-- ['dm_id']=3010000;
-- ['reset_unlock']=0;
-- ['condition_stage_id']=3012201;
-- ['start_date']=20213115;
-- ['reset_reward']=1;
-- ['end_date']=29211231;
-- ['type']=2;
-- ['item']='700901;10';
-- ['stage_id']=3012202;
-- ['grade']=2;

----------------------------------------------------------------------
-- class UI_DmgateDifficultyItem
----------------------------------------------------------------------
UI_DmgateDifficultyItem = class(PARENT, {
    m_data = '',

    m_stageID = '',
    m_currDifficultyLevel = '',


    -- nodes in ui file
    m_selectedBtn = '',
    m_stageLabel = '',

    m_defaultStarSprites = '', -- 흑백별
    m_clearedStarSprites = '', -- 노란별
    m_lockSprite = '', -- 자물쇠
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:init(data)
    local vars = self:load('dmgate_scene_stage_item.ui')
    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end


----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:initMember(data)
    local vars = self.vars

    self.m_data = data
    
    self:setStageID(self.m_data['stage_id'])

    -- nodes in ui file
    self.m_selectedBtn = vars['selectedBtn']
    self.m_stageLabel = vars['stageLabel']
    self.m_lockSprite = vars['lockSprite']

    self.m_defaultStarSprites = {}
    table.insert(self.m_defaultStarSprites, vars['noClearSprite1'])
    table.insert(self.m_defaultStarSprites, vars['noClearSprite2'])
    table.insert(self.m_defaultStarSprites, vars['noClearSprite3'])

    self.m_clearedStarSprites = {}
    table.insert(self.m_clearedStarSprites, vars['clearSprite1'])
    table.insert(self.m_clearedStarSprites, vars['clearSprite2'])
    table.insert(self.m_clearedStarSprites, vars['clearSprite3'])
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:initUI()
    self.m_stageLabel:setString(g_dmgateData:getStageDiffText(self.m_stageID))
    self.m_stageLabel:setTextColor(g_dmgateData:getStageDiffTextColor(self.m_stageID))
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:initButton()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:refresh()
    self:refreshStarSprite()
    self:refreshLockSprite()
end

----------------------------------------------------------------------
-- function refreshLockSprite
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:refreshLockSprite()
    local isStageOpened = g_dmgateData:isStageOpened(self.m_stageID) and g_dmgateData:checkStageTime(self.m_stageID)

    self.m_lockSprite:setVisible(not isStageOpened)
    self.m_selectedBtn:setEnabled(isStageOpened)
end

----------------------------------------------------------------------
-- function refreshStarSprite
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:refreshStarSprite()
    local level = self.m_currDifficultyLevel
    local isCleared = g_dmgateData:isStageCleared(self.m_stageID)
    
    for index, starSprite in pairs(self.m_defaultStarSprites) do
       
        if index <= level then
            starSprite:setVisible(true)
        else
            starSprite:setVisible(false)
        end
    end

   
    for index, starSprite in pairs(self.m_clearedStarSprites) do

        if index <= level and isCleared then
            starSprite:setVisible(true)
        else
            starSprite:setVisible(false)
        end
    end
end

----------------------------------------------------------------------
-- function set
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:getStageID()
    return self.m_stageID
end

----------------------------------------------------------------------
-- function set
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:setStageID(stage_id)
    self.m_stageID = stage_id
    self.m_currDifficultyLevel = g_dmgateData:getDifficultyID(self.m_stageID)
end


----------------------------------------------------------------------
-- function is
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:isStageLocked()
    return not self.m_lockSprite:isVisible()
end