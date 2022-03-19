SELECT * 
FROM Covid_19_Project..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM Covid_19_Project..CovidVaccinations
--ORDER BY 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_19_Project..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Indicates Likelihood of dying if you contract covid in relative country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From Covid_19_Project..CovidDeaths
Where Location like '%States%'
order by 1,2

--Looking at Total Cases vs Population
--Indicates percentage of population that contracted Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as Positive_Case_Percentage
From Covid_19_Project..CovidDeaths
Where Location like '%States%'
order by 1,2


--Observing countries with highest infection rate compared to Population

Select Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as 
Positive_Case_Percentage
From Covid_19_Project..CovidDeaths
--Where Location like '%States%'
Group by Location, population
order by Positive_Case_Percentage DESC

--Indicates Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
From Covid_19_Project..CovidDeaths
--Where Location like '%States%'
Where continent is not null
Group by Location
order by Total_Death_Count DESC

--OBSERVING A BREAK DOWN OF DEATH COUNT BY CONTINENT
--Indicating Continents with Highest Death Count Per population

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From Covid_19_Project..CovidDeaths
--Where Location like '%States%'
Where continent is not null
Group by continent
order by Total_Death_Count DESC



--Observing Global Numbers

Select date, Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as Death_Percentage
From Covid_19_Project..CovidDeaths
--Where Location like '%States%'
Where continent is not null
Group By date
order by 1,2

--Global Total

Select Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as Death_Percentage
From Covid_19_Project..CovidDeaths
--Where Location like '%States%'
Where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/Population) * 100
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Use CTE
With PopvsVac (continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/Population) * 100
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac




--Temp Table
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_Vaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/Population) * 100
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (Rolling_People_Vaccinated/population)*100
From #PercentagePopulationVaccinated


--Creating View to store data for later visulizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/Population) * 100
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_19_Project..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc