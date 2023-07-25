/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  --Standardize Date Format

  Alter Table [dbo].[NashvilleHousing]
  Alter Column SaleDate Date

  --Populate Property Address Data Where it is null

  Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress)
  From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
  Where a.PropertyAddress is null
Order by a.ParcelID

Update a
Set a.propertyaddress = isnull(a.propertyaddress,b.PropertyAddress)
 From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into individual Columns (Address, City, State) 

Select
SUBSTRING (propertyaddress, 1,CHARINDEX(',',propertyaddress)-1) Address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) As OtherAddress
From NashvilleHousing

  Alter Table [dbo].[NashvilleHousing]
  Add PropertySplitAddress nvarchar(255)

  Update [dbo].[NashvilleHousing]
  Set PropertySplitAddress= SUBSTRING (propertyaddress, 1,CHARINDEX(',',propertyaddress)-1)

  Alter Table [dbo].[NashvilleHousing]
  Add PropertySplitCity nvarchar(255)

  Update [dbo].[NashvilleHousing]
  Set PropertySplitCity= SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,len(propertyaddress))

  Select
  PARSENAME (REPLACE (OwnerAddress,',','.'),3),
  PARSENAME (REPLACE (OwnerAddress,',','.'),2),
  PARSENAME (REPLACE (OwnerAddress,',','.'),1)
  From NashvilleHousing
  
  Select OwnerAddress
  From NashvilleHousing
  
    Alter Table [dbo].[NashvilleHousing]
  Add OwnerSplitAddress nvarchar(255)

  Update [dbo].[NashvilleHousing]
  Set OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress,',','.'),3)

    Alter Table [dbo].[NashvilleHousing]
  Add OwnerSplitCity nvarchar(255)

  Update [dbo].[NashvilleHousing]
  Set OwnerSplitCity= PARSENAME (REPLACE (OwnerAddress,',','.'),2)

    Alter Table [dbo].[NashvilleHousing]
  Add OwnerSplitState nvarchar(255)

  Update [dbo].[NashvilleHousing]
  Set OwnerSplitState = PARSENAME (REPLACE (OwnerAddress,',','.'),1)

--Change Y and N to Yes an No in "SoldASVacant" Field    

  Select  SoldAsVacant,
  Case 
  When SoldAsVacant ='Y' Then 'Yes'
  When SoldAsVacant= 'N' Then 'No'
 Else SoldAsVacant
  End 
  From NashvilleHousing



 Update [dbo].[NashvilleHousing]
  Set SoldAsVacant=   Case 
  When SoldAsVacant ='Y' Then 'Yes'
  When SoldAsVacant= 'N' Then 'No'
 Else SoldAsVacant
  End
  
  Select Distinct SoldAsVacant, COUNT (SoldAsVacant)
  From NashvilleHousing
  Group By SoldAsVacant
  Order By 2

  --Remove Duplicates

  With RowNumCTE AS (
  Select *,
  ROW_NUMBER () OVER(
  Partition By ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order By
			   UniqueId) Row_Num

  From NashvilleHousing)


  Delete 
  From RowNumCTE
  Where Row_Num>1

  --Delete Unused Columns
  
  Alter Table [dbo].[NashvilleHousing]
  Drop Column [SaleDate], [OwnerAddress],[TaxDistrict],[PropertyAddress]
  
  Select*
  From [dbo].[NashvilleHousing]