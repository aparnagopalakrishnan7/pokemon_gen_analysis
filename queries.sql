-- You must not change the next line or the table definitions.
SET SEARCH_PATH TO projectschema;

-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<           QUESTION ONE                  >>>>>>>>>>>>>>>>>>>>>>>>>

-- Legendary vs SubLegendary Pokemon 

-- This table contains the distribution of Legendary and SubLegendary pokemon by types. 
drop table if exists DistributionByTypeInfo cascade; 
create table DistributionByTypeInfo (
	primaryType text, 
	numLegendary int, 
	numSublegendary int
);

drop table if exists AbilityInfo cascade; 
create table AbilityInfo (
	-- either Legendary or Sublegendary 
	category text, 
	numZeroAbility int, 
	numOneAbility int, 
	numTwoAbility int
);

drop table if exists AvgStatsComparisonInfo cascade; 
create table AvgStatsComparisonInfo (
 	PrimaryType text,
        DiffAvgHeight float,  
	DiffAvgWeight float,  
	DiffAvgAttack float,  
	DiffAvgDefence float,  
	DiffAvgSpecialAttack float,  
	DiffAvgSpecialDefence float,  
	DiffAvgSpeed float
);

-- Get the distribution of Legendary and SubLegendary Pokemon by their types and the average number of egg types for each category by type.  
-- first, getting the distribution by type for legendary pokemon 
DROP VIEW IF EXISTS NonZeroLegendaryByType CASCADE; 
CREATE VIEW NonZeroLegendaryByType AS 
SELECT i.PrimaryType, count(*) as numLegendary, avg(l.NumeggType) as avgNumEggType
FROM LegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name
GROUP BY i.PrimaryType; 
-- they all have avgnumeggtype = 1. 

-- give 0 to the values for the types for which there are no legendary pokemon. 
DROP VIEW IF EXISTS ZeroLegByType CASCADE; 
CREATE VIEW ZeroLegByType AS 
SELECT t.Name, 0 as numLegendary, 0 as avgNumEggType
FROM TypeInfo t
WHERE t.Name not in (select distinct primaryType from NonZeroLegendaryByType);

-- combine to get information about legendary for EVERY type 
DROP VIEW IF EXISTS LegendaryByType CASCADE; 
CREATE VIEW LegendaryByType AS 
(SELECT * from NonZeroLegendaryByType)
UNION 
(SELECT * from ZeroLegByType);

-- next, getting the distribution by type for sublegendary pokemon
DROP VIEW IF EXISTS NonZeroSubLegendaryByType CASCADE; 
CREATE VIEW NonZeroSubLegendaryByType AS 
SELECT i.PrimaryType, count(*) as numSubLegendary,  avg(l.NumeggType) as avgNumEggType
FROM SubLegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name
GROUP BY i.PrimaryType; 
-- they also all have numeggtype = 1, so comparison with Legendary pokemon on this parameter will not be informative. 

-- give 0 to the values for the types for which there are no sublegendary pokemon.
DROP VIEW IF EXISTS ZeroSubLegByType CASCADE; 
CREATE VIEW ZeroSubLegByType AS 
SELECT t.Name, 0 as numSubLegendary, 0 as avgNumEggType
FROM TypeInfo t
WHERE t.Name not in (select distinct primaryType from NonZeroSubLegendaryByType);

-- combine to get information about legendary for EVERY type 
DROP VIEW IF EXISTS SubLegendaryByType CASCADE; 
CREATE VIEW SubLegendaryByType AS 
(SELECT * from NonZeroSubLegendaryByType)
UNION 
(SELECT * from ZeroSubLegByType);

-- combine the information from the LegendaryByType and SubLegendaryByType queries. we are not including the results regarding avgnumeggtype because all non-zero values of this attribute have the same value for both legendary and sublegendary pokemon as discussed before. 
DROP VIEW IF EXISTS DistributionByType CASCADE; 
CREATE VIEW DistributionByType AS
SELECT t1.PrimaryType, t2.numLegendary, t1.numSubLegendary
FROM SubLegendaryByType t1, LegendaryByType t2
WHERE t1.PrimaryType = t2.PrimaryType;

-- Get the difference of averages of height, weight, HP, Attack, Defence, SpecialAttack, SpecialDefence, and Speed statistics for Legendary and SubLegendary Pokemon for each type. Positive value indicates that Legendary Pokemon has a higher average for that stat. Negative value indicates that SubLegendary Pokemon has a higher average for that stat. 
DROP VIEW IF EXISTS AverageStats CASCADE; 
CREATE VIEW AverageStats AS 
-- combining rows from legendary and sublegendary tables 
SELECT t1.PrimaryType, (LegAvgHeight - SubLegAvgHeight) as AvgHeight,  (LegAvgWeight - SubLegAvgWeight) as AvgWeight,  (LegAvgAttack - SubLegAvgAttack) as AvgAttack,  (LegAvgDefence - SubLegAvgDefence) as AvgDefence,  (LegAvgSpecialAttack - SubLegAvgSpecialAttack) as AvgSpecialAttack,  (LegAvgSpecialDefence - SubLegAvgSpecialDefence) as AvgSpecialDefence,  (LegAvgSpeed - SubLegAvgSpeed) as AvgSpeed
FROM 
-- getting average values for legendary pokemon 
(SELECT i.PrimaryType, avg(i.Height) as LegAvgHeight, avg(i.Weight) as LegAvgWeight, avg(i.HP) as LegAvgHP, avg(i.Attack) as LegavgAttack, avg(i.Defence) as LegavgDefence, avg(i.SpecialAttack) as LegAvgSpecialAttack, avg(i.SpecialDefence) as LegAvgSpecialDefence, avg(Speed) as LegavgSpeed
FROM LegendaryPokemon l, BasicInfo i 
WHERE l.pID = i.pID and l.Name = i.Name
GROUP BY i.PrimaryType) t1, 
-- getting average values for sublegendary pokemon 
(SELECT i.PrimaryType, avg(i.Height) as SubLegAvgHeight, avg(i.Weight) as SubLegAvgWeight, avg(i.HP) as SubLegAvgHP, avg(i.Attack) as SubLegavgAttack, avg(i.Defence) as SubLegavgDefence, avg(i.SpecialAttack) as SubLegAvgSpecialAttack, avg(i.SpecialDefence) as SubLegAvgSpecialDefence, avg(Speed) as SubLegavgSpeed
FROM SubLegendaryPokemon l, BasicInfo i 
WHERE l.pID = i.pID and l.Name = i.Name
GROUP BY i.PrimaryType) t2
WHERE t1.PrimaryType = t2.PrimaryType;

-- get sublegendary pokemon which have a gender (i.e. are in the genderedPokemon table).
DROP VIEW IF EXISTS GenderedSubLegendary CASCADE;
CREATE VIEW GenderedSubLegendary AS
SELECT g.pID, g.Name
FROM GenderedPokemon g, SubLegendaryPokemon l 
WHERE g.pID = l.pID and g.name = l.Name;

-- get legendary pokemon which have a gender (i.e. are in the genderedPokemon table). 
DROP VIEW IF EXISTS GenderedLegendary CASCADE;
CREATE VIEW GenderedLegendary AS
SELECT g.pID, g.Name
FROM GenderedPokemon g, LegendaryPokemon l 
WHERE g.pID = l.pID and g.name = l.Name;
-- since no legendary pokemon has a gender, we cannot compare legendary and sublegendary pokemon on this parameter either. 

-- below doesn't matter because none of the current legendary pokemon are gendered. this was a line of questioning that could be explored in future generations, if gendered Legendary pokemon are introduced.  
-- Categorising by types, get the average percent of males of Legendary and SubLegendaryPokemon. 
DROP VIEW IF EXISTS AvgGendered CASCADE; 
CREATE VIEW AvgGendered AS
SELECT t1.PrimaryType, t1.avgPercentMale as LegAvgPercentMale, t2.avgPercentMale as SubLegAvgPercentMale
-- getting average info for legendary pokemon 
FROM (SELECT b.PrimaryType, avg(g.percentMale) as avgPercentMale
FROM LegendaryPokemon l, GenderedPokemon g, BasicInfo b
WHERE l.pID = g.pID and l.Name = g.Name and l.pID = b.pID and l.Name = b.Name
GROUP BY b.PrimaryType) t1, 
-- getting average info for sublegendary pokemon 
(SELECT b.PrimaryType, avg(g.percentMale) as avgPercentMale
FROM SubLegendaryPokemon l, GenderedPokemon g, BasicInfo b
WHERE l.pID = g.pID and l.Name = g.Name and l.pID = b.pID and l.Name = b.Name
GROUP BY b.PrimaryType) t2
WHERE t1.PrimaryType = t2.PrimaryType;

-- get number of legendary pokemon which have no primary ability and no secondary ability. 
DROP VIEW IF EXISTS zeroAbilityLegendary CASCADE; 
CREATE VIEW zeroAbilityLegendary AS 
SELECT count(*) as numzeroleg
FROM LegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.PrimaryAbility is NULL and (l.pID, l.Name) not in (select pID, Name from SecondaryAbilityInfo);

-- get number of legendary pokemon which have only a primary ability and no secondary ability. 
DROP VIEW IF EXISTS OneAbilityLegendary CASCADE; 
CREATE VIEW OneAbilityLegendary AS 
SELECT count(*) as numoneLeg
FROM LegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.PrimaryAbility is not NULL and (l.pID, l.Name) not in (select pID, Name from SecondaryAbilityInfo);

-- get number of legendary pokemon which have two abilities. 
DROP VIEW IF EXISTS twoAbilityLegendary CASCADE; 
CREATE VIEW twoAbilityLegendary AS 
SELECT count(*) as numTwoLeg
FROM LegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.primaryAbility is not NULL and (l.pID, l.Name) in (select pID, Name from SecondaryAbilityInfo);

-- get number of sublegendary pokemon which have no primary ability and no secondary ability. 
DROP VIEW IF EXISTS zeroAbilitySubLegendary CASCADE; 
CREATE VIEW zeroAbilitySubLegendary AS 
SELECT count(*) as numZeroSubLeg
FROM SubLegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.PrimaryAbility is NULL and (l.pID, l.Name) not in (select pID, Name from SecondaryAbilityInfo);

-- get number of legendary pokemon which have only a primary ability and no secondary ability. 
DROP VIEW IF EXISTS OneAbilitySubLegendary CASCADE; 
CREATE VIEW OneAbilitySubLegendary AS 
SELECT count(*) as numonesubleg
FROM SubLegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.PrimaryAbility is not NULL and (l.pID, l.Name) not in (select pID, Name from SecondaryAbilityInfo);

-- get number of legendary pokemon which have two abilities. 
DROP VIEW IF EXISTS twoAbilitySubLegendary CASCADE; 
CREATE VIEW twoAbilitySubLegendary AS 
SELECT count(*) as numTwoSubLeg
FROM SubLegendaryPokemon l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.primaryAbility is not NULL and (l.pID, l.Name) in (select pID, Name from SecondaryAbilityInfo);

-- insert information from distributionByType into table assigned.  
insert into distributionbyTypeInfo
select * from distributionBytype;

-- insert information about number of abilities of legendary pokemon. 
insert into AbilityInfo 
VALUES ('Legendary'::text, (select numzeroleg::int from zeroabilityLegendary), (select numoneleg::int from oneAbilityLegendary), (select numTwoleg::int from twoAbilityLegendary));

-- insert information about number of abilities of sublegendary pokemon. 
insert into AbilityInfo 
VALUES ('SubLegendary'::text, (select numzerosubleg::int from zeroabilitySubLegendary), (select numonesubleg::int from oneAbilitySubLegendary), (select numTwosubleg::int from twoAbilitySubLegendary));

-- insert average stats info 
insert into AvgStatsComparisonInfo 
select * from averageStats;




-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<           QUESTION TWO                  >>>>>>>>>>>>>>>>>>>>>>>>>


DROP TABLE IF EXISTS q2 cascade;

CREATE TABLE q2 (
    category Char(20),
    HP Real,
    Attack Real,
    Defense Real,
    SpecialAttack Real,
    SpecialDefence Real,
    Speed Real,
    CatchRate Real
);


-- All the stats of each mythical pokemon
DROP VIEW IF EXISTS PokemonMythicalTypes CASCADE;
CREATE VIEW PokemonMythicalTypes AS
SELECT b.pID, b.Name, GenerationNumber, HP, Attack, Defence, SpecialAttack, SpecialDefence, Speed, CatchRate, PrimaryAbility
FROM BasicInfo b, MythicalPokemon m
WHERE b.pID = m.pID and b.Name = m.Name;

-- All the stats of each non-mythical pokemon
DROP VIEW IF EXISTS NonMythicalPokemons CASCADE;
CREATE VIEW NonMythicalPokemons AS
(SELECT b.pID, b.Name, GenerationNumber, HP, Attack, Defence, SpecialAttack, SpecialDefence, Speed, CatchRate, PrimaryAbility
FROM BasicInfo b)
EXCEPT
(SELECT * FROM PokemonMythicalTypes);


-- Breaking the stats comparison between mythical and non-mythical pokemon down:

-- compare HP
DROP VIEW IF EXISTS EachTypeAvgHP CASCADE;
CREATE VIEW EachTypeAvgHP AS
(SELECT pID, 'mythical' as category, avg(HP) as HP
FROM PokemonMythicalTypes
GROUP BY pID)
UNION
(SELECT pID, 'non-mythical' as category, avg(HP) as HP
FROM NonMythicalPokemons
GROUP BY pID);

DROP VIEW IF EXISTS TotalAverageHP CASCADE;
CREATE VIEW TotalAverageHP AS
SELECT category, avg(HP) as HP
FROM EachTypeAvgHP
GROUP BY category;


-- compare Attack
DROP VIEW IF EXISTS EachTypeAvgAttack CASCADE;
CREATE VIEW EachTypeAvgAttack AS
(SELECT pID, 'mythical' as category, avg(Attack) as Attack
FROM PokemonMythicalTypes
GROUP BY pID)
UNION
(SELECT pID, 'non-mythical' as category, avg(Attack) as Attack
FROM NonMythicalPokemons
GROUP BY pID);

DROP VIEW IF EXISTS TotalAverageAttack CASCADE;
CREATE VIEW TotalAverageAttack AS
SELECT category, avg(Attack) as Attack
FROM EachTypeAvgAttack
GROUP BY category;


-- compare Defence
DROP VIEW IF EXISTS EachTypeAvgDefence CASCADE;
CREATE VIEW EachTypeAvgDefence AS
(SELECT pID, 'mythical' as category, avg(Defence) as Defence
FROM PokemonMythicalTypes
GROUP BY pID)
UNION
(SELECT pID, 'non-mythical' as category, avg(Defence) as Defence
FROM NonMythicalPokemons
GROUP BY pID);

DROP VIEW IF EXISTS TotalAverageDefence CASCADE;
CREATE VIEW TotalAverageDefence AS
SELECT category, avg(Defence) as Defence
FROM EachTypeAvgDefence
GROUP BY category;


-- compare SpecialAttack
DROP VIEW IF EXISTS EachTypeAvgSpecialAttack CASCADE;
CREATE VIEW EachTypeAvgSpecialAttack AS
(SELECT pID, 'mythical' as category, avg(SpecialAttack) as SpecialAttack
FROM PokemonMythicalTypes
GROUP BY pID)
UNION
(SELECT pID, 'non-mythical' as category, avg(SpecialAttack) as SpecialAttack
FROM NonMythicalPokemons
GROUP BY pID);

DROP VIEW IF EXISTS TotalAverageSpecialAttack CASCADE;
CREATE VIEW TotalAverageSpecialAttack AS
SELECT category, avg(SpecialAttack) as SpecialAttack
FROM EachTypeAvgSpecialAttack
GROUP BY category;


-- compare SpecialDefence
DROP VIEW IF EXISTS EachTypeAvgSpecialDefence CASCADE;
CREATE VIEW EachTypeAvgSpecialDefence AS
(SELECT pID, 'mythical' as category, avg(SpecialDefence) as SpecialDefence
FROM PokemonMythicalTypes
GROUP BY pID)
UNION
(SELECT pID, 'non-mythical' as category, avg(SpecialDefence) as SpecialDefence
FROM NonMythicalPokemons
GROUP BY pID);

DROP VIEW IF EXISTS TotalAverageSpecialDefence CASCADE;
CREATE VIEW TotalAverageSpecialDefence AS
SELECT category, avg(SpecialDefence) as SpecialDefence
FROM EachTypeAvgSpecialDefence
GROUP BY category;


-- compare speed
DROP VIEW IF EXISTS EachTypeAvgSpeed CASCADE;
CREATE VIEW EachTypeAvgSpeed AS
(SELECT pID, 'mythical' as category, avg(speed) as Speed
FROM PokemonMythicalTypes
GROUP BY pID)
UNION
(SELECT pID, 'non-mythical' as category, avg(Speed) as Speed
FROM NonMythicalPokemons
GROUP BY pID);

DROP VIEW IF EXISTS TotalAverageSpeed CASCADE;
CREATE VIEW TotalAverageSpeed AS
SELECT category, avg(speed) as Speed
FROM EachTypeAvgSpeed
GROUP BY category;


-- compare catch rate
DROP VIEW IF EXISTS EachTypeAvgCatchRate CASCADE;
CREATE VIEW EachTypeAvgCatchRate AS
(SELECT pID, 'mythical' as category, avg(CatchRate) as CatchRate
FROM PokemonMythicalTypes
GROUP BY pID, CatchRate
HAVING CatchRate IS NOT null)
UNION
(SELECT pID, 'non-mythical' as category, avg(CatchRate) as CatchRate
FROM NonMythicalPokemons
GROUP BY pID, CatchRate
HAVING CatchRate IS NOT NULL);

DROP VIEW IF EXISTS TotalAverageCatchRate CASCADE;
CREATE VIEW TotalAverageCatchRate AS
SELECT category, avg(CatchRate) as CatchRate
FROM EachTypeAvgCatchRate
GROUP BY category;

-- get number of mythical pokemon who have only one ability
DROP VIEW IF EXISTS OneAbilityMythical CASCADE; 
CREATE VIEW OneAbilityMythical AS 
SELECT count(*) as oneAbility
FROM PokemonMythicalTypes l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.PrimaryAbility is not NULL and (l.pID, l.Name) not in (select pID, Name from SecondaryAbilityInfo);

-- get number of mythical pokemon who have two abilities
DROP VIEW IF EXISTS TwoAbilityMythical CASCADE; 
CREATE VIEW TwoAbilityMythical AS 
SELECT count(*) as twoAbility
FROM PokemonMythicalTypes l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.primaryAbility is not NULL and (l.pID, l.Name) in (select pID, Name from SecondaryAbilityInfo);

-- get number of non-mythical pokemon who have only one ability
DROP VIEW IF EXISTS OneAbilityNonMythical CASCADE; 
CREATE VIEW OneAbilityNonMythical AS 
SELECT count(*) as oneAbility
FROM NonMythicalPokemons l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.PrimaryAbility is not NULL and (l.pID, l.Name) not in (select pID, Name from SecondaryAbilityInfo);

-- get number of non-mythical pokemon who have two abilities
DROP VIEW IF EXISTS TwoAbilityNonMythical CASCADE; 
CREATE VIEW TwoAbilityNonMythical AS 
SELECT count(*) as twoAbility
FROM NonMythicalPokemons l, BasicInfo i
WHERE l.pID = i.pID and l.Name = i.Name and i.primaryAbility is not NULL and (l.pID, l.Name) in (select pID, Name from SecondaryAbilityInfo);



-- THE QUERIES DOWN BELOW:

-- all the average stats combined, divided by mythical and non-mythical pokemon (QUERY 1)
INSERT INTO q2
(SELECT * FROM
TotalAverageHP NATURAL JOIN TotalAverageAttack
               NATURAL JOIN TotalAverageDefence 
               NATURAL JOIN TotalAverageSpecialAttack 
               NATURAL JOIN TotalAverageSpecialDefence 
               NATURAL JOIN TotalAverageSpeed
               NATURAL JOIN TotalAverageCatchRate);

-- QUERY 2
SELECT * FROM q2;

-- the number of mythical pokemons with one ability and those with two abilities (QUERY 3)
SELECT * FROM OneAbilityMythical, TwoAbilityMythical;

-- the number of non-mythical pokemons with one ability and those with two abilities (QUERY 4)
SELECT * FROM OneAbilityNonMythical, TwoAbilityNonMythical;

-- first generation a mythical pokemon appeared in (QUERY 5)
SELECT min(GenerationNumber)
FROM PokemonMythicalTypes;





-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<           QUESTION THREE                  >>>>>>>>>>>>>>>>>>>>>>>>>



DROP TABLE IF EXISTS RangeAvgInfo CASCADE;
-- this table contains the average of averages of a Pokemon stat for each PrimaryType across all generations and the range = max - min of that stat for each PrimaryType across all generations.  This information provides detail about the differences in strength of Pokemon between generations. 
CREATE TABLE RangeAvgInfo (
	primaryType text,
       	heightrange float,
       	weightrange float,	
	HPrange float,
	Attackrange float,
	Defencerange float,
	SpecialAttackrange float,
	SpecialDefencerange float,
	Speedrange float,
	avgavgheight float,
	avgavgweight float,
	avgavghp float,
	avgavgattack float,
	avgavgdefence float,
	avgavgspecialattack float,
	avgavgspecialdefence float,
	avgavgspeed float
	);

-- this table contains information about how many (primary) types of Pokemon were present in each generation. 
DROP TABLE IF EXISTS NumGenInfo cascade; 
create table numGenInfo (
	generationNumber int, 
	numPrimaryTypes int
);

-- Get the total number of types (primary types) in each generation. This shows how the game became more complex/the Pokemon became more diverse generation-wise.
DROP VIEW IF EXISTS NumGenerationTypes CASCADE;
CREATE VIEW NumGenerationTypes AS 
SELECT i.GenerationNumber, count(distinct i.primarytype) as NumPrimaryTypes
FROM BasicInfo i
GROUP BY i.generationNumber;
-- We find that the generations are very similar in the number of types they had +-1. 

-- Get the average stats for each type in each generation. 
DROP VIEW IF EXISTS GenerationAvgStatsByType cascade; 
CREATE VIEW GenerationAvgStatsByType AS 
SELECT generationNumber, primaryType, avg(height) as avgHeight, avg(weight) as avgWeight,  avg(HP) as avgHP,  avg(attack) as avgAttack,  avg(defence) as avgDefence,  avg(specialAttack) as avgSpecialAttack,  avg(specialDefence) as avgSpecialDefence,  avg(speed) as avgSpeed
FROM BasicInfo
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Comparison of height across generations 
-- Get the average height for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgHeightByType cascade; 
CREATE VIEW GenerationAvgHeightByType AS 
SELECT generationNumber, primaryType, avg(height) as avgHeight
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average height by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS HeightRangeByType cascade; 
CREATE VIEW HeightRangeByType AS
SELECT primaryType, (max(avgHeight) - min(avgHeight)) as HeightRange
FROM generationAvgHeightByType
group by primaryType;

-- compatison of weight across generations 
-- Get the average weight for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgWeightByType cascade; 
CREATE VIEW GenerationAvgWeightByType AS 
SELECT generationNumber, primaryType, avg(weight) as avgWeight
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average weight by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS WeightRangeByType cascade; 
CREATE VIEW WeightRangeByType AS
SELECT primaryType, (max(avgweight) - min(avgWeight)) as WeightRange
FROM generationAvgWeightByType
group by primaryType;

-- comparison of HP across generations 
-- Get the average HP for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgHPByType cascade; 
CREATE VIEW GenerationAvgHPByType AS 
SELECT generationNumber, primaryType, avg(HP) as avgHP
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average HP by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS HPRangeByType cascade; 
CREATE VIEW HPRangeByType AS
SELECT primaryType, (max(avgHP) - min(avgHP)) as HPRange
FROM generationAvgHPByType
group by primaryType;

-- comparison of attack across generations 
-- Get the average attack for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgAttackByType cascade; 
CREATE VIEW GenerationAvgAttackByType AS 
SELECT generationNumber, primaryType, avg(Attack) as avgAttack
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average attack by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS AttackRangeByType cascade; 
CREATE VIEW AttackRangeByType AS
SELECT primaryType, (max(avgAttack) - min(avgAttack)) as AttackRange
FROM generationAvgAttackByType
group by primaryType;

-- comparison of defence across generations 
-- Get the average defence for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgDefenceByType cascade; 
CREATE VIEW GenerationAvgDefenceByType AS 
SELECT generationNumber, primaryType, avg(defence) as avgdefence
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average defence by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS DefenceRangeByType cascade; 
CREATE VIEW DefenceRangeByType AS
SELECT primaryType, (max(avgDefence) - min(avgDefence)) as DefenceRange
FROM generationAvgDefenceByType
group by primaryType;

-- comparison of special attack across generations 
-- Get the average special attack for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgSpecialAttackByType cascade; 
CREATE VIEW GenerationAvgSpecialAttackByType AS 
SELECT generationNumber, primaryType, avg(SpecialAttack) as avgspecialattack
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average special attack by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS specialAttackRangeByType cascade; 
CREATE VIEW SpecialAttackRangeByType AS
SELECT primaryType, (max(avgSpecialAttack) - min(avgSpecialAttack)) as SpecialAttackRange
FROM generationAvgSpecialAttackByType
group by primaryType;

-- comparison of special defence across generations 
-- Get the average special defence for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgSpecialdefenceByType cascade; 
CREATE VIEW GenerationAvgSpecialdefenceByType AS 
SELECT generationNumber, primaryType, avg(Specialdefence) as avgspecialdefence
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average special defence by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS specialdefenceRangeByType cascade; 
CREATE VIEW SpecialdefenceRangeByType AS
SELECT primaryType, (max(avgSpecialdefence) - min(avgSpecialdefence)) as SpecialdefenceRange
FROM generationAvgSpecialdefenceByType
group by primaryType;


-- comparison of speed across generations 
-- Get the average speed for each type of each generation. This is used in future queries. 
DROP VIEW IF EXISTS GenerationAvgspeedByType cascade; 
CREATE VIEW GenerationAvgspeedByType AS 
SELECT generationNumber, primaryType, avg(speed) as avgspeed
from basicInfo 
GROUP BY (generationNumber, primaryType)
order by generationNumber;

-- Get the range = max - min for average speed by type over all generations. This shows us the range of difference of each stat on average. 
DROP VIEW IF EXISTS speedRangeByType cascade; 
CREATE VIEW speedRangeByType AS
SELECT primaryType, (max(avgspeed) - min(avgspeed)) as speedRange
FROM generationAvgspeedByType
group by primaryType;

-- combine the range results from the <Stat>RangeByType views above. 
DROP VIEW IF EXISTS RangeByType cascade; 
CREATE VIEW rangeByType AS 
SELECT h.primaryType, h.heightRange, w.weightRange, hp.HPRange, a.attackrange, d.defenceRange, spa.specialattackrange, spd.specialdefencerange, s.speedrange
FROM heightRangeByType h, weightRangeByType w, hpRangeByType hp, attackRangeByType a, defenceRangeByType d, specialattackRangeByType spa, specialdefenceRangeByType spd, speedRangeByType s
WHERE h.primaryType  = w.primaryType and w.primaryType = hp.primaryType and  hp.primaryType=  a.primaryType and a.primarytype = d.primaryType and  d.primaryType = spa.primaryType and spa.primaryType = spd.primaryType  and spd.primaryType =  s.primaryType;

-- get average of average of stats for each type. (we do this by averaging values for each stat across all generations from GenerationAvgStatsByType.)
DROP VIEW IF EXISTS AvgStatsByType cascade;
CREATE VIEW AvgStatsByType as
select primarytype, avg(avgheight) as AvgAvgHeight, avg(avgweight) as AvgAvgweight, avg(avghp) as AvgAvgHP, avg(avgAttack) as AvgAvgAttack, avg(avgdefence) as AvgAvgDefence, avg(avgSpecialAttack) as AvgAvgSpecialAttack, avg(avgSpecialdefence) as AvgAvgSpecialDefence, avg(avgspeed) as AvgAvgSpeed
from generationAvgStatsByType 
group by primarytype;

-- in order to interpret the ranges, we need the knowledge of scales/average of each of the stats, so combine that information as well. 
DROP VIEW IF EXISTS RangeAvgByType cascade; 
CREATE VIEW RangeAvgByType AS
SELECT *
FROM rangebyType JOIN AvgStatsByType using (primarytype);

-- inserting the values of RangeAvgbyType and GenerationStatsComparison into their respective tables.
INSERT INTO NumGenInfo 
select * from NumGenerationTypes;

INSERT INTO RangeAvgInfo 
select * from rangeAvgByType;
