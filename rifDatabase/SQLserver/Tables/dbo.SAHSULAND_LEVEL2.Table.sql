USE [RIF40]
GO
/****** Object:  Table [dbo].[SAHSULAND_LEVEL2]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SAHSULAND_LEVEL2](
	[LEVEL2] [varchar](20) NOT NULL,
	[NAME] [varchar](200) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL2.LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL2', @level2type=N'COLUMN',@level2name=N'LEVEL2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL2."NAME"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL2', @level2type=N'COLUMN',@level2name=N'NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.SAHSULAND_LEVEL2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SAHSULAND_LEVEL2'
GO
