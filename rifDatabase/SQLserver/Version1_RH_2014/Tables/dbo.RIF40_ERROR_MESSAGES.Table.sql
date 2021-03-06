USE [RIF40]
GO
/****** Object:  Table [dbo].[RIF40_ERROR_MESSAGES]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RIF40_ERROR_MESSAGES](
	[ERROR_CODE] [numeric](5, 0) NOT NULL,
	[TAG] [varchar](80) NOT NULL,
	[TABLE_NAME] [varchar](30) NULL,
	[CAUSE] [varchar](4000) NOT NULL,
	[ACTION] [varchar](512) NOT NULL,
	[MESSAGE] [varchar](512) NOT NULL,
	[ROWID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [RIF40_ERROR_MESSAGES_PK] PRIMARY KEY CLUSTERED 
(
	[ERROR_CODE] ASC,
	[TAG] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[RIF40_ERROR_MESSAGES]  WITH NOCHECK ADD  CONSTRAINT [RIF40_ERROR_MESSAGES_CODE_CK] CHECK  (([ERROR_CODE]=(-2291) OR [ERROR_CODE]=(-2290) OR [ERROR_CODE]=(-4088) OR [ERROR_CODE]=(-1) OR [ERROR_CODE]>=(-20999) AND [ERROR_CODE]<=(-20000)))
GO
ALTER TABLE [dbo].[RIF40_ERROR_MESSAGES] CHECK CONSTRAINT [RIF40_ERROR_MESSAGES_CODE_CK]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.ERROR_CODE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'ERROR_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.TAG' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'TAG'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.TABLE_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'TABLE_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.CAUSE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'CAUSE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.ACTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'ACTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.MESSAGE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'COLUMN',@level2name=N'MESSAGE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.RIF40_ERROR_MESSAGES_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'CONSTRAINT',@level2name=N'RIF40_ERROR_MESSAGES_PK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_ERROR_MESSAGES.RIF40_ERROR_MESSAGES_CODE_CK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_ERROR_MESSAGES', @level2type=N'CONSTRAINT',@level2name=N'RIF40_ERROR_MESSAGES_CODE_CK'
GO
