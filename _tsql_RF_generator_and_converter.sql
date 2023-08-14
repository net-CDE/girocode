-- RF creditor reference generator, validator and reference converter


--Example 1: 1672303027271545 % 97 = 1
--Example 2: 18205271565 % 97 = 1
--Example 3: 124271535 % 97 = 82
--Example 4: 4377271521 % 97 = 51 

Declare @in01 bigint = 1672303027271545
      , @in02 bigint = 18205271565
      , @in03 bigint = 124271535
      , @in04 bigint = 4377271521

Select  @in01 % 97
      , @in02 % 97
      , @in03 % 97
      , @in04 % 97

-- RFpz 1012345678271501
Declare @test  bigint = 1012345678271572
Select @test % 97

Declare @in bigint = 1012345678 -- 10stellige AktenNo
      , @pz bigint

Set @in = ( @in * 1000000 ) + 271500  -- "RF" + 00 am Ende ergänzen
Set @pz =  @in % 97
select @in, 97 - @pz + 1, Format(97 - @pz + 1, '00')

-- return 
RF721012345678
--=================================================================


Create Function dbo.sFN_RF_createChecksum ( @AktenNummer nchar(10) )
Returns nchar(14)
as
Begin
    Declare @Result nchar(14)
          , @input  bigint
          , @pz     bigint

    -- calculation
    Set @input = Try_Convert( bigint, @AktenNummer )
    Set @input = ( @input * 1000000 ) + 271500  -- "RF" als Ziffern + 00 am Ende ergänzen
    Set @pz = 97 - ( @input % 97 ) + 1

    Set @Result = 'RF' + Format( @pz, '00' ) + @AktenNummer

    -- Return 
    Return @Result
End
GO

select dbo.sFN_RF_createChecksum('1012345678') -- RF721012345678 = ok
     , dbo.sFN_RF_createChecksum('1012T45678') -- RF721012T45678 = NULL  wg. Try_Convert
---------------------------------------------------------------------
Create Function dbo.sFN_RF_verifyChecksum( @RFinput nvarchar(25) )
Returns nchar(1)
as
Begin
    Declare @Result nchar(1) = '0'
          , @partRF nchar(2)
          , @partCN bigint  -- part ContractNumber
          , @partPZ bigint  -- part Checksum
          , @calcPZ bigint

    -- calculation
    Set @partRF = SubString( @RFinput, 1, 2 )
    Set @partCN = Try_Convert( bigint, SubString( @RFinput, 5, 21 ) ) 
    Set @partPZ = Try_Convert( bigint, SubString( @RFinput, 3, 2 ) )

    Set @partCN = ( @partCN * 1000000 ) + 271500  -- "RF" als Ziffern + 00 am Ende ergänzen
    Set @calcPZ = 97 - ( @partCN % 97 ) + 1

    Set @Result = Case
                     When @partRF <> 'RF'      Then '5'  -- falscher Beginn, kein "RF"
                     When @partCN is NULL      Then '6'  -- Buchstaben in der "ContractNumber"
                     When @partPZ <> @calcPZ   Then '7'  -- falsche Prüfziffer
                     When @partPZ =  @calcPZ   Then '1'  -- = ok
                     End

    -- Return 
    Return @Result
End
GO

select dbo.sFN_RF_verifyChecksum('RF721012345678')
     , dbo.sFN_RF_verifyChecksum('RF721012T45678')
     , dbo.sFN_RF_verifyChecksum('RZ721012345678')
     , dbo.sFN_RF_verifyChecksum('RF72101235678')
     , dbo.sFN_RF_verifyChecksum('RF721012345678')


