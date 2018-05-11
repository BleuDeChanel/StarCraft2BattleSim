:- include('Protoss Units.pl').
:- include('Zerg Units.pl').
:- include('Terran Units.pl').


%% You can edit the values in Protoss/Zerg/Terran Units.pl and play around with the simulation.


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
% GasToMinRatio is the value of how much gas is worth in minerals. (Typical value is 3 or 3.5)
% R is the result, a list of units with their resource effiecieny
%% Such as (Unit, MineralLeft, GasLeft, ResourcesLeft(After conversion), UnitsLeft, EnemyUnitsLeft)


%% TODO:
%% Logs showing no unit built.


%% (DONE) If Armour makes the attack of single unit go under 0.5. Make the BasicAttack do 0.5 damage. It is the minimum damage


%% Use Battle Result to get resource effiecieny of each battle which will be R.
%% Add enemy casualties to result?

%% Print out more stats from battles as they happen (DONE)
%% Import KB from other files

main(Unit, NumberOfUnits, MinAvailable, GasAvailable, Race, GasToMinRatio) :-
	validUnit(Unit),
	validRace(Race),
	validNumOfUnits(NumberOfUnits),
	validMinerals(MinAvailable),
	validGas(GasAvailable),
	validGasToMinRatio(GasToMinRatio),
	filterUserUnitInOrder(Race, MinAvailable, GasAvailable, ListOfPossibleUnits),
	battleSimulation(Unit, NumberOfUnits, ListOfPossibleUnits, MinAvailable, GasAvailable, BattleResult),
	costEfficiencyList2(BattleResult, MinAvailable, GasAvailable, GasToMinRatio, CELResult),
	merge_sort(CELResult, Result),
	print_message(banner, resourceBanner()),
	prettyPrint(Result).

prolog:message(enteringBattleMessage(EUnitLeft, EUnit, Unit)) -->
        [ '\n ====================SIMULATION START====================  \n ~w is entering battle against the enemies ~D ~ws'-[Unit, EUnitLeft, EUnit] ].

prolog:message(buildMessage(Unit, UnitLeft, MinAvailable, GasAvailable)) -->
        [ 'BUILD UNITS: Built ~D ~ws from ~D Minerals ~D Gas'-[UnitLeft, Unit, MinAvailable, GasAvailable] ].

prolog:message(rangeMessage(Unit1, Unit2, Unit1Range, Unit2Range, Unit2AttackTime)) -->
        [ 'RANGE CHECK: ~w has ~D Range. ~w has ~D Range. \n It will take ~5fms for ~w to get in range.'-[Unit1, Unit1Range, Unit2, Unit2Range, Unit2AttackTime, Unit2] ].

prolog:message(battleBanner()) -->
        [ '====================BATTLE START===================='-[] ].

prolog:message(attackMessage(Unit1, NumUnit1, SingleAttack, Unit2, Damage)) -->
        [ '~D ~ws attack ~w for ~1f each. ~1f Total Damage'-[NumUnit1, Unit1, Unit2, SingleAttack, Damage] ].

prolog:message(attackBanner()) -->
        [ '==========ATTACK=========='-[] ].

prolog:message(defendMessage(Defender, DefenderUnitsLeft, (TankHP,TankShield), Damage)) -->
        [ '~w takes ~1f damage. ~D ~ws left. Focused unit has ~1f HP ~1f Shield left.'-[Defender, Damage, DefenderUnitsLeft, Defender, TankHP, TankShield] ].

prolog:message(defendBanner()) -->
        [ '==========DEFEND=========='-[] ].

prolog:message(defenderDiedMessage(Defender, DefenderUnitsLeft, Damage, OverDamage)) -->
        [ '~w took ~1f damage and died. ~D ~ws left. Leftover ~1f damage passed on to next target, if it exists.'-[Defender, Damage,  DefenderUnitsLeft, Defender, OverDamage] ].

