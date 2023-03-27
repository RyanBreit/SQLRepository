-- Cleaning date format

SELECT * 
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashVilleHousing
Add SaleDateNew Date;

Update NashvilleHousing
SET SaleDateNew = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDateConverted

-- Populate Property Address Data

SELECT PropertyAddress, ParcelID
FROM NashvilleHousing
-- WHERE PropertyAddress IS NULL 
Order BY ParcelID

-- SELF JOIN
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing as a
JOIN NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Using Self Join data to update table 
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing as a
JOIN NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

	-- Breaking Out Address into individual columns (Address, City, State) 

SELECT PropertyAddress, ParcelID
FROM NashvilleHousing
-- WHERE PropertyAddress IS NULL 
-- Order BY ParcelID

-- This substring will split the adress and city by the comma delimiter
-- Use -1 and +1 to help avoid the comma in the table
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address 
FROM NashvilleHousing

-- Adding new columns for Address and City
-- Updating Table to reflect new columns using our past substring queries
ALTER TABLE NashVilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashVilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Cleaning Owner Address Data and splitting between Address, City, and State 
SELECT OwnerAddress
FROM NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing

-- Adding new columns for Address, City, and State
ALTER TABLE NashVilleHousing
Add NewOwnerAddress NVARCHAR(255);

Update NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashVilleHousing
Add NewOwnerCity NVARCHAR(255);

Update NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashVilleHousing
Add NewOwnerState NVARCHAR(255);

Update NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


-- Changing SoldAsVancant column to 'Yes' and 'No', as opposed to 'Y' and 'N'
SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing

-- Updating Table using the case statment 
UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END


-- Removing Duplicates 
-- We Will create a CTE for the duplicate values 
-- Partition by will help group our duplicates with a specific value to which we can delete all rows that contain that specified value

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDateNew,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS Row_num
FROM NashvilleHousing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
where Row_num > 1 

-- Delete Unused Columns
SELECT * 
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, TaxDistrict  


-- (Not in video, just personal intrigue)
SELECT distinct(PropertySplitCity), count(PropertySplitCity) AS CityCount
FROM NashvilleHousing
Group By PropertySplitCity
ORDER BY CityCount