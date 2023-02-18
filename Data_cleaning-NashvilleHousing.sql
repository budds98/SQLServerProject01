select *
from nashvillehousing



--Standardising Date Format

select saledateconverted, convert(date,Saledate)
from nashvillehousing

--update nashvillehousing #not working
--set saledate = convert(date,Saledate) #not working

alter table nashvillehousing
add SaleDateCoverted date;

update nashvillehousing
set SaleDateConverted = convert(date,Saledate)



-- Populating Property Address Data

select *
from nashvillehousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress,
b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out PropertyAddress into Individual Columns (Address, City, State)

select PropertyAddress
from nashvillehousing

select
substring(PropertyAddress, 1,charindex(',', PropertyAddress)-1) as Address
,substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from nashvillehousing

alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update nashvillehousing
set PropertySplitAddress = substring(PropertyAddress, 1,charindex(',', PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update nashvillehousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select*
from NashvilleHousing


--Breaking out OwnerAddress into Individual Columns

select OwnerAddress
from NashvilleHousing

select 
Parsename(replace(OwnerAddress,',','.'),3),
Parsename(replace(OwnerAddress,',','.'),2),
Parsename(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update nashvillehousing
set OwnerSplitAddress = Parsename(replace(OwnerAddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update nashvillehousing
set OwnerSplitCity = Parsename(replace(OwnerAddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update nashvillehousing
set OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)

select*
from NashvilleHousing



--Change Y and N to 'Yes' and 'No' in 'SoldAsVancant' field

select distinct(SoldAsVacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

update nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end



--Removing Duplicates from the table

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() over
	(partition by 
		parcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	order by
		uniqueID) as RowNum
from NashvilleHousing
)
select*
from RowNumCTE
order by PropertyAddress



--Deleting Unused Columns

select*
from NashvilleHousing

Alter table NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

Alter table NashvilleHousing
drop column saledate