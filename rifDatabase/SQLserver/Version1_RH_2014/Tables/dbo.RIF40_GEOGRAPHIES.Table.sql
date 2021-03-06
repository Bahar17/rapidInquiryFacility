USE [RIF40]
GO
/****** Object:  Table [dbo].[RIF40_GEOGRAPHIES]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RIF40_GEOGRAPHIES](
	[GEOGRAPHY] [varchar](50) NOT NULL,
	[DESCRIPTION] [varchar](250) NOT NULL,
	[HIERARCHYTABLE] [varchar](30) NOT NULL,
	[SRID] [numeric](6, 0) NOT NULL,
	[DEFAULTCOMPAREA] [varchar](30) NULL,
	[DEFAULTSTUDYAREA] [varchar](30) NULL,
	[POSTAL_POPULATION_TABLE] [varchar](30) NULL,
	[POSTAL_POINT_COLUMN] [varchar](30) NULL,
	[PARTITION] [numeric](1, 0) NOT NULL,
	[MAX_GEOJSON_DIGITS] [numeric](2, 0) NULL,
 CONSTRAINT [RIF40_GEOGRAPHIES_PK] PRIMARY KEY CLUSTERED 
(
	[GEOGRAPHY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] ADD  DEFAULT ((0)) FOR [SRID]
GO
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] ADD  DEFAULT ((0)) FOR [PARTITION]
GO
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] ADD  DEFAULT ((8)) FOR [MAX_GEOJSON_DIGITS]
GO
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES]  WITH NOCHECK ADD  CONSTRAINT [POSTAL_POPULATION_TABLE_CK] CHECK  (([POSTAL_POPULATION_TABLE] IS NOT NULL AND [POSTAL_POINT_COLUMN] IS NOT NULL OR [POSTAL_POPULATION_TABLE] IS NULL AND [POSTAL_POINT_COLUMN] IS NULL))
GO
ALTER TABLE [dbo].[RIF40_GEOGRAPHIES] CHECK CONSTRAINT [POSTAL_POPULATION_TABLE_CK]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.GEOGRAPHY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'GEOGRAPHY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.HIERARCHYTABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'HIERARCHYTABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.SRID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'SRID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.DEFAULTCOMPAREA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'DEFAULTCOMPAREA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.DEFAULTSTUDYAREA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'DEFAULTSTUDYAREA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.POSTAL_POPULATION_TABLE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'POSTAL_POPULATION_TABLE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.POSTAL_POINT_COLUMN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'POSTAL_POINT_COLUMN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES."PARTITION"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'PARTITION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.MAX_GEOJSON_DIGITS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'COLUMN',@level2name=N'MAX_GEOJSON_DIGITS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.RIF40_GEOGRAPHIES_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'CONSTRAINT',@level2name=N'RIF40_GEOGRAPHIES_PK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_GEOGRAPHIES.POSTAL_POPULATION_TABLE_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_GEOGRAPHIES', @level2type=N'CONSTRAINT',@level2name=N'POSTAL_POPULATION_TABLE_CK'
GO
