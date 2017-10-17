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

Protoss(zealot).
Terran(marine).
Zerg(zergling).

Mineral(zealot, 100).
Mineral(marine, 50).
Mineral(zergling, 25).

Gas(zealot, 0).
Gas(marine, 0).
Gas(zergling, 0).

Supply(zealot, 2).
Supply(marine, 1).
Supply(zergling, 0.5).

Hp(zealot, 100).
Armor(zealot, 1).
PlasmaShield(zealot, 50).
Upgrade(zealot, 0).
Groundattack(zealot, 16).
CoolDown(zealot, 0.86).
AttributeModifier(zealot, light).
AttributeModifier(zealot, biological).

Hp(marine, 45).
Armor(marine, 0).
Upgrade(marine, 0).
Groundattack(marine, 6).
Airattack(marine, 6).
CoolDown(marine, 0.61).
AttributeModifier(marine, light).
AttributeModifier(marine, biological).

Hp(zergling, 35).
Armor(zergling, 0).
Upgrade(zergling, 0).
Groundattack(zergling, 5).
CoolDown(zergling, 0.497).
AttributeModifier(zergling, light).
AttributeModifier(zergling, biological).


