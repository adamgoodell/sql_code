/*
Cleaning Data in SQL Queries
*/

Select Top(1000)
* 
From DevTest.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From DevTest.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
-- Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DevTest.dbo.NashvilleHousing a
JOIN DevTest.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DevTest.dbo.NashvilleHousing a
JOIN DevTest.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From DevTest.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address

From DevTest.dbo.NashvilleHousing

AlTER TABLE DevTest.dbo.NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )

ALTER TABLE DevTest.dbo.NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT TOP (100) *
From NashvilleHousing;

Select OwnerAddress
From NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DevTest.dbo.NashvilleHousing

ALTER TABLE DevTest.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255),
 OwnerSplitCity NVARCHAR(255),
 OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT TOP (500) *
From NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From DevTest.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
From DevTest.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS (

Select *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID
    ) row_num

From DevTest.dbo.NashvilleHousing
-- ORDER BY ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
-- Order By PropertyAddress

Select *
From RowNumCTE
Where row_num > 1
-- Order By PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE DevTest.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DevTest.dbo.NashvilleHousing
DROP COLUMN SaleDate