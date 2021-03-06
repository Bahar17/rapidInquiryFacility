USE [RIF40]
GO
/****** Object:  Table [dbo].[T_RIF40_FDW_TABLES]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_RIF40_FDW_TABLES](
	[USERNAME] [varchar](90) NOT NULL,
	[TABLE_NAME] [varchar](30) NOT NULL,
	[CREATE_STATUS] [varchar](1) NOT NULL,
	[ERROR_MESSAGE] [varchar](300) NULL,
	[DATE_CREATED] [datetime2](0) NOT NULL,
	[ROWTEST_PASSED] [numeric](1, 0) NOT NULL,
 CONSTRAINT [T_RIF40_FDW_TABLES_PK] PRIMARY KEY CLUSTERED 
(
	[TABLE_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] ADD  DEFAULT (user_name()) FOR [USERNAME]
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] ADD  DEFAULT (sysdatetime()) FOR [DATE_CREATED]
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] ADD  DEFAULT ((0)) FOR [ROWTEST_PASSED]
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES]  WITH NOCHECK ADD  CONSTRAINT [T_RIF40_FDW_TABLES_TN_FK] FOREIGN KEY([TABLE_NAME])
REFERENCES [dbo].[RIF40_TABLES] ([TABLE_NAME])
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] CHECK CONSTRAINT [T_RIF40_FDW_TABLES_TN_FK]
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES]  WITH CHECK ADD  CONSTRAINT [T_RIF40_FDW_TABLES_CK1] CHECK  (([CREATE_STATUS]='N' OR [CREATE_STATUS]='E' OR [CREATE_STATUS]='C'))
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] CHECK CONSTRAINT [T_RIF40_FDW_TABLES_CK1]
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES]  WITH CHECK ADD  CONSTRAINT [T_RIF40_FDW_TABLES_CK2] CHECK  (([ROWTEST_PASSED]=(1) OR [ROWTEST_PASSED]=(0)))
GO
ALTER TABLE [dbo].[T_RIF40_FDW_TABLES] CHECK CONSTRAINT [T_RIF40_FDW_TABLES_CK2]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.USERNAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'USERNAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.TABLE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.CREATE_STATUS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'CREATE_STATUS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.ERROR_MESSAGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'ERROR_MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.DATE_CREATED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'DATE_CREATED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.ROWTEST_PASSED' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'COLUMN',@level2name=N'ROWTEST_PASSED'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.T_RIF40_FDW_TABLES_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_FDW_TABLES_PK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.T_RIF40_FDW_TABLES_CK1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_FDW_TABLES_CK1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_FDW_TABLES.T_RIF40_FDW_TABLES_CK2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_FDW_TABLES', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_FDW_TABLES_CK2'
GO
