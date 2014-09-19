USE [RIF40]
GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLog](
	[ErrorTimestamp] [datetime2](7) NOT NULL,
	[ErrorMessage] [nvarchar](200) NULL
) ON [PRIMARY]

GO