prolog:message(nextAttackMessage(EUnit,Unit,NewENextHit, NewNextHit)) -->
        [ '~w can attack in ~5fms. ~w can attack in ~5fms.'-[Unit, NewNextHit, EUnit, NewENextHit] ].

prolog:message(nextAttackBanner()) -->
        [ '==========JUMP TO NEXT ATTACK=========='-[] ].

prolog:message(battleEnd(DeadUnit, AliveUnit, AliveLeft)) -->
        [ 'All ~ws are dead. There are ~D ~ws left.'-[DeadUnit, AliveLeft, AliveUnit] ].

prolog:message(battleEndBanner()) -->
        [ '==========BATTLE END=========='-[] ].

prolog:message(invalidUnit(Unit)) -->
        [ '~w is not a unit in our Knowledge Base '-[Unit] ].

prolog:message(invalidRace(Race)) -->
        [ '~w is not a race in StarCraft 2'-[Race] ].

prolog:message(invalidNumberOfUnits()) -->
        [ 'Please enter a number greater than 0 for Enemy\'s number of units.'-[] ].

prolog:message(invalidMinerals()) -->
        [ 'Please enter a number greater than 0 for Minerals Available.'-[] ].

prolog:message(invalidGas()) -->
        [ 'Please enter a number greater than or equal to 0 for Gas Available.'-[] ].


prolog:message(invalidGasToMinRatio()) -->
        [ 'Please enter a number greater than 0 for Gas to Min Ratio.'-[] ].

prolog:message(noUnit(Unit)) -->
		[ 'No ~w can be built.'-[Unit] ].

prolog:message(prettyPrintMessage(Unit, MineralLeft, GasLeft, ResourcesLeft, UnitsLeft, EnemyUnitsLeft)) -->
        [ 'With ~w you saved: ~D minerals, ~D gas, ~1f resources total(gas to minerals based on your ratio). ~D ~ws survived. And ~D Enemey units left.'-[Unit, MineralLeft, GasLeft, ResourcesLeft, UnitsLeft, Unit, EnemyUnitsLeft] ].

prolog:message(resourceBanner()) -->
        [ '==========RESOURCE EFFICIENCY SUMMARY=========='-[] ].

%% prettyPrint will print the results nicely for the user
prettyPrint([]).
prettyPrint([(Unit, MineralLeft, GasLeft, ResourcesLeft, UnitsLeft, EnemyUnitsLeft)| T]) :-
	print_message(informational, prettyPrintMessage(Unit, MineralLeft, GasLeft, ResourcesLeft, UnitsLeft, EnemyUnitsLeft)),
	prettyPrint(T).

%% Checks if unit is valid
%% validUnit(Unit) is true if Unit is in our KB
validUnit(Unit) :-
	prop(Unit,race,_).
validUnit(Unit) :-
	\+ prop(Unit,race,_),
	print_message(error, invalidUnit(Unit)),
	false.

%% Checks if race is valid
%% validRace(Race) is true if Race is one of protoss,zerg or terran
validRace(Race) :-
	member(Race, [terran,protoss,zerg]).
validRace(Race) :-
	\+ member(Race, [terran,protoss,zerg]),
	print_message(error, invalidRace(Race)),
	false.

%% Checks if NumberOfUnits is greater than 0.
validNumOfUnits(NumberOfUnits) :-
	NumberOfUnits > 0.
validNumOfUnits(NumberOfUnits) :-
	\+ NumberOfUnits > 0,
	print_message(error, invalidNumberOfUnits()),
	false.

%% Checks if valid amount of minerals
validMinerals(MinAvailable) :-
	MinAvailable > 0.
validMinerals(MinAvailable) :-
	\+ MinAvailable > 0,
	print_message(error, invalidMinerals()),
	false.

%% Checks if valid amount of gas
validGas(GasAvailable) :-
	GasAvailable >= 0.
validGas(GasAvailable) :-
	\+ GasAvailable >= 0,
	print_message(error, invalidGas()),
	false.


