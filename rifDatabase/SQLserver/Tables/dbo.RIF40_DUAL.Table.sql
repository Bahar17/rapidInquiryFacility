USE [RIF40]
GO
/****** Object:  Table [dbo].[RIF40_DUAL]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RIF40_DUAL](
	[DUMMY] [varchar](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_DUAL.DUMMY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_DUAL', @level2type=N'COLUMN',@level2name=N'DUMMY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.RIF40_DUAL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RIF40_DUAL'
GO
