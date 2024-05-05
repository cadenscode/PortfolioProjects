Select location, date, total_cases, new_cases, total_deaths, population
From Coviddeaths
Order by 1,2

-- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths::numeric/total_cases::numeric)*100 as Deathpercentage
From Coviddeaths
Order by 1,2

-- Looking at the total cases vs. the population

Select location, date, total_cases, total_deaths, (total_deaths::numeric/total_cases::numeric)*100 as Deathpercentage
From Coviddeaths
WHERE location like '%States' 
AND (total_deaths::numeric/total_cases::numeric)*100 IS not Null
Order by 1,2 desc


-- Looking at country with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases::numeric/population::numeric)) * 100 as PercentPopulationthatInfected
From Coviddeaths
GROUP BY location, population
HAVING (Max(total_cases::numeric/population::numeric)) * 100 is not null
Order by 4 desc

-- Countries with Highest Death Count per population

Select location, MAX(Total_Deaths) as TotalDeathCount
From Coviddeaths
Where continent is not null
GROUP BY location
Having Max(Total_Deaths) is not null
Order by TotalDeathCount desc

-- Breaking it down by continent

Select continent, MAX(Total_Deaths) as TotalDeathCount
From Coviddeaths
Where continent is not null
GROUP BY continent
Having Max(Total_Deaths) is not null
Order by TotalDeathCount desc

-- script above doesn't include Canada

Select location, MAX(Total_Deaths) as TotalDeathCount
From Coviddeaths
Where continent is null
GROUP BY location
Having Max(Total_Deaths) is not null
Order by TotalDeathCount desc



-- Global Numbers

Select date, SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, (SUM(new_deaths::numeric) / NULLIF(SUM(new_cases::numeric), 0)) * 100 AS death_percentage
From CovidDeaths
Where continent is not null
Group by date
Order by 1

-- Looking at total population vs vaccinations
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations_smoothed, 
Sum(new_vaccinations_smoothed) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated, 
From CovidDeaths CD
	JOIN CovidVaccinations cv
		on CD.location = cv.location AND
		cd.date = cv.date
where cd.continent is not null
AND cv.new_vaccinations_smoothed is not null
Order by location, date


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations_smoothed, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations_smoothed, 
Sum(new_vaccinations_smoothed) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
From CovidDeaths CD
	JOIN CovidVaccinations cv
		on CD.location = cv.location AND
		cd.date = cv.date
where cd.continent is not null
AND cv.new_vaccinations_smoothed is not null
)
Select*, (RollingPeopleVaccinated::numeric/Population::numeric)*100
From PopvsVac




-- Temp Table

CREATE TEMP TABLE PercentPopulationVaccinateds
(
Continent varchar(255),
location varchar(255),
Date date,
Population numeric,
new_vaccinations_smoothed bigint,
RollingPeopleVaccinateed numeric
);

Insert into PercentPopulationVaccinateds 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations_smoothed, 
Sum(new_vaccinations_smoothed) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
From CovidDeaths CD
	JOIN CovidVaccinations cv
		on CD.location = cv.location AND
		cd.date = cv.date
where cd.continent is not null
AND cv.new_vaccinations_smoothed is not null


Select * from PercentPopulationVaccinateds



-- VIEW 
Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations_smoothed, 
Sum(new_vaccinations_smoothed) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
From CovidDeaths CD
	JOIN CovidVaccinations cv
		on CD.location = cv.location AND
		cd.date = cv.date
where cd.continent is not null
AND cv.new_vaccinations_smoothed is not null

