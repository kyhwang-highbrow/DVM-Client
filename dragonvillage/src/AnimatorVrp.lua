-------------------------------------
-- class AnimatorVrp
-------------------------------------
AnimatorVrp = class(Animator, {
    })

-------------------------------------
-- function init
-------------------------------------
function AnimatorVrp:init(file_name)
    if (file_name) then
        local file_name = string.gsub(file_name, '%.vrp', '')

        -- plist 등록
        --cc.SpriteFrameCache:getInstance():addSpriteFrames(file_name .. '.plist')

        -- vrp 생성
        self.m_node = cc.AzVRP:create(file_name .. '.vrp')
        if self.m_node then
            self.m_node:loadPlistFiles('')
            self.m_node:buildSprite('')
        end
        self:changeAni('idle', true, true)
    end

    self.m_type = ANIMATOR_TYPE_VRP
end

-------------------------------------
-- function setSkin
-------------------------------------
function AnimatorVrp:setSkin(skin_name)
    self:setSkinForDragonHeroes(skin_name)
end

-------------------------------------
-- function changeAni
-------------------------------------
function AnimatorVrp:changeAni(animation_name, loop, checking)
    if (not self.m_node) then
        return
    end

    if (not checking) then
        if animation_name then

            -- 앞모습 먼저(임시)
            if not self.m_node:setVisual('group', animation_name .. '_f') then
                if not self.m_node:setVisual('group', animation_name) then
                    if not self.m_node:setVisual('group', 'idle') then
                        self.m_node:setVisual('group', 'idle_f')
                    end
                end
            end
            self.m_node:setRepeat(loop)
        end
        self.m_currAnimation = animation_name
    else
        if animation_name and (self.m_currAnimation ~= animation_name) then

            -- 앞모습 먼저(임시)
            if not self.m_node:setVisual('group', animation_name .. '_f') then
                if not self.m_node:setVisual('group', animation_name) then
                    if not self.m_node:setVisual('group', 'idle') then
                        self.m_node:setVisual('group', 'idle_f')
                    end
                end
            end
            self.m_node:setRepeat(loop)
        end
        self.m_currAnimation = animation_name
    end

    self:addAniHandler(nil)
    self:setEventHandler(nil)

	self.m_aniName = animation_name
end

-------------------------------------
-- function addAniHandler
-------------------------------------
function AnimatorVrp:addAniHandler(cb)
    if cb then
        self.m_node:registerScriptLoopHandler(cb)
    else
        self.m_node:unregisterScriptLoopHandler()
    end
end

-------------------------------------
-- function getVisualList
-------------------------------------
function AnimatorVrp:getVisualList()
    local visual = self.m_node

    local content = visual:getVisualListLuaTable()
    local data = loadstring('return ' .. content)()

    local ret_data = {}
    for i,v in ipairs(data) do
        --[[
        -- 그룹명까지 저장할 경우
        local group = v['group']
        local name = v['name']
        if ret_data[group] == nil then
            ret_data[group] = {}
        end
        ret_data[group][name] = true
        --]]
        local name = v['name']
        table.insert(ret_data, name)
    end

    return ret_data
end

-------------------------------------
-- function getDuration
-------------------------------------
function AnimatorVrp:getDuration()
    if (not self.m_node) then
        return 0
    end

    return self.m_node:getDuration()
end

-------------------------------------
-- function setIgnoreLowEndMode
-------------------------------------
function AnimatorVrp:setIgnoreLowEndMode(ignore)
    if (not self.m_node) then
        return
    end

    self.m_node:setIgnoreLowEndMode(ignore)
end

-------------------------------------
-- function isIgnoreLowEndMode
-------------------------------------
function AnimatorVrp:isIgnoreLowEndMode(ignore)
    if (not self.m_node) then
        return false
    end

    return self.m_node:isIgnoreLowEndMode()
end

-------------------------------------
-- function setTimeScale
-------------------------------------
function AnimatorVrp:setTimeScale(time_scale)
    if (not self.m_node) then
        return false
    end

    return self.m_node:setTimeScale(time_scale)
end

-------------------------------------
-- function getTimeScale
-------------------------------------
function AnimatorVrp:getTimeScale()
    if (not self.m_node) then
        return 1
    end

    return self.m_node:getTimeScale()
end






-------------------------------------
-------------------------------------
-- UI에서 사용될 경우를 위해 함수 추가
-------------------------------------
function AnimatorVrp:setVisual(group, visual)
    return self.m_node:setVisual(group, visual)
end
function AnimatorVrp:registerScriptLoopHandler(func)
    return self.m_node:registerScriptLoopHandler(func)
end
function AnimatorVrp:setRepeat(loop)
    return self.m_node:setRepeat(loop)
end
-------------------------------------
-------------------------------------





-------------------------------------
-- function setSkinForDragonHeroes
-------------------------------------
function AnimatorVrp:setSkinForDragonHeroes(skin_name)
    local grade = tonumber(skin_name) or 6
    local eclv = 0

    local t_parts = {
        'tag_head_01',
        'tag_head_02',
        'tag_face_01',
        'tag_face_02',
        'tag_body_01',
        'tag_body_02',
        'tag_joint_01',
        'tag_joint_02',
        'tag_joint_03',
        'tag_foot_01',
        'tag_foot_02',
        'tag_foot_03',
        'tag_foot_04',
        'tag_leg_01',
        'tag_leg_02',
        'tag_leg_03',
        'tag_leg_04',

        'tag_shoulder_01',
        'tag_shoulder_02',
        'tag_arm_01',
        'tag_arm_02',
        'tag_arm_03',
        'tag_arm_04',
        'tag_hand_01',
        'tag_hand_02',
        'tag_hand_03',
        'tag_hand_04',
        'tag_finger_01',
        'tag_finger_02',
        'tag_finger_03',

        'tag_weapon_01',
        'tag_weapon_02',

        'tag_effect_01',
        'tag_effect_02',
        'tag_effect_03',
        'tag_effect_04',

        'tag_costume_01',
        'tag_costume_02',
        'tag_costume_03',
        'tag_costume_04',
        'tag_costume_05',
        'tag_costume_06',
        'tag_costume_07',
        'tag_costume_08',
        'tag_costume_09',
        'tag_costume_10',
        'tag_costume_11',
        'tag_costume_12',
        'tag_cape_01',
        'tag_cape_02',
        'tag_cape_03',

        'tag_thing_01',
        'tag_thing_02',
        'tag_thing_03',
        'tag_thing_04',
        'tag_thing_05',
        'tag_thing_06',
        'tag_thing_07',
        'tag_thing_08',
        'tag_thing_09',
        'tag_thing_10',
    }

    for i,v in ipairs(t_parts) do
        self:bindVrpForHero(self.m_node, self.m_resName, v, grade, eclv)
    end
end

-------------------------------------
-- function bindVrpForHero
-- @param visual
-- @param res_name
-- @param tag_name
-- @param hero_grade
-------------------------------------
function AnimatorVrp:bindVrpForHero(visual, res_name, tag_name, hero_grade, eclv)
    local debug_log = 'AnimatorVrp:bindVrpForHero() WARNING : '
    local eclv = eclv or 0

    -- 본체 visual
    if not visual then
        cclog(debug_log .. 'visual is nil!')
        return
    end

    -- 파츠 vrp 리소스명(vrp는 본채와 동일하다고 가정)
    if not res_name then
        cclog(debug_log .. 'res_name is nil!')
        return
    end

    -- 본체 visual을 통해 tag가 존재하는지 확인
    if (not tag_name) or (not visual:getSocketNode(tag_name)) then
        --cclog(debug_log .. 'tag_name is nil!')
        return
    end

    -- parts vrp 생성(vrp는 본채와 동일하다고 가정)
    local parts = cc.AzVRP:create(res_name)
    if (not parts) then
        cclog(debug_log .. 'parts is nil!')
        return
    end

    -- sprite 빌드
    parts:buildSprite('')

    --[[
    -- tag명과 등급으로 group명 지정
    local group_name = string.format('%s_0%d', tag_name, hero_grade)

    -- group명이 유효한지 확인
    if not parts:setVisual(group_name) then
        cclog(debug_log .. 'group_name is nil! ' .. group_name)
        return
    end
    --]]

    local t_parts_name = {}
    if eclv > 0 then
        for i=eclv, 1, -1 do
            local tmp = (100 * i)
            table.insert(t_parts_name, tostring(tmp))
        end
    end

    for i=hero_grade, 1, -1 do
        table.insert(t_parts_name, string.format('00%d', i))
    end

    local function setPartsVisual(parts, tag_name, idx)
        local tmp_name = string.format('%s_%s', tag_name, idx)
        return parts:setVisual('tag', tmp_name)
    end

    for i, v in ipairs(t_parts_name) do
        if setPartsVisual(parts, tag_name, v) then
            break
        end
    end

    -- 본체 visual에 parts를 bind
    visual:bindVRP(tag_name, parts)
end