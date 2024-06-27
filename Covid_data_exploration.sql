/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From covid_database.CovidDeaths
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_database.CovidDeaths
Where continent is not null 
order by date;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_database.CovidDeaths 
order by date;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_database.CovidDeaths 
order by 1,2;


--  Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_database.CovidDeaths 
Group by Location, Population;


-- Death Percentage  combining all data

SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CONVERT(new_deaths, SIGNED)) AS total_deaths, 
    (SUM(CONVERT(new_deaths, SIGNED)) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM 
    covid_database.CovidDeaths
ORDER BY 
    total_cases, total_deaths;

-- date with maximum new cases

select Location,date,new_cases
from
covid_database.CovidDeaths
ORDER BY 
    new_cases desc limit 1;
    
    

-- date with maximum new deaths

select Location,date,new_deaths
from
covid_database.CovidDeaths
ORDER BY 
    new_deaths desc limit 1;    
    
    
    

-- Total Population vs Vaccinations	


Select dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations,(vac.total_vaccinations/dea.population)*100 as Percentage_popu_vacc
From covid_database.CovidDeaths dea
Join covid_database.covid_vaccination vac
On dea.location = vac.location
and dea.date = vac.date;




-- Shows Percentage of Population that has recieved at least one Covid Vaccine without using total deaths

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
From covid_database.CovidDeaths dea
Join covid_database.covid_vaccination vac

	On dea.location = vac.location
	and dea.date = vac.date
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

drop table PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric(18,2),
New_vaccinations numeric(18,2),
RollingPeopleVaccinated numeric(18,2)
);
INSERT INTO PercentPopulationVaccinated (
    Continent, 
    Location, 
    Date, 
    Population, 
    New_vaccinations, 
    RollingPeopleVaccinated
)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
     COALESCE(NULLIF(vac.new_vaccinations, ''), 0) AS new_vaccinations,  -- Handle empty strings and NULLs
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    covid_database.CovidDeaths dea
JOIN 
    covid_database.covid_vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date;


SELECT *, 
       (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated_view as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    covid_database.CovidDeaths dea
JOIN 
    covid_database.covid_vaccination vac
    ON dea.date = vac.date
where dea.continent is not null ;

