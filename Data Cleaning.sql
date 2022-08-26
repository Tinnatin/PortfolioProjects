--Cleaning Data in SQL Queries

Select *
From dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
From dbo.NashvilleHousing 

UPDATE dbo.NashvilleHousing
SET SaleDate=CONVERT(Date, SaleDate)

--Property Address

Select *
From dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking down address into columns as address, city, state
Select PropertyAddress
From dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255); 

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255); 

UPDATE dbo.NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select *
From dbo.NashvilleHousing


Select OwnerAddress
From dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.') ,3),
PARSENAME(REPLACE(OwnerAddress,',','.') ,2),
PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255); 

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.') ,3)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255); 

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.') ,2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255); 

UPDATE dbo.NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.') ,1)




--Change Y and N to Yes and No in SoldAsVacant

Select Distinct (SoldAsVacant), count(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2
      --So we have 399 N and 52 Y

Select SoldAsVacant
, CASE When SoldAsVacant='Y'Then 'Yes'
	   When SoldAsVacant='N' Then 'No'
	   Else SoldAsVacant
	   END
From dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=CASE When SoldAsVacant='Y'Then 'Yes'
	   When SoldAsVacant='N' Then 'No'
	   Else SoldAsVacant
	   END
From dbo.NashvilleHousing


--Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				 UniqueID
				 ) row_num 
From NashvilleHousing
)

DELETE
From RowNumCTE
Where row_num>1

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				 UniqueID
				 ) row_num 
From NashvilleHousing
)

Select *
From RowNumCTE
Order by PropertyAddress



--Delete unused columns


Select * 
From dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NashvilleHousing
DROP Column SaleDate
