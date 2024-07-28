-- Data Cleaning and Standardization 

--Select SaleDate
--From housing..housingsheet

Alter Table housing..housingsheet
Add NewSaleDate Date;

Update housing..housingsheet
Set NewSaleDate = Convert(Date , SaleDate)

Select NewSaleDate
From housing..housingsheet


--Handling Null Values in propertyAddress Column (Since it has Alot of Null Values)
-- in ParcelID Column There are duplicates of both ID and propertyAddress , We can use this to populate null values
-- Self Joining to compare values

Select TableA.ParcelID  , TableA.PropertyAddress , TableB.ParcelID, TableB.PropertyAddress,
	ISNULL(TableA.PropertyAddress, TableB.PropertyAddress) --replaces A with B if A is null
	From housing..housingsheet TableA
	Join housing..housingsheet TableB
		on TableA.ParcelID = TableB.ParcelID
		and TableA.[UniqueID ] <> TableB.[UniqueID ]



Update TableA
	Set propertyAddress = ISNULL(TableA.PropertyAddress, TableB.PropertyAddress) 
	From housing..housingsheet TableA
	Join housing..housingsheet TableB
		on TableA.ParcelID = TableB.ParcelID
		and TableA.[UniqueID ] <> TableB.[UniqueID ]
		Where TableA.PropertyAddress is null




-- breaking address into different columns

-- propertyAddress : (using substring)

-- split to left value (first value) when ',' is seen (-1) so the ',' is not included
Select propertyAddress,
	SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) -1 )  as StreetAddress, 
	SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) + 1, LEN(propertyAddress) - CHARINDEX(',', propertyAddress)) AS City
	FROM housing..housingsheet



Alter TABLE housing..housingsheet
	ADD StreetAddress NVARCHAR(255);

Alter TABLE housing..housingsheet
	ADD CityAddress NVARCHAR(255);


UPDATE housing..housingsheet
SET StreetAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) -1 )

UPDATE housing..housingsheet
SET CityAddress = SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) + 1, LEN(propertyAddress) - CHARINDEX(',', propertyAddress))



--OwnerAddress : (using PARSENAME())  parsename looks for '.' since we have ',' instead , we have to replace it. and also is backwards

Select 
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3),
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2),
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1)
From housing..housingsheet


Alter TABLE housing..housingsheet
	ADD OwnerStreetAddress NVARCHAR(255);

Alter TABLE housing..housingsheet
	ADD OwnerCityAddress NVARCHAR(255);

Alter TABLE housing..housingsheet
	ADD OwnerState NVARCHAR(255);


UPDATE housing..housingsheet
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3)

UPDATE housing..housingsheet
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2)

UPDATE housing..housingsheet
SET OwnerState = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1)




-- SoldasVacant field has 4 value counts : yes, no, y, n 


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
	From housing..housingsheet
	group by SoldAsVacant
	order by count(SoldasVacant)


-- changing that to 2 

Select SoldAsVacant,  
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END 
	From housing..housingsheet


UPDATE housing..housingsheet
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
	Order by UniqueID
	) row_num
From housing..housingsheet	
)

DELETE
From RowNumCTE
where row_num > 1



-- Removing Unused Columns

ALTER TABLE housing..housingsheet
Drop column OwnerAddress , PropertyAddress , TaxDistrict , SaleDate, CityAddress

Select * From housing..housingsheet

