% Knowledgebase using Triple
%
% Properties we are keeping
% - Mineral: How much mineral needed to make one unit
% - Gas: How much gas neede to make one unit
% - Armor: Default armor of the unit
% - Hp: Default hp of the unit
% - Shield: Default Plasma Shielf of the unit (Only Protoss unit)
% - AttributeModifier: Attribute modifiers of the unit
% - Ground Attack: Default ground attack damage of the unit
% - BonusAttack:how much bonus attack does this unit has to BonusType
% - BonusType:to which type does this unit has a bonus attack
% - Race: Race of the unit
% - Range: Range of the unit's attack
% - Speed: Movement speed of the unit

% damage calculation
% # of unit * ( (basic attack + bonus) / cooldown ) = Total dps

% U is the enemies unit.
%% Inspect will give back:
%% Mineral,
%% Gas,
%% Shield, (0 if unit has no sheilds)
%% Armour,
%% GroundAttack,
%% BonusAttack, (Has this value added to GroundAttack when attacking one of it's BonusType)
%% BonusType, (List of type bonuses)
%% CoolDown, (Time inbetween attacks)
%% attributeModifier, (List of attributes this unit has)
%% Range (Range of Unit's attack)
% inspect(U, Mineral, Gas, HP, Shield, Armour, GroundAttack, BonusAttack, BonusTyp% e, CoolDown, Range) :-
% prop(U, mineral, Mineral), gas(U, Gas), hp(U, HP), shield(U, Shield),
% armour(U, Armour), groundAttack(U,GroundAttack)
% bonusAttack(U,BonusAttack), bonusType(U, BonusType), coolDown(U,
% CoolDown), range(U, Range).

%% counter (
%%	Get info about enemies unit
%%	Relevant info: Mineral, Gas, HP, Shields, Armour, Groundattack, BonusAttack, BonusType(s),Cooldown, Range

%%	L = Get possible units for us from race and ???
%%	R1 = List of names of the unit
%%	R2 = resources left after battle of unit

%%	damageCalculation(L, R1, R2) :-
%%		Head do calculation put result in R.


%%		BR  = battle result of this units damage calculation
%%		R is our result list which will have the unit and its total resources after battle
%%		resource effiecieny calculation(BR, R)
%%		H how many units we have left = ceiling(HP total of our units after battle/hp of one unit)
%%		H*cost of one unit = total resources after battle.

%%		damageCalculation(T,R)


%%	find highest resources left(R).

%% )

%% Taking into account Range:
%% They get extra number of attacks based on how much higher the unit's range is compared to it's opponents.
%% # of units*attack = bonus damage from range.
%% At beginning of fight subtract bonus damage from range from enemy with lowers range total hp pool.

%% (Basic attack + bonus atk - armour)/CD * number of units is DPS.



