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
	%% Make sure NumberOfUnits > 0.
	dif(NumberOfUnits, 0),
	%% Make sure Minerals are given
	MinAvailable > 49,
	%% Make sure Unit is valid.
	%% Make sure race is valid.
	inspect(Unit, EMineral, EGas, EHP, EShield, EArmour, EGroundAttack, EBonusAttack, EBonusType, ECoolDown, ERange),
	inspectRace(R, L),
	battleSimulation(Unit, NumberOfUnits, L, MinAvailable, GasAvailable, R).


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
% inspect(U, Mineral, Gas, HP, Shield, Armour, GroundAttack, BonusAttack, BonusTypes, CoolDown, Range) :-
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
	dif(GPU, 0),
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

%% Same range
rangeChecker(EUnit, Unit, 0, 0) :-
	prop(EUnit, range, ER),
	prop(Unit, range, R),
	R = ER.

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
	prop(EUnit, hp, EHP),
	prop(Unit, hp, HP),
	prop(EUnit, shield, EShield),
	prop(Unit, shield, Shield),

	tick(EUnit, Unit, EUnitLeft, UnitLeft, ENextHit, NextHit, (HP, Shield), (EHP, EShield), R).



%% Gets Damage for this attack done by Attacker on Defender
%% Damage = UnitLeft * ( ( BasicAttack + BonusAttack - EArmour) ).
%% Add shield armour value.
%% Tests:
%% attack(zealot, 500, zealot, D). Expect D = 7500
attack(Attacker, AttackerUnitleft, Defender, Damage) :-
	prop(Attacker, groundAttack, BasicAttack),
	BonusAttack is 0,
	prop(Defender, armour, DefenderArmour),
	SingleAttack is BasicAttack + BonusAttack - DefenderArmour,
	Damage is AttackerUnitleft * SingleAttack.




%% NOTE: Shield will be added to HP, and use same Armour as it's unit's Armour. 
%% It should have it's own armour value.

%% 	Looking into Attack 
%% 		1. Must keep track of UnitsLeft.
%% 		2. Keep track of one DamagedUnit per side. Damaged unit is (HPLeft, ShieldLeft)
%% 		3. An attack is 
%% 			Damage = UnitLeft * ( ( BasicAttack + BonusAttack - EArmour) ).
%% 			TempHP = EDamagedUnit's HP
%% 			EDamagedUnit's HP = EDamagedUnit's HP - Damage. If 0, dead. EUnitLeft - 1. EDamagedUnit HP set to full.
%% 			Damage = Damage - TempHP.
%% 			Repeat till Damage is 0.

%% Base case
%% Defender doesn't die. Set the New values. 
%% Case 1: Shield doesn't break
%% Tests: 
%% defend(10, zealot, (100,50),1,(NewHP, NewShield), NewLeft).
defend(Damage, Defender, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), DefenderUnitLeft, (DefenderDamagedUnitHP, NewDefenderDamagedUnitShield), DefenderUnitLeft) :-
	NewDefenderDamagedUnitShield is DefenderDamagedUnitShield - Damage,
	NewDefenderDamagedUnitShield >= 0.
	

%% Case 2: Shield does break, Unit lives
%% Tests:
%% defend(50, zealot, (100,50),1,(NewHP, NewShield), NewLeft).
%% defend(75, zealot, (100,0),1,(NewHP, NewShield), NewLeft).
%% defend(75, zealot, (100,5),1,(NewHP, NewShield), NewLeft).

defend(Damage, Defender, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), DefenderUnitLeft, (NewDefenderDamagedUnitHP, 0), DefenderUnitLeft) :-
	NewDefenderDamagedUnitShield is DefenderDamagedUnitShield - Damage,
	NewDefenderDamagedUnitShield < 0,
	NewDamage is Damage - DefenderDamagedUnitShield,
	NewDefenderDamagedUnitHP is DefenderDamagedUnitHP - NewDamage,
	NewDefenderDamagedUnitHP > 0.

