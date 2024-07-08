
Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- select the data that we are going to be using
select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date,total_cases,total_deaths,(CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location,Population, date , total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



Select Location, Population,date , MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population,date
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is  null 
and Location not in ('World','European Union','International','High income','Upper middle income','Lower middle income','Low income')
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- global number
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac(Coninent, Location, Date, Population, New_Vaccinations,RollingPeopleVacinated)
as(
select dea.continent, dea.location,dea.date,population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by  dea.location, dea.date) as rollingpeoplevacinated
--(rollingpeoplevacinated/population)*100
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVacinated/Population)*100
from PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #PercentagePopulationVacinated
create table  #PercentagePopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacinations numeric,
RollingPeopleVacinated numeric,

)
insert into #PercentagePopulationVacinated
select dea.continent, dea.location,dea.date,population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by  dea.location, dea.date) as rollingpeoplevacinated
--(rollingpeoplevacinated/population)*100
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVacinated/Population)*100
from #PercentagePopulationVacinated



-- Creating View to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated;