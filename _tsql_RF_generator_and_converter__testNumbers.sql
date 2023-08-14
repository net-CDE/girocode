--check Function dbo.sFN_RF_createChecksum() & dbo.sFN_RF_verifyChecksum()

-- Zahlenliste
Declare @begin  bigint
      , @end    bigint
	  
-- prev      1012345678
Set @begin = 1000000100
Set @end   = 1000009799 
;
With NumberSequence( Number ) 
as
  ( Select @begin as 'Number'
  
    Union all    
	
	Select Number + 1        
	From   NumberSequence        
	Where  Number < @end
  ) 
SELECT Number
     , dbo.sFN_RF_createChecksum( Number ) as 'RF_Number'
into   ##tempRFnumbers
FROM   NumberSequence 
order  by 2 ASC
Option (MaxRecursion 10000)

----
select *
from   ##tempRFnumbers
order  by 2 asc

select SubString(RF_Number, 1, 4), count( SubString(RF_Number, 1, 4) )
from   ##tempRFnumbers
group  by SubString(RF_Number, 1, 4)
order  by 1

-- validate PZ
select *, dbo.sFN_RF_verifyChecksum( RF_Number ) as 'check'
from   ##tempRFnumbers
order  by 1 

--
drop table ##tempRFnumbers