SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 3,4


--SELECT *
--FROM PortfolioProject.dbo.CovidVacc$
--Order by 3,4

--Select the Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country(India)
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%India%'
order by 1,2

--Looking at total cases vs population
SELECT Location, date, total_cases, population,(total_cases/population)*100 as InfectionPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%India%'
order by 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population, Max(total_cases)as HighestInfectionCount,Max((total_cases/population))*100 as InfectionPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%India%'
Group by location, population
order by InfectionPercentage desc

--Showing countries with highestdeathcount 
SELECT Location, Max(cast(total_deaths as int))as HighestDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%India%'
Where continent is not null
Group by location
order by  HighestDeathCount desc

-- Let's Break things down by continent
--Showing the continents with the highest 

SELECT continent, Max(cast(total_deaths as int))as HighestDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%India%'
Where continent is not null
Group by continent
order by  HighestDeathCount desc

-- GLOBAL NUMBERS
SELECT date, Sum(new_cases) as NewCases, SUM(cast(new_deaths as int)) as totalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercent --, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%India%'
Where continent is not null
Group by date
order by 1,2


Select *
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVacc$ vac
  On dea.location = vac.location
  and dea.date = vac.date

--Looking at Total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVacc$ vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVacc$ vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--Temp Table


Create Table #Pop_Vacc_1
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #Pop_Vacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVacc$ vac
  On dea.location = vac.location
  and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #Pop_Vacc_1

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea 
Join PortfolioProject.dbo.CovidVacc$ vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PopulationVaccinated