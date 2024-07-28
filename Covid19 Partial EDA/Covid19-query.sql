-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- EDA 



SELECT location, total_cases , new_cases, total_deaths , population
FROM covid19..CovidDeaths
order by 1,2


-- Cases vs Deaths rate

SELECT location , date ,  total_cases, total_deaths , (total_deaths/total_cases)* 100 as death_rate 
From covid19..CovidDeaths 
Where location like '%Asia' 
order by 1,2



-- Cases vs Population rate

SELECT location , date , population , total_cases , (total_cases/population)*100 as infected_rate
From covid19..CovidDeaths 
Where location like '%Asia'  and continent is not null 
order by infected_rate DESC

-- max infection_rate

SELECT location  , population , MAX(total_cases) as max_total_cases , MAX((total_cases/population))*100 as max_infected_rate
From covid19..CovidDeaths 
where continent is not null
group by location, population
order by max_infected_rate DESC


-- max death_rate

SELECT location  , population , MAX(cast(total_deaths as int )) as max_total_deaths
From covid19..CovidDeaths 
where continent is not null
group by location, population
order by max_total_deaths DESC


-- continents
-- so in our data where continent is null , the value of continents are stored in location column so
-- we have to set continent is null and group bt location to see the correct values 
-- else if we do group by continent , it'll show us incorrect values (eg. one country in that continent's values)

SELECT location , MAX(cast(total_deaths as int )) as max_total_deaths
From covid19..CovidDeaths 
where continent is null
group by location
order by max_total_deaths DESC


-- global numbers 

Select date , SUM(new_cases) as total_cases , SUM(cast(new_deaths as int )) as total_deaths, SUM(cast(new_deaths as int ))/SUM(new_cases) as global_death_rate 
From covid19..CovidDeaths
where continent is not null
group by date
order by 1,2


Select  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int )) as total_deaths, SUM(cast(new_deaths as int ))/SUM(new_cases) as global_death_rate 
From covid19..CovidDeaths
where continent is not null
--group by date
order by 1,2



-- population vs vaccination rate 

Select dea.location , dea.date , dea.population , vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rolling_vaccinated_number
From covid19 .. CovidDeaths as dea 
Join covid19 .. CovidVaccinations as vac 
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null 
	order by 1 , 2

-- CTE
-- when partitioning by a value we don't have to order it by that value 


with PopvsVac (continent , location , date , population , new_vaccinations,  rolling_vaccinated_number)
as (
Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_vaccinated_number
From covid19 .. CovidDeaths as dea 
Join covid19 .. CovidVaccinations as vac 
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null 
	--order by 1 , 2 
	)

Select *  , (rolling_vaccinated_number/population)*100 as vaccinated_rate
From PopvsVac


-- we can either create a new table or use CTE to perform an operation on a newly created variable 

-- Temp Table 
Drop table if exists #VaccinatedRate
Create table #VaccinatedRate
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_vaccinated_number numeric

)

insert into #VaccinatedRate
Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as rolling_vaccinated_number
From covid19 .. CovidDeaths as dea 
Join covid19 .. CovidVaccinations as vac 
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null 
	--order by 1 , 2 
Select *  , (rolling_vaccinated_number/population)*100 as vaccinated_rate
From #VaccinatedRate


--  Creating Views

create view VaccinatedRate as
Select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as rolling_vaccinated_number
From covid19 .. CovidDeaths as dea 
Join covid19 .. CovidVaccinations as vac 
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null 
	--order by 1 , 2 
	



create view globaldeathrate as 

Select date , SUM(new_cases) as total_cases , SUM(cast(new_deaths as int )) as total_deaths, SUM(cast(new_deaths as int ))/SUM(new_cases) as global_death_rate 
From covid19..CovidDeaths
where continent is not null
group by date
--order by 1,2


create view maxdeathrate as 

SELECT location  , population , MAX(cast(total_deaths as int )) as max_total_deaths
From covid19..CovidDeaths 
where continent is not null
group by location, population
--order by max_total_deaths DESC


create view maxinfectionrate as 

SELECT location  , population , MAX(total_cases) as max_total_cases , MAX((total_cases/population))*100 as max_infected_rate
From covid19..CovidDeaths 
where continent is not null
group by location, population
--order by max_infected_rate DESC