%% Case 3: Defender Dies
%% Reduce Total Damage left
%% Check if shield breaks
%% Check if HP hits 0
%% Subtract total damage
%% Setup new frontline unit
%% Unit count down by one
%% Tests:
%% defend(1000, zealot, (100,50),100,(NewHP, NewShield), NewLeft). 	Expect: NewHP = 50  NewShield = 0  NewLeft = 94
%% defend(250, zealot, (100,50),2,(NewHP, NewShield), NewLeft).		Expect: NewHP = 50  NewShield = 0  NewLeft = 1
%% defend(300, zealot, (100,50),2,(NewHP, NewShield), NewLeft). 	Expect: NewHP = 100 NewShield = 50 NewLeft = 0
defend(Damage, Defender, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), DefenderUnitLeft, (NewDefenderDamagedUnitHP, NewDefenderDamagedUnitShield), NewDefenderUnitLeft) :-
	TempShield is DefenderDamagedUnitShield - Damage,
	TempShield < 0,
	NewDamage is Damage - DefenderDamagedUnitShield,
	TempHP is DefenderDamagedUnitHP - NewDamage,
	TempHP =< 0,
	NewNewDamage is NewDamage - DefenderDamagedUnitHP,
	prop(Defender, shield, FreshShield),
	prop(Defender, hp, FreshHP),
	TempUnitLeft is DefenderUnitLeft - 1,
	defend(NewNewDamage, Defender, (FreshHP, FreshShield), TempUnitLeft, (NewDefenderDamagedUnitHP, NewDefenderDamagedUnitShield), NewDefenderUnitLeft).

	

%% Looking at Tick
%% 	Doesn't tick on 0.01, but jumps to next attack tick after each tick. Keeping track of who attacks next and when.
%% 	1.
%% 		Need to keep track of NextHit. 
%% 		Everytime NextHit hits 0:
%% 			1. Attack.
%% 			2. Set NextHit to CD.
%% tick(EUnit, Unit, EUnitLeft, UnitLeft, ENextHit, NextHit, DamagedUnit, EDamagedUnit, R)
%% Eunit - Enemy's Unit
%% Unit - Your Unit
%% EUnitLeft - Enemy's units left (Battle is over when at 0)
%% UnitLeft - Your units left (Battle is over when at 0)
%% ENextHit - Ticks till enemy can attack (attacks at 0)
%% NextHit - Ticks till you can attack (attacks at 0)
%% EDamagedUnit - Enemy's frontline unit, gets hit first and can have non full hp/shield
%% DamagedUnit - your frontline unit, gets hit first and can have non full hp/shield
%% R is result of battle, (Unit, TotalHP of your army left)

%% Tests:
%% tick()

%% No one can hit, Jump to next attack. Cases: Enemey is next hit, You're next hit, you both are next hit(same ENextHit and NextHit)
tick(EUnit, Unit, EUnitLeft, UnitLeft, ENextHit, NextHit, EDamagedUnit, DamagedUnit, R) :- 
	EUnitLeft > 0,
	UnitLeft > 0,
	ENextHit > 0,
	NextHit > 0,
	%% ENextHit < NextHit,

	X is ENextHit - 0.01,
	Y is NextHit - 0.01,
	tick(EUnit, Unit, EUnitLeft, UnitLeft, 0, Y, EDamagedUnit, DamagedUnit, R).

%% No Enemies left!!! Record result and exit tick.
tick(_, Unit, EUnitLeft, UnitLeft, _, _, _, (HP, Shield), (Unit,TotalHP)) :- 
	EUnitLeft =< 0,
	UnitLeft > 0,
	prop(Unit, hp, FullHP),
	TotalHP is FullHP * UnitLeft + HP.

