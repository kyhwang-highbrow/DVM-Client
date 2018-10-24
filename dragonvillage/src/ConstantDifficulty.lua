DIFFICULTY = {}

-------------------------------------
-- function init
-- @breif 난이도 초기화
-------------------------------------
function DIFFICULTY:init()
    -- param : num, str, text, color
    self:addDifficultyInfo(0, 'easy', Str('쉬움'), COLOR['diff_easy'])
    self:addDifficultyInfo(1, 'normal', Str('보통'), COLOR['diff_normal'])
    self:addDifficultyInfo(2, 'hard', Str('어려움'), COLOR['diff_hard'])
    self:addDifficultyInfo(3, 'hell', Str('지옥'), COLOR['diff_hel'])

    -- enum
    DIFFICULTY.EASY = 0
    DIFFICULTY.NORMAL = 1
    DIFFICULTY.HARD = 2
    DIFFICULTY.HEL = 3
end

-------------------------------------
-- function addDifficultyInfo
-------------------------------------
function DIFFICULTY:addDifficultyInfo(num, str, text, color)
    local t_data = {}
    t_data['number'] = num
    t_data['string'] = str
    t_data['text'] = text
    t_data['color'] = color

    if (not self.m_lDifficultyInfo) then
        self.m_lDifficultyInfo = {}
    end

    self.m_lDifficultyInfo[num] = t_data
end

-------------------------------------
-- function getInfo
-------------------------------------
function DIFFICULTY:getInfo(difficulty)
    local _type = type(difficulty)

    if (_type == 'number') then
        return self.m_lDifficultyInfo[difficulty]

    elseif (_type == 'string') then
        for i,v in pairs(self.m_lDifficultyInfo) do
            if (v['string'] == difficulty) then
                return v
            end
        end

    else
        error()
    end

    return nil
end

-------------------------------------
-- function getStr
-------------------------------------
function DIFFICULTY:getStr(difficulty)
    local ret = nil
    local t_info = self:getInfo(difficulty)
    if t_info then
        ret = t_info['string']
    end

    return ret or nil
end

-------------------------------------
-- function getNum
-------------------------------------
function DIFFICULTY:getNum(difficulty)
    local ret = nil
    local t_info = self:getInfo(difficulty)
    if t_info then
        ret = t_info['number']
    end

    return ret or nil
end

-------------------------------------
-- function getText
-------------------------------------
function DIFFICULTY:getText(difficulty)
    local ret = nil
    local t_info = self:getInfo(difficulty)
    if t_info then
        ret = t_info['text']
    end

    return ret or 'none'
end

-------------------------------------
-- function getColor
-------------------------------------
function DIFFICULTY:getColor(difficulty)
    local ret = nil
    local t_info = self:getInfo(difficulty)
    if t_info then
        ret = t_info['color']
    end

    return ret or cc.c4b(255, 255, 255, 255)
end


DIFFICULTY:init()