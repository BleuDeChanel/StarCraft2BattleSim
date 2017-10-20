% Knowledgebase using Triple
%
% Properties we are keeping
% - Mineral
% - Gas
% - Armor
% - Hp
% - Shield
% - AttributeModifier
% -
%
prop(zealot, armour, 100).
prop(zealot, mineral, 100).
prop(zealot, gas, 100).
prop(zealot, hp, 100).
prop(zealot, shield, 100).
prop(zealot, groundAttack, 100).
prop(zealot, bonusAttack, 100).
prop(zealot, bonusType, 100).
prop(zealot, coolDown, 100).
prop(zealot, attributeModifier, 100).
prop(zealot, range, 100).
prop(zealot, race, protoss).
prop(immortal, race, protoss).
prop(zergling, race, zerg).













%% Unit is the enemies unit you wish to fight
%% NumberOfUnits is the number of the enemy's unit
%% MinAvailable is how minerals you can spend on your army
%% GasAvailable is much gas you can spend on your army
%% Race is your Race, it will restrict what units you can build
%% R is the result, a list of units with their resource effiecieny


counter(Unit, NumberOfUnits, MinAvailable, GasAvailable, Race, R) :-
	inspect(Unit, EMineral, EGas, EHP, EShield, EArmour, EGroundAttack, EBonusAttack, EBonusType, ECoolDown, ERange),
	inspectRace(R, L).


%% U is the enemies unit.
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
inspect(U, Mineral, Gas, HP, Shield, Armour, GroundAttack, BonusAttack, BonusType, CoolDown, Range) :-
	prop(U, mineral, Mineral),
	prop(U, gas, Gas),
	prop(U, hp, HP),
	prop(U, shield, Shield),
	prop(U, armour, Armour),
	prop(U, groundAttack, GroundAttack),
	prop(U, bonusAttack, BonusAttack),
	prop(U, bonusType, BonusType),
	prop(U, coolDown, CoolDown),
	prop(U, range, Range).



%% R is a race (Protoss, Zerg, Terran)
%% L is a list of units this race can make that are in our KB

inspectRace(R, L) :-
	findall(X0, prop(X0, race, R), L).



%% MaxBuild is true if R is GA / GPU.
%% If GPU is 0 give -1.
maxBuild(_,0,-1). 
maxBuild(GA,GPU,R) :- 
	R is GA / GPU.

%% SpecialMin is true when R is min of X and Y. Except -1 is max.
specialMin(-1, Y, Y).
specialMin(X, -1, X).
specialMin(X, Y, R) :-
	dif(X, -1),
	dif(Y, -1),
	R is min(X,Y).


%% U is unit to build.
%% MinAvailable is the minerals available
%% GasAvailable is the gas available
%% UnitsBuilt is the number of unit U built from recourses given
builtUnits(U, MinAvailable, GasAvailable, UnitsBuilt) :-
	prop(U, gas, GasPerUnit),
	prop(U, mineral, MineralsPerUnit),
	maxBuild(GasAvailable, GasPerUnit, GasMax),
	maxBuild(MinAvailable, MineralsPerUnit, MineralMax),
	specialMin(GasMax, MineralMax, UnitsBuilt).
	






% Protoss(X) is true if unit X is a Protoss unit.
%
% Terran(X) is true if unit X is a Terran unit.
%
% Zerg(X) is true if unit X is a Zerg unit.
%
% GroundAttack(X,Y) is true if unit X can attack ground with Y DPS.
%
% AirAttack(X,Y) is true if unit X can attack air with Y DPS.
%
% Hp(X,Y) is true if Y is the hp of unit X.
%
% Armor(X,Y) is true if Y is the armor of unit X.
%
% PlasmaShield(X,Y) is true if Y is the plasma shield of unit X where X
% is a Protoss unit.
%
% Supply(X,Y) is true if Y is supply required to make one unit X.
%
% Mineral(X,Y) is true if Y is how much mineral it costs to make one
% unit X.
%
% Gas(X,Y) is true if Y is how much gas it costs to make one unit X.
%
% Upgrade(X,Y) is true if Y is a number of upgrades completed for unit
% X.
%
% AttributeModifier(X,Y) is true if Y is an attribute modifer of unit X.
%
% Bonus(X,Y,Z) is true if unit X has Y amount of bonus damage versus
% type Z.
%
% BonusDPS(X,Y,Z) is true if unit X has Y amount of bonus DPS versus
% type Z.
%
% CoolDown(X,Y) is true if Y is an attack cooldown of unit X
%
% ProtossCounter(X,Y) is true if Y is a Protoss counter unit of X
%
% TerranCounter(X,Y) is true if Y is a Terran counter unit of X
%
% ZergCounter(X,Y) is true if Y is a Zerg counter unit of X.
%

% Knowledge Base

%% Protoss(zealot).
%% Terran(marine).
%% Zerg(zergling).

%% Mineral(zealot, 100).
%% Mineral(marine, 50).
%% Mineral(zergling, 25).

%% Gas(zealot, 0).
%% Gas(marine, 0).
%% Gas(zergling, 0).

%% Supply(zealot, 2).
%% Supply(marine, 1).
%% Supply(zergling, 0.5).



%% Hp(marine, 45).
%% Armor(marine, 0).
%% Upgrade(marine, 0).
%% Groundattack(marine, 6).
%% Airattack(marine, 6).
%% CoolDown(marine, 0.61).
%% AttributeModifier(marine, light).
%% AttributeModifier(marine, biological).

%% Hp(zergling, 35).
%% Armor(zergling, 0).
%% Upgrade(zergling, 0).
%% Groundattack(zergling, 5).
%% CoolDown(zergling, 0.497).
%% AttributeModifier(zergling, light).
%% AttributeModifier(zergling, biological).


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

%% Before battle calculation we have list L of units we can build
%% Foreach unit in L
%% Build max number of units
%% Do damageCalculation against enemies units (lots of smaller parts/functions)
%% Record results

%% The result of the battle calculation is a list L where each element in L is units name and total hp left after battle


%% After doing each unit and getting results calculate resource effiecieny based on units left and this units cost.

%% Taking into account Range:
%% They get extra number of attacks based on how much higher the unit's range is compared to it's opponents.
%% # of units*attack = bonus damage from range.
%% At beginning of fight subtract bonus damage from range from enemy with lowers range total hp pool.

%% (Basic attack + bonus atk - armour)/CD * number of units is DPS.



