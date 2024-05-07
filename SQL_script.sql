
DROP DATABASE IF EXISTS DataCleaning;
CREATE DATABASE DataCleaning;

USE Datacleaning;

--Retrieve first 10 records of the dataset
SELECT TOP 10 * 
FROM nashville;

--Inspect the Columns and their data types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Nashville';

--Check for the presence of duplicates values
SELECT uniqueID,
       COUNT(*) AS row_count
FROM nashville
GROUP BY uniqueid
HAVING  COUNT(*) > 1;

--Check for null/blank values in the PropertyAddress Column
SELECT *
FROM Nashville
WHERE PropertyAddress IS NULL or PropertyAddress = ' ';

--Where property adress is null, replace with owner address
UPDATE Nashville
SET PropertyAddress = ISNULL(PropertyAddress,OwnerAddress);

--Check for the presence of null/blank rows in property address again
SELECT *
FROM Nashville
WHERE PropertyAddress IS NULL or PropertyAddress = ' ';

--Extract City name from the Propety Address
SELECT 
	PropertyAddress,
	LEFT(propertyAddress,CHARINDEX(',',PropertyAddress)-1) AS PropAddress,
	REPLACE(SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)),', TN','' ) AS PropCity
FROM Nashville;

ALTER TABLE Nashville
ADD PropAddress NVARCHAR(125), PropCity NVARCHAR(125);

UPDATE Nashville
SET PropAddress = LEFT(propertyAddress,CHARINDEX(',',PropertyAddress)-1),
    PropCity = REPLACE(SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)),', TN','' );

--Delete the PropertyAddress Column
ALTER TABLE Nashville
DROP COLUMN PropertyAddress;

--Check for null or blanks in the OwnerName Column
SELECT COUNT(*) AS null_counts
FROM Nashville
WHERE OwnerName IS NULL OR OwnerName = ' ';

--Delete all properties with no owners
DELETE FROM Nashville
WHERE OwnerName IS NULL;

--Breaking down the OwnerAddress Column
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS OwnerAdd,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS OwnerCity,
REPLACE(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1),'TN','TENNESSEE') AS OwnerState --replace TN with Tennessee
From Nashville;

ALTER TABLE Nashville
ADD OwnerAdd NVARCHAR(125), 
    OwnerCity NVARCHAR(125),
	OwnerState NVARCHAR(125);


UPDATE Nashville 
SET OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
    OwnderCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerState = REPLACE(PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1),'TN','TENNESSEE');

--Delete OwnerAddress Column
ALTER TABLE Nashville
DROP COLUMN OwnerAddress;

--Where soldasvacant = 0 replace with no, where it is 1, replace with yes
ALTER TABLE Nashville
ALTER COLUMN SoldAsVacant NVARCHAR(20);

SELECT 
    SoldAsVacant,
	CASE WHEN soldAsVacant = 0 THEN 'No' ELSE 'Yes' END AS soldAsVacant
FROM Nashville;

UPDATE Nashville
SET SoldAsVacant = CASE WHEN soldAsVacant = 0 THEN 'No' ELSE 'Yes' END;

--Delete TaxDistrict Column(Irrelevant column)
ALTER TABLE nashville
DROP COLUMN TaxDistrict;

--check for duplicates again
SELECT STRING_AGG(COLUMN_NAME,',')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Nashville';

WITH duplicate_cte AS (
				SELECT *,
				      ROW_NUMBER()OVER(PARTITION BY UniqueID,ParcelID,LandUse,SaleDate,SalePrice,LegalReference,SoldAsVacant,OwnerName,Acreage,LandValue,BuildingValue,TotalValue,YearBuilt,Bedrooms,FullBath,HalfBath,PropAddress,PropCity,OwnerAdd,OwnerCity,OwnerState ORDER BY (SELECT NULL)) AS row_count
                FROM Nashville
)
SELECT *
FROM duplicate_cte
WHERE row_count > 1;

