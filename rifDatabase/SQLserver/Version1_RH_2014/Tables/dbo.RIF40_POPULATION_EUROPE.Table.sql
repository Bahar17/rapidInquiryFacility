USE [RIF40]
GO
/****** Object:  Table [dbo].[RIF40_POPULATION_EUROPE]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RIF40_POPULATION_EUROPE](
	[YEAR] [numeric](4, 0) NOT NULL,
	[AGE_SEX_GROUP] [numeric](3, 0) NOT NULL,
	[TOTAL] [numeric](10, 2) NOT NULL,
 CONSTRAINT [RIF40_POPULATION_EUROPE_PK] PRIMARY KEY CLUSTERED 
(
	[AGE_SEX_GROUP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[RIF40_POPULATION_EUROPE] ADD  DEFAULT ((1991)) FOR [YEAR]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE."YEAR"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE', @level2type=N'COLUMN',@level2name=N'YEAR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE.AGE_SEX_GROUP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE', @level2type=N'COLUMN',@level2name=N'AGE_SEX_GROUP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE.TOTAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE', @level2type=N'COLUMN',@level2name=N'TOTAL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_POPULATION_EUROPE.RIF40_POPULATION_EUROPE_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_POPULATION_EUROPE', @level2type=N'CONSTRAINT',@level2name=N'RIF40_POPULATION_EUROPE_PK'
GO
