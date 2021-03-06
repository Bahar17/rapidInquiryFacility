USE [RIF40]
GO
/****** Object:  Table [dbo].[T_RIF40_PARAMETERS]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_RIF40_PARAMETERS](
	[PARAM_NAME] [varchar](30) NOT NULL,
	[PARAM_VALUE] [varchar](50) NOT NULL,
	[PARAM_DESCRIPTION] [varchar](250) NOT NULL,
 CONSTRAINT [T_RIF40_PARAMETERS_PK] PRIMARY KEY CLUSTERED 
(
	[PARAM_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS.PARAM_NAME' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS', @level2type=N'COLUMN',@level2name=N'PARAM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS.PARAM_VALUE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS', @level2type=N'COLUMN',@level2name=N'PARAM_VALUE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS.PARAM_DESCRIPTION' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS', @level2type=N'COLUMN',@level2name=N'PARAM_DESCRIPTION'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'RIF40.T_RIF40_PARAMETERS.T_RIF40_PARAMETERS_PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_RIF40_PARAMETERS', @level2type=N'CONSTRAINT',@level2name=N'T_RIF40_PARAMETERS_PK'
GO
