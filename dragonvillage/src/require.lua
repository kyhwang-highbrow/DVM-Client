local t_module = {
    'Cocos2d',
    'Cocos2dConstants',
    'lib/net',
    'lib/class',
    'lib/utils',
    'lib/StringUtils',
    'lib/Translate',
    'lib/scheduler',
    'lib/SocketTCP',
    'lib/math',
    'lib/Radian',
    'uilib/UIManager',
    'uilib/UI',
    'uilib/UILoader',
    'uilib/TableView',
    'uilib/Notification',
    'perpleLib/StringUtils',
    'perpleLib/sn',
    'perpleLib/crand',
    'perpleLib/PerpleScene',
    'perpleLib/PerpleScene',
    'fixed_constant',
    'Constant',
    'ConstantForArt',
    'ConstantDragonEvolution',
    'ConstantDragonGrade',
    'ConstantAttribute',
    'ConstantString',
    'SoundMgr',
    'SoundMgrController',
    'SoundMgrProtected',
    'PatchData',
    'PatchCore',

    -- Util
    'Table',
    'RichLabel',
    'NumberLabel',
    'LevelupDirector',
    'LevelupDirector_GameResult',
    'MapManager',
    'ScrollMap',
    'ScrollMapLayer',
    'AnimationMap',
    'ServerData',
    'UserData',
    'DropHelper',
    'DragonSkillManager',
    'DragonSkillIndivisualInfo',
    'SumRandom',
    'ValidationAssistant',
    'Counter',
    'Stopwatch',
    'Camera',
    'CameraTouchHandler',
    'Camera_Lobby',
    'CameraTouchHandler_Lobby',
    'Camera_LobbySwipe',
    'ValidationDragon',
    'TableViewExtension',
    'StatusEffectHelper',
    'AreaOfEffectHelper',
    'ShaderCache',

    -- Interface
    'IEventDispatcher',
    'ITopUserInfo_EventListener',

    -- Scene
    'SceneCommon',
    'SceneLogo',
    'ScenePatch',
    'SceneTitle',
    'SceneLobby',
    'SceneDV',
    'SceneGame',
    'SceneAdventure',
    'SceneDragonManage',

    -- Phys
	'PhysWorld',
    'PhysObject',

    'Animator',
    'AnimatorPng',
    'AnimatorSpine',
    'AnimatorVrp',

    'Entity',
    'GameWorld',
    'GameWorld_Touch',
    'GameWorld_Formation',
    'GameState',
    'TamerSkillSystem',

	'Missile',
    'MissileBoomerang',
    'MissileCurve',
    'MissileDrop',
    'MissileDropGuid',
    'MissileDropRandom',
    'MissileDropTarget',
    'MissileDropZigzag',
    'MissileGuid',
    'MissileGuidTarget',
    'MissileTarget',
    'MissileZigzag',
    'MissileEffecter',
    'MissileLua',
    'MissileBounce',
    'MissileFix',
    'require_MissileLua',
    'LaserMissile',

	'Character',
    'CharacterEvent',
    'CharacterState',
    'CharacterSkill',
    'CharacterStateDelegate',
    'Hero',
    'Tamer',
    'Enemy',
    'EnemyLua',
    'EnemyLua_Boss',
    'Monster_GiantDragon',
    'require_EnemyLua',
    'EnemyMovement',
    'MissileFactory',
    'MissileLauncher',
    
	-- COMMON MISSILE (공통탄)
	'CommonMissile',
	'CommonMissile_Straight',
	'CommonMissile_Cruise',
	'CommonMissile_Shotgun',
	'CommonMissile_Release',
	'CommonMissile_High',

	-- STATUS EFFECT
	'StatusEffect',
    'StatusEffect_Trigger',
    'StatusEffect_PassiveSpatter',
	'StatusEffect_CheckWorld',
	'StatusEffect_Recovery',
	'StatusEffect_DotDmg',
	'StatusEffect_addAttack',
	
	'StatusEffectIcon',

	-- EFFECT
	'LinkEffect',
	'EffectHeal',
    'EffectBezierLink',
    'EffectLinearDot',
    
    -- SKILL    
	'Skill',
    'Laser',
	'SkillRay',
    'SkillLaser',
    'Thunder',
	'SkillBuff',
	'SkillDarkLightning',
    'SkillChainLightning',
    'SkillHealTarget',
    'SkillHealAround',
    'SkillShield',
    'SkillAttributeAmor',
    'SkillCurve',
    'SkillProtection',
    'SkillBulletHole',
    'SkillMeleeHack',
	'SkillMeleeHack_Specific',
    'SkillDeepStab',
    'SkillHealingWind',
    'SkillCrash',
    'SkillLeafBlade',
	'SkillPurpleProtection',
    'SkillSummon',
	'SkillDispelMagic',
    'SkillSpatter',
	'SkillAoERound',
	'SkillExplosion',
	'SkillConicAtk',
	'SkillConicAtk_Spread',
	'SkillRolling',
	'SkillAddAttack',
    'SkillLeonBasic',
	'SkillCounterAttack',

    -- SKILL INDICATOR
    'SkillIndicatorMgr',
    'SkillIndicator',
    'SkillIndicator_Tamer',
    'SkillIndicator_laser',
    'SkillIndicator_Range',
    'SkillIndicator_Target',
	'SkillIndicator_OppositeTarget',
    'SkillIndicator_HealingWind',
    'SkillIndicator_Crash',
    'SkillIndicator_LeafBlade',
	'SkillIndicator_AoERound',
	'SkillIndicator_Conic',
	'SkillIndicator_ConicSpread',

	-- S.P.
    'SpecialPower',
    'SpecialPowerLeon',
    
	-- BUFF
	'Buff',
    'Buff_Protection',
    'Buff_Shield',
	'Buff_Barrier',
    
	'WaveMgr',
    'DynamicWave',
    'ActivityCarrier',

	-- UI
    'UI_NetworkLoading',
    'UI_TitleScene',
    'UI_LobbyNew',
    'UI_Game',
    'UI_GameResult',
    'UI_GamePause',
    'UI_GameDebug',
    'UI_ReadySceneNew',
    'UI_Ready_DragonListItem',
    'UI_AdventureSceneNew',
    'UI_AdventureChapterSelectPopup',
    'UI_AdventureChapterButton',
    'UI_AdventureStageButton',
    'UI_AdventureFirstRewardPopup',
    'UI_IngameDragonInfo',
    'UI_Popup',
    'UI_DragonManageScene',
    'UI_DragonUpgradePopup',
    'UI_DragonUpgradeResult',
    'UI_DragonEvolutionPopup',
    'UI_DragonEvolutionWindow',
    'UI_DragonEvolutionResult',
    'UI_DragonDetailPopup',
    'UI_DragonFriendshipPopup',
    'UI_Tooltip',
	'UI_Tooltip_Indicator',
    'UI_TopUserInfo',
    'UI_ShopPopup',
    'UI_GameRewardPopup',
    'UI_ItemCard',
    'UI_ProductButton',
    'UI_InventoryEvolutionStonePopup',
    'UI_InventoryFruitPopup',
    'UI_SkillCard',
    'UI_Tooltip_Skill',
    'UI_DragonGachaResult',
    'UI_GuidePopup',
    'UI_NestDungeonScene',
    'UI_NestDragonDungeonListItem',
    'UI_NestDungeonStageSelectPopup',
    'UI_EditBoxPopup',

    -- UIC (UI Component)
    'UIC_Node',
    'UIC_Button',

    'DamageCalc',
    'IconHelper',
    'AnimatorHelper',
    'FormationMgr',
    'FormationMgr_TargetRule',
    'StatusCalculator',
    'StatusCalculatorFormula',
    'ObjectGold',
    'ObjectCharge',

    'DragonCard',
    'TriggerHpPercent',
    'EffectTimer',

    -- Data
    'DataAdventure',
    'DataStamina',
    'DataDragonList',
    'DataEvolutionStone',
    'DataFruit',
    'DataFruit_ListHelper',
    'DataFriendship',

    -- Network
    'Network',
}

-------------------------------------
-- function loadModule
-------------------------------------
function loadModule()
    for i,v in ipairs(t_module) do
        require(v)
    end

    require 'socket'
end

-------------------------------------
-- function reloadModule
-------------------------------------
function reloadModule()
    print('#############################')
    print('## reloadModule() start    ##')

    for i,v in ipairs(t_module) do
        if (v ~= 'SoundMgr') and (v ~= 'uilib/UIManager') and (v ~= 'uilib/UILoader')
            and (v ~= 'uilib/TableView') then
            package.loaded[v] = nil
            require(v)
        end
    end

    TABLE:init()
    print('## reloadModule() end      ##')
    print('#############################')
end