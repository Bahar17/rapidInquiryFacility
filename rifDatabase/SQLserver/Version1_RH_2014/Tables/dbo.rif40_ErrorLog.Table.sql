USE [RIF40]
GO
/****** Object:  Table [dbo].[rif40_ErrorLog]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rif40_ErrorLog](
	[Error_Number] [int] NOT NULL,
	[Error_LINE] [int] NOT NULL,
	[Error_Location] [sysname] NOT NULL,
	[Error_Message] [varchar](max) NULL,
	[SPID] [int] NULL,
	[Program_Name] [varchar](255) NULL,
	[Client_Address] [varchar](255) NULL,
	[Authentication] [varchar](50) NULL,
	[Error_User_Application] [varchar](100) NULL,
	[Error_Date] [datetime] NULL,
	[Error_User_System] [sysname] NOT NULL,
	[Id_new] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[rif40_ErrorLog] ADD  CONSTRAINT [dfltErrorLog_error_date]  DEFAULT (getdate()) FOR [Error_Date]
GO
ALTER TABLE [dbo].[rif40_ErrorLog] ADD  CONSTRAINT [dfltErrorLog_error_user_system]  DEFAULT (suser_sname()) FOR [Error_User_System]
GO
