USE [RIF40]
GO
/****** Object:  Table [dbo].[T_RIF40_STUDY_SQL_LOG]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_RIF40_STUDY_SQL_LOG](
	[USERNAME] [varchar](90) NOT NULL,
	[STUDY_ID] [numeric](8, 0) NOT NULL,
	[STATEMENT_TYPE] [varchar](30) NOT NULL,
	[STATEMENT_NUMBER] [numeric](6, 0) NOT NULL,
	[LOG_MESSAGE] [varchar](4000) NOT NULL,
	[LOG_SQLCODE] [varchar](5) NOT NULL,
	[ROWCOUNT] [numeric](12, 0) NOT NULL,
	[START_TIME] [datetimeoffset](6) NOT NULL,
	[ELAPSED_TIME] [numeric](10, 4) NOT NULL,
	[AUDSID] [varchar](90) NOT NULL,
 CONSTRAINT [T_RIF40_STUDY_SQL_LOG_PK] PRIMARY KEY CLUSTERED 
(
	[STUDY_ID] ASC,
	[STATEMENT_NUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG] ADD  DEFAULT (user_name()) FOR [USERNAME]
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_STUDY_SQLLOG_STDID_FK] FOREIGN KEY([STUDY_ID])
REFERENCES [dbo].[T_RIF40_STUDIES] ([STUDY_ID])
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG] CHECK CONSTRAINT [T_RIF40_STUDY_SQLLOG_STDID_FK]
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG]  WITH CHECK ADD  CONSTRAINT [STATEMENT_TYPE_CK1] CHECK  (([STATEMENT_TYPE]='DENOMINATOR_CHECK' OR [STATEMENT_TYPE]='NUMERATOR_CHECK' OR [STATEMENT_TYPE]='POST_INSERT' OR [STATEMENT_TYPE]='INSERT' OR [STATEMENT_TYPE]='CREATE'))
GO
ALTER TABLE [dbo].[T_RIF40_STUDY_SQL_LOG] CHECK CONSTRAINT [STATEMENT_TYPE_CK1]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.STUDY_ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'STUDY_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.STATEMENT_TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'STATEMENT_TYPE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.STATEMENT_NUMBER' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'STATEMENT_NUMBER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.LOG_MESSAGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'LOG_MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.LOG_SQLCODE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'LOG_SQLCODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG."ROWCOUNT"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'ROWCOUNT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.START_TIME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'START_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.ELAPSED_TIME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'ELAPSED_TIME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.AUDSID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'COLUMN',@level2name=N'AUDSID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.T_RIF40_STUDY_SQL_LOG_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_STUDY_SQL_LOG_PK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_STUDY_SQL_LOG.STATEMENT_TYPE_CK1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_STUDY_SQL_LOG', @level2type=N'CONSTRAINT',@level2name=N'STATEMENT_TYPE_CK1'
GO
