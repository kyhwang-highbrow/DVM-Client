AnimatorHelper = {}

-------------------------------------
-- function makeDragonAnimator
-------------------------------------
function AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)

	local res_name = self:getDragonResName(res_name, evolution, attr)
	local animator

    -- 드래곤의 경우는 추후 적용
    if (self:isIntegratedSpineResName(res_name)) then
        animator = MakeAnimatorSpineToIntegrated(res_name)
    else
        animator = MakeAnimator(res_name)
    end

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/godaeshinryong_light_03/godaeshinryong_light_03.spine')
        animator:setColor(cc.c3b(0, 0, 0))
    end

    if animator then
        animator.m_node:setMix('idle', 'attack', 0.1)
        animator.m_node:setMix('idle', 'idle', 0.1)
        animator.m_node:setMix('idle', 'skill_appear', 0.5)
        animator.m_node:setMix('attack', 'skill_appear', 0.5)
        
        animator.m_node:setMix('skill_appear', 'idle', 0.2)
        animator.m_node:setMix('skill_appear', 'skill_idle', 0.2)
        animator.m_node:setMix('idle', 'skill_idle', 0.2)
        animator.m_node:setMix('attack', 'skill_idle', 0.2)

        animator.m_node:setMix('skill_disappear', 'idle', 0.5)

        animator.m_node:setMix('pose_1', 'idle', 0.2)
        animator.m_node:setMix('idle', 'pose_1', 0.2)
    end

    return animator
end

-------------------------------------
-- function makeDragonAnimatorByTransform
-------------------------------------
function AnimatorHelper:makeDragonAnimatorByTransform(struct_dragon_data)
    local did = struct_dragon_data['did']
    local evolution = struct_dragon_data['evolution']
    local is_slime = TableSlime:isSlimeID(did)

    local t_dragon
    if is_slime then
        t_dragon = TableSlime():get(did)
    else
        t_dragon = TableDragon():get(did)
    end
    
    local res_name = t_dragon['res']
    local attr = t_dragon['attr']

    if struct_dragon_data['dragon_skin'] ~= nil and struct_dragon_data['dragon_skin'] ~= 0 then
        local skin_id = struct_dragon_data['dragon_skin']
        local skin_res = TableDragonSkin:getDragonSkinValue('res', skin_id)
        local skin_attribute = TableDragonSkin:getDragonSkinValue('attribute', skin_id)

        res_name = skin_res
        attr = skin_attribute
    end

    -- 성체부터 외형변환 적용
    if (evolution == POSSIBLE_TRANSFORM_CHANGE_EVO) then
        evolution = struct_dragon_data['transform'] or evolution
    end

    return self:makeDragonAnimator(res_name, evolution, attr)
end

-------------------------------------
-- function makeDragonAnimator_usingDid
-------------------------------------
function AnimatorHelper:makeDragonAnimator_usingDid(did, evolution)
    local t_dragon = TableDragon():get(did)
    local evolution = evolution or 3
    return AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
end

-------------------------------------
-- function makeTamerAnimator
-------------------------------------
function AnimatorHelper:makeTamerAnimator(res_name)
    local animator = MakeAnimator(res_name)

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/developing_dragon/developing_dragon.spine')
    end

    if animator then
        animator.m_node:setMix('idle', 'attack', 0.1)
        animator.m_node:setMix('idle', 'idle', 0.1)
        animator.m_node:setMix('idle', 'skill_appear', 0.5)
        animator.m_node:setMix('attack', 'skill_appear', 0.5)

        animator.m_node:setMix('skill_appear', 'skill_idle', 0.2)
        animator.m_node:setMix('idle', 'skill_idle', 0.2)
        animator.m_node:setMix('attack', 'skill_idle', 0.2)

        -- 테이머가 사용함
        animator.m_node:setMix('idle', 'summon', 0.2)
        animator.m_node:setMix('summon', 'idle', 0.2)
    end

    return animator
end

-------------------------------------
-- function makeMonsterAnimator
-------------------------------------
function AnimatorHelper:makeMonsterAnimator(res_name, attr, evolution)

    local res_name = self:getMonsterResName(res_name, attr, evolution)
    local animator

    if (self:isIntegratedSpineResName(res_name)) then
        animator = MakeAnimatorSpineToIntegrated(res_name)
    else
        animator = MakeAnimator(res_name)
    end

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/developing_dragon/developing_dragon.spine')
    end

    if animator then
        animator.m_node:setMix('idle', 'attack', 0.1)
        animator.m_node:setMix('idle', 'idle', 0.1)
        animator.m_node:setMix('attack', 'idle', 0.1)
    end

    return animator
end

-------------------------------------
-- function makeSummonCreatureAnimator
-------------------------------------
function AnimatorHelper:makeSummonCreatureAnimator(res_name, attr, evolution)

    local res_name = self:getMonsterResName(res_name, attr, evolution)
    local animator

    if (self:isIntegratedSpineResName(res_name)) then
        animator = MakeAnimatorSpineToIntegrated(res_name)
    else
        animator = MakeAnimator(res_name)
    end

    if (not animator.m_node) then
        animator = MakeAnimator('res/character/dragon/developing_dragon/developing_dragon.spine')
    end

    if animator then
        animator.m_node:setMix('idle', 'attack', 0.1)
        animator.m_node:setMix('idle', 'idle', 0.1)
        animator.m_node:setMix('attack', 'idle', 0.1)


        animator.m_node:setMix('idle', 'die_appear', 0.5)
        animator.m_node:setMix('die_appear', 'die_idle', 0.5)
        animator.m_node:setMix('die_idle', 'idle', 0.5)
    end

    return animator
end

-------------------------------------
-- function getDragonResName
-------------------------------------
function AnimatorHelper:getDragonResName(res_name, evolution, attr)
	local res_name = res_name
	
	if evolution then 
		res_name = string.gsub(res_name, '#', '0' .. evolution)
	end
	if attr then 
		res_name = string.gsub(res_name, '@', attr)
	end
    
    res_name = string.gsub(res_name, '!', 'all')

    return res_name
end

-------------------------------------
-- function getMonsterResName
-------------------------------------
function AnimatorHelper:getMonsterResName(res_name, attr, evolution)
	if evolution then 
		res_name = string.gsub(res_name, '#', '0' .. evolution)
	end
    local res_name = string.gsub(res_name, '@', attr)

    res_name = string.gsub(res_name, '!', 'all')

    return res_name
end

-------------------------------------
-- function getTitleAnimator
-- @brief 언어별 타이틀 애니를 생성한다
-------------------------------------
function AnimatorHelper:isSameDate(month, day)
    local cur_month = os.date("%m")
    local cur_day = os.date("%d")

    if (month == cur_month and day == cur_day) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getTitleAnimator
-- @brief 언어별 타이틀 애니를 생성한다
-------------------------------------
function AnimatorHelper:getTitleAnimator(is_first_enter)
	local lang = g_localData:getLang()

	local res
	if (lang == 'ja') then
		res = 'res/ui/spine/title_ja/title_ja.spine'
	elseif (lang == 'zh') then
		res = 'res/ui/spine/title_zh/title_zh.spine'
	elseif (lang == 'th') then
		res = 'res/ui/spine/title_th/title_th.spine'
	elseif (lang == 'es') then
		res = 'res/ui/spine/title_es/title_es.spine'
	else
        if (self:isSameDate('04', '01') and not is_first_enter) then
            res = 'res/ui/spine/title_april_fool/title.spine'
        else
            res = 'res/ui/spine/title/title.spine'
        end
	end

	local animator = MakeAnimator(res)

    -- 2018.08.24 sgkim 추가 해상도 대응
    -- 18.5:9 (삼성 갤럭시 등), 18:9 (LG, Pexel2XL), 19.5:9 (iPhoneX)
    -- 드빌M의 타이틀 이미지가 1280 * 960으로 제작되어 불가피하게 하드코딩
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local scale = visibleSize.width/1280
    if (scale > 1) then
	    animator:setScale(scale)
	    animator:setPositionY(-30)
    end

	return animator
end


-------------------------------------
-- function isIntegratedSpineResName
-- @brief 하나의 json으로 모든 속성이 공유되는 형태의 spine 리소스인지 검증
-------------------------------------
function AnimatorHelper:isIntegratedSpineResName(res_name)
    -- ex) res_name = res/character/dragon/gale_all_03/gale_earth_03.spine
    local path, file_name, extension = string.match(res_name, "(.-)([^//]-)(%.[^%.]+)$")
    if (pl.stringx.endswith(path, '_all/') or string.find(path, '_all_')) then
        return true
    end

    return false
end