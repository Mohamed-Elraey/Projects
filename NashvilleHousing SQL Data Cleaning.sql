SELECT * 
FROM [NashvilleHousing ]  

SELECT *
FROM CovidDeaths

-- Standardize Date Format

SELECT CONVERT(DATE,SaleDate)
FROM [NashvilleHousing ]

UPDATE [NashvilleHousing ]   
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing 
ADD SaleDateConverted Date;

UPDATE [NashvilleHousing ]
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted
FROM  [NashvilleHousing ]

-- If it doesn't Update properly
-- Populate Property Address data
SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ]
--Where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.[NashvilleHousing ] a
JOIN PortfolioProject.dbo.[NashvilleHousing ] b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[NashvilleHousing ]a
JOIN PortfolioProject.dbo.[NashvilleHousing ]b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State) for PropertyAddress and OwnerAddress Columns
--PropertyAddress Column
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM [NashvilleHousing ]

ALTER TABLE [NashvilleHousing ]
ADD PropertySplitAdress nvarchar(255);

UPDATE [NashvilleHousing ]
SET PropertySplitAdress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [NashvilleHousing ]
ADD PropertySplitCity nvarchar(255);

UPDATE [NashvilleHousing ]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitAdress,PropertySplitCity
FROM [NashvilleHousing ]

--OwnerAddress Column
SELECT OwnerAddress
FROM [NashvilleHousing ]

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerSplitAdress ,
 PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS  OwnerSplitCity,
  PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS  OwnerSplitState
FROM [NashvilleHousing ]

ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitAdress nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitCity nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitState nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerSplitAdress,OwnerSplitCity,OwnerSplitState
FROM [NashvilleHousing ]

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT  SoldAsVacant, COUNT(SoldAsVacant)
FROM [NashvilleHousing ]
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'YES'
		WHEN SoldAsVacant='N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM [NashvilleHousing ]

UPDATE [NashvilleHousing ]
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'YES'
							WHEN SoldAsVacant='N' THEN 'NO'
								ELSE SoldAsVacant
								END

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.[NashvilleHousing ]
--order by ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress


-- Delete Unused Columns
SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ]


ALTER TABLE PortfolioProject.dbo.[NashvilleHousing ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

