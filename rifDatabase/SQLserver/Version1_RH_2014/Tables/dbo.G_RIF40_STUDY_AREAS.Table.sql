USE [RIF40]
GO
/****** Object:  Table [dbo].[G_RIF40_STUDY_AREAS]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[G_RIF40_STUDY_AREAS](
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [varchar](300) NOT NULL,
	[BAND_ID] [numeric](2, 0) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS.BAND_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'BAND_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.G_RIF40_STUDY_AREAS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'G_RIF40_STUDY_AREAS'
GO
