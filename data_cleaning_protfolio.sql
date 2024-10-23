select * from housing_datacleaning;

-- polpulate property address data(same adress)

select * from housing_datacleaning
-- where PropertyAddress is null 
order by ParcelID ;

SELECT count(*)
FROM housing_datacleaning 
WHERE PropertyAddress = ''; 

-- ( we take to fill empty address)
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
coalesce(a.PropertyAddress, b.PropertyAddress) as combineadress    -- (we did a.address to put in b.property address where b.propertyadress is null)
from housing_datacleaning as a
join housing_datacleaning as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where b.PropertyAddress = '' ;  -- (here we check a condition )

SET SQL_SAFE_UPDATES = 0;

update housing_datacleaning as a
join housing_datacleaning as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
set a.PropertyAddress = coalesce(b.PropertyAddress, a.PropertyAddress)
where a.PropertyAddress = '';

SELECT a.ParcelID, b.PropertyAddress 
FROM housing_datacleaning AS a 
JOIN housing_datacleaning AS b 
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID;


-- Breaking out adress into individual coulmn (Address , city , state) 
select  PropertyAddress from housing_datacleaning;

select substring(PropertyAddress, 1, locate(',', PropertyAddress)-1) as address,
substring(PropertyAddress,locate(',', PropertyAddress)+1 , length(PropertyAddress)) as city
from housing_datacleaning;

-- (we alter the table to put adress and city in propertyadress)  
alter table housing_datacleaning 
add PropertysplitAddress varchar(255);

update housing_datacleaning 
set PropertysplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress)-1);

alter table housing_datacleaning 
add PropertysplitCity varchar(255);

update housing_datacleaning 
set PropertysplitCity = substring(PropertyAddress,locate(',', PropertyAddress)+1 , length(PropertyAddress)) ;

select * from housing_datacleaning;

-- (to change owneradress address, city, state)
select substring_index(OwnerAddress, ',' , +1 ),
substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
substring_index(OwnerAddress, ',' , -1)
from housing_datacleaning;

alter table housing_datacleaning
add OwnersplitAddress varchar(255);

update housing_datacleaning
set OwnersplitAddress =  substring_index(OwnerAddress, ',' , +1 ) ;

alter table housing_datacleaning
add OwnersplitCity varchar(255);

update housing_datacleaning
set OwnersplitCity =  substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) ;

alter table housing_datacleaning
add Ownersplitstate varchar(255);

update housing_datacleaning
set Ownersplitstate = substring_index(OwnerAddress, ',' , -1);

select * from housing_datacleaning;

--  change y and n to  yes and no in sold as vaccant field

select distinct (SoldAsVacant), count(SoldAsVacant)
from housing_datacleaning
group by SoldAsVacant
order by 2;

select  SoldAsVacant,
case 
    when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end
from housing_datacleaning;

update  housing_datacleaning
set  SoldAsVacant =
case 
    when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end;
-- -----------------------------------------------------------------------------------------------------------------------    

-- remove dublicates 
SET SQL_SAFE_UPDATES = 0;

with rollnumCTE as(
select *, 
row_number() over(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from housing_datacleaning 
-- order by ParcelID
) 
-- delete from housing_datacleaning
-- where UniqueID IN (
--     SELECT UniqueID
--     FROM rollnumCTE
--      where row_num > 1
-- )

select * from rollnumCT
     where row_num > 1 
     order by  PropertyAddress;
-- -----------------------------------------------------------------------------------------------------------------------      

-- delete  unused  column

select * from housing_datacleaning;

alter table housing_datacleaning 
drop  column OwnerAddress, 
drop column TaxDistrict, 
drop column PropertyAddress;








