USE [RIF40]
GO
/****** Object:  Table [dbo].[SpatialTable]    Script Date: 19/09/2014 12:07:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SpatialTable](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[GeomCol1] [geometry] NULL,
	[GeomCol2]  AS ([GeomCol1].[STAsText]())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