%% Checks if GasToMinRatio is greater than 0
validGasToMinRatio(GasToMinRatio) :-
	GasToMinRatio > 0.
validGasToMinRatio(GasToMinRatio) :-
	\+ GasToMinRatio > 0,
	print_message(error, invalidGasToMinRatio()),
	false.


%% R is a race (Protoss, Zerg, Terran) of the User
%% L is a list of units this race can make that are in our KB

inspectRace(R, L) :-
	findall(X0, prop(X0, race, R), L).

%% intersects(L1, L2) is true if one of L1's elements is in L2.
intersects([H|_],List) :-
    member(H,List),
    !.
intersects([_|T],List) :-
    intersects(T,List).

%% MaxBuild is true if R is GA / GPU.
%% If GPU is 0 give -1.
maxBuild(_,0,-1).
maxBuild(GA,GPU,R) :-
	dif(GPU, 0),
	R is floor(GA / GPU).

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
	NextHit is Distance / MovePerTick,
	print_message(informational, rangeMessage(EUnit, Unit, ER, R, NextHit)).

%% Unit hits first
rangeChecker(EUnit, Unit, ENextHit, 0) :-
	prop(EUnit, range, ER),
	prop(Unit, range, R),
	R > ER,
	Distance is R - ER,
	prop(EUnit, speed, Speed),
	Tick is 0.01,
	MovePerTick is Speed * Tick,
	ENextHit is Distance / MovePerTick,
	print_message(informational, rangeMessage(Unit, EUnit, R, ER, ENextHit)).

%% Same range
rangeChecker(EUnit, Unit, 0, 0) :-
	prop(EUnit, range, ER),
	prop(Unit, range, R),
	R = ER,
	print_message(informational, rangeMessage(Unit, EUnit, R, ER, 0)).


%% battleSimulation(Unit, NumberOfUnits, L, MinAvailable, GasAvailable, R). is true when:
%% Unit is the enemies unit
%% EUnitLeft is the number of enemy units
%% L is a list of units this will simulate battle for
%% MinAvailable is how many minerals you have available
%% GasAvailable is how much gas you have available
%% R is a list of elements. Each element has (Unit, UnitsLeft of the player, Enemy Units Left)
battleSimulation(_, _, [], _, _, []).
battleSimulation(EUnit, EUnitLeft, [Unit|T], MinAvailable, GasAvailable, [R1 | R]) :-
	print_message(banner, enteringBattleMessage(EUnitLeft, EUnit, Unit)),
	buildUnits(Unit, MinAvailable, GasAvailable, UnitLeft),
	print_message(informational, buildMessage(Unit, UnitLeft, MinAvailable, GasAvailable)),
	rangeChecker(EUnit, Unit, ENextHit, NextHit),
	prop(EUnit, hp, EHP),
	prop(Unit, hp, HP),
	prop(EUnit, shield, EShield),
	prop(Unit, shield, Shield),
	OriginalEUnitLeft is EUnitLeft,
	print_message(banner, battleBanner()),
	tick(EUnit, Unit, EUnitLeft, UnitLeft, ENextHit, NextHit, (EHP, EShield), (HP, Shield), R1),
	battleSimulation(EUnit, OriginalEUnitLeft, T, MinAvailable, GasAvailable, R).

%% getBonusAttack will take in a defender and Attacker and return the Attacker's BonusAttack against the Defender in BonusAttack.
%% Note: Currently it does not support a unit having different bonusAttacks for different Defenders
%% Gets Attacker's BonusType array and Defender's AttributeModifier array and see's if a value matches.
%% If a value matches set BonusAttack. If not return 0.

%% Case: Attacker's bonusAttack is 0 for all. Return 0.
getBonusAttack(Attacker, _, 0) :-
	prop(Attacker, bonusAttack, BonusAttack),
	BonusAttack = 0.

%% Case: we have a match in BonusTypes and AttributeModifiers so the bonusAttack applies
getBonusAttack(Attacker, Defender, BonusAttack) :-
	prop(Attacker, bonusAttack, BonusAttack),
	BonusAttack > 0,
	prop(Attacker, bonusType, BonusTypes),
	prop(Defender, attributeModifier, AttributeModifiers),
	intersects(BonusTypes, AttributeModifiers).

%% No match in BonusTypes and AttributeModifiers so the bonusAttack is 0
getBonusAttack(Attacker, Defender, 0) :-
	prop(Attacker, bonusAttack, BonusAttack),
	BonusAttack > 0,
	prop(Attacker, bonusType, BonusTypes),
	prop(Defender, attributeModifier, AttributeModifiers),
	\+ intersects(BonusTypes, AttributeModifiers).

%% checkSingleAttack(SingleAttack, R) is true when SingleAttack is less than 0.5 and R is 0.5
%% or SingleAttack is greater than 0.5, R is SingleAttack
checkSingleAttack(SingleAttack, 0.5) :-
	SingleAttack < 0.5.
checkSingleAttack(SingleAttack, SingleAttack) :-
	SingleAttack >= 0.5.

%% Gets Damage for this attack done by Attacker on Defender
%% Damage = UnitLeft * ( ( BasicAttack + BonusAttack - EArmour) ).
%% Add shield armour value.
%% Tests:
%% attack(zealot, 500, zealot, D). Expect D = 7500
attack(Attacker, AttackerUnitleft, Defender, Damage) :-
	prop(Attacker, groundAttack, BasicAttack),
	getBonusAttack(Attacker, Defender, BonusAttack),
	prop(Defender, armour, DefenderArmour),
	SingleAttack is BasicAttack + BonusAttack - DefenderArmour,
	checkSingleAttack(SingleAttack, NewSingleAttack),
	Damage is AttackerUnitleft * NewSingleAttack,
	print_message(informational, attackMessage(Attacker, AttackerUnitleft, NewSingleAttack, Defender, Damage)).

%% NOTE: Shield will use same Armour as its unit's Armour.
%% It should have it's own armour value.

%%	Looking into Attack
%%		1. Must keep track of UnitsLeft.
%%		2. Keep track of one DamagedUnit per side. Damaged unit is (HPLeft, ShieldLeft)
%%		3. An attack is
%%			Damage = UnitLeft * ( ( BasicAttack + BonusAttack - EArmour) ).
%%			TempHP = EDamagedUnit's HP
%%			EDamagedUnit's HP = EDamagedUnit's HP - Damage. If 0, dead. EUnitLeft - 1. EDamagedUnit HP set to full.
%%			Damage = Damage - TempHP.
%%			Repeat till Damage is 0.
%% Base case
%% Defender lives. Set the New values.
%% Case 1: Shield doesn't break
%% Tests:
%% defend(10, zealot, (100,50),1,(NewHP, NewShield), NewLeft).
defend(Damage, Defender, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), DefenderUnitLeft, (DefenderDamagedUnitHP, NewDefenderDamagedUnitShield), DefenderUnitLeft) :-
	dif(DefenderUnitLeft,0),
	dif(Damage,0),
	NewDefenderDamagedUnitShield is DefenderDamagedUnitShield - Damage,
	NewDefenderDamagedUnitShield >= 0,
	print_message(informational, defendMessage(Defender, DefenderUnitLeft, (DefenderDamagedUnitHP,NewDefenderDamagedUnitShield), Damage)).


%% Case 2: Shield does break, Unit lives
%% Tests:
%% defend(50, zealot, (100,50),1,(NewHP, NewShield), NewLeft).
%% defend(75, zealot, (100,0),1,(NewHP, NewShield), NewLeft).
%% defend(75, zealot, (100,5),1,(NewHP, NewShield), NewLeft).

defend(Damage, Defender, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), DefenderUnitLeft, (NewDefenderDamagedUnitHP, 0), DefenderUnitLeft) :-
	dif(DefenderUnitLeft,0),
	dif(Damage,0),
	NewDefenderDamagedUnitShield is DefenderDamagedUnitShield - Damage,
	NewDefenderDamagedUnitShield < 0,
	NewDamage is Damage - DefenderDamagedUnitShield,
	NewDefenderDamagedUnitHP is DefenderDamagedUnitHP - NewDamage,
	NewDefenderDamagedUnitHP > 0,
	print_message(informational, defendMessage(Defender, DefenderUnitLeft, (NewDefenderDamagedUnitHP,0), Damage)).

%% Case 3: Defender Dies
%% Reduce Total Damage left
%% Check if shield breaks
%% Check if HP hits 0
%% Subtract total damage
%% Setup new frontline unit
%% Unit count down by one
%% Tests:
%% defend(1000, zealot, (100,50),100,(NewHP, NewShield), NewLeft).	Expect: NewHP = 50  NewShield = 0  NewLeft = 94
%% defend(250, zealot, (100,50),2,(NewHP, NewShield), NewLeft).		Expect: NewHP = 50  NewShield = 0  NewLeft = 1
%% defend(300, zealot, (100,50),2,(NewHP, NewShield), NewLeft).		Expect: NewHP = 100 NewShield = 50 NewLeft = 0
defend(Damage, Defender, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), DefenderUnitLeft, (NewDefenderDamagedUnitHP, NewDefenderDamagedUnitShield), NewDefenderUnitLeft) :-
	dif(DefenderUnitLeft,0),
	dif(Damage,0),
	TempShield is DefenderDamagedUnitShield - Damage,
	TempShield < 0,
	NewDamage is Damage - DefenderDamagedUnitShield,
	TempHP is DefenderDamagedUnitHP - NewDamage,
	TempHP =< 0,
	NewNewDamage is NewDamage - DefenderDamagedUnitHP,
	prop(Defender, shield, FreshShield),
	prop(Defender, hp, FreshHP),
	TempUnitLeft is DefenderUnitLeft - 1,
	DamageTaken is Damage - NewNewDamage,
	print_message(informational, defenderDiedMessage(Defender, TempUnitLeft, DamageTaken, NewNewDamage)),
	defend(NewNewDamage, Defender, (FreshHP, FreshShield), TempUnitLeft, (NewDefenderDamagedUnitHP, NewDefenderDamagedUnitShield), NewDefenderUnitLeft).


%% After unit died in defence, and 0 units left Done.
defend(_, _, (_, _), 0, (0, 0), 0).

%% 0 damage left after unit died, defence is over
defend(0, _, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), TempUnitLeft, (DefenderDamagedUnitHP, DefenderDamagedUnitShield), TempUnitLeft) :-
	dif(TempUnitLeft,0).


%% Jumps to next attack

%% No one can hit. Jump to next attack. Cases: Enemey is next hit, You're next hit, you both are next hit(same ENextHit and NextHit)
%% Enemy is next hit
goToNextAttack(ENextHit, NextHit, 0, NewNextHit) :-
	dif(ENextHit,NextHit),
	ENextHit < NextHit,
	NewNextHit is NextHit - ENextHit.

%% You're next hit
goToNextAttack(ENextHit, NextHit, NewENextHit, 0) :-
	dif(ENextHit,NextHit),
	NextHit < ENextHit,
	NewENextHit is ENextHit - NextHit.
%% Both are next hit
goToNextAttack(NextHit, NextHit, 0, 0).

%% Looking at Tick
%%	One of ENextHit and NextHit is 0.
%%
%%	1.
%%		Need to keep track of NextHit.
%%		Everytime NextHit hits 0:
%%			1. Attack.
%%			2. Set NextHit to CD.
%% tick(EUnit, Unit, EUnitLeft, UnitLeft, ENextHit, NextHit, DamagedUnit, EDamagedUnit, R)
%% Eunit - Enemy's Unit
%% Unit - Your Unit
%% EUnitLeft - Enemy's units left (Battle is over when at 0)
%% UnitLeft - Your units left (Battle is over when at 0)
%% ENextHit - Ticks till enemy can attack (attacks at 0)
%% NextHit - Ticks till you can attack (attacks at 0)
%% EDamagedUnit - Enemy's frontline unit, gets hit first and can have non full hp/shield
%% DamagedUnit - your frontline unit, gets hit first and can have non full hp/shield
%% R is result of battle, (Unit, UnitLeft, EUnitLeft)

%% Tests:
%% tick(zealot,zealot,70,60,0,0,(100,50),(100,50),R).

%% No Enemies left!!! Record result and exit tick.
tick(EUnit, Unit, EUnitLeft, UnitLeft, _, _, _, _, (Unit,UnitLeft,0)) :-
	EUnitLeft =< 0,
	UnitLeft > 0,
	print_message(banner, battleEndBanner()),
	print_message(informational, battleEnd(EUnit, Unit, UnitLeft)).

%% No Units left :( Record result and exit tick.
tick(EUnit, Unit, EUnitLeft, UnitLeft, _, _, _, _, (Unit,0,EUnitLeft)) :-
	UnitLeft =< 0,
	print_message(banner, battleEndBanner()),
	print_message(informational, battleEnd(Unit, EUnit, EUnitLeft)).

%% Unit can hit
tick(EUnit, Unit, EUnitLeft, UnitLeft, ENextHit, 0, EDamagedUnit, DamagedUnit, R) :-
	EUnitLeft > 0,
	UnitLeft > 0,
	ENextHit > 0,
	print_message(banner, attackBanner()),
	attack(Unit, UnitLeft, EUnit, Damage),
	print_message(banner, defendBanner()),
	defend(Damage, EUnit, EDamagedUnit, EUnitLeft, NewEDamageUnit, NewEUnitLeft),
	prop(Unit, coolDown, CD),
	CDms is CD / 0.01,
	goToNextAttack(ENextHit, CDms, NewENextHit, NewNextHit),
	print_message(banner, nextAttackBanner()),
	print_message(informational, nextAttackMessage(EUnit,Unit,NewENextHit, NewNextHit)),
	tick(EUnit, Unit, NewEUnitLeft, UnitLeft, NewENextHit, NewNextHit, NewEDamageUnit, DamagedUnit, R).


%% Enemy unit can hit
tick(EUnit, Unit, EUnitLeft, UnitLeft, 0, NextHit, EDamagedUnit, DamagedUnit, R) :-
	EUnitLeft > 0,
	UnitLeft > 0,
	NextHit > 0,
	print_message(banner, attackBanner()),
	attack(EUnit, EUnitLeft, Unit, Damage),
	print_message(banner, defendBanner()),
	defend(Damage, Unit, DamagedUnit, UnitLeft, NewDamageUnit, NewUnitLeft),
	prop(EUnit, coolDown, ECD),
	ECDms is ECD / 0.01,
	goToNextAttack(ECDms, NextHit, NewENextHit, NewNextHit),
	print_message(banner, nextAttackBanner()),
	print_message(informational, nextAttackMessage(EUnit,Unit,NewENextHit, NewNextHit)),
	tick(EUnit, Unit, EUnitLeft, NewUnitLeft, NewENextHit, NewNextHit, EDamagedUnit, NewDamageUnit, R).

%% Both units can hit
%% Both attack with full force.
%% Then defend.
tick(EUnit, Unit, EUnitLeft, UnitLeft, 0, 0, EDamagedUnit, DamagedUnit, R) :-
	EUnitLeft > 0,
	UnitLeft > 0,
	print_message(banner, attackBanner()),
	attack(EUnit, EUnitLeft, Unit, EDamage),
	print_message(banner, attackBanner()),
	attack(Unit, UnitLeft, EUnit, Damage),
	print_message(banner, defendBanner()),
	defend(EDamage, Unit, DamagedUnit, UnitLeft, NewDamageUnit, NewUnitLeft),
	print_message(banner, defendBanner()),
	defend(Damage, EUnit, EDamagedUnit, EUnitLeft, NewEDamageUnit, NewEUnitLeft),
	prop(EUnit, coolDown, ECD),
	prop(Unit, coolDown, CD),
	ECDms is ECD / 0.01,
	CDms is CD / 0.01,
	goToNextAttack(ECDms,CDms,NewENextHit,NewNextHit),
	print_message(banner, nextAttackBanner()),
	print_message(informational, nextAttackMessage(EUnit,Unit,NewENextHit, NewNextHit)),
	tick(EUnit, Unit, NewEUnitLeft, NewUnitLeft, NewENextHit, NewNextHit, NewEDamageUnit, NewDamageUnit, R).


% Res is 1(true) if the N is greater than 0, meaning User can make the
% Unit.
availableUnit(Unit, MinAvailable, GasAvailable, Res) :- buildUnits(Unit, MinAvailable, GasAvailable, N), N>0, Res is 1.

% Builds a list of units that are available to make from the input list
%% Example availableUnits(500,0,[zealot,immortal,probe,colossus,stalker],[],R). gives R = [probe, zealot]
availableUnits(_, _, [], L, L).
availableUnits(MinAvailable, GasAvailable, [H|T], Acc, Result) :- availableUnit(H, MinAvailable, GasAvailable, 1) ->
availableUnits(MinAvailable, GasAvailable, T, [H|Acc], Result);
print_message(informational, noUnit(H)),
availableUnits(MinAvailable,GasAvailable,T,Acc,Result).

% Filters a list of units in reverse order according to the race and
% resources available.
filterUserUnit(Race, MinAvailable, GasAvailable, Result) :- inspectRace(Race,ListofAllUnits), availableUnits(MinAvailable, GasAvailable, ListofAllUnits, [], Result).

% Reverse the order back.
filterUserUnitInOrder(Race, MinAvailable, GasAvailable, OrderedResult) :-
	filterUserUnit(Race, MinAvailable, GasAvailable, Result),
	reverse(Result, OrderedResult).

% Calculate the mineral spent; lower the number, more efficient the unit is.
mineralSpent(Unit,UnitsLeft, MineralSpent) :-
	prop(Unit,mineral, MinCost),
	MineralSpent is UnitsLeft*MinCost.


% Calculate the gas spent; lower the number, more efficient the
% unit is.
gasSpent(Unit,UnitsLeft, GasSpent) :-
	prop(Unit, gas, GasCost),
	GasSpent is UnitsLeft*GasCost.

% Calculate the resource spent; lower the number, more efficient the
% unit is.
resourceSpent(Unit, GasToMin, UnitsLeft, ResourceSpent) :-
	prop(Unit,mineral, MinCost),
	prop(Unit,gas,GasCost),
	UnitCost = MinCost+GasCost*GasToMin,
	ResourceSpent is UnitsLeft*UnitCost.

% Calculate the resource spent, returning the Mineral and Gas spent
% separate.
resourceSpent2(Unit, GasToMin, UnitsLeft, MineralSpent, GasSpent, ResourceSpent) :-
	prop(Unit, mineral, MinCost),
	prop(Unit,gas,GasCost),
	UnitCost = MinCost+GasCost*GasToMin,
	MineralSpent is UnitsLeft*MinCost,
	GasSpent is UnitsLeft*GasCost,
	ResourceSpent is UnitsLeft*UnitCost.

% Return the cost efficiency of the unit.
costEfficiency(Unit, GasToMin, UnitsLeft, MinAv, GasAv, (Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft)) :-
	prop(Unit, mineral, MinCost),
	prop(Unit,gas,GasCost),
	UnitCost = MinCost+GasCost*GasToMin,
	ResourceAv = MinAv+GasAv*GasToMin,
	MineralSpent is UnitsLeft*MinCost,
	GasSpent is UnitsLeft*GasCost,
	ResourceSpent is UnitsLeft*UnitCost,
	buildUnits(Unit,MinAv,GasAv,N),
	MinLeft is MinAv-(N*MinCost-MineralSpent),
	GasLeft is GasAv-(N*GasCost-GasSpent),
	ResourceLeft is ResourceAv-((N*MinCost+N*GasCost*GasToMin)-ResourceSpent).

% Return the list of all units' cost efficiency
costEfficiencyList([],_,_,_,[]).
costEfficiencyList([(Unit,UnitsLeft)|T],MinAv,GasAv,GasToMin,[R1|R]) :-
	costEfficiency(Unit, GasToMin, UnitsLeft, MinAv, GasAv, R1),
	costEfficiencyList(T,MinAv,GasAv,GasToMin,R).


% Return the cost efficiency of the unit with EUnitsLeft
costEfficiency2(Unit, GasToMin, UnitsLeft, MinAv, GasAv, EUnitsLeft, (Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)) :-
	prop(Unit, mineral, MinCost),
	prop(Unit,gas,GasCost),
	UnitCost = MinCost+GasCost*GasToMin,
	ResourceAv = MinAv+GasAv*GasToMin,
	MineralSpent is UnitsLeft*MinCost,
	GasSpent is UnitsLeft*GasCost,
	ResourceSpent is UnitsLeft*UnitCost,
	buildUnits(Unit,MinAv,GasAv,N),
	MinLeft is MinAv-(N*MinCost-MineralSpent),
	GasLeft is GasAv-(N*GasCost-GasSpent),
	ResourceLeft is ResourceAv-((N*MinCost+N*GasCost*GasToMin)-ResourceSpent).

% Return the list of all units' cost efficiency with EUnitsLeft
costEfficiencyList2([],_,_,_,[]).
costEfficiencyList2([(Unit,UnitsLeft,EUnitsLeft)|T],MinAv,GasAv,GasToMin,[R1|R]) :-
	costEfficiency2(Unit, GasToMin, UnitsLeft, MinAv, GasAv,EUnitsLeft, R1),
	costEfficiencyList2(T,MinAv,GasAv,GasToMin,R).

% Perform a merge sort to sort the most cost efficient units in order
divide(L,A,B):- halve(L,[],A,B).
halve(L,L,[],L).      % for lists of even length
halve(L,[_|L],[],L).  % for lists of odd length
halve([H|T],Acc,[H|L],B):-halve(T,[_|Acc],L,B).

merge_sort([],[]).
merge_sort([X],[X]).
merge_sort(List,Sorted):-
	List=[_,_|_],
	divide(List,L1,L2),
	merge_sort(L1,Sorted1),merge_sort(L2,Sorted2),
	merge(Sorted1,Sorted2,Sorted).

merge([],L,L).
merge(L,[],L):-L\=[].
merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],
      [(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T]):-
	EUnitsLeft = 0,
	EUnitsLeft2 = 0,
	ResourceLeft>ResourceLeft2,
	merge(T1,[(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],T).
merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T]):-
	EUnitsLeft = 0,
	EUnitsLeft2 = 0,
	ResourceLeft=<ResourceLeft2,
	merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],T2,T).
merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],
      [(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T]):-
	EUnitsLeft = 0,
	EUnitsLeft2 \= 0,
	merge(T1,[(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],T).
merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T]):-
	EUnitsLeft \= 0,
	EUnitsLeft2 = 0,
	merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],T2,T).
merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],
      [(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T]):-
	EUnitsLeft \= 0,
	EUnitsLeft2 \= 0,
	ResourceLeft > ResourceLeft2,
	merge(T1,[(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],T).
merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T2],
      [(Unit2,MinLeft2,GasLeft2,ResourceLeft2,UnitsLeft2,EUnitsLeft2)|T]):-
	EUnitsLeft \= 0,
	EUnitsLeft2 \= 0,
	ResourceLeft =< ResourceLeft2,

	merge([(Unit,MinLeft,GasLeft,ResourceLeft,UnitsLeft,EUnitsLeft)|T1],T2,T).
