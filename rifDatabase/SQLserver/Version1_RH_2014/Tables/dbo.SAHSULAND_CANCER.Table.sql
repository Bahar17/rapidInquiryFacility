USE [RIF40]
GO
/****** Object:  Table [dbo].[SAHSULAND_CANCER]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SAHSULAND_CANCER](
	[YEAR] [numeric](4, 0) NOT NULL,
	[AGE_SEX_GROUP] [numeric](3, 0) NOT NULL,
	[LEVEL1] [varchar](20) NOT NULL,
	[LEVEL2] [varchar](20) NOT NULL,
	[LEVEL3] [varchar](20) NOT NULL,
	[LEVEL4] [varchar](20) NOT NULL,
	[ICD] [varchar](4) NOT NULL,
	[TOTAL] [numeric](9, 5) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.AGE_SEX_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.ICD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'ICD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER.TOTAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER', @level2type=N'COLUMN',@level2name=N'TOTAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_CANCER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_CANCER'
GO
