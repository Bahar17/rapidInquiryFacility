/****** 
Check - USERNAME exists.
Check - USERNAME is Kerberos USER on INSERT.
Check - DELETE only allowed on own records.
Check - CONDITION for SQL injection : NEED TO SEE FUNCTION CODE , MIDDLEWARE ??

  ******/
SELECT TOP 1000 [INV_ID]
      ,[STUDY_ID]
      ,[USERNAME]
      ,[LINE_NUMBER]
      ,[CONDITION]
      ,[ROWID]
  FROM [RIF40].[dbo].[T_RIF40_INV_CONDITIONS]