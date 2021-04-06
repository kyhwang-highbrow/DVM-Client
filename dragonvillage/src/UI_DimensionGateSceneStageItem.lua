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
-- class UI_DimensionGateSceneStageItem
----------------------------------------------------------------------
UI_DimensionGateSceneStageItem = class(PARENT, {
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
function UI_DimensionGateSceneStageItem:init(data)
    local vars = self:load('dmgate_scene_stage_item.ui')
    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end


----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DimensionGateSceneStageItem:initMember(data)
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
function UI_DimensionGateSceneStageItem:initUI()
    self.m_stageLabel:setString(g_dimensionGateData:getStageDiffText(self.m_stageID))
    self.m_stageLabel:setTextColor(g_dimensionGateData:getStageDiffTextColor(self.m_stageID))
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DimensionGateSceneStageItem:initButton()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DimensionGateSceneStageItem:refresh()
    self:refreshStarSprite()
    self:refreshLockSprite()
end

----------------------------------------------------------------------
-- function refreshLockSprite
----------------------------------------------------------------------
function UI_DimensionGateSceneStageItem:refreshLockSprite()
    local isStageOpened = g_dimensionGateData:isStageOpened(self.m_stageID) and g_dimensionGateData:checkStageTime(self.m_stageID)

    self.m_lockSprite:setVisible(not isStageOpened)
    self.m_selectedBtn:setEnabled(isStageOpened)
end

----------------------------------------------------------------------
-- function refreshStarSprite
----------------------------------------------------------------------
function UI_DimensionGateSceneStageItem:refreshStarSprite()
    local level = self.m_currDifficultyLevel
    local isCleared = g_dimensionGateData:isStageCleared(self.m_stageID)
    
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
function UI_DimensionGateSceneStageItem:getStageID()
    return self.m_stageID
end

----------------------------------------------------------------------
-- function set
----------------------------------------------------------------------
function UI_DimensionGateSceneStageItem:setStageID(stage_id)
    self.m_stageID = stage_id
    self.m_currDifficultyLevel = g_dimensionGateData:getDifficultyID(self.m_stageID)
end