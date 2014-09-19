USE [RIF40]
GO
/****** Object:  Table [dbo].[RIF40_OUTCOME_GROUPS]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RIF40_OUTCOME_GROUPS](
	[OUTCOME_TYPE] [varchar](20) NOT NULL,
	[OUTCOME_GROUP_NAME] [varchar](30) NOT NULL,
	[OUTCOME_GROUP_DESCRIPTION] [varchar](250) NOT NULL,
	[FIELD_NAME] [varchar](30) NOT NULL,
	[MULTIPLE_FIELD_COUNT] [numeric](2, 0) NOT NULL,
 CONSTRAINT [RIF40_OUTCOME_GROUPS_PK] PRIMARY KEY CLUSTERED 
(
	[OUTCOME_GROUP_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS]  WITH NOCHECK ADD  CONSTRAINT [RIF40_OUTCOME_GROUPS_TYPE_FK] FOREIGN KEY([OUTCOME_TYPE])
REFERENCES [dbo].[RIF40_OUTCOMES] ([OUTCOME_TYPE])
GO
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS] CHECK CONSTRAINT [RIF40_OUTCOME_GROUPS_TYPE_FK]
GO
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS]  WITH NOCHECK ADD  CONSTRAINT [OUTCOME_TYPE_CK2] CHECK  (([OUTCOME_TYPE]='BIRTHWEIGHT' OR [OUTCOME_TYPE]='OPCS' OR [OUTCOME_TYPE]='ICD-O' OR [OUTCOME_TYPE]='ICD' OR [OUTCOME_TYPE]='A&E'))
GO
ALTER TABLE [dbo].[RIF40_OUTCOME_GROUPS] CHECK CONSTRAINT [OUTCOME_TYPE_CK2]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.OUTCOME_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'OUTCOME_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.OUTCOME_GROUP_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'OUTCOME_GROUP_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.OUTCOME_GROUP_DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'OUTCOME_GROUP_DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.FIELD_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'FIELD_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.MULTIPLE_FIELD_COUNT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'COLUMN',@level2name=N'MULTIPLE_FIELD_COUNT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.RIF40_OUTCOME_GROUPS_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'CONSTRAINT',@level2name=N'RIF40_OUTCOME_GROUPS_PK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_OUTCOME_GROUPS.OUTCOME_TYPE_CK2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_OUTCOME_GROUPS', @level2type=N'CONSTRAINT',@level2name=N'OUTCOME_TYPE_CK2'
GO
