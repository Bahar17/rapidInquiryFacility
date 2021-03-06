USE [RIF40]
GO
/****** Object:  Table [dbo].[SAHSULAND_GEOGRAPHY]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SAHSULAND_GEOGRAPHY](
	[LEVEL1] [varchar](20) NOT NULL,
	[LEVEL2] [varchar](20) NOT NULL,
	[LEVEL3] [varchar](20) NOT NULL,
	[LEVEL4] [varchar](20) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY.LEVEL4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY', @level2type=N'COLUMN',@level2name=N'LEVEL4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_GEOGRAPHY'
GO
