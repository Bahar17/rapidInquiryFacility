USE [RIF40]
GO
/****** Object:  Table [dbo].[SAHSULAND_COVARIATES_LEVEL4]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SAHSULAND_COVARIATES_LEVEL4](
	[YEAR] [numeric](4, 0) NOT NULL,
	[LEVEL4] [varchar](20) NOT NULL,
	[SES] [numeric](1, 0) NOT NULL,
	[AREATRI1KM] [numeric](1, 0) NOT NULL,
	[NEAR_DIST] [numeric](7, 2) NOT NULL,
	[TRI_1KM] [numeric](1, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.SES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'SES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.AREATRI1KM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'AREATRI1KM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.NEAR_DIST' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'NEAR_DIST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4.TRI_1KM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4', @level2type=N'COLUMN',@level2name=N'TRI_1KM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_COVARIATES_LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_COVARIATES_LEVEL4'
GO
