USER_DATA_VER = '1.2.4'

-------------------------------------
-- class UserData
-------------------------------------
UserData = class({
        m_userData = '',
        m_masterData = '',
        m_cache = '',

        -- 스태미나 관련
        m_staminaList = '',

        m_dataAdventure = 'DataAdventure',
        m_dataDragonList = 'DataDragonList',
        m_dataEvolutionStone = 'DataEvolutionStone',
        m_dataFruit = 'DataFruit',
        m_dataFriendship = 'DataFriendship',

        m_bDirtyLocalSaveData = 'boolean', -- 로컬 세이브 데이터 변경 여부
    })

-------------------------------------
-- function init
-------------------------------------
function UserData:init()
    self.m_cache = {}
    self.m_bDirtyLocalSaveData = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function UserData:getInstance()
    if g_userDataOld then
        return g_userDataOld
    end

    g_userDataOld = UserData()
    g_userDataOld:loadMasterFile()
    g_adventureData = g_userDataOld.m_dataAdventure
    g_dragonListData = g_userDataOld.m_dataDragonList
    g_evolutionStoneData = g_userDataOld.m_dataEvolutionStone
    g_fruitData = g_userDataOld.m_dataFruit
    g_friendshipData = g_userDataOld.m_dataFriendship

    return g_userDataOld
end

-------------------------------------
-- function loadMasterFile
-------------------------------------
function UserData:loadMasterFile()
    local f = io.open(self:getMasterFileName(), 'r')

    if f then
        local content = f:read('*all')

        if #content > 0 then
            self.m_masterData = json.decode(content)
        end
        f:close()
    else
        self.m_masterData = {}

        self.m_masterData['data_cnt'] = 1
        self.m_masterData['data'] = 'user_data_1.json'
        self.m_masterData['data_list'] = {'user_data_1.json'}

        self:saveMasterFile()
    end

    self:loadUserDataFile()


    -- 스태미나 생성
    self.m_staminaList = {}
    for i,v in pairs(self.m_userData['stamina']) do
        local max_stamina = 10
        local charge_time = 300

        if (i == 'st_ad') then
            --local user_lv = self.m_userData['lv']
            --local t_user = TABLE:get('user')[user_lv]
            --max_stamina = t_user['stamina']
            max_stamina = 10
            charge_time = 300
        end
        local t_data = v

        self.m_staminaList[i] = DataStamina(i, v[1], max_stamina, charge_time, v[2], t_data)
    end
end

-------------------------------------
-- function saveMasterFile
-------------------------------------
function UserData:saveMasterFile()
    local f = io.open(self:getMasterFileName(),'w')
    if not f then return false end

    -- cclog(luadump(self.m_data))
    local content = dkjson.encode(self.m_masterData, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function getMasterFileName
-------------------------------------
function UserData:getMasterFileName()
    local file = 'master_file.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end


-------------------------------------
-- function loadUserDataFile
-------------------------------------
function UserData:loadUserDataFile()
    local f = io.open(self:getUserDataFile(), 'r')

    if f then
        local content = f:read('*all')

        if #content > 0 then
            self.m_userData = json.decode(content)
        end
        f:close()

        if (self.m_userData['ver'] ~= USER_DATA_VER) then
            self.m_userData = nil
        end
    end
    
    if (self.m_userData) then
        self:afterLoadUserDataFile()
    else
        self.m_userData = {}

        -- @ 세이브데이터 버전
        self.m_userData['ver'] = USER_DATA_VER

        -- @ 유저 정보
        self.m_userData['lv'] = 1           -- 레벨
        self.m_userData['exp'] = 0          -- 경험치
        self.m_userData['nickname'] = 'dragon'  -- 닉네임

        -- @ 재화 정보
        self.m_userData['gold'] = 5000
        self.m_userData['cash'] = 0

        -- @ 행동력(stamina)
        -- scenario
        -- arena
        self.m_userData['stamina'] = {}
        self.m_userData['stamina']['st_ad'] = {10, os.time()}


        -- @ 모험모드(Adventure)
        self.m_userData['adventure'] = nil -- DataAdventure 클래스에서 초기화

        -- 설정
        self.m_userData['setting'] = {}  

        self:afterLoadUserDataFile()
        self:setDirtyLocalSaveData()
    end
end

-------------------------------------
-- function afterLoadUserDataFile
-------------------------------------
function UserData:afterLoadUserDataFile()
    -- @ 모험모드(Adventure)
    self.m_dataAdventure = DataAdventure(self, self.m_userData)

    self.m_dataDragonList = DataDragonList(self, self.m_userData)

    self.m_dataEvolutionStone = DataEvolutionStone(self, self.m_userData)
    self.m_dataFruit = DataFruit(self, self.m_userData)
    self.m_dataFriendship = DataFriendship(self, self.m_userData)
end

-------------------------------------
-- function getdragonList
-------------------------------------
function UserData:getdragonList()
    local list = {}
    
    for i,v in pairs(self.m_userData['dragon']) do
        table.insert(list, v)
    end

    return list
end

-------------------------------------
-- function saveUserDataFile
-------------------------------------
function UserData:saveUserDataFile()
    local f = io.open(self:getUserDataFile(),'w')
    if not f then return false end

    -- cclog(luadump(self.m_data))
    local content = dkjson.encode(self.m_userData, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function getUserDataFile
-------------------------------------
function UserData:getUserDataFile()
    local file = self.m_masterData['data']
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function update
-------------------------------------
function UserData:update(dt)
    for i,v in pairs(self.m_staminaList) do
        v:update(dt)
    end

    if self.m_bDirtyLocalSaveData then
        self.m_bDirtyLocalSaveData = false
        self:saveUserDataFile()
    end
end

-------------------------------------
-- function setDirtyLocalSaveData
-------------------------------------
function UserData:setDirtyLocalSaveData(immediately)
    if immediately then
        self:saveUserDataFile()
    else
        self.m_bDirtyLocalSaveData = true
    end
end

-------------------------------------
-- function adjustStamina
-------------------------------------
function UserData:adjustStamina()
    for i,v in pairs(self.m_staminaList) do
        v:adjust()

        self.m_userData['stamina'][i][1] = v.m_stamina
        self.m_userData['stamina'][i][2] = v.m_lastChargeTime
    end

    self:setDirtyLocalSaveData()
end

-------------------------------------
-- function useStamina
-------------------------------------
function UserData:useStamina(type, cnt)
    local stamina = self.m_staminaList[type]
    
    if (not stamina) then
        return false
    end

    local success = stamina:useStamina(cnt)
    self:adjustStamina()

    return success
end


-------------------------------------
-- function addCumulativePurchasesLog
-- @biref 누적 구매 로그 추가
-------------------------------------
function UserData:addCumulativePurchasesLog(type, cnt)
    if (not self.m_userData['log']) then
        self.m_userData['log'] = {}
    end

    if (not self.m_userData['log'][type]) then
        self.m_userData['log'][type] = 0
    end

    self.m_userData['log'][type] = self.m_userData['log'][type] + cnt

    self:setDirtyLocalSaveData()
end

-------------------------------------
-- function getCumulativePurchasesLog
-- @biref 누적 구매 로그
-------------------------------------
function UserData:getCumulativePurchasesLog(type)
    if (not self.m_userData['log']) then
        return 0
    end

    if (not self.m_userData['log'][type]) then
        return 0
    end

    return tonumber(self.m_userData['log'][type])
end

-------------------------------------
-- function addTamerExpAtStage
-- @biref 테이머 경험치 추가
-------------------------------------
function UserData:addTamerExpAtStage(stage_id, rate)
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    local add_exp = t_drop and t_drop['tamer_exp'] or 0
    add_exp = math_floor(add_exp * rate)
    local t_ret_data = self:addTamerExp(add_exp)

    return t_ret_data
end

-------------------------------------
-- function addDragonExpAtStage
-- @biref 드래곤 경험치 추가
-------------------------------------
function UserData:addDragonExpAtStage(dragon_id, stage_id, rate)
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]
    local add_exp = t_drop and t_drop['dragon_exp'] or 0
    add_exp = math_floor(add_exp * rate)

    local t_ret_data = self.m_dataDragonList:addDragonExp(dragon_id, add_exp)
    return t_ret_data
end

-------------------------------------
-- function addTamerExp
-- @biref 테이머 경험치 추가
-------------------------------------
function UserData:addTamerExp(add_exp)
    local t_ret_data = {}

    local curr_lv = self.m_userData['lv']
    local curr_exp = self.m_userData['exp']

    t_ret_data['prev_lv'] = self.m_userData['lv']
    t_ret_data['prev_exp'] = self.m_userData['exp']

    local table_exp = TABLE:get('exp_tamer')

    -- 최대레벨 여부
    local is_max_level = false

    -- 실제 증가된 경험치
    local org_add_exp = add_exp
    local real_add_exp = 0

    while true do
        local t_exp = table_exp[curr_lv]

        -- 최대 레벨일 경우
        if (t_exp['exp_t'] == 0) then
            is_max_level = true
            break
        end

        -- 경험치가 없을 경우
        if (add_exp <= 0) then
            break
        end

        local prev_exp = curr_exp
        curr_exp = (curr_exp + add_exp)

        if (t_exp['exp_t'] <= curr_exp) then
            add_exp = curr_exp - t_exp['exp_t']
            curr_lv = curr_lv + 1
            curr_exp = 0
            real_add_exp = real_add_exp + (t_exp['exp_t'] - prev_exp)
        else
            real_add_exp = real_add_exp + add_exp
            add_exp = 0
        end
    end    

    local t_exp = table_exp[curr_lv]

    self.m_userData['lv'] = curr_lv
    self.m_userData['exp'] = curr_exp

    t_ret_data['curr_lv'] = self.m_userData['lv']
    t_ret_data['curr_exp'] = self.m_userData['exp']
    t_ret_data['curr_max_exp'] = t_exp['exp_t']
    t_ret_data['is_max_level'] = is_max_level
    t_ret_data['add_lv'] = (t_ret_data['curr_lv'] - t_ret_data['prev_lv'])
    t_ret_data['add_exp'] = real_add_exp

    -- 레벨업을 했을 경우
    if (0 < t_ret_data['add_lv']) then    
        self.m_staminaList['st_ad']:setMaxStamina(t_exp['stamina'])
    end

    self:setDirtyLocalSaveData()

    return t_ret_data
end

-------------------------------------
-- function initTamer
-- @TEST
-------------------------------------
function UserData:initTamer()
    self.m_userData['lv'] = 1
    self.m_userData['exp'] = 0

    self:setDirtyLocalSaveData(true)
end

-------------------------------------
-- function initTamer
-- @TEST
-------------------------------------
function UserData:levelUpTamer()
    self.m_userData['lv'] = self.m_userData['lv'] + 1
    self.m_userData['exp'] = 0

    self:setDirtyLocalSaveData(true)
end

-------------------------------------
-- function optainItem
-- @brief 아이템을 획득(세이브)
-- @return 실제로 획득한 개수
-------------------------------------
function UserData:optainItem(item_id, count)
    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]

    if (not t_item) then
        error('item_id : ' .. item_id)
    end

    local type = t_item['type']
    local value = t_item['val_1']
    local final_count = 0

    -- 캐시
    if (type == 'cash') then
        local final_count = (value * count)
        self.m_userData['cash'] = self.m_userData['cash'] + final_count

    -- 골드
    elseif (type == 'gold') then
        local final_count = (value * count)
        self.m_userData['gold'] = self.m_userData['gold'] + final_count

    -- 진화석
    elseif (type == 'evolution_stone') then
        local final_count = (value * count)
        self.m_dataEvolutionStone:addEvolutionStone(t_item['rarity'], t_item['attr'], final_count)

    -- 열매
    elseif (type == 'fruit') then
        local final_count = (value * count)
        self.m_dataFruit:addFruit(t_item['rarity'], t_item['attr'], final_count)

    else
        error('item_type : ' .. type)
    end

    if g_topUserInfo then g_topUserInfo:refreshData() end
    self:setDirtyLocalSaveData()
    return final_count
end