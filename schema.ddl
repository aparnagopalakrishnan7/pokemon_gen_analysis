drop schema if exists projectschema cascade;
create schema projectschema;
set search_path to projectschema;

-- Type for the Pokemon Stats which must be non-zero. 
create domain Stats as float
	default null 
	check (value >= 0);

create table TypeInfo(
	-- Name of the type like 'Normal', 'Bug', 'Poison' etc.
	Name text primary key, 
	-- Names of the types against which this type is weakest against. 
	WeakestAgainst text,
	-- Names of the types against which this type is resistant towards.
	ResistantTowards text, 
	-- Names of the types against which this type is strongest against. 
	StrongestAgainst text);

create table BasicInfo (
	-- Pokemon ID of this Pokemon.  
	pID integer, 
	-- Name of this Pokemon. 
	Name text unique,
	-- Generation in which this Pokemon was introduced. 
	GenerationNumber integer,  
	-- Species of this Pokemon. 
	Species text not null, 
	-- Name of primary type of this Pokemon. 
	PrimaryType text not null references TypeInfo,
	-- The height of this Pokemon in meters. 
	Height Stats not null,
	-- The weight of this Pokemon in kilograms. 
	Weight Stats not null, 
	-- The name of the primary ability of this Pokemon. 
	PrimaryAbility text, 
	-- The base HP of this Pokemon. 
	HP Stats not null,
	-- The base Attack of this Pokemon. 
	Attack Stats not null,
	-- The base Defence of this Pokemon. 
	Defence Stats not null,      
	-- The base SpecialAttack of this Pokemon. 
	SpecialAttack Stats not null, 
	-- The base SpecialDefence of this Pokemon. 
	SpecialDefence Stats not null,
	-- The base Speed of this Pokemon. 
	Speed Stats not null,
	-- The catch rate of this Pokemon.
	CatchRate Stats, 
	-- The base friendship of this Pokemon when it is caught. 
	BaseFriendship Stats, 
	-- The base experience of this Pokemon when it is caught. 
	BaseExperience Stats,  
	-- The growth rate of this Pokemon. 
	GrowthRate text,
	-- The primary type of the eggs of this Pokemon. This is not a type from the TypeInfo table because there are further subtypes only relevant to eggs and not to hatched Pokemon. 
	PrimaryEggType text,
	-- Number of cycles required to hatch an egg of this Pokemon. 
	EggCycles Stats,
	primary key(pID, Name),
	-- The generation number is always a positive int. 
	check(GenerationNumber > 0));

create table GenderedPokemon (
	-- The unique Pokemon ID of this Pokemon. 
	pID integer, 
	-- Name of this Pokemon. 
	Name text unique,
	-- percent of the population of this Pokemon which is male.
	PercentMale float not null, 
	primary key(pID, Name),
	foreign key (pID, Name) references BasicInfo on delete cascade on update cascade,
	check (0.0 <= PercentMale AND PercentMale <= 100.0)); 

create table SecondaryTypeInfo (
	-- The unique Pokemon ID of this Pokemon. 
	pID integer,
	-- Name of this Pokemon. 
	Name text unique, 
	-- Second type of this Pokemon. 
	SecondaryType text not null references TypeInfo, 
	primary key(pID, Name),
	foreign key (pID, Name) references BasicInfo on delete cascade on update cascade);

create table SecondaryAbilityInfo (
	-- The unique Pokemon ID of this Pokemon. 
	pID integer,
	-- Name of this Pokemon. 
	Name text unique,  
	-- Name of secondary ability of this pokemon. 
	SecondaryAbility text not null, 
	primary key(pID, Name),
	foreign key (pID, Name) references BasicInfo on delete cascade on update cascade); 

create table HiddenAbilityInfo (
	-- The unique Pokemon ID of this Pokemon. 
	pID integer,
	-- Name of this Pokemon. 
	Name text unique,  
	-- Name of hidden ability of this pokemon. 
	HiddenAbility text not null, 
	primary key(pID, Name),
	foreign key (pID, Name) references BasicInfo on delete cascade on update cascade); 

create table LegendaryPokemon(
	-- The unique Pokemon ID of this Pokemon. 
	pID integer,
	-- Name of this Pokemon. 
	Name text unique, 
	-- number of types of eggs of this pokemon. 
	NumEggType integer not null,
	primary key(pID, Name),
	foreign key (pID, Name) references BasicInfo on delete cascade on update cascade);

create table SubLegendaryPokemon(
	-- The unique Pokemon ID of this Pokemon. 
	pID integer,
	-- Name of this Pokemon. 
	Name text unique,  
	-- Number of types of eggs of this pokemon.
	NumEggType integer not null, 
	primary key(pID, Name),
	foreign key (pID, Name) references BasicInfo on delete cascade on update cascade);

create table MythicalPokemon(
	-- The unique Pokemon ID of this Pokemon. 
	pID integer,
	-- Name of this Pokemon. 
	Name text unique, 
	-- number of types of eggs of this pokemon. 
	NumEggType integer not null, 
	primary key(pID, Name),
	foreign key (pID, Name) references BasicInfo on delete cascade on update cascade);


