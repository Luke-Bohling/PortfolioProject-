

/*
Covid-19 Data Exploration 

Skills outlined: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

The following spreadsheets were used for this activity: Covid_Master.xlsx, Covid_Hospitalizations.xlsx, 
Covid_Vaccinations.xlsx, Covid_Demographic.xlsx and Covid_Deaths.xlsx


*/


--Data that we will be starting with


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 


-- Examining total_cases and total_deaths within the United States
-- Looking for what percent of the population has died from covid

SELECT Location, date, total_cases, new_cases, total_cases, total_deaths, (total_deaths/total_cases) *100 as PercentDeath
FROM PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null 
order by 1,2


-- Examining total_cases and population Within the United States
-- Looking for what percent of the population has been infected with covid


SELECT Location, date, total_cases, new_cases, total_cases, total_deaths, (total_cases/population) *100 as PercentInfected 
FROM PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null 
order by 1,2


-- Examining Countries with the highest infection rate compared to their population 
-- Looking for which country has the highest percent of their population infected 


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Examining Countries with the highest death count per population 
-- Looking for which continent who population was effected most by covid 
-- using cast to convert total_deaths to its correct datatype 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- Same as above, however, looking at continents 


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
--order by TotalDeathCount desc


--examining global deaths per global popualtion 


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2


-- examining percent of the population that has been infected and the percentage of people infected that have been to the hospital within the United States.


Select MAX((dea.total_cases/dea.population)) *100 as PercentPopulationInfected, SUM(cast(hosp.hosp_patients as int)) as total_patients, 
SUM(cast(hosp.hosp_patients as int))/SUM(dea.new_cases) *100 as PercentInfectedInHospital
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidHospitalization as hosp
	On dea.location = hosp.location
	and dea.date = hosp.date 
where dea.continent is not null and dea.location like '%state%'
--group by hosp.hosp_patients
order by 1,2


-- examining covid-19 mortality and current risk factors


Select dea.continent, dea.location, dea.date, dea.population, (dea.total_deaths/dea.population) *100 as PercentDead, dem.aged_70_older, dem.population_density, dem.median_age, dem.diabetes_prevalence, dem.cardiovasc_death_rate
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidDemographics as dem
	On dea.location = dem.location
	and dea.date = dem.date 
where dea.continent is not null-- and dea.location like '%states%'
order by 2,3


-- examining total populationa and new vaccinations per day within the United States 

--alter table PortfolioProject..CovidDeaths
	--alter column location varchar (150)


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%states%'
order by 2,3


-- CTE (1) examining max number of people vaccinated per day globally 


With PopvsVac (Continent, Location, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, MAX((RollingPeopleVaccinated)/Population) *100 MaxVaccinated 
From PopvsVac
group by Continent, Location, Population, New_vaccinations, RollingPeopleVaccinated
order by 2,3



-- New rolling count for hospital patients within the United States


Select dea.continent, dea.location, dea.date, dea.population, hosp.hosp_patients
, SUM(cast(hosp.hosp_patients as INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingHospCount
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidHospitalization as hosp
	On dea.location = hosp.location
	and dea.date = hosp.date 
where dea.continent is not null and dea.location like '%states%'
order by 2,3 desc

-- CTE (2) further examination into the percent of a population that has been hospitalized due to covid-19

With PopvsHosp (Continent, Location, Date, Population, Hospital_Patients, RollingHospCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, hosp.hosp_patients
, SUM(cast(hosp.hosp_patients as INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingHospCount
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidHospitalization as hosp
	On dea.location = hosp.location
	and dea.date = hosp.date 
where dea.continent is not null and dea.location like '%states%'
--Order by 2,3
)
Select *, (RollingHospCount/Population) *100 as PercentPopulationInHosp
From PopvsHosp
order by PercentPopulationInHosp desc


--TEMP TABLE (1)

Drop Table if Exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
Select *, (RollingPeopleVaccinated/Population) *100 as PercentVaccinated 
From #PercentPopulationVaccinated 



--Temp Table (2)

Drop Table If Exists #PeopleInHopsital
Create Table #PeopleInHopsital
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
hosp_patients numeric,
RollingHospCount numeric,
)
Insert into #PeopleInHopsital
Select dea.continent, dea.location, dea.date, dea.population, hosp.hosp_patients
, SUM(cast(hosp.hosp_patients as INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingHospCount
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidHospitalization as hosp
	On dea.location = hosp.location
	and dea.date = hosp.date 
where dea.continent is not null --and dea.location like '%states%'
order by 2,3 desc

Select *, (RollingHospCount/Population) *100 as PercentPopulationInHosp
From #PeopleInHopsital
--order by PercentPopulationInHosp desc



-- Creating view to store data for visualizations 

Create View PercentPopulationVaccinatedNew as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
