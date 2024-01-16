/* 
Cleaning Data in SQL Queries
*/
Select *
From PortfolioProject.dbo.NashvilleHousing
--standardize Date Format
Select SaleDate, Convert (date, saledate)
From PortfolioProject.dbo.NashvilleHousing
 
Update NashvilleHousing
SET SaleDate = CONVERT(date, saledate)
Alter Table NashvilleHousing
Add SaleDateCoverted date;

Update NashvilleHousing
Set SaleDateCoverted = convert (date, SaleDate)
-- Populate Property Address data
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Nếu dòng có cùng ParcelID mà lại có giá trị UniqueID giống nhau (trong cùng một bảng), thì điều kiện a.UniqueID <> b.UniqueID sẽ loại bỏ chúng, để bạn chỉ có những cặp dòng có cùng ParcelID nhưng có giá trị UniqueID khác nhau từ cùng một bảng

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
---Hàm ISNULL được sử dụng để kiểm tra nếu giá trị của a.PropertyAddress là null thì sẽ trả về giá trị của b.PropertyAddress. 
SET PropertyAddress = isnull (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--- Breaking out address into individual Columns ( Address, City, State)
select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--- where PropertyAddress is null
--- Order by ParcelID

Select
---CHARINDEX(',', PropertyAddress) - 1. Điều này có nghĩa là nó trích xuất phần của chuỗi từ vị trí bắt đầu (vị trí 1) đến vị trí ngay trước dấu phẩy đầu tiên, hiệu quả là phần đại diện cho địa chỉ trước dấu phẩy đầu tiên.
SUBSTRING (propertyAddress,1, Charindex(',', PropertyAddress)-1) as Address,--- -1 ý nghĩa bỏ đi dấu phẩy phía sau
SUBSTRING (propertyAddress, Charindex(',', PropertyAddress) +1,len(propertyaddress)) as Address --- +1 bỏ dấu phẩy phía trước ---len(propertyaddress) để không bị tính khoảng trắng ở phía sau phần cuối của địa chỉ
From PortfolioProject..NashvilleHousing
USE PortfolioProject;
Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);
--- tách và theo các cột địa chỉ vào bảng
Update NashvilleHousing
Set PropertySplitAddress= SUBSTRING (propertyAddress,1, Charindex(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitcity nvarchar (255);

Update NashvilleHousing
Set PropertySplitcity = SUBSTRING (propertyAddress, Charindex(',', PropertyAddress) +1,len(propertyaddress))

select *
From PortfolioProject..NashvilleHousing


select OwnerAddress
From PortfolioProject..NashvilleHousing

--- cách phân tách với hàm parsename
Select
PARSENAME (replace(OwnerAddress,',','.'),3), --- replace thay thế dấu phẩy bằng dấu chấm--- 1 là lấy phần sau dấu chấm , số tăng dần từ phải qua trái --- thay dấu phẩy thành dấu chấm để phù hợp với hàm parsename
PARSENAME (replace(ownerAddress,',','.'),2),
PARSENAME (replace(ownerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing



USE PortfolioProject;
Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);
--- tách và theo các cột địa chỉ vào bảng
Update NashvilleHousing
Set OwnerSplitAddress= PARSENAME (replace(OwnerAddress,',','.'),3)
Alter Table NashvilleHousing
Add OwnerSplitcity nvarchar (255);

Update NashvilleHousing
Set OwnerSplitcity = (replace(ownerAddress,',','.'),2)
 
Alter Table NashvilleHousing
Add OwnerSplitstate nvarchar (255);

Update NashvilleHousing
Set OwnerSplitstate = PARSENAME (replace(ownerAddress,',','.'),1)


select *
from PortfolioProject..NashvilleHousing

---change Y and N to Yes and No in "sold as Vacant" field --- thay đổi lựa chọn y => yes

Select Distinct(SoldAsvacant) --- kiểm trang bộ lọc có bao nhiêu lựa chọn
from PortfolioProject..NashvilleHousing

Select Distinct(SoldAsvacant), count (soldasvacant) --- đếm mỗi loại có bao nhiêu 
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


Select Soldasvacant,
case When soldasvacant = 'y' then 'yes'
     When soldasvacant = 'n' then 'no'
	 else soldasvacant
	 end
From PortfolioProject..NashvilleHousing
Update NashvilleHousing
SET  SoldAsVacant = case When soldasvacant = 'y' then 'yes'
                         When soldasvacant = 'n' then 'no'
	                     else soldasvacant
	                     end

--- Remove Duplicates
with RowNumCTE As(
Select *, ROW_NUMBER () over (partition by parcelID, propertyaddress, saleprice, saleDate, LegalReference Order by UniqueID) row_num --- kiểm tra dòng có giá trị giống nhau theo par by , nếu giống sẽ đánh số khác 1 trong cột rownumber
From PortfolioProject.dbo.NashvilleHousing)
---order by ParcelID
Select  *
from RowNumCTE
where row_num>1
order by PropertyAddress
Delete --- xoá hàng trùng
from RowNumCTE
where row_num>1
---order by PropertyAddress

---- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing
alter table PortfolioProject..NashvilleHousing --- lệnh biến đổi thêm/bớt các cột
drop column OwnerAddress, Taxdistrict, PropertyAddress
alter table PortfolioProject..NashvilleHousing --- lệnh biến đổi thêm/bớt các cột
drop column saleDate