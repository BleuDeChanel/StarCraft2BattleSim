prop(probe, mineral, 100).
prop(probe, gas, 0).
prop(probe, armour, 0).
prop(probe, hp, 20).
prop(probe, shield, 20).
prop(probe, race, protoss).
prop(probe, attributeModifier, [light,mechanical]).
prop(probe, groundAttack, 5).
prop(probe, bonusAttack, 0).
prop(probe, bonusType, []).
prop(probe, coolDown, 1.07).
prop(probe, range, 0).
prop(probe, speed, 3.94).

prop(zealot, mineral, 100).
prop(zealot, gas, 0).
prop(zealot, armour, 1).
prop(zealot, hp, 100).
prop(zealot, shield, 50).
prop(zealot, race, protoss).
prop(zealot, attributeModifier, [light,biological]).
prop(zealot, groundAttack, 16).
prop(zealot, bonusAttack, 0).
prop(zealot, bonusType, []).
prop(zealot, coolDown, 0.86).
prop(zealot, range, 0).
prop(zealot, speed, 3.15).

prop(sentry, mineral, 50).
prop(sentry, gas, 100).
prop(sentry, armour, 1).
prop(sentry, hp, 40).
prop(sentry, shield, 40).
prop(sentry, race, protoss).
prop(sentry, attributeModifier, [light,mechanical,psionic]).
prop(sentry, groundAttack, 6).
prop(sentry, bonusAttack, 0).
prop(sentry, bonusType, []).
prop(sentry, coolDown, 0.71).
prop(sentry, range, 5).
prop(sentry, speed, 3.15).

prop(stalker, mineral, 125).
prop(stalker, gas, 50).
prop(stalker, armour, 1).
prop(stalker, hp, 80).
prop(stalker, shield, 80).
prop(stalker, race, protoss).
prop(stalker, attributeModifier, [armoured,mechanical]).
prop(stalker, groundAttack, 10).
prop(stalker, bonusAttack, 4).
prop(stalker, bonusType, [armoured]).
prop(stalker, coolDown, 1.03).
prop(stalker, range, 6).
prop(stalker, speed, 4.13).

prop(adept, mineral, 100).
prop(adept, gas, 25).
prop(adept, armour, 1).
prop(adept, hp, 70).
prop(adept, shield, 70).
prop(adept, race, protoss).
prop(adept, attributeModifier, [light,biological]).
prop(adept, groundAttack, 10).
prop(adept, bonusAttack, 12).
prop(adept, bonusType, [light]).
prop(adept, coolDown, 1.61).
prop(adept, range, 4).
prop(adept, speed, 3.5).

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

% Unit is the enemies unit you wish to fight
% NumberOfUnits is the number of the enemy's unit
% MinAvailable is how minerals you can spend on your army
% GasAvailable is much gas you can spend on your army
% Race is your Race, it will restrict what units you can build
% R is the result, a list of units with their resource effiecieny


counter(Unit, NumberOfUnits, MinAvailable, GasAvailable, Race, R) :-
	inspect(Unit, EMineral, EGas, EHP, EShield, EArmour, EGroundAttack, EBonusAttack, EBonusType, ECoolDown, ERange),
	inspectRace(R, L),
	battleSimulation(Unit, NumberOfUnits, L, MinAvailable, GasAvailable, R).


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
% inspect(U, Mineral, Gas, HP, Shield, Armour, GroundAttack, BonusAttack, BonusTypes, CoolDown, Range) :-
% prop(U, mineral, Mineral), gas(U, Gas), hp(U, HP), shield(U, Shield),
% armour(U, Armour), groundAttack(U,GroundAttack)
% bonusAttack(U,BonusAttack), bonusType(U, BonusType), coolDown(U,
% CoolDown), range(U, Range).

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
	diff(GPU, 0),
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
buildUnits(U, MinAvailable, GasAvailable, UnitsBuilt) :-
	prop(U, gas, GasPerUnit),
	prop(U, mineral, MineralsPerUnit),
	maxBuild(GasAvailable, GasPerUnit, GasMax),
	maxBuild(MinAvailable, MineralsPerUnit, MineralMax),
	specialMin(GasMax, MineralMax, UnitsBuilt).


%% Grants free hits for opponent with higher range based on slower units movement speed to get into range.
%% EUnit hits first
rangeChecker(EUnit, Unit, 0, NextHit) :-
	prop(EUnit, range, ER),
	prop(Unit, range, R),
	ER > R,
	Distance is ER - R,
	prop(Unit, speed, Speed),
	Tick is 0.01,
	MovePerTick is Speed * Tick,
	NextHit is Distance / MovePerTick.

%% Unit hits first
rangeChecker(EUnit, Unit, ENextHit, 0) :-
	prop(EUnit, range, ER),
	prop(Unit, range, R),
	R > ER,
	Distance is R - ER,
	prop(EUnit, speed, Speed),
	Tick is 0.01,
	MovePerTick is Speed * Tick,
	ENextHit is Distance / MovePerTick.


	%% Take speed of slower unit (LOOK AT NOTES)





%% battleSimulation(Unit, NumberOfUnits, L, MinAvailable, GasAvailable, R). is true when:
%% Unit is the enemies unit
%% EUnitLeft is the number of enemy units
%% L is a list of units that are available to your race
%% MinAvailable is how many minerals you have available
%% GasAvailable is how much gas you have available
%% R is a list of elements. Each element has unit, HP total left, and resources leftover.
%% HP total left is the total HP left of the built units after going through battleSimulation with the enemy
battleSimulation(EUnit, EUnitLeft, [], MinAvailable, GasAvailable, []).
battleSimulation(EUnit, EUnitLeft, [Unit|T], MinAvailable, GasAvailable, R) :-
	buildUnits(Unit, MinAvailable, GasAvailable, UnitLeft),
	
	rangeChecker(Eunit, Unit, ENextHit, NextHit),
	prop(EUnit, coolDown, ECD),
	prop(Unit, coolDown, CD),
	tick(0,ECD, CD, EUnitLeft, UnitLeft, ENextHit,NextHit,R).
	




tick(Time, ECD, CD, EUnitLeft, UnitLeft, ENextHit, NextHit) :-
	



% damage calculation
% # of unit * ( (basic attack + bonus) - Earmour / cooldown ) = Total dps

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









