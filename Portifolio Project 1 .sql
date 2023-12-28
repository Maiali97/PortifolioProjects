Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (CAST(total_deaths as int) / NULLIF(CAST(total_cases as int), 0))*100 as Death_Percent
From PortfolioProject..CovidDeaths$
Where location like '%Egypt%'
and continent is not null
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 

Select location, date, population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as Percent_population_infected
From PortfolioProject..CovidDeaths$
-- Where location like '%Egypt%'
Where continent is not null
Order by 1,2


-- Looking at countries with highest infection rate compared to population 

Select location, population, Max(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as Percent_population_infected
From PortfolioProject..CovidDeaths$
 -- Where location like '%Egypt%'
Group by location, population
Order by Percent_population_infected desc

-- Showing countries with highest Death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
 -- Where location like '%Egypt%'
 Where continent is not null
Group by location
Order by TotalDeathCount desc


-- LET'S break things down by continent 

-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
 -- Where location like '%Egypt%'
 Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS (Death Percentage per day)

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%Egypt%'
Where continent is not null
Group by date
Order by 1,2


 -- GLOBAL NUMBERS (Death Percentage)

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%Egypt%'
Where continent is not null
--Group by date
Order by 1,2



-- Join the two tables (Deaths & Vaccinations)


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USING CTE

WITH PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as Percent_People_Vacc
From PopvsVac

-- USING TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated 
Create Table  #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as Percent_People_Vacc
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated