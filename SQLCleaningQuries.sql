/*

Cleaning Data with SQL
HousingDataNashvilleTN.xlsx was used for this activity and HousingDataNashvilleTN(cleaned) is the final product

*/




-- Data that I will be using




Select *
From DataCleaning..HousingData





-- Formatting Date 





Select SaleDateConverted 
From DataCleaning..HousingData


Update HousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE HousingData
Add SaleDateConverted Date;

Update HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)




-- Populate Property Address Data 



Select *
From DataCleaning..HousingData
-- Where PropertyAddress is null 
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning..HousingData a
Join DataCleaning..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 




Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning..HousingData a
Join DataCleaning..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 



-- Seperating Addresses into Individual Columns 



Select PropertyAddress
From DataCleaning..HousingData
-- Where PropertyAddress is null 
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address 

From DataCleaning..HousingData



ALTER TABLE HousingData
Add PropertySplitAddress nvarchar(255);

ALTER TABLE HousingData
Add PropertySplitCity nvarchar(255);


Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))



Select*
From DataCleaning..HousingData


Select OwnerAddress
From DataCleaning..HousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From DataCleaning..HousingData




ALTER TABLE HousingData
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE HousingData
Add OwnerSplitCity nvarchar(255);

ALTER TABLE HousingData
Add OwnerSplitState nvarchar(255);


Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


Select*
From DataCleaning..HousingData



-- Change Y and N to Yes and No in "Sold as Vacant" field 




Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From DataCleaning..HousingData
group by SoldAsVacant
Order by 2



Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From DataCleaning..HousingData


Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END




-- Removing Duplicates 


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY	
				UniqueID
				) row_num

From DataCleaning..HousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num >1
-- Order by PropertyAddress


Select *
From DataCleaning..HousingData



-- Deleting Unused Columns 




Select *
From DataCleaning..HousingData

ALTER TABLE DataCleaning..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE DataCleaning..HousingData
DROP COLUMN SaleDate
