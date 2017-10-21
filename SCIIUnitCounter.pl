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
	inspectRace(R, L).


% U is the enemies unit.
% Inspect will give back:
% Mineral,
% Gas,
% Armour
% Shield, (0 if unit has no sheilds, that is not Protoss race)
% HP,
% GroundAttack,
% BonusAttack, (Has this value added to GroundAttack when attacking one of it's BonusType)
% BonusType, (List of type bonuses)
% CoolDown, (Time inbetween attacks)
% attributeModifier, (List of attributes this unit has)
% Range (Range of Unit's attack)
% inspect(U, Mineral, Gas, HP, Shield, Armour, GroundAttack, BonusAttack, BonusTyp% e, CoolDown, Range) :-
% prop(U, mineral, Mineral), gas(U, Gas), hp(U, HP), shield(U, Shield),
% armour(U, Armour), groundAttack(U,GroundAttack)
% bonusAttack(U,BonusAttack), bonusType(U, BonusType), coolDown(U,
% CoolDown), range(U, Range).

inspect(U, Mineral, Gas, Armour, HP, Shield, GroundAttack, BonusAttack, BonusType, CoolDown, Range) :-
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



%% R is a race (Protoss, Zerg, Terran) of the User
%% L is a list of units this race can make that are in our KB

inspectRace(R, L) :-
	findall(X0, prop(X0, race, R), L).



%% MaxBuild is true if R is GA / GPU.
%% If GPU is 0 give -1.
maxBuild(_,0,-1).
maxBuild(GA,GPU,R) :-
	GPU \== 0,
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





% Jin Min trying to wrap around his head.
%
prop(probe, mineral, 50).
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

prop(darkTemplar, mineral, 125).
prop(darkTemplar, gas, 125).
prop(darkTemplar, armour, 1).
prop(darkTemplar, hp, 40).
prop(darkTemplar, shield, 80).
prop(darkTemplar, race, protoss).
prop(darkTemplar, attributeModifier, [light,biological,psionic]).
prop(darkTemplar, groundAttack, 10).
prop(darkTemplar, bonusAttack, 12).
prop(darkTemplar, bonusType, [light]).
prop(darkTemplar, coolDown, 1.61).
prop(darkTemplar, range, 4).
prop(darkTemplar, speed, 3.5).

prop(immortal, mineral, 250).
prop(immortal, gas, 100).
prop(immortal, armour, 1).
prop(immortal, hp, 200).
prop(immortal, shield, 100).
prop(immortal, race, protoss).
prop(immortal, attributeModifier, [armoured,mechanical]).
prop(immortal, groundAttack, 20).
prop(immortal, bonusAttack, 30).
prop(immortal, bonusType, [armoured]).
prop(immortal, coolDown, 1.04).
prop(immortal, range, 6).
prop(immortal, speed, 3.15).

prop(colossus, mineral, 300).
prop(colossus, gas, 200).
prop(colossus, armour, 1).
prop(colossus, hp, 200).
prop(colossus, shield, 150).
prop(colossus, race, protoss).
prop(colossus, attributeModifier, [armoured,mechanical,massive]).
prop(colossus, groundAttack, 12).
prop(colossus, bonusAttack, 0).
prop(colossus, bonusType, []).
prop(colossus, coolDown, 1.18).
prop(colossus, range, 6).
prop(colossus, speed, 3.15).
%
%
%
%
% availableUnits(MinAvailable, GasAvailable, AllUnits, Acc, Result).
% (AllUnits is ListofAllUnits)

availableUnits(_, _,[],L,L).
availableUnits(MinAvailable, GasAvailable, [H|T],Acc,[H|RT]) :- builtUnits(H, MinAvailable, GasAvailable, N), N>0, availableUnits(MinAvailable, GasAvailable, T, [H|Acc], RT).

% availableUnits(MinAvailable, GasAvailable, [H|T],Acc,[D|RT]) :-
% dif(H,D), builtUnits(H, MinAvailable, GasAvailable, N), N>0,
% availableUnits(MinAvailable, GasAvailable,T,Acc,RT).

% ?-
% availableUnits(400,
% 0, [probe,zealot,sentry,stalker,adept,darkTemplar,immortal,colossus],
% [], R). (MinAvailable and GasAvailable inputs are availabe on the
% upper function // I'm passing them as a input now) (400, 0) R =
% [probe, zealot];

filterUserUnit(Race, MinAvailable, GasAvailable, Result) :- inspectRace(Race,ListofAllUnits), availableUnits(MinAvailable, GasAvailable, ListofAllUnits, [], Result).
