/*
Cleaning data in SQL Querries
*/

select*
from [Portfolio Project]..NationalHousing

--Standardized Date Format
select SaleDateCinverted, convert(date, SaleDate)
from [Portfolio Project]..NationalHousing

update NationalHousing
SET SaleDate= CONVERT(date,SaleDate)

ALTER TABLE NationalHousing
Add SaleDateCinverted  Date;

update NationalHousing
SET SaleDateCinverted = CONVERT(date,SaleDate)

---Populate Property Address Data

select*
from [Portfolio Project]..NationalHousing
--where PropertyAddress is null
order by ParcelID

select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NationalHousing a
Join  [Portfolio Project]..NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] = b.[UniqueID ]
where a.PropertyAddress is not null


update a
SET PropertyAddress =isnull (a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NationalHousing a
Join  [Portfolio Project]..NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] = b.[UniqueID ]
where a.PropertyAddress is not null



--Breakiing address into Individual Column (Address, City, State)
select PropertyAddress
from [Portfolio Project]..NationalHousing
--Order by ParcelID

--Delimeter is what seperate two words in this case its comma

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress) --Checks where the comma is 
from [Portfolio Project]..NationalHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) as Address
from [Portfolio Project]..NationalHousing


ALTER TABLE NationalHousing
Add PropertSplitAddress  nvarchar(255);

update NationalHousing
SET PropertSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NationalHousing
Add PropertSplitCity  nvarchar(255);

update NationalHousing
SET PropertSplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))

select*
from [Portfolio Project]..NationalHousing

---Alternatively;
select OwnerAddress
from [Portfolio Project]..NationalHousing

select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
from [Portfolio Project]..NationalHousing

--Parsing does things backward therefore we reverse the order to 3,2,1

select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
from [Portfolio Project]..NationalHousing



ALTER TABLE NationalHousing
Add OwnerSplitAddress  nvarchar(255);

update NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NationalHousing
Add OwnerSplitCity  nvarchar(255);

update NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NationalHousing
Add OwnerSplitState  nvarchar(255);

update NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

select*
from [Portfolio Project]..NationalHousing

---Change Y and N to Yes and No in 'Sold as Vacant' field


select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Portfolio Project]..NationalHousing
Group by SoldAsVacant
Order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
from [Portfolio Project]..NationalHousing

UPDATE NationalHousing
SET SoldAsVacant= case when SoldAsVacant = 'Y' then 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

--Removing Duplicates

---Checking number of Duplicates 
with RowNumCTE AS (
select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				)ROW_NUM


from [Portfolio Project]..NationalHousing
--Order by ParcelID
)

SELECT*
from RowNumCTE
WHERE ROW_NUM >1
ORDER BY PropertyAddress

---Deleting duplicates
with RowNumCTE AS (
select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				)ROW_NUM


from [Portfolio Project]..NationalHousing
--Order by ParcelID
)

DELETE
from RowNumCTE
WHERE ROW_NUM >1
---ORDER BY PropertyAddress


---Delete Unused Column

select*
from [Portfolio Project]..NationalHousing


alter table [Portfolio Project]..NationalHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

alter table [Portfolio Project]..NationalHousing
drop column SaleDate