-------------------------------------
-- table QuickLinkHelper
-------------------------------------
QuickLinkHelper = {}

local T_LINK_FUNC

-------------------------------------
-- function quickLink
-------------------------------------
function QuickLinkHelper.quickLink(link_type, condition)
    local link_func = T_LINK_FUNC[link_type]
    if (link_func) then
        link_func(condition)
    else
        return false
    end
end

-------------------------------------
-- function possibleLink
-------------------------------------
function QuickLinkHelper.possibleLink(link_type)
    if (T_LINK_FUNC[link_type]) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function gameModeLink
-------------------------------------
function QuickLinkHelper.gameModeLink(game_mode, dungeon_mode, condition)
    local link_type

    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        -- 공통 진화 던전 플레이
        if (dungeon_mode == NEST_DUNGEON_EVO_STONE) then
            link_type = 'ply_ev'

        -- 거목 던전 플레이
        elseif (dungeon_mode == NEST_DUNGEON_TREE) then
            link_type = 'ply_tree'

        -- 악몽 던전 플레이
        elseif (dungeon_mode == NEST_DUNGEON_NIGHTMARE) then
            link_type = 'ply_nm'

        end

    -- 고대의 탑 플레이
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        if (attr) then
            link_type =  'ply_attr_tower'
        else
            link_type =  'ply_tower'
        end

    -- 콜로세움 플레이
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        link_type = 'ply_clsm'

    -- 인연던전 플레이
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        link_type = 'ply_rel'

    -- 클랜던전 플레이
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        link_type = 'ply_cldg'

    -- 모험 모드
    else
        link_type = 'ply_adv'

    end

    -- 바로 가기를 활용한다.
    QuickLinkHelper.quickLink(link_type, condition)
end


T_LINK_FUNC = {
    -- stage clear
    ['clr_stg'] = function(condition)
        local stage_id = condition
        UINavigator:goTo('adventure', stage_id)
    end,

    -- 모험 플레이
    ['ply_adv'] = function()
        UINavigator:goTo('adventure')
    end,

    -- 고대의 탑 플레이
    ['ply_tower'] = function()
        UINavigator:goTo('ancient')
    end,
    
    -- 고대의 탑 클리어
    ['clr_tower'] = function()
        UINavigator:goTo('ancient')
    end,

    -- 시험의 탑 플레이
    ['ply_attr_tower'] = function()
        UINavigator:goTo('attr_tower')
    end,

	-- 시험의 탑 클리어
    ['clr_att_all'] = function()
        UINavigator:goTo('attr_tower')
    end,

    -- 콜로세움 플레이
    ['ply_clsm'] = function()
        UINavigator:goTo('colosseum')
    end,

    -- 콜로세움 {1} 연승
    ['cwin_clsm'] = function()
        UINavigator:goTo('colosseum')
    end,

    -- 공통 진화 던전 플레이
    ['ply_ev'] = function()
        UINavigator:goTo('nest_evo_stone')
    end,

    -- 거목 던전 플레이
    ['ply_tree'] = function()
        UINavigator:goTo('nest_tree')
    end,

    -- 악몽 던전 플레이
    ['ply_nm'] = function()
        UINavigator:goTo('nest_nightmare')
    end,
    
    -- 악몽던전 클리어
    ['clr_nm'] = function()
        UINavigator:goTo('nest_nightmare')
    end,

    -- 탐험 플레이
    ['ply_epl'] = function()
        UINavigator:goTo('exploration')
    end,
    
    -- 인연 던전 플레이
    ['ply_rel'] = function()
        UINavigator:goTo('secret_relation')
    end,

    -- 인연 던전 발견
    ['fnd_rel'] = function()
        UINavigator:goTo('secret_relation')
    end,

    -- 클랜 던전 플레이
    ['ply_cldg'] = function()
        UINavigator:goTo('clan_raid')
    end,

    -- 유저 레벨 달성
    ['u_lv'] = function()
        UINavigator:goTo('adventure')
    end,

    -- 드래곤 레벨 달성
    ['d_lv'] = function()
        UINavigator:goTo('adventure')
    end,

    -- 친구 n명 달성
    ['make_frd'] = function()
        UINavigator:goTo('friend')
    end,
    -- 우정포인트 주고 받기
    ['send_fp'] = function()
        UINavigator:goTo('friend')
    end,
    ['get_fp'] = function()
        UINavigator:goTo('friend')
    end,

    -- 테이머 겟
    ['t_get'] = function()
        UINavigator:goTo('tamer')
    end,
    -- 테이머 스킬 레벨 업
    ['t_sklvup'] = function()
        UINavigator:goTo('tamer')
    end,
    



    -- 룬 장착
    ['r_eq'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,    
    -- 드래곤 성장일지 - 룬 장착
    ['r_eq_s'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'rune', start_dragon)
    end,
    -- 드래곤 성장일지 - 특정 능력치 체크 (룬 장착, 강화쪽 체크)
    ['check_d_stat'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'rune', start_dragon)
    end,

    -- 룬 강화
    ['r_enc'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,
    -- 룬 강화 성공/실패
    ['r_enc_scs'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,
    ['r_enc_fail'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,




    -- 드래곤 스킬 레벨 업
    ['d_sklvup'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,
    -- X 등급 드래곤 스킬레벨업
    ['d_sklvup_r'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,
    ['d_sklvup_h'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,
    ['d_sklvup_l'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,

    -- 드래곤 진화
    ['d_evup'] = function()
        UINavigator:goTo('dragon_manage', 'evolution')
    end,
    -- 진화로 X 드래곤 n종 획득
    ['d_evol_2'] = function()
        UINavigator:goTo('dragon_manage', 'evolution')
    end,
    ['d_evol_3'] = function()
        UINavigator:goTo('dragon_manage', 'evolution')
    end,
    -- 드래곤 성장일지 - 드래곤 진화
    ['d_evup_s'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'evolution', start_dragon)
    end,

    -- 드래곤 레벨업
    ['d_lvup'] = function()
        UINavigator:goTo('dragon_manage', 'level_up')
    end,
    -- 레벨업 재료 사용
    ['d_use_mtrl'] = function()
        UINavigator:goTo('dragon_manage', 'level_up')
    end,

    -- 드래곤 등급업
    ['d_grup'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    -- 승급으로 드래곤 n종 획득
    ['d_grup_4'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    ['d_grup_5'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    ['d_grup_6'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    -- 드래곤 성장일지 - 드래곤 성장일지
    ['d_grup_s'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'grade', start_dragon)
    end,

    -- 드래곤 승급 확인하기
    ['check_grup'] = function()
        UINavigator:goTo('dragon_manage')
    end,

    -- 친밀도 과일 먹임
    ['fruit'] = function()
        UINavigator:goTo('dragon_manage', 'friendship')
    end,
    ['feed'] = function()
        UINavigator:goTo('dragon_manage', 'friendship')
    end,
    -- 친밀도 일심동체 만들기
    ['d_flv_9'] = function()
        UINavigator:goTo('dragon_manage', 'friendship')
    end,
    -- 드래곤 성장일지 - 친밀도 올리기
    ['fr_lvup'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'friendship', start_dragon)
    end,

    -- 작별
    ['goodbye'] = function()
        UINavigator:goTo('dragon_manage')
    end,



    
    -- 알 부화
    ['egg'] = function()
        UINavigator:goTo('hatchery', 'incubate')
    end,
    -- 드래곤 n종 획득
    ['did_u'] = function()
        UINavigator:goTo('hatchery')
    end,
    -- X 속성 드래곤 n종 획득
    ['attr_u_e'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_w'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_f'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_l'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_d'] = function()
        UINavigator:goTo('hatchery')
    end,
    -- X 소환 하기
    ['smn'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['smn_fp'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['smn_rel'] = function()
        UINavigator:goTo('hatchery')
    end,
    -- 조합 하기
    ['comb'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,
    ['comb_120101'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,
    ['comb_120345'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,
    ['comb_120404'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,

    -- 바로가기 키를 띄우지 않을 것들
}