--Data cleaning in SQL

SELECT * 
FROM Datacleaning..housing

--Standardize Date Format

ALTER TABLE housing
ADD SaleDateConverted Date

UPDATE housing
SET saledateconverted = CONVERT(Date, SaleDate)

--Populating Property Addresses field

SELECT *  
FROM Datacleaning..housing
WHERE Propertyaddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM Datacleaning..housing AS a
JOIN Datacleaning..housing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM Datacleaning..housing AS a
JOIN Datacleaning..housing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking Address into individual columns(Address, city, state)

SELECT PropertyAddress
FROM Datacleaning..housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM Datacleaning..housing

ALTER TABLE Datacleaning..housing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Datacleaning..housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Datacleaning..housing
ADD PropertySplitCity NVARCHAR(255)

UPDATE Datacleaning..housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT * FROM Datacleaning..housing

SELECT OwnerAddress
FROM Datacleaning..housing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Datacleaning..housing

ALTER TABLE Datacleaning..housing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE Datacleaning..housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Datacleaning..housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Datacleaning..housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Datacleaning..housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE Datacleaning..housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- SELECTING all from our data to see the effects of all our work done so far

SELECT * 
FROM Datacleaning..housing

-- Changing Y and N to Yes and No in the Sold as Vacant Column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Datacleaning..housing
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Datacleaning..housing


UPDATE Datacleaning..housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
LegalReference
ORDER BY 
UniqueID
) AS row_num
FROM Datacleaning..housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--Delete Unused columns

ALTER TABLE Datacleaning..housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM Datacleaning..housing