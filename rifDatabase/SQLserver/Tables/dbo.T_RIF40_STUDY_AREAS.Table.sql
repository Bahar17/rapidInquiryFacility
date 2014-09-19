USE [RIF40]
GO
/****** Object:  Table [dbo].[T_RIF40_STUDY_AREAS]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_RIF40_STUDY_AREAS](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[AREA_ID] [varchar](300) NOT NULL,
	[BAND_ID] [numeric](8, 0) NULL,
	[ROWID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [T_RIF40_STUDY_AREAS_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[AREA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_AREAS] ADD  DEFAULT (user_name()) FOR [USERNAME]
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_AREAS] ADD  DEFAULT (newid()) FOR [ROWID]
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_AREAS]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDYAREAS_STUDY_ID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_AREAS] CHECK CONSTRAINT [T_RIF40_STUDYAREAS_STUDY_ID_FK]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.AREA_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'AREA_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.BAND_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'COLUMN',@level2name=N'BAND_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_AREAS.T_RIF40_STUDY_AREAS_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_AREAS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_STUDY_AREAS_PK'
GO
