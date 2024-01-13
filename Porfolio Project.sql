
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

-- select data that we are going to be using
Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2
-- Looking at total cases vss total deaths
Select location,date,total_cases,total_deaths,(cast(total_deaths as  DECIMAL)/cast(total_cases as  DECIMAL))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2
-- Showw likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(cast(total_deaths as  DECIMAL)/cast(total_cases as  DECIMAL))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%' and continent is not null
order by 1,2

--Looking at coutries with highest infection Rate compared to population
--some what percentage of population got covid
Select location,date,total_cases,total_deaths,population,(cast(total_cases as  DECIMAL)/cast( population as  DECIMAL))*100 as PercentPopulationinfected
From PortfolioProject..CovidDeaths
Where location like '%state%' and continent is not null
order by 1,2
--Looking at country with highest infection Rate compared to pupolation
Select location,population,max(total_cases)as highestInfectioncount,max((cast(total_deaths as  DECIMAL)/cast(population as  DECIMAL)))*100 as PercentPopulationinfected
From PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not null
Group by location, population -- group by không đung trong các cột không dùng hàm
order by PercentPopulationinfected desc -- lệnh order by desc để theo thứ tự giảm dần


-- showing Countries with highesst death count per population
Select location,Max (total_deaths) as Totaldeathcount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not null
Group by location
order by Totaldeathcount desc

-- let's break  things down by continent
Select continent,Max (total_deaths) as Totaldeathcount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not null
Group by continent
order by Totaldeathcount desc

-- showwing continents with the highest death count per population
Select continent,Max (total_deaths) as Totaldeathcount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not null
Group by continent
order by Totaldeathcount desc
-- Global numbers
Select sum(new_cases) as total_cases, sum (cast (new_deaths as int )) as total_deaths,
CASE 
        WHEN sum(cast (new_cases as int)) <> 0 THEN sum (cast (new_deaths as int )) /sum (cast (new_cases as int))*100
		ELSE NULL  -- hoặc giá trị mặc định khác nếu bạn muốn
		END AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%state%' and 
where continent is not null
--group by date
order by 1,2
-- looking at total population vs vaccinations
-- USE CTE
with popvsVac (continent, location, date, population, new_vaccinations, rollingpeopleVaccinated) -- tạo bảng tạm thời
as (
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) -- tính tổng vac.new_vaccinations cho mỗi nhóm dea.location, đồng thời sắp xếp kết quả trong mỗi nhóm theo cột location và date
as rollingpeopleVaccinated --(rollingpeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3
	 )
select *, (rollingpeopleVaccinated/population)*100
from popvsVac
--Temp table
drop table if exists #PercentPopulationvaccinated -- Xoá bảng khi đã tồn tại 1 bảng tương tự (clear)
Create Table #PercentPopulationvaccinated  -- Dấu thăng (#) trước tên bảng thường được sử dụng để chỉ ra rằng đây là một bảng tạm thời (temporary table)
(
Continent nvarchar (255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationvaccinated -- chèn dữ liệu vào bảng
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) -- tính tổng vac.new_vaccinations cho mỗi nhóm dea.location, đồng thời sắp xếp kết quả trong mỗi nhóm theo cột location và date
as rollingpeopleVaccinated --(rollingpeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3
select *, (rollingpeopleVaccinated/population)*100
from #PercentPopulationvaccinated
-- Creating view to store data for later visualizations
Create view PercentPopulationvaccinated as
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) -- tính tổng vac.new_vaccinations cho mỗi nhóm dea.location, đồng thời sắp xếp kết quả trong mỗi nhóm theo cột location và date
as rollingpeopleVaccinated --(rollingpeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3
 Select *
  from PercentPopulationvaccinated