%% No Units left :( Record result and exit tick.
tick(_, Unit, _, UnitLeft, _, _, _, _, (Unit,0)) :-
	UnitLeft =< 0.

%% Unit can hit
tick(EUnit, Unit, EUnitLeft, UnitLeft, ENextHit, 0, EDamagedUnit, DamagedUnit, R) :-
	EUnitLeft > 0,
	UnitLeft > 0,
	ENextHit > 0,
	attack(Unit, UnitLeft, EUnit, Damage),
	defend(Damage, EUnit, EDamagedUnit, EUnitLeft, NewEDamageUnit, NewEUnitLeft),
	X is ENextHit - 0.01,
	prop(Unit, coolDown, NewNextHit),
	tick(EUnit, Unit, NewEUnitLeft, UnitLeft, X, NewNextHit, NewEDamageUnit, DamagedUnit, R).


%% Enemy unit can hit
tick(EUnit, Unit, EUnitLeft, UnitLeft, 0, NextHit, EDamagedUnit, DamagedUnit, R) :-
	EUnitLeft > 0,
	UnitLeft > 0,
	NextHit > 0,
	attack(EUnit, EUnitLeft, Unit, Damage),
	defend(Damage, Unit, DamagedUnit, UnitLeft, NewDamageUnit, NewUnitLeft),
	prop(EUnit, coolDown, NewENextHit),
	Y is NextHit - 0.01,
	tick(EUnit, Unit, EUnitLeft, NewUnitLeft, NewENextHit, Y, EDamagedUnit, NewDamageUnit, R).

%% Both units can hit
%% Both attack with full force.
%% Then defend.
tick(EUnit, Unit, EUnitLeft, UnitLeft, 0, 0, EDamagedUnit, DamagedUnit, R) :-
	EUnitLeft > 0,
	UnitLeft > 0,
	attack(EUnit, EUnitLeft, Unit, EDamage),
	attack(Unit, UnitLeft, EUnit, Damage),
	defend(EDamage, Unit, DamagedUnit, UnitLeft, NewDamageUnit, NewUnitLeft),
	defend(Damage, EUnit, EDamagedUnit, EUnitLeft, NewEDamageUnit, NewEUnitLeft),
	prop(EUnit, coolDown, NewENextHit),
	prop(Unit, coolDown, NewNextHit),
	tick(EUnit, Unit, NewEUnitLeft, NewUnitLeft, NewENextHit, NewNextHit, NewEDamageUnit, NewDamageUnit, R).


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



% Jin Min trying to wrap around his head.
%
% availableUnits(MinAvailable, GasAvailable, AllUnits, Result).
% (AllUnits is ListofAllUnits)

availableUnits(_, _,[],L,L).
availableUnits(MinAvailable, GasAvailable, [H|T],Acc,[H|RT]) :- buildUnits(H, MinAvailable, GasAvailable, N), N>0, availableUnits(MinAvailable, GasAvailable,T,[H|Acc],RT).
% availableUnits(MinAvailable, GasAvailable,[H|T],Acc,[D|RT]) :-
% dif(H,D), buildUnits(H, MinAvailable, GasAvailable, N), N>0,
% availableUnits(MinAvailable, GasAvailable,T,Acc,RT).

% ?- % availableUnits(400,0,
% [probe,zealot,sentry,stalker,adept,darkTemplar,immortal,colossus], [],
% R). (MinAvailable and GasAvailable inputs are availabe on the upper
% function // I'm passing them as a input now) (400, 0) R = [probe,
% zealot];

% Res is 1(true) if the N is greater than 0, meaning can make the Unit.
availableUnit(Unit, MinAvailable, GasAvailable, Res) :- buildUnits(Unit, MinAvailable, GasAvailable, N), N>0, Res is 1.

% This returns the reversed order and doesn't work with a list including
% N = 0... Huge bug.
availableUnits2(_, _, [], L, L).
availableUnits2(MinAvailable, GasAvailable, [H|T], Acc, Result) :- availableUnit(H, MinAvailable, GasAvailable, 1), availableUnits2(MinAvailable, GasAvailable, T, [H|Acc], Result).


availableUnits22(U, MinAvailable, GasAvailable, L) :- findall(U, buildUnits(U, MinAvailable, GasAvailable, N>0), L).

filterUserUnit(Race, MinAvailable, GasAvailable, Result) :- inspectRace(Race,ListofAllUnits), availableUnits(MinAvailable, GasAvailable, ListofAllUnits, [], Result).
