-- cleaning data in SQL

select* 
from portfolioProject..nashvilleHousing

-- standard date format

select Saledate, convert(date, saledate)
from portfolioProject..nashvilleHousing


update nashvilleHousing
set SaleDate = convert(date,saledate)


--populate property address

select *
from portfolioProject..nashvilleHousing
--where propertyaddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioProject..nashvilleHousing a
join portfolioProject..nashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioProject..nashvilleHousing a
join portfolioProject..nashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- breaking address into individual columns

select PropertyAddress
from portfolioProject..nashvilleHousing

select
SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)) as address
from portfolioProject..nashvilleHousing


-- owner address
SELECT owneraddress
from portfolioProject..nashvilleHousing

SELECT 
PARSENAME(replace(owneraddress, ',', '.'),3),
PARSENAME(replace(owneraddress, ',', '.'),2),
PARSENAME(replace(owneraddress, ',', '.'),1)
from portfolioProject..nashvilleHousing

alter table nashvillehousing
add ownersplitaddress Nvarchar(255);

update nashvilleHousing
set ownersplitaddress = PARSENAME(replace(owneraddress, ',', '.'),3)


alter table nashvillehousing
add ownersplitcity Nvarchar(255);

update nashvilleHousing
set ownersplitcity = PARSENAME(replace(owneraddress, ',', '.'),2)


alter table nashvillehousing
add ownersplitstate Nvarchar(255);

update nashvilleHousing
set ownersplitstate = PARSENAME(replace(owneraddress, ',', '.'),1)

select *
from portfolioProject..nashvilleHousing


-- change Y and N to yes and no in "sold as vacant"

select distinct(SoldAsVacant),count(soldASvacant)
from portfolioProject..nashvilleHousing
group by SoldAsVacant
order by 2



select soldAsVacant
, case when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
	   ELSE soldasvacant
	   END
from portfolioProject..nashvilleHousing

update nashvilleHousing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
	    ELSE soldasvacant
	   END


-- removing duplicates

WITH rownumCTE AS(
select *,
     ROW_NUMBER() OVER (
	 PARTITION BY parcelID,
	             propertyAddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
				 uniqueID
				 ) row_num

from portfolioProject..nashvilleHousing
--order by ParcelID
)
select *
from rownumCTE
where row_num >1
--order by PropertyAddress


-- deleting unused columns

select *
from portfolioProject..nashvilleHousing

ALTER TABLE portfolioProject..nashvilleHousing
DROP COLUMN owneraddress, taxdistrict,propertyaddress

ALTER TABLE portfolioProject..nashvilleHousing
DROP COLUMN saledate

