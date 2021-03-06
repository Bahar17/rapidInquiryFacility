USE [RIF40]
GO
/****** Object:  Table [dbo].[T_RIF40_CONTEXTUAL_STATS]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[INV_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [numeric](8, 0) NOT NULL,
	[AREA_POPULATION] [numeric](38, 6) NULL,
	[AREA_OBSERVED] [numeric](38, 6) NULL,
	[TOTAL_COMPARISION_POPULATION] [numeric](38, 6) NULL,
	[VARIANCE_HIGH] [numeric](38, 6) NULL,
	[VARIANCE_LOW] [numeric](38, 6) NULL,
	[ROWID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [T_RIF40_CONTEXTUAL_STATS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[AREA_ID] ASC,
	[INV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS] ADD  DEFAULT (user_name()) FOR [USERNAME]
GO
ALTER TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS] ADD  DEFAULT (newid()) FOR [ROWID]
GO
ALTER TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_CONSTATS_STUDY_ID_FK] FOREIGN KEY([STUDY_ID], [INV_ID])
REFERENCES [dbo].[T_RIF40_INVESTIGATIONS] ([STUDY_ID], [INV_ID])
GO
ALTER TABLE [dbo].[T_RIF40_CONTEXTUAL_STATS] CHECK CONSTRAINT [T_RIF40_CONSTATS_STUDY_ID_FK]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.INV_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'INV_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.AREA_POPULATION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'AREA_POPULATION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.AREA_OBSERVED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'AREA_OBSERVED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.TOTAL_COMPARISION_POPULATION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'TOTAL_COMPARISION_POPULATION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.VARIANCE_HIGH' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'VARIANCE_HIGH'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.VARIANCE_LOW' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'COLUMN',@level2name=N'VARIANCE_LOW'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_CONTEXTUAL_STATS.T_RIF40_CONTEXTUAL_STATS_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_CONTEXTUAL_STATS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_CONTEXTUAL_STATS_PK'
GO
