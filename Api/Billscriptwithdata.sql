--create database Billing
--use Billing
/****** Object:  UserDefinedFunction [dbo].[adjustedDate]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[adjustedDate](@dateReceived DATETIME, @numberOfDays int ,@Holidays nvarchar(max), @WeekOff nvarchar(max),@AdtnlHolidays nvarchar(max))
RETURNS DATETIME
AS
BEGIN
    DECLARE @adjustedDate DATETIME = @dateReceived
   

    -- Continue adding 1 day to @adjustedDate recursively until find one date that is not a weekend or holiday
    IF( EXISTS (select 1 from openjson(@Holidays,'$.Holidays') where value=@adjustedDate) or  EXISTS (select 1 from  openjson(@WeekOff,'$.weekOff') where value=DATENAME(weekday,@adjustedDate) )
	or EXISTS (select 1 from openjson(@AdtnlHolidays,'$.AdditionalDays') where value=@adjustedDate)
	 )   
        SET @adjustedDate = dbo.adjustedDate(DATEADD(DAY, @numberOfDays, @adjustedDate), @numberOfDays,@Holidays, @WeekOff,@AdtnlHolidays)

    RETURN @adjustedDate
END
GO
/****** Object:  UserDefinedFunction [dbo].[getFinYear]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getFinYear]()
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @QM_FIN_YEAR VARCHAR(200) =
        CASE
            WHEN Month(GETDATE()) BETWEEN 4 AND 12
			THEN CONVERT(VARCHAR(4),right(YEAR(GETDATE()),2)) + '-' + CONVERT(VARCHAR(4),(YEAR(GETDATE()) % 100 ) + 1)
               -- THEN CONVERT(VARCHAR(4),YEAR(GETDATE())) + '-' + CONVERT(VARCHAR(4),(YEAR(GETDATE()) % 100 ) + 1)
            WHEN Month(GETDATE()) BETWEEN 1 AND 3
                THEN CONVERT(VARCHAR(4),YEAR(GETDATE()) - 1) + '-' + CONVERT(VARCHAR(4),(YEAR(GETDATE()) % 100 ) + 1)
	END
	RETURN @QM_FIN_YEAR
END
GO
/****** Object:  UserDefinedFunction [dbo].[JsonToKeyPair]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[JsonToKeyPair]  
(  
    @Tiers varchar(max)  
)  
RETURNS varchar(100) -- or whatever length you need  
AS  
BEGIN  
     
   DECLARE @tempTable table (ID int ,[key] varchar(50), [value] varchar(50))  
  
   insert @tempTable  
   SELECT [RN] = Row_number() OVER (ORDER BY [key]), [key], [value]   
  FROM OPENJSON(@Tiers) --WITH ([Key] NVARCHAR(50),Value NVARCHAR(50))   
    
  DECLARE @TierFilter nvarchar(max) = '' , @key nvarchar(100),@value nvarchar(100)  
  DECLARE @start int =1 ,@cnt INT = (SELECT count(*) FROM @tempTable);  
    
  WHILE @start <= @cnt BEGIN  
   SELECT @key = [key],@value=[value]  
   FROM @tempTable  
   WHERE ID = @start  
   SET @TierFilter = @TierFilter + ''+ @key +':' + @value + ','  
   SET @start = @start + 1;  
  END;  
    if @cnt > 0 Begin set @TierFilter = SUBSTRING ( @TierFilter ,0 , len(@TierFilter) )End
		
    RETURN  @TierFilter  
  
END
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[Split] (
      @InputString                  VARCHAR(8000),
      @Delimiter                    VARCHAR(50)
)

RETURNS @Items TABLE (
      Item                          VARCHAR(8000)
)

AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END

      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','

--INSERT INTO @Items VALUES (@Delimiter) -- Diagnostic
--INSERT INTO @Items VALUES (@InputString) -- Diagnostic

      DECLARE @Item                 VARCHAR(8000)
      DECLARE @ItemList       VARCHAR(8000)
      DECLARE @DelimIndex     INT

      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            INSERT INTO @Items VALUES (@Item)

            -- Set @ItemList = @ItemList minus one less item
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      END -- End WHILE

      IF @Item IS NOT NULL -- At least one delimiter was encountered in @InputString
      BEGIN
            SET @Item = @ItemList
            INSERT INTO @Items VALUES (@Item)
      END

      -- No delimiters were encountered in @InputString, so just return @InputString
      ELSE INSERT INTO @Items VALUES (@InputString)

      RETURN

END
GO
/****** Object:  Table [dbo].[Action]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Action](
	[ActionId] [int] NOT NULL,
	[MenuId] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Remarks] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Action_ActionId] PRIMARY KEY CLUSTERED 
(
	[ActionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Area]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Area](
	[AreaId] [int] IDENTITY(1,1) NOT NULL,
	[StateId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[CityId] [int] NOT NULL,
	[AreaName] [nvarchar](100) NOT NULL,
	[Pincode] [nvarchar](20) NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
	[AreaCode] [nvarchar](5) NULL,
 CONSTRAINT [PK_Area_AreaId] PRIMARY KEY CLUSTERED 
(
	[AreaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditLog]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditLog](
	[AuditId] [int] IDENTITY(1,1) NOT NULL,
	[ActionName] [nvarchar](90) NULL,
	[Description] [ntext] NULL,
	[ScreenName] [nvarchar](90) NULL,
	[ActionBy] [nvarchar](90) NULL,
	[Date] [datetime] NULL,
	[ActionType] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[City]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City](
	[CityId] [int] IDENTITY(1,1) NOT NULL,
	[StateId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[CityName] [nvarchar](100) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_City_CityId] PRIMARY KEY CLUSTERED 
(
	[CityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Company]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Company](
	[CompanyId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](100) NOT NULL,
	[CompanyCode] [nvarchar](20) NOT NULL,
	[CountryId] [int] NOT NULL,
	[StateId] [int] NULL,
	[CityId] [int] NULL,
	[AreaId] [int] NULL,
	[AddressLine1] [nvarchar](max) NULL,
	[ParentCompany] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
	[EMail] [nvarchar](max) NULL,
	[PhoneNo] [nvarchar](max) NULL,
	[Website] [nvarchar](max) NULL,
	[BusinessId] [int] NULL,
	[TypeId] [int] NULL,
	[CompanyLogo] [nvarchar](200) NULL,
	[AddressLine2] [nvarchar](300) NULL,
	[FaxNo] [nvarchar](50) NULL,
	[Pincode] [nvarchar](15) NULL,
	[OrgLvlId] [int] NULL,
 CONSTRAINT [PK_Company_CompanyId] PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[CountryId] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](100) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
	[CountryCode] [nvarchar](10) NULL,
	[CurrencyName] [nvarchar](500) NULL,
	[CurrencyCode] [nvarchar](50) NULL,
	[CurrencySymbol] [nvarchar](20) NULL,
 CONSTRAINT [PK_Country_CountryId] PRIMARY KEY CLUSTERED 
(
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CUS_tCustomerMaster]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CUS_tCustomerMaster](
	[CustomerId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerName] [varchar](30) NULL,
	[CustomerGSTNo] [varchar](15) NULL,
	[ContactNo] [varchar](15) NULL,
	[State] [varchar](50) NULL,
	[StateCode] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[data]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[data](
	[StudentId] [int] NULL,
	[StudentName] [varchar](50) NULL,
	[Address] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Debtors_table]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Debtors_table](
	[BillNo] [int] NULL,
	[payableAmount] [decimal](15, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Department]    Script Date: 11/27/2018 7:55:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Department](
	[DepartmentId] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [nvarchar](max) NULL,
	[CompanyId] [int] NULL,
	[ParentId] [int] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[Code] [varchar](10) NULL,
 CONSTRAINT [PK_Department_DepartmentId] PRIMARY KEY CLUSTERED 
(
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Designation]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Designation](
	[DesignationId] [int] IDENTITY(1,1) NOT NULL,
	[DesignationName] [nvarchar](max) NULL,
	[CompanyId] [int] NOT NULL,
	[DepartmentId] [int] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[Superior] [int] NULL,
	[Code] [varchar](10) NULL,
 CONSTRAINT [PK_Designation_DesignationId] PRIMARY KEY CLUSTERED 
(
	[DesignationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[EmployeeId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[CompanyId] [int] NOT NULL,
	[DepartmentId] [int] NOT NULL,
	[DesignationId] [int] NOT NULL,
	[DOJ] [datetime] NULL,
	[DOB] [datetime] NULL,
	[Gender] [nvarchar](1) NULL,
	[MaritalStatus] [nvarchar](1) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[EmployeeCode] [nvarchar](200) NULL,
	[FatherName] [nvarchar](200) NULL,
	[ReportingTo] [int] NULL,
	[BloodGroup] [nvarchar](10) NULL,
	[SpouseName] [nvarchar](50) NULL,
	[Children] [int] NULL,
	[ProfilePhoto] [nvarchar](200) NULL,
	[kpostUcode] [varchar](max) NULL,
	[KpostUCodeStatus] [bit] NOT NULL,
 CONSTRAINT [PK_Employee_EmployeeId] PRIMARY KEY CLUSTERED 
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeAcademy]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeAcademy](
	[AcademyId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [int] NULL,
	[EmployeeId] [int] NULL,
	[Graduation] [nvarchar](100) NULL,
	[Degree] [nvarchar](100) NULL,
	[Specialization] [nvarchar](100) NULL,
	[University] [nvarchar](100) NULL,
	[Percentage] [float] NULL,
	[YearofPassing] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[DocAttachment] [nvarchar](200) NULL,
 CONSTRAINT [PK_EmployeeAcademy_AcademyId] PRIMARY KEY CLUSTERED 
(
	[AcademyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeAddress]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeAddress](
	[EmployeeID] [int] NOT NULL,
	[CompanyId] [int] NULL,
	[PerAddress1] [nvarchar](500) NULL,
	[PerAddress2] [nvarchar](500) NULL,
	[PerArea] [nvarchar](200) NULL,
	[PerCity] [nvarchar](200) NULL,
	[PerState] [nvarchar](200) NULL,
	[PerCountry] [nvarchar](200) NULL,
	[PerPincode] [nvarchar](20) NULL,
	[PerEmailId] [nvarchar](100) NULL,
	[PerMobile] [nvarchar](20) NULL,
	[PerLandline] [nvarchar](20) NULL,
	[IsSameAddress] [bit] NULL,
	[CommAddress1] [nvarchar](500) NULL,
	[CommAddress2] [nvarchar](500) NULL,
	[CommArea] [nvarchar](200) NULL,
	[CommCity] [nvarchar](200) NULL,
	[CommState] [nvarchar](200) NULL,
	[CommCountry] [nvarchar](200) NULL,
	[CommPincode] [nvarchar](20) NULL,
	[CommEmailId] [nvarchar](100) NULL,
	[CommMobile] [nvarchar](20) NULL,
	[CommLandline] [nvarchar](20) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_EmployeeAddress_AddressId] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeComponent]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeComponent](
	[EmployeeComponentId] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [int] NULL,
	[ComponentId] [int] NULL,
	[Amount] [money] NULL,
	[SalaryType] [varchar](300) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeComponentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeExperience]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeExperience](
	[ExperienceId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [int] NULL,
	[EmployeeId] [int] NULL,
	[Organization] [nvarchar](200) NULL,
	[Department] [nvarchar](200) NULL,
	[Designation] [nvarchar](200) NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[YearsofExperience] [float] NULL,
	[Remarks] [nvarchar](500) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_EmployeeExperience_ExperienceId] PRIMARY KEY CLUSTERED 
(
	[ExperienceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeSalary]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeSalary](
	[EmployeeSalaryId] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [int] NULL,
	[Current_Month] [nvarchar](30) NULL,
	[Salary] [int] NULL,
	[SalaryDtls] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeSalaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLog](
	[ErrorId] [int] IDENTITY(1,1) NOT NULL,
	[ErrorCode] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Message] [nvarchar](max) NULL,
	[ErrorLine] [nvarchar](70) NULL,
	[ScreenName] [nvarchar](70) NULL,
	[ActionName] [nvarchar](70) NULL,
	[Date] [datetime] NULL,
	[ActionBy] [nvarchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[INV_tInventoryMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INV_tInventoryMaster](
	[ProductNameId] [int] NULL,
	[ProductSizeId] [int] NULL,
	[Quantity] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Menu]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menu](
	[MenuId] [int] NOT NULL,
	[MenuName] [nvarchar](max) NULL,
	[MenuUrl] [nvarchar](max) NULL,
	[MenuIcon] [nvarchar](max) NULL,
	[MenuOrder] [int] NULL,
	[ParentMenu] [int] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[ProcessPrivilege] [nvarchar](3) NULL,
 CONSTRAINT [PK_Menu_MenuId] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NatureOfBusiness]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NatureOfBusiness](
	[BusinessId] [int] IDENTITY(1,1) NOT NULL,
	[BusinessName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_NatureOfBusiness_BusinessId] PRIMARY KEY CLUSTERED 
(
	[BusinessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrganizationLevel]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganizationLevel](
	[OrgLvlId] [int] IDENTITY(1,1) NOT NULL,
	[LevelName] [nvarchar](100) NOT NULL,
	[Parent] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
	[Code] [varchar](10) NULL,
 CONSTRAINT [PK_OrganizationLevel_OrgLvlId] PRIMARY KEY CLUSTERED 
(
	[OrgLvlId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OwnershipTypes]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OwnershipTypes](
	[TypeId] [int] IDENTITY(1,1) NOT NULL,
	[OwnershipName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_OwnershipTypes_TypeId] PRIMARY KEY CLUSTERED 
(
	[TypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRO_tProductNameMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRO_tProductNameMaster](
	[ProductNameId] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [varchar](30) NULL,
	[HSN_Code] [varchar](15) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductNameId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRO_tProductSizeMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRO_tProductSizeMaster](
	[ProductSizeId] [int] IDENTITY(1,1) NOT NULL,
	[ProductSize] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductSizeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PUR_tPurchaseDetails]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PUR_tPurchaseDetails](
	[BillNo] [int] NULL,
	[ProductNameId] [int] NULL,
	[HSN_Code] [varchar](15) NULL,
	[ProductSizeId] [int] NULL,
	[Quantity] [int] NULL,
	[Rate] [decimal](15, 5) NULL,
	[Amount] [decimal](15, 5) NULL,
	[Tax] [varchar](10) NULL,
	[TotalAmount] [decimal](15, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PUR_tPurchaseMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PUR_tPurchaseMaster](
	[BillNo] [int] NOT NULL,
	[BillDate] [datetime] NULL,
	[VendorId] [int] NULL,
	[GrandTotal] [decimal](15, 5) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleMaster](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](100) NOT NULL,
	[OrgLvlId] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_RoleMaster_RoleId] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleMenuMapping]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleMenuMapping](
	[RoleId] [int] NOT NULL,
	[MenuId] [int] NOT NULL,
	[ActionList] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_RoleMenuMapping_RoleMenuMappingId_RoleId_MenuId] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SAL_tSalesDetails]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SAL_tSalesDetails](
	[BillNo] [int] NULL,
	[ProductNameId] [int] NULL,
	[HSN_Code] [varchar](10) NULL,
	[ProductSizeId] [int] NULL,
	[Quantity] [int] NULL,
	[Rate] [decimal](15, 5) NULL,
	[Amount] [decimal](15, 5) NULL,
	[Tax] [varchar](10) NULL,
	[TotalAmount] [decimal](15, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SAL_tSalesDetailsPaid]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SAL_tSalesDetailsPaid](
	[BillNo] [int] NULL,
	[ProductNameId] [int] NULL,
	[HSN_Code] [varchar](10) NULL,
	[ProductSizeId] [int] NULL,
	[Quantity] [int] NULL,
	[Rate] [decimal](15, 5) NULL,
	[Amount] [decimal](15, 5) NULL,
	[Tax] [varchar](10) NULL,
	[TotalAmount] [decimal](15, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SAL_tSalesMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SAL_tSalesMaster](
	[BillNo] [int] IDENTITY(1,1) NOT NULL,
	[BillingDate] [datetime] NULL,
	[GSTNo] [varchar](15) NULL,
	[CustomerId] [int] NULL,
	[GrandTotal] [decimal](15, 5) NULL,
	[PaidAmount] [decimal](15, 5) NULL,
	[BalanceAmount] [decimal](15, 5) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[State1]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[State1](
	[sateId] [int] NULL,
	[stateName] [varchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StateMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StateMaster](
	[StateId] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[StateName] [nvarchar](100) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_StateMaster_StateMasterId] PRIMARY KEY CLUSTERED 
(
	[StateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Token]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Token](
	[TokenId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [bigint] NOT NULL,
	[AuthToken] [nvarchar](100) NULL,
	[IssuedOn] [datetime] NULL,
	[ExpiresOn] [datetime] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Token_TokenId] PRIMARY KEY CLUSTERED 
(
	[TokenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransporationDetails]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransporationDetails](
	[BillNo] [int] NULL,
	[TransporationMode] [varchar](max) NULL,
	[VehicleNumber] [varchar](50) NULL,
	[DateOfSupply] [datetime] NULL,
	[PlaceOfSupply] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserMaster]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserMaster](
	[UserId] [bigint] IDENTITY(1001,1) NOT NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[UserName] [nvarchar](150) NOT NULL,
	[PasswordHash] [nvarchar](100) NOT NULL,
	[PasswordKey] [nvarchar](100) NOT NULL,
	[ResetKey] [nvarchar](100) NULL,
	[EmailId] [nvarchar](200) NOT NULL,
	[RoleId] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
	[RefId] [bigint] NULL,
	[UserType] [varchar](15) NULL,
	[CompanyId] [int] NULL,
	[SelectedCompany] [int] NULL,
 CONSTRAINT [PK_UserMaster_UserId] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserMenuMapping]    Script Date: 11/27/2018 7:55:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserMenuMapping](
	[UserId] [bigint] NOT NULL,
	[MenuId] [int] NOT NULL,
	[ActionList] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_UserMenuMapping_UserMaster_UserId_MenuId] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VEN_tVendorMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VEN_tVendorMaster](
	[VendorId] [int] IDENTITY(1,1) NOT NULL,
	[GSTNo] [varchar](15) NULL,
	[VendorName] [varchar](30) NULL,
	[Address] [varchar](200) NULL,
	[ContactNo] [varchar](15) NULL,
PRIMARY KEY CLUSTERED 
(
	[VendorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Area] ON 

INSERT [dbo].[Area] ([AreaId], [StateId], [CountryId], [CityId], [AreaName], [Pincode], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [AreaCode]) VALUES (1, 1, 1, 1, N'Alwarpet', N'600025', 1001, CAST(N'2017-11-13T13:07:29.093' AS DateTime), 1001, CAST(N'2017-11-13T13:07:29.093' AS DateTime), 1, NULL)
INSERT [dbo].[Area] ([AreaId], [StateId], [CountryId], [CityId], [AreaName], [Pincode], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [AreaCode]) VALUES (2, 1, 1, 1, N'Ranipet', N'632404', 1004, CAST(N'2017-12-22T11:13:47.560' AS DateTime), 1004, CAST(N'2017-12-22T11:13:47.560' AS DateTime), 1, NULL)
INSERT [dbo].[Area] ([AreaId], [StateId], [CountryId], [CityId], [AreaName], [Pincode], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [AreaCode]) VALUES (3, 1, 1, 2, N'Thoppur', N'625008', 1004, CAST(N'2018-05-30T11:50:15.237' AS DateTime), 1004, CAST(N'2018-05-30T11:50:15.237' AS DateTime), 1, N'TPR')
INSERT [dbo].[Area] ([AreaId], [StateId], [CountryId], [CityId], [AreaName], [Pincode], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [AreaCode]) VALUES (4, 1, 1, 3, N'Meyyanur', N'636004', 1005, CAST(N'2018-07-26T14:49:24.293' AS DateTime), 1005, CAST(N'2018-07-26T14:49:24.293' AS DateTime), 1, N'Mey')
INSERT [dbo].[Area] ([AreaId], [StateId], [CountryId], [CityId], [AreaName], [Pincode], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [AreaCode]) VALUES (5, 1, 1, 1, N'saidapet', N'600015', 1004, CAST(N'2018-08-09T16:34:35.063' AS DateTime), 1004, CAST(N'2018-08-09T16:34:35.063' AS DateTime), 1, N'sdt')
INSERT [dbo].[Area] ([AreaId], [StateId], [CountryId], [CityId], [AreaName], [Pincode], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [AreaCode]) VALUES (6, 1, 1, 1, N'R.A. PURAM', N'600028', 1004, CAST(N'2018-08-09T16:37:37.523' AS DateTime), 1004, CAST(N'2018-08-09T16:37:53.470' AS DateTime), 1, N'RAP')
SET IDENTITY_INSERT [dbo].[Area] OFF
SET IDENTITY_INSERT [dbo].[AuditLog] ON 

INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (1, N'Remove DrawingType', N'8 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-02-16T19:38:14.947' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (2, N'Remove DrawingType', N'8 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-04-07T13:18:00.850' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (3, N'Remove DrawingType', N'7 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-04-07T13:18:10.227' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (4, N'Remove DrawingType', N'9 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-04-07T13:21:17.710' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (5, N'Remove DrawingType', N'17 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-04-07T17:44:03.623' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (6, N'Remove DrawingType', N'18 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-04-07T17:44:07.020' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (7, N'Remove DrawingType', N'19 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-04-07T17:50:13.937' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (8, N'Remove DrawingType', N'20 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-04-17T12:48:13.130' AS DateTime), N'Success')
INSERT [dbo].[AuditLog] ([AuditId], [ActionName], [Description], [ScreenName], [ActionBy], [Date], [ActionType]) VALUES (9, N'Remove DrawingType', N'17 DrawingType Removed ', N'typeofDrawing', N'1', CAST(N'2018-08-03T12:12:21.460' AS DateTime), N'Success')
SET IDENTITY_INSERT [dbo].[AuditLog] OFF
SET IDENTITY_INSERT [dbo].[City] ON 

INSERT [dbo].[City] ([CityId], [StateId], [CountryId], [CityName], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive]) VALUES (1, 1, 1, N'Chennai', 1001, CAST(N'2017-11-13T13:07:29.093' AS DateTime), 1001, CAST(N'2017-11-13T13:07:29.093' AS DateTime), 1)
INSERT [dbo].[City] ([CityId], [StateId], [CountryId], [CityName], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive]) VALUES (2, 1, 1, N'Madurai', 1004, CAST(N'2018-05-30T11:49:28.720' AS DateTime), 1004, CAST(N'2018-05-30T11:49:28.720' AS DateTime), 1)
INSERT [dbo].[City] ([CityId], [StateId], [CountryId], [CityName], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive]) VALUES (3, 1, 1, N'Salem', 1005, CAST(N'2018-07-26T14:45:15.533' AS DateTime), 1005, CAST(N'2018-07-26T14:45:15.533' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[City] OFF
SET IDENTITY_INSERT [dbo].[Company] ON 

INSERT [dbo].[Company] ([CompanyId], [CompanyName], [CompanyCode], [CountryId], [StateId], [CityId], [AreaId], [AddressLine1], [ParentCompany], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [EMail], [PhoneNo], [Website], [BusinessId], [TypeId], [CompanyLogo], [AddressLine2], [FaxNo], [Pincode], [OrgLvlId]) VALUES (1, N'kaizen technosoft', N'PG', 1, 1, 1, 1, N'Greenways Tower', 0, 1001, CAST(N'2017-11-13T13:22:37.720' AS DateTime), 1001, CAST(N'2017-11-13T13:22:37.720' AS DateTime), 1, N'coc@gmail.com', N'9847156823', N'www.coc.com', 5, 1, N'636463665156781865.png', NULL, N'0456321897', N'600025', 1)
SET IDENTITY_INSERT [dbo].[Company] OFF
SET IDENTITY_INSERT [dbo].[Country] ON 

INSERT [dbo].[Country] ([CountryId], [CountryName], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [CountryCode], [CurrencyName], [CurrencyCode], [CurrencySymbol]) VALUES (1, N'India', 1001, CAST(N'2017-11-13T13:07:29.090' AS DateTime), 1004, CAST(N'2018-02-05T16:19:00.927' AS DateTime), 1, N'+91', N'Rupees', N'INR', N'₹')
SET IDENTITY_INSERT [dbo].[Country] OFF
SET IDENTITY_INSERT [dbo].[CUS_tCustomerMaster] ON 

INSERT [dbo].[CUS_tCustomerMaster] ([CustomerId], [CustomerName], [CustomerGSTNo], [ContactNo], [State], [StateCode]) VALUES (1, N'vj', N'67', N'888674524', N'TN', N'637005')
INSERT [dbo].[CUS_tCustomerMaster] ([CustomerId], [CustomerName], [CustomerGSTNo], [ContactNo], [State], [StateCode]) VALUES (2, N'John', N'G123', N'968532741', N'TamilNadu', N'637005')
SET IDENTITY_INSERT [dbo].[CUS_tCustomerMaster] OFF
INSERT [dbo].[data] ([StudentId], [StudentName], [Address]) VALUES (2, N'sathish', N'chennai')
SET IDENTITY_INSERT [dbo].[ErrorLog] ON 

INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (1, N'13609', N'GEN_sAddDrawingType', N'JSON text is not properly formatted. Unexpected character ''s'' is found at position 0.', N'6', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-04-07T11:50:45.860' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (2, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''s'' is found at position 0.', N'14', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-04-07T12:08:08.250' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (3, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''s'' is found at position 0.', N'14', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-04-07T12:08:10.597' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (4, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''s'' is found at position 0.', N'14', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-04-07T12:08:11.350' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (5, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''s'' is found at position 0.', N'14', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-04-07T12:08:11.657' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (6, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''s'' is found at position 0.', N'14', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-04-07T12:08:17.300' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (7, N'512', N'GEN_subModifyDrawingType', N'Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.', N'5', N'Drawing Master', N'[GEN_subModifyDrawingType]', CAST(N'2018-04-18T13:14:08.447' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (8, N'512', N'GEN_subModifyDrawingType', N'Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.', N'5', N'Drawing Master', N'[GEN_subModifyDrawingType]', CAST(N'2018-04-18T13:14:16.220' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (9, N'547', N'sp_GEN_ModifyIOM', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_IOM_UOM_Master_UOM_Id". The conflict occurred in database "KPMES_Prod", table "dbo.UOM_Master", column ''UOM_Id''.', N'16', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-04-19T16:59:06.103' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (10, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_IOM_UOM_Master_UOM_Id". The conflict occurred in database "KPMES_Prod", table "dbo.UOM_Master", column ''UOM_Id''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-04-19T16:59:40.030' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (11, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_IOM_UOM_Master_UOM_Id". The conflict occurred in database "KPMES_Prod", table "dbo.UOM_Master", column ''UOM_Id''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-04-19T17:01:29.177' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (12, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_IOM_UOM_Master_UOM_Id". The conflict occurred in database "KPMES_Prod", table "dbo.UOM_Master", column ''UOM_Id''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-04-19T17:08:27.160' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (13, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_IOM_UOM_Master_UOM_Id". The conflict occurred in database "KPMES_Prod", table "dbo.UOM_Master", column ''UOM_Id''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-04-19T17:10:28.830' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (14, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_IOM_UOM_Master_UOM_Id". The conflict occurred in database "KPMES_Prod", table "dbo.UOM_Master", column ''UOM_Id''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-04-19T17:11:04.223' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (15, N'547', N'sp_CPS_Delete_BillOfQuantity', N'The DELETE statement conflicted with the REFERENCE constraint "FK_RfqDetail_RfqMaster_PowId". The conflict occurred in database "KPMES_Prod", table "dbo.RfqPowDetail", column ''PowId''.', N'7', N'Bill of Quantity', N'sp_CPS_Delete_BillOfQuantity', CAST(N'2018-05-08T11:06:42.860' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (16, N'547', N'sp_CPS_Delete_BillOfQuantity', N'The DELETE statement conflicted with the REFERENCE constraint "FK_RfqDetail_RfqMaster_PowId". The conflict occurred in database "KPMES_Prod", table "dbo.RfqPowDetail", column ''PowId''.', N'7', N'Bill of Quantity', N'sp_CPS_Delete_BillOfQuantity', CAST(N'2018-05-08T11:06:51.397' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (17, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:36:48.703' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (18, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:36:54.393' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (19, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:37:04.790' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (20, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:38:10.587' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (21, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:38:51.203' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (22, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:38:51.830' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (23, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:38:52.020' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (24, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:40:15.573' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (25, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:45:20.480' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (26, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:47:37.360' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (27, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:48:18.810' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (28, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:50:32.627' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (29, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:54:58.880' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (30, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T15:57:29.193' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (31, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T16:04:45.490' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (32, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T16:05:10.790' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (33, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T16:13:59.203' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (34, N'13609', NULL, N'JSON text is not properly formatted. Unexpected character ''"'' is found at position 0.', N'1', N'Item Of Machinery(IOM)', N'Check Combination Exist', CAST(N'2018-05-08T16:14:15.100' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (35, N'547', N'TEMP_spDeleteRFQTemplate', N'The DELETE statement conflicted with the REFERENCE constraint "fk_rfqGenerateTemplate_RfqTemplate_RfQTempId". The conflict occurred in database "KPMES_Prod", table "dbo.tRfQGenerateTemplate", column ''RfqTempId''.', N'12', N'RFQTemplate', N'TEMP_spDeleteRFQTemplate', CAST(N'2018-05-09T10:42:35.603' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (36, N'547', N'TEMP_spDeleteRFQTemplate', N'The DELETE statement conflicted with the REFERENCE constraint "fk_rfqGenerateTemplate_RfqTemplate_RfQTempId". The conflict occurred in database "KPMES_Prod", table "dbo.tRfQGenerateTemplate", column ''RfqTempId''.', N'12', N'RFQTemplate', N'TEMP_spDeleteRFQTemplate', CAST(N'2018-05-09T10:42:49.370' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (37, N'547', N'TEMP_spDeleteRFQTemplate', N'The DELETE statement conflicted with the REFERENCE constraint "fk_rfqGenerateTemplate_RfqTemplate_RfQTempId". The conflict occurred in database "KPMES_Prod", table "dbo.tRfQGenerateTemplate", column ''RfqTempId''.', N'12', N'RFQTemplate', N'TEMP_spDeleteRFQTemplate', CAST(N'2018-05-10T13:42:10.450' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (38, N'547', N'sp_CPS_Delete_BillOfQuantity', N'The DELETE statement conflicted with the REFERENCE constraint "FK_RfqDetail_RfqMaster_PowId". The conflict occurred in database "KPMES_Prod", table "dbo.RfqPowDetail", column ''PowId''.', N'7', N'Bill of Quantity', N'sp_CPS_Delete_BillOfQuantity', CAST(N'2018-05-11T16:41:49.320' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (39, N'547', N'sp_CPS_Delete_BillOfQuantity', N'The DELETE statement conflicted with the REFERENCE constraint "FK_RfqDetail_RfqMaster_PowId". The conflict occurred in database "KPMES_Prod", table "dbo.RfqPowDetail", column ''PowId''.', N'7', N'Bill of Quantity', N'sp_CPS_Delete_BillOfQuantity', CAST(N'2018-05-11T16:41:55.753' AS DateTime), NULL)
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (40, N'245', N'RPT_sWorkOrderReport', N'Conversion failed when converting the varchar value ''22,23,24,25,28,29,38,41,43,44,45,42'' to data type int.', N'45', N'RFQ Report', N'Insert new IOM', CAST(N'2018-05-22T15:21:50.613' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (41, N'245', N'RPT_sWorkOrderReport', N'Conversion failed when converting the varchar value ''56,58,59,60'' to data type int.', N'45', N'RFQ Report', N'Insert new IOM', CAST(N'2018-05-22T15:22:07.493' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (42, N'245', N'RPT_sWorkOrderReport', N'Conversion failed when converting the varchar value ''56,58,59,60'' to data type int.', N'45', N'RFQ Report', N'Insert new IOM', CAST(N'2018-05-22T15:47:23.783' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (43, N'245', N'RPT_sWorkOrderReport', N'Conversion failed when converting the varchar value ''22,23'' to data type int.', N'45', N'RFQ Report', N'Insert new IOM', CAST(N'2018-05-22T15:47:56.897' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (59, N'547', N'sp_Insert_ProjectSequence', N'The INSERT statement conflicted with the FOREIGN KEY constraint "fk_ProjectSequence_CA_Type_TypeId". The conflict occurred in database "KPMES_Prod", table "dbo.CA_Type", column ''TypeId''.', N'18', N'Project Sequence', N'Insert Successfully', CAST(N'2018-06-04T16:36:17.213' AS DateTime), N'1019')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (60, N'547', N'sp_Insert_ProjectSequence', N'The INSERT statement conflicted with the FOREIGN KEY constraint "fk_ProjectSequence_CA_Type_TypeId". The conflict occurred in database "KPMES_Prod", table "dbo.CA_Type", column ''TypeId''.', N'18', N'Project Sequence', N'Insert Successfully', CAST(N'2018-06-04T16:37:45.937' AS DateTime), N'1019')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (61, N'547', N'sp_GEN_ModifyIOM', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'16', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-06-15T15:32:27.710' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (62, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-21T10:00:52.540' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (63, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-21T10:08:33.220' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (64, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-21T10:27:34.927' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (65, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-21T10:37:07.257' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (66, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-21T10:59:24.327' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (67, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-21T10:59:54.307' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (68, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Prod", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-21T11:16:13.250' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (69, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-22T11:29:24.677' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (70, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-22T11:33:21.623' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (71, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-22T11:35:24.720' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (72, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-22T13:22:45.477' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (73, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-22T14:04:26.003' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (74, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "KPMES_Test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-22T14:06:47.370' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (75, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-27T17:45:06.557' AS DateTime), N'1019')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (76, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-06-27T17:46:38.383' AS DateTime), N'1019')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (77, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-07-02T10:54:13.983' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (78, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-07-02T13:07:39.883' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (79, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-07-02T13:10:24.573' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (80, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-07-02T13:29:08.063' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (81, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-07-02T13:55:43.377' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (82, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (13, 24, 1754, 8, 1044).', N'39', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-02T14:58:40.347' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (83, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (13, 24, 1754, 8, 1044).', N'39', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-02T14:59:22.140' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (84, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-07-02T15:11:55.303' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (93, N'547', N'sp_GEN_InsertNewIOM', N'The INSERT statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'23', N'Item Of Material(IOM)', N'Insert new IOM', CAST(N'2018-07-02T15:54:45.500' AS DateTime), N'1004')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (94, N'547', N'sp_GEN_ModifyIOM', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'16', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-07-03T10:39:40.743' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (95, N'547', N'sp_GEN_ModifyIOM', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOM_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'16', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-07-03T10:40:25.483' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (96, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (31, <NULL>, 3303, 174, 1052).', N'23', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-04T15:03:34.953' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (97, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (35, 69, 5627, <NULL>, <NULL>).', N'23', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-04T17:47:08.297' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (98, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (35, 69, 5627, <NULL>, <NULL>).', N'23', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-04T17:48:37.390' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (99, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (35, 69, 5627, <NULL>, <NULL>).', N'23', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-04T17:49:23.477' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (100, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (38, 71, 0, 404, 1460).', N'32', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-09T13:57:30.720' AS DateTime), N'1021')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (101, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (31, 61, 3303, 151, 1331).', N'32', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-09T15:14:02.110' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (102, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (31, 61, 3303, 151, 1331).', N'32', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-09T15:14:59.120' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (103, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (31, 61, 3298, 221, 1130).', N'112', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-17T19:23:20.640' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (104, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (31, 61, 3303, 223, 1348).', N'112', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-18T12:17:30.853' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (106, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (32, 62, 4016, 1, 1235).', N'112', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-23T13:06:30.660' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (107, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (32, 62, 4015, 1, 1235).', N'112', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-23T15:19:30.470' AS DateTime), N'1019')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (108, N'2627', N'PRJ_spWorkAllocation', N'Violation of UNIQUE KEY constraint ''ucCodes''. Cannot insert duplicate key in object ''dbo.PRJ_tWorkAllocation''. The duplicate key value is (32, 62, 4015, 1, 1235).', N'112', N'Add new Work Allocation', N'PRJ_spWorkAllocation', CAST(N'2018-07-23T15:24:30.260' AS DateTime), N'1019')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (109, N'245', N'GEN_subRemoveDrawingType', N'Conversion failed when converting the varchar value '' DrawingType Removed '' to data type int.', N'13', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-08-03T12:17:25.530' AS DateTime), N'1')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (110, N'245', N'GEN_subRemoveDrawingType', N'Conversion failed when converting the varchar value '' DrawingType Removed '' to data type int.', N'13', N'Drawing Master', N'AddDrawingType ', CAST(N'2018-08-10T16:51:30.053' AS DateTime), N'1')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (111, N'8152', N'RPT_sWorkOrderReport', N'String or binary data would be truncated.', N'14', N'RFQ Report', N'Insert new IOM', CAST(N'2018-08-13T17:27:39.120' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (112, N'8152', N'RPT_sWorkOrderReport', N'String or binary data would be truncated.', N'14', N'RFQ Report', N'Insert new IOM', CAST(N'2018-08-13T18:14:54.547' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (113, N'8152', N'RPT_sWorkOrderReport', N'String or binary data would be truncated.', N'14', N'RFQ Report', N'Insert new IOM', CAST(N'2018-08-13T18:18:55.580' AS DateTime), N'1005')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (114, N'8152', N'RPT_sWorkOrderReport', N'String or binary data would be truncated.', N'14', N'RFQ Report', N'Insert new IOM', CAST(N'2018-08-13T18:26:34.310' AS DateTime), N'1117')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (115, N'8152', N'RPT_sWorkOrderReport', N'String or binary data would be truncated.', N'14', N'RFQ Report', N'Insert new IOM', CAST(N'2018-08-13T18:28:58.807' AS DateTime), N'1117')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (117, N'8152', N'sp_Get_FinalProjectSchedule', N'String or binary data would be truncated.', N'46', N'Final planning', N'', CAST(N'2018-08-16T18:43:07.277' AS DateTime), N'1117')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (118, N'547', N'sp_GEN_ModifyIOCA', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOCA_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'15', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-08-17T18:57:02.787' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (119, N'547', N'sp_GEN_ModifyIOCA', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOCA_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'15', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-08-17T19:04:27.517' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (120, N'547', N'sp_GEN_ModifyIOCA', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOCA_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'15', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-08-17T19:05:41.913' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (121, N'547', N'sp_GEN_ModifyIOCA', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOCA_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'15', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-08-17T19:06:54.327' AS DateTime), N'1002')
INSERT [dbo].[ErrorLog] ([ErrorId], [ErrorCode], [Description], [Message], [ErrorLine], [ScreenName], [ActionName], [Date], [ActionBy]) VALUES (122, N'547', N'sp_GEN_ModifyIOCA', N'The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_UnitsMaster_IOCA_UnitId". The conflict occurred in database "kpmes_test", table "dbo.UnitsMaster", column ''UnitId''.', N'15', N'Item Of Material(IOM)', N'Check Combination Exist', CAST(N'2018-08-17T19:10:31.873' AS DateTime), N'1002')
SET IDENTITY_INSERT [dbo].[ErrorLog] OFF
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, NULL, 1)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, NULL, 5)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, NULL, 12)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, NULL, 1)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, 3, 36)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, 4, 163)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, 2, 100)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, 1, 93)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (2, 3, 350)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (NULL, NULL, 1)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (NULL, NULL, 1)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (NULL, NULL, 1)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (NULL, NULL, 1)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (1, 5, 267)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (NULL, 5, 70)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (2, 1, 111)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (2, 4, 305)
INSERT [dbo].[INV_tInventoryMaster] ([ProductNameId], [ProductSizeId], [Quantity]) VALUES (2, 2, 25)
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (2, N'Administrator', N'', N'fa fa-sitemap', 2, 0, 1, 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (3, N'Organization', N'', NULL, 6, 2, 1, 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (4, N'Role Library', NULL, NULL, 3, 2, 1, 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (5, N'User Menu Privilege', N'userMenuMapping', NULL, 204, 4, 1, 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (6, N'Creating of Role', N'role', NULL, 202, 4, 1, 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.467' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (7, N'Role Menu Privilege', N'roleMenuMapping', NULL, 203, 4, 1, 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (8, N'Location', NULL, NULL, 4, 2, 1, 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (9, N'Country', N'country', NULL, 401, 8, 1, 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (10, N'State', N'state', NULL, 402, 8, 1, 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (11, N'City', N'city', NULL, 403, 8, 1, 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (12, N'Area', N'area', NULL, 404, 8, 1, 0, CAST(N'2017-05-18T16:08:19.470' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (13, N'Human Resource', NULL, N'fa fa-users', 5, 0, 1, 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (14, N'Company Initiation', N'company', NULL, 401, 3, 1, 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (15, N'Department', N'department', NULL, 402, 13, 1, 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (16, N'Designation', N'designation', NULL, 403, 13, 1, 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), 0, CAST(N'2017-05-18T16:08:19.473' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (31, N'Employee', N'employee', NULL, 404, 13, 1, NULL, CAST(N'2017-05-25T13:14:25.060' AS DateTime), NULL, CAST(N'2017-05-25T13:14:25.060' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (47, N'Creating User Account', N'createUser', N'', 7, 2, 1, 0, CAST(N'2017-05-31T12:29:57.347' AS DateTime), 0, CAST(N'2017-05-31T12:29:57.347' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (48, N'Organization Level', N'organization', N'', 402, 3, 1, 0, CAST(N'2017-06-01T16:44:47.887' AS DateTime), 0, CAST(N'2017-06-01T16:44:47.887' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (49, N'Organization Level Chart', N'organizationLevelChart', N'', 403, 3, 1, 0, CAST(N'2017-06-01T16:42:37.323' AS DateTime), 0, CAST(N'2017-06-01T16:42:37.323' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (50, N'Organization Chart', N'employeeChart', N'', 405, 13, 1, 0, CAST(N'2017-06-07T10:14:09.047' AS DateTime), 0, CAST(N'2017-06-07T10:14:09.047' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (51, N'Purchase Order', N'', N'', 406, 0, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (52, N'Purchase Details', N'PurchaseDetails', N'', 407, 51, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (53, N'Purchase Return', N'PurchaseReturn', N'', 408, 51, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (54, N'Sales Order', N'', N'', 409, 0, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (55, N'Sales Details', N'SalesDetails', N'', 410, 54, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (56, N'Sales Return', N'SalesReturn', N'', 411, 54, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (57, N'Inventory', N'', N'', 412, 0, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (58, N'Inventory List', N'InventoryList', N'', 413, 57, 1, 0, CAST(N'2018-10-29T13:38:11.790' AS DateTime), 0, CAST(N'2018-10-29T13:38:11.790' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (59, N'Debtors', N'', N'', 414, 0, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (60, N'Debtors List', N'DebtorsList', N'', 415, 59, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (61, N'Report', N'', N'', 416, 0, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
INSERT [dbo].[Menu] ([MenuId], [MenuName], [MenuUrl], [MenuIcon], [MenuOrder], [ParentMenu], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [ProcessPrivilege]) VALUES (62, N'Periodic Reports', N'periodicreports', N'', 417, 61, 1, 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), 0, CAST(N'2018-10-29T00:00:00.000' AS DateTime), N'NA')
SET IDENTITY_INSERT [dbo].[NatureOfBusiness] ON 

INSERT [dbo].[NatureOfBusiness] ([BusinessId], [BusinessName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1, N'Manufacturing', 1, 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime), 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime))
INSERT [dbo].[NatureOfBusiness] ([BusinessId], [BusinessName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (2, N'Trading', 1, 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime), 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime))
INSERT [dbo].[NatureOfBusiness] ([BusinessId], [BusinessName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (3, N'Professional', 1, 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime), 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime))
INSERT [dbo].[NatureOfBusiness] ([BusinessId], [BusinessName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (4, N'Builder', 1, 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime), 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime))
INSERT [dbo].[NatureOfBusiness] ([BusinessId], [BusinessName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (5, N'Service Sector', 1, 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime), 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime))
INSERT [dbo].[NatureOfBusiness] ([BusinessId], [BusinessName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (6, N'Contractor', 1, 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime), 1, CAST(N'2017-06-03T11:36:06.333' AS DateTime))
SET IDENTITY_INSERT [dbo].[NatureOfBusiness] OFF
SET IDENTITY_INSERT [dbo].[OrganizationLevel] ON 

INSERT [dbo].[OrganizationLevel] ([OrgLvlId], [LevelName], [Parent], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [Code]) VALUES (1, N'Head Office', 0, 1001, CAST(N'2017-11-13T13:07:29.090' AS DateTime), 1001, CAST(N'2018-08-16T18:31:31.407' AS DateTime), 1, N'HO')
SET IDENTITY_INSERT [dbo].[OrganizationLevel] OFF
SET IDENTITY_INSERT [dbo].[OwnershipTypes] ON 

INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (1, N'Sole Proprietorship Concern', 1, 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime), 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime))
INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (2, N'Partnership Concern', 1, 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime), 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime))
INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (3, N'Private Limited Company', 1, 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime), 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime))
INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (4, N'Public Limited Company', 1, 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime), 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime))
INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (5, N'LLP', 1, 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime), 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime))
INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (6, N'One Person Company', 1, 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime), 1, CAST(N'2017-06-03T11:34:53.553' AS DateTime))
INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (7, N'State GovernMent', 1, 1, CAST(N'2017-06-07T15:05:47.717' AS DateTime), 1, CAST(N'2017-06-07T15:05:47.717' AS DateTime))
INSERT [dbo].[OwnershipTypes] ([TypeId], [OwnershipName], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (8, N'Central GovernMent', 1, 1, CAST(N'2017-06-07T15:05:47.720' AS DateTime), 1, CAST(N'2017-06-07T15:05:47.720' AS DateTime))
SET IDENTITY_INSERT [dbo].[OwnershipTypes] OFF
SET IDENTITY_INSERT [dbo].[PRO_tProductNameMaster] ON 

INSERT [dbo].[PRO_tProductNameMaster] ([ProductNameId], [ProductName], [HSN_Code]) VALUES (1, N'Pant', N'CT21')
INSERT [dbo].[PRO_tProductNameMaster] ([ProductNameId], [ProductName], [HSN_Code]) VALUES (2, N'Shirt', N'ST123')
SET IDENTITY_INSERT [dbo].[PRO_tProductNameMaster] OFF
SET IDENTITY_INSERT [dbo].[PRO_tProductSizeMaster] ON 

INSERT [dbo].[PRO_tProductSizeMaster] ([ProductSizeId], [ProductSize]) VALUES (1, N'S')
INSERT [dbo].[PRO_tProductSizeMaster] ([ProductSizeId], [ProductSize]) VALUES (2, N'M')
INSERT [dbo].[PRO_tProductSizeMaster] ([ProductSizeId], [ProductSize]) VALUES (3, N'L')
INSERT [dbo].[PRO_tProductSizeMaster] ([ProductSizeId], [ProductSize]) VALUES (4, N'XL')
INSERT [dbo].[PRO_tProductSizeMaster] ([ProductSizeId], [ProductSize]) VALUES (5, N'XXL')
SET IDENTITY_INSERT [dbo].[PRO_tProductSizeMaster] OFF
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (1, 1, N'CT21', 3, 12, CAST(900.00000 AS Decimal(15, 5)), CAST(10800.00000 AS Decimal(15, 5)), N'5', CAST(11340.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (1, 1, N'CT21', 3, 12, CAST(900.00000 AS Decimal(15, 5)), CAST(10800.00000 AS Decimal(15, 5)), N'5', CAST(11340.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (1, 1, N'CT21', 3, 12, CAST(900.00000 AS Decimal(15, 5)), CAST(10800.00000 AS Decimal(15, 5)), N'5', CAST(11340.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (4, 1, N'CT21', 2, 6, CAST(1234.00000 AS Decimal(15, 5)), CAST(7404.00000 AS Decimal(15, 5)), N'5', CAST(7774.20000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (67688, 1, N'CT21', 2, 3, CAST(545.00000 AS Decimal(15, 5)), CAST(1635.00000 AS Decimal(15, 5)), N'3', CAST(1684.05000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (189, 1, N'CT21', 2, 15, CAST(2.00000 AS Decimal(15, 5)), CAST(30.00000 AS Decimal(15, 5)), N'10', CAST(33.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (189, 2, N'ST123', 1, 30, CAST(2.00000 AS Decimal(15, 5)), CAST(60.00000 AS Decimal(15, 5)), N'10', CAST(66.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (150, 1, N'CT21', 3, 15, CAST(2.00000 AS Decimal(15, 5)), CAST(30.00000 AS Decimal(15, 5)), N'5', CAST(31.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (150, 2, N'ST123', 4, 15, CAST(2.00000 AS Decimal(15, 5)), CAST(30.00000 AS Decimal(15, 5)), N'10', CAST(33.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (151, 1, N'CT21', 3, 10, CAST(5.00000 AS Decimal(15, 5)), CAST(50.00000 AS Decimal(15, 5)), N'5', CAST(52.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (151, 2, N'ST123', 2, 15, CAST(5.00000 AS Decimal(15, 5)), CAST(75.00000 AS Decimal(15, 5)), N'5', CAST(78.75000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (155, 1, N'CT21', 1, 10, CAST(3.00000 AS Decimal(15, 5)), CAST(30.00000 AS Decimal(15, 5)), N'4', CAST(31.20000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (770, 2, N'ST123', 1, 75, CAST(799.00000 AS Decimal(15, 5)), CAST(59925.00000 AS Decimal(15, 5)), N'5', CAST(62921.25000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (770, 1, N'CT21', 1, 85, CAST(788.00000 AS Decimal(15, 5)), CAST(66980.00000 AS Decimal(15, 5)), N'5', CAST(70329.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 1, N'CT21', 2, 100, CAST(1000.00000 AS Decimal(15, 5)), CAST(100000.00000 AS Decimal(15, 5)), N'5', CAST(105000.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 2, N'ST123', 2, 10, CAST(1000.00000 AS Decimal(15, 5)), CAST(10000.00000 AS Decimal(15, 5)), N'5', CAST(10500.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 1, N'CT21', 3, 35, CAST(999.00000 AS Decimal(15, 5)), CAST(34965.00000 AS Decimal(15, 5)), N'5', CAST(36713.25000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 1, N'CT21', 4, 15, CAST(1267.00000 AS Decimal(15, 5)), CAST(19005.00000 AS Decimal(15, 5)), N'10', CAST(20905.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 1, N'CT21', 4, 90, CAST(788.00000 AS Decimal(15, 5)), CAST(70920.00000 AS Decimal(15, 5)), N'3', CAST(73047.60000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 1, N'CT21', 5, 100, CAST(1780.00000 AS Decimal(15, 5)), CAST(178000.00000 AS Decimal(15, 5)), N'8', CAST(192240.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 2, N'ST123', 4, 90, CAST(455.00000 AS Decimal(15, 5)), CAST(40950.00000 AS Decimal(15, 5)), N'5', CAST(42997.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 2, N'ST123', 3, 150, CAST(575.00000 AS Decimal(15, 5)), CAST(86250.00000 AS Decimal(15, 5)), N'5', CAST(90562.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 2, N'ST123', 1, 50, CAST(454.00000 AS Decimal(15, 5)), CAST(22700.00000 AS Decimal(15, 5)), N'5', CAST(23835.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (333, 1, N'CT21', 5, 10, CAST(799.00000 AS Decimal(15, 5)), CAST(7990.00000 AS Decimal(15, 5)), N'5', CAST(8389.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (8888, 1, N'CT21', 1, 5, CAST(588.00000 AS Decimal(15, 5)), CAST(2940.00000 AS Decimal(15, 5)), N'6', CAST(3116.40000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (8978, 2, N'ST123', 1, 60, CAST(700.00000 AS Decimal(15, 5)), CAST(42000.00000 AS Decimal(15, 5)), N'5', CAST(44100.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (4516, 1, N'CT21', 1, 5, CAST(566.00000 AS Decimal(15, 5)), CAST(2830.00000 AS Decimal(15, 5)), N'5', CAST(2971.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (78, 1, N'CT21', 1, 50, CAST(600.00000 AS Decimal(15, 5)), CAST(30000.00000 AS Decimal(15, 5)), N'5', CAST(31500.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (78, 1, N'CT21', 4, 58, CAST(800.00000 AS Decimal(15, 5)), CAST(46400.00000 AS Decimal(15, 5)), N'5', CAST(48720.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseDetails] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (4568, 2, N'ST123', 4, 200, CAST(966.00000 AS Decimal(15, 5)), CAST(193200.00000 AS Decimal(15, 5)), N'5', CAST(202860.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (1, CAST(N'2018-10-03T18:30:00.000' AS DateTime), 1, CAST(2016.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (4, CAST(N'2018-10-06T18:30:00.000' AS DateTime), 2, CAST(7774.20000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (12, CAST(N'2018-10-01T18:30:00.000' AS DateTime), 1, CAST(838.95000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (45, CAST(N'2018-10-31T18:30:00.000' AS DateTime), 2, CAST(13912.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (56, CAST(N'2018-10-01T18:30:00.000' AS DateTime), 1, CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (78, CAST(N'2018-11-12T18:30:00.000' AS DateTime), 1, CAST(80220.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (90, CAST(N'2018-11-07T18:30:00.000' AS DateTime), 1, CAST(315000.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (150, CAST(N'2018-11-01T18:30:00.000' AS DateTime), 2, CAST(64.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (151, CAST(N'2018-11-01T18:30:00.000' AS DateTime), 1, CAST(131.25000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (155, CAST(N'2018-10-31T18:30:00.000' AS DateTime), 1, CAST(31.20000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (189, CAST(N'2018-10-31T18:30:00.000' AS DateTime), 1, CAST(99.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (234, CAST(N'2018-10-01T18:30:00.000' AS DateTime), 2, CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (333, CAST(N'2018-11-11T18:30:00.000' AS DateTime), 2, CAST(604190.85000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (345, CAST(N'2018-10-09T18:30:00.000' AS DateTime), 1, CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (445, CAST(N'2018-10-02T18:30:00.000' AS DateTime), 2, CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (456, CAST(N'2018-10-09T18:30:00.000' AS DateTime), 2, CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (678, CAST(N'2018-11-20T18:30:00.000' AS DateTime), 1, CAST(133360.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (770, CAST(N'2018-11-07T18:30:00.000' AS DateTime), 3, CAST(166635.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (1890, CAST(N'2018-11-20T18:30:00.000' AS DateTime), 1, CAST(144574.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (4516, CAST(N'2018-11-12T18:30:00.000' AS DateTime), 2, CAST(2971.50000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (4568, CAST(N'2018-11-05T18:30:00.000' AS DateTime), 2, CAST(202860.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (8888, CAST(N'2018-11-12T18:30:00.000' AS DateTime), 1, CAST(3116.40000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (8978, CAST(N'2018-11-04T18:30:00.000' AS DateTime), 3, CAST(44100.00000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (67688, CAST(N'2018-11-12T18:30:00.000' AS DateTime), 1, CAST(17177.85000 AS Decimal(15, 5)))
INSERT [dbo].[PUR_tPurchaseMaster] ([BillNo], [BillDate], [VendorId], [GrandTotal]) VALUES (14564576, CAST(N'2018-10-03T18:30:00.000' AS DateTime), 1, CAST(345276.75000 AS Decimal(15, 5)))
SET IDENTITY_INSERT [dbo].[RoleMaster] ON 

INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [OrgLvlId], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive]) VALUES (1, N'Super Admin', 1, 1001, CAST(N'2017-11-13T13:07:29.090' AS DateTime), 1001, CAST(N'2017-11-13T13:07:29.090' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[RoleMaster] OFF
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (0, 2, N'ST123', 3, 5, CAST(500.00000 AS Decimal(15, 5)), CAST(2500.00000 AS Decimal(15, 5)), N'5', CAST(2625.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (14, 1, N'CT21', 3, 50, CAST(500.00000 AS Decimal(15, 5)), CAST(25000.00000 AS Decimal(15, 5)), N'1', CAST(25250.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (16, 1, N'CT21', 5, 100, CAST(400.00000 AS Decimal(15, 5)), CAST(40000.00000 AS Decimal(15, 5)), N'5', CAST(42000.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (23, 1, N'CT21', 3, 40, CAST(44234.00000 AS Decimal(15, 5)), CAST(1769360.00000 AS Decimal(15, 5)), N'33', CAST(1244744.76000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (25, 1, N'CT21', 3, 5, CAST(424.00000 AS Decimal(15, 5)), CAST(2120.00000 AS Decimal(15, 5)), N'3432', CAST(-74170.32000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (26, 1, N'CT21', 1, 90, CAST(999.00000 AS Decimal(15, 5)), CAST(89910.00000 AS Decimal(15, 5)), N'10', CAST(98901.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (26, 2, N'ST123', 1, 95, CAST(999.00000 AS Decimal(15, 5)), CAST(94905.00000 AS Decimal(15, 5)), N'10', CAST(104395.50000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (27, 1, N'CT21', 1, 1, CAST(100.00000 AS Decimal(15, 5)), CAST(100.00000 AS Decimal(15, 5)), N'2', CAST(102.90000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (27, 2, N'ST123', 1, 1, CAST(1500.00000 AS Decimal(15, 5)), CAST(1500.00000 AS Decimal(15, 5)), N'0', CAST(1575.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (28, 1, N'CT21', 4, 2, CAST(434.00000 AS Decimal(15, 5)), CAST(1302.00000 AS Decimal(15, 5)), N'23', CAST(1052.66700 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (29, 1, N'CT21', 1, 1, CAST(1000.00000 AS Decimal(15, 5)), CAST(1000.00000 AS Decimal(15, 5)), N'2', CAST(1029.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (29, 2, N'ST123', 1, 1, CAST(1500.00000 AS Decimal(15, 5)), CAST(1500.00000 AS Decimal(15, 5)), N'0', CAST(1575.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (30, 1, N'CT21', 1, 1, CAST(1000.00000 AS Decimal(15, 5)), CAST(1000.00000 AS Decimal(15, 5)), N'2', CAST(1029.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (30, 2, N'ST123', 1, 1, CAST(1500.00000 AS Decimal(15, 5)), CAST(1500.00000 AS Decimal(15, 5)), N'0', CAST(1575.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (31, 1, N'CT21', 3, 4, CAST(79.00000 AS Decimal(15, 5)), CAST(316.00000 AS Decimal(15, 5)), N'8', CAST(341.28000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (32, 1, N'CT21', 1, 5, CAST(1000.00000 AS Decimal(15, 5)), CAST(5000.00000 AS Decimal(15, 5)), N'10', CAST(4725.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (33, 1, N'CT21', 5, 4, CAST(1000.00000 AS Decimal(15, 5)), CAST(4000.00000 AS Decimal(15, 5)), N'5', CAST(4200.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (34, 1, N'CT21', 1, 100, CAST(500.00000 AS Decimal(15, 5)), CAST(50000.00000 AS Decimal(15, 5)), N'5', CAST(47500.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (34, 1, N'CT21', 3, 10, CAST(100.00000 AS Decimal(15, 5)), CAST(1000.00000 AS Decimal(15, 5)), N'0', CAST(1050.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (18, 1, N'CT21', 2, 44, CAST(1800.00000 AS Decimal(15, 5)), CAST(79200.00000 AS Decimal(15, 5)), N'2', CAST(80784.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesDetailsPaid] ([BillNo], [ProductNameId], [HSN_Code], [ProductSizeId], [Quantity], [Rate], [Amount], [Tax], [TotalAmount]) VALUES (22, 1, N'CT21', 2, 20, CAST(600.00000 AS Decimal(15, 5)), CAST(12000.00000 AS Decimal(15, 5)), N'5', CAST(11970.00000 AS Decimal(15, 5)))
SET IDENTITY_INSERT [dbo].[SAL_tSalesMaster] ON 

INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (1, CAST(N'2018-10-15T18:30:00.000' AS DateTime), N'44', 1, CAST(713.92000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (2, CAST(N'2018-10-22T18:30:00.000' AS DateTime), N'34', 1, CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (3, CAST(N'2018-10-03T18:30:00.000' AS DateTime), N'5654', 1, CAST(2120.40000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (4, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'GD321', 1, CAST(2375.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (5, CAST(N'2018-11-05T18:30:00.000' AS DateTime), N'44', 1, CAST(1615.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (6, CAST(N'2018-11-06T18:30:00.000' AS DateTime), N'fd', 1, CAST(227.04000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (7, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'44', 1, CAST(549.10000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (8, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'5654', 1, CAST(12201.30000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (9, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'n67', 1, CAST(2483.64000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (10, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'n67', 1, CAST(2483.64000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (11, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'n67', 1, CAST(2483.64000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (12, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'n67', 1, CAST(2483.64000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (13, CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'n67', 1, CAST(2483.64000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (15, CAST(N'2018-11-07T18:30:00.000' AS DateTime), N'5654', 1, CAST(31590.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (17, CAST(N'2018-11-05T18:30:00.000' AS DateTime), N'456', 1, CAST(38403.52000 AS Decimal(15, 5)), CAST(38403.52000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (19, CAST(N'2018-11-05T18:30:00.000' AS DateTime), N'656', 1, CAST(79318.80000 AS Decimal(15, 5)), CAST(79318.80000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (21, CAST(N'2018-11-14T18:30:00.000' AS DateTime), N'852', 1, CAST(99.00000 AS Decimal(15, 5)), CAST(99.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (22, CAST(N'2018-11-14T18:30:00.000' AS DateTime), N'fd', 1, CAST(64600.00000 AS Decimal(15, 5)), CAST(64600.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (24, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'fsfs', 1, CAST(1185471.20000 AS Decimal(15, 5)), CAST(1185471.20000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (25, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'24324234', 1, CAST(-70638.40000 AS Decimal(15, 5)), CAST(-70638.40000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (26, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'5678', 1, CAST(179820.00000 AS Decimal(15, 5)), CAST(179820.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (27, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'DP12', 1, CAST(1598.00000 AS Decimal(15, 5)), CAST(1598.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (28, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'3', 1, CAST(1002.54000 AS Decimal(15, 5)), CAST(104.67000 AS Decimal(15, 5)), CAST(897.87000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (29, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'DP12', 1, CAST(2604.00000 AS Decimal(15, 5)), CAST(2480.00000 AS Decimal(15, 5)), CAST(0.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (30, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'DP12', 1, CAST(2604.00000 AS Decimal(15, 5)), CAST(2404.00000 AS Decimal(15, 5)), CAST(200.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (31, CAST(N'2018-11-02T00:00:00.000' AS DateTime), N'sdkfhlew', 1, CAST(381.57000 AS Decimal(15, 5)), CAST(181.57000 AS Decimal(15, 5)), CAST(200.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (32, CAST(N'2018-11-08T00:00:00.000' AS DateTime), N'534', 1, CAST(4725.00000 AS Decimal(15, 5)), CAST(3300.00000 AS Decimal(15, 5)), CAST(1425.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (33, CAST(N'2018-11-10T00:00:00.000' AS DateTime), N'G12', 2, CAST(9500.00000 AS Decimal(15, 5)), CAST(8500.00000 AS Decimal(15, 5)), CAST(1000.00000 AS Decimal(15, 5)))
INSERT [dbo].[SAL_tSalesMaster] ([BillNo], [BillingDate], [GSTNo], [CustomerId], [GrandTotal], [PaidAmount], [BalanceAmount]) VALUES (34, CAST(N'2018-11-10T00:00:00.000' AS DateTime), N'45', 2, CAST(48550.00000 AS Decimal(15, 5)), CAST(41550.00000 AS Decimal(15, 5)), CAST(7000.00000 AS Decimal(15, 5)))
SET IDENTITY_INSERT [dbo].[SAL_tSalesMaster] OFF
SET IDENTITY_INSERT [dbo].[StateMaster] ON 

INSERT [dbo].[StateMaster] ([StateId], [CountryId], [StateName], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive]) VALUES (1, 1, N'Tamilnadu', 1001, CAST(N'2017-11-13T13:07:29.090' AS DateTime), 1001, CAST(N'2017-11-13T13:07:29.090' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[StateMaster] OFF
SET IDENTITY_INSERT [dbo].[Token] ON 

INSERT [dbo].[Token] ([TokenId], [UserId], [AuthToken], [IssuedOn], [ExpiresOn], [IsActive], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn]) VALUES (416, 1004, N'e281839a-87d4-4440-901a-5c7083c234d6', CAST(N'2018-11-14T16:49:54.863' AS DateTime), CAST(N'2018-11-14T17:04:54.863' AS DateTime), NULL, NULL, CAST(N'2018-11-14T16:49:55.443' AS DateTime), NULL, CAST(N'2018-11-14T16:49:55.443' AS DateTime))
SET IDENTITY_INSERT [dbo].[Token] OFF
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (9, N'bus', N'4234', CAST(N'2018-11-07T18:30:00.000' AS DateTime), N'sfsdf')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (14, N'bus', N'fd56', CAST(N'2018-11-25T18:30:00.000' AS DateTime), N'sfsdf')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (16, N'bus', N'1234', CAST(N'2018-11-26T18:30:00.000' AS DateTime), N'gfg')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (20, N'bus', N'rftg', CAST(N'2018-11-19T18:30:00.000' AS DateTime), N'xcv')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (23, N'xved', N'4364356', CAST(N'2018-11-20T18:30:00.000' AS DateTime), N'advd')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (25, N'2414', N'424', CAST(N'2018-11-19T18:30:00.000' AS DateTime), N'21412')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (26, N'bus', N'Tn4567', CAST(N'2018-10-31T18:30:00.000' AS DateTime), N'CHN')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (27, N'bus', N'4234', CAST(N'2018-11-01T18:30:00.000' AS DateTime), N'sfsdf')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (28, N'rer', N'df', CAST(N'2018-11-25T18:30:00.000' AS DateTime), N'fddf')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (29, N'bus', N'4234', CAST(N'2018-11-01T18:30:00.000' AS DateTime), N'sfsdf')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (30, N'bus', N'4234', CAST(N'2018-11-01T18:30:00.000' AS DateTime), N'sfsdf')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (31, N'gbh', N'li876896', CAST(N'2018-11-02T10:27:41.160' AS DateTime), N'jhmgkjg')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (32, N'tert', N'6546', CAST(N'2018-11-27T18:30:00.000' AS DateTime), N'yrtyr')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (33, N'bus', N'g1234', CAST(N'2018-11-09T18:30:00.000' AS DateTime), N'Chn')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (34, N'ghg', N'677', CAST(N'2018-11-13T18:30:00.000' AS DateTime), N'chn')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (18, N'dfg', N'fgd', CAST(N'2018-11-26T18:30:00.000' AS DateTime), N'gdfg')
INSERT [dbo].[TransporationDetails] ([BillNo], [TransporationMode], [VehicleNumber], [DateOfSupply], [PlaceOfSupply]) VALUES (22, N'bike', N'5657', CAST(N'2018-11-25T18:30:00.000' AS DateTime), N'sfsdf')
SET IDENTITY_INSERT [dbo].[UserMaster] ON 

INSERT [dbo].[UserMaster] ([UserId], [FirstName], [LastName], [UserName], [PasswordHash], [PasswordKey], [ResetKey], [EmailId], [RoleId], [CreatedBy], [CreatedOn], [ModifiedBy], [ModifiedOn], [IsActive], [RefId], [UserType], [CompanyId], [SelectedCompany]) VALUES (1004, N'Admin', NULL, N'admin', N'qSpIAk9CG+8jrV2NmL7BO+AZjSjVQD80e57htay5AIc=', N'0Ba6lLGOV17UYH3J0eRvTen34inzQQKO', NULL, N'admin@gmail.com', 1, 1001, CAST(N'2017-11-13T13:24:01.667' AS DateTime), 1001, CAST(N'2017-11-13T13:24:01.667' AS DateTime), 1, NULL, N'EMP', 1, 1)
SET IDENTITY_INSERT [dbo].[UserMaster] OFF
SET IDENTITY_INSERT [dbo].[VEN_tVendorMaster] ON 

INSERT [dbo].[VEN_tVendorMaster] ([VendorId], [GSTNo], [VendorName], [Address], [ContactNo]) VALUES (1, N'DP12', N'Dinesh', N'Chennai', N'1234567890')
INSERT [dbo].[VEN_tVendorMaster] ([VendorId], [GSTNo], [VendorName], [Address], [ContactNo]) VALUES (2, N'1234', N'surya', N'saidapoet', N'8765432190')
INSERT [dbo].[VEN_tVendorMaster] ([VendorId], [GSTNo], [VendorName], [Address], [ContactNo]) VALUES (3, N'12540', N'Mari', N'saidapet', N'9877384637')
SET IDENTITY_INSERT [dbo].[VEN_tVendorMaster] OFF
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Company__11A0134B14D64523]    Script Date: 11/27/2018 7:55:05 PM ******/
ALTER TABLE [dbo].[Company] ADD UNIQUE NONCLUSTERED 
(
	[CompanyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Company__11A0134B5D7C29ED]    Script Date: 11/27/2018 7:55:05 PM ******/
ALTER TABLE [dbo].[Company] ADD UNIQUE NONCLUSTERED 
(
	[CompanyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__UserMast__7ED91ACE63E1C99E]    Script Date: 11/27/2018 7:55:05 PM ******/
ALTER TABLE [dbo].[UserMaster] ADD UNIQUE NONCLUSTERED 
(
	[EmailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__UserMast__7ED91ACEB162429B]    Script Date: 11/27/2018 7:55:05 PM ******/
ALTER TABLE [dbo].[UserMaster] ADD UNIQUE NONCLUSTERED 
(
	[EmailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__UserMast__C9F284560796C5B1]    Script Date: 11/27/2018 7:55:05 PM ******/
ALTER TABLE [dbo].[UserMaster] ADD UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__UserMast__C9F28456AA4369B7]    Script Date: 11/27/2018 7:55:05 PM ******/
ALTER TABLE [dbo].[UserMaster] ADD UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Action] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Action] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Area] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Area] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[City] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[City] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Company] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Company] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Country] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Country] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Department] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Department] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Designation] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Designation] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ((0)) FOR [KpostUCodeStatus]
GO
ALTER TABLE [dbo].[Menu] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Menu] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[OrganizationLevel] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[OrganizationLevel] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[RoleMaster] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[RoleMaster] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[RoleMenuMapping] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[RoleMenuMapping] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[StateMaster] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[StateMaster] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Token] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Token] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[UserMaster] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[UserMaster] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[UserMenuMapping] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[UserMenuMapping] ADD  DEFAULT (getdate()) FOR [ModifiedOn]
GO
ALTER TABLE [dbo].[Action]  WITH CHECK ADD  CONSTRAINT [FK_Action_Menu_MenuId] FOREIGN KEY([MenuId])
REFERENCES [dbo].[Menu] ([MenuId])
GO
ALTER TABLE [dbo].[Action] CHECK CONSTRAINT [FK_Action_Menu_MenuId]
GO
ALTER TABLE [dbo].[Area]  WITH CHECK ADD  CONSTRAINT [FK_Area_City_CityId] FOREIGN KEY([CityId])
REFERENCES [dbo].[City] ([CityId])
GO
ALTER TABLE [dbo].[Area] CHECK CONSTRAINT [FK_Area_City_CityId]
GO
ALTER TABLE [dbo].[Area]  WITH CHECK ADD  CONSTRAINT [FK_Area_Country_CountryId] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([CountryId])
GO
ALTER TABLE [dbo].[Area] CHECK CONSTRAINT [FK_Area_Country_CountryId]
GO
ALTER TABLE [dbo].[Area]  WITH CHECK ADD  CONSTRAINT [FK_Area_State_StateId] FOREIGN KEY([StateId])
REFERENCES [dbo].[StateMaster] ([StateId])
GO
ALTER TABLE [dbo].[Area] CHECK CONSTRAINT [FK_Area_State_StateId]
GO
ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FK_City_Country_CountryId] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([CountryId])
GO
ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FK_City_Country_CountryId]
GO
ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FK_City_State_StateId] FOREIGN KEY([StateId])
REFERENCES [dbo].[StateMaster] ([StateId])
GO
ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FK_City_State_StateId]
GO
ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_Area_AreaId] FOREIGN KEY([AreaId])
REFERENCES [dbo].[Area] ([AreaId])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Area_AreaId]
GO
ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_City_CityId] FOREIGN KEY([CityId])
REFERENCES [dbo].[City] ([CityId])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_City_CityId]
GO
ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_Country_CountryId] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([CountryId])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_Country_CountryId]
GO
ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_NatureOfBusiness_BusinessId] FOREIGN KEY([BusinessId])
REFERENCES [dbo].[NatureOfBusiness] ([BusinessId])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_NatureOfBusiness_BusinessId]
GO
ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_OrgLvl_OrgLvlId] FOREIGN KEY([OrgLvlId])
REFERENCES [dbo].[OrganizationLevel] ([OrgLvlId])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_OrgLvl_OrgLvlId]
GO
ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_OwnershipTypes_TypeId] FOREIGN KEY([TypeId])
REFERENCES [dbo].[OwnershipTypes] ([TypeId])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_OwnershipTypes_TypeId]
GO
ALTER TABLE [dbo].[Company]  WITH CHECK ADD  CONSTRAINT [FK_Company_State_StateId] FOREIGN KEY([StateId])
REFERENCES [dbo].[StateMaster] ([StateId])
GO
ALTER TABLE [dbo].[Company] CHECK CONSTRAINT [FK_Company_State_StateId]
GO
ALTER TABLE [dbo].[Department]  WITH CHECK ADD  CONSTRAINT [FK_Department_Company_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[Department] CHECK CONSTRAINT [FK_Department_Company_CompanyId]
GO
ALTER TABLE [dbo].[Designation]  WITH CHECK ADD  CONSTRAINT [FK_Designation_Company_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[Designation] CHECK CONSTRAINT [FK_Designation_Company_CompanyId]
GO
ALTER TABLE [dbo].[Designation]  WITH CHECK ADD  CONSTRAINT [FK_Designation_Department_DepartmentId] FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Department] ([DepartmentId])
GO
ALTER TABLE [dbo].[Designation] CHECK CONSTRAINT [FK_Designation_Department_DepartmentId]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Company_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Company_CompanyId]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Department_DepartmentId] FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[Department] ([DepartmentId])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Department_DepartmentId]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Designation_DesignationId] FOREIGN KEY([DesignationId])
REFERENCES [dbo].[Designation] ([DesignationId])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Designation_DesignationId]
GO
ALTER TABLE [dbo].[EmployeeAcademy]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeAcademy_Company_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[EmployeeAcademy] CHECK CONSTRAINT [FK_EmployeeAcademy_Company_CompanyId]
GO
ALTER TABLE [dbo].[EmployeeAcademy]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeAcademy_Employee_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeAcademy] CHECK CONSTRAINT [FK_EmployeeAcademy_Employee_EmployeeId]
GO
ALTER TABLE [dbo].[EmployeeAddress]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeAddress_Company_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[EmployeeAddress] CHECK CONSTRAINT [FK_EmployeeAddress_Company_CompanyId]
GO
ALTER TABLE [dbo].[EmployeeAddress]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeAddress_Employee_EmployeeId] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeAddress] CHECK CONSTRAINT [FK_EmployeeAddress_Employee_EmployeeId]
GO
ALTER TABLE [dbo].[EmployeeComponent]  WITH CHECK ADD  CONSTRAINT [EmployeeComponent_Employee_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeComponent] CHECK CONSTRAINT [EmployeeComponent_Employee_EmployeeId]
GO
ALTER TABLE [dbo].[EmployeeExperience]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeExperience_Company_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[EmployeeExperience] CHECK CONSTRAINT [FK_EmployeeExperience_Company_CompanyId]
GO
ALTER TABLE [dbo].[EmployeeExperience]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeExperience_Employee_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeExperience] CHECK CONSTRAINT [FK_EmployeeExperience_Employee_EmployeeId]
GO
ALTER TABLE [dbo].[EmployeeSalary]  WITH CHECK ADD  CONSTRAINT [EmployeeSalary_Employee_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employee] ([EmployeeId])
GO
ALTER TABLE [dbo].[EmployeeSalary] CHECK CONSTRAINT [EmployeeSalary_Employee_EmployeeId]
GO
ALTER TABLE [dbo].[PUR_tPurchaseDetails]  WITH CHECK ADD FOREIGN KEY([BillNo])
REFERENCES [dbo].[PUR_tPurchaseMaster] ([BillNo])
GO
ALTER TABLE [dbo].[PUR_tPurchaseDetails]  WITH CHECK ADD FOREIGN KEY([ProductNameId])
REFERENCES [dbo].[PRO_tProductNameMaster] ([ProductNameId])
GO
ALTER TABLE [dbo].[PUR_tPurchaseDetails]  WITH CHECK ADD FOREIGN KEY([ProductSizeId])
REFERENCES [dbo].[PRO_tProductSizeMaster] ([ProductSizeId])
GO
ALTER TABLE [dbo].[PUR_tPurchaseMaster]  WITH CHECK ADD FOREIGN KEY([VendorId])
REFERENCES [dbo].[VEN_tVendorMaster] ([VendorId])
GO
ALTER TABLE [dbo].[RoleMaster]  WITH CHECK ADD  CONSTRAINT [FK_RoleMaster_OrgLvl_OrgLvlId] FOREIGN KEY([OrgLvlId])
REFERENCES [dbo].[OrganizationLevel] ([OrgLvlId])
GO
ALTER TABLE [dbo].[RoleMaster] CHECK CONSTRAINT [FK_RoleMaster_OrgLvl_OrgLvlId]
GO
ALTER TABLE [dbo].[RoleMenuMapping]  WITH CHECK ADD  CONSTRAINT [FK_RoleMenuMapping_Menu_MenuId] FOREIGN KEY([MenuId])
REFERENCES [dbo].[Menu] ([MenuId])
GO
ALTER TABLE [dbo].[RoleMenuMapping] CHECK CONSTRAINT [FK_RoleMenuMapping_Menu_MenuId]
GO
ALTER TABLE [dbo].[RoleMenuMapping]  WITH CHECK ADD  CONSTRAINT [FK_RoleMenuMapping_RoleMaster_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[RoleMaster] ([RoleId])
GO
ALTER TABLE [dbo].[RoleMenuMapping] CHECK CONSTRAINT [FK_RoleMenuMapping_RoleMaster_RoleId]
GO
ALTER TABLE [dbo].[StateMaster]  WITH CHECK ADD  CONSTRAINT [FK_State_Country_CountryId] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([CountryId])
GO
ALTER TABLE [dbo].[StateMaster] CHECK CONSTRAINT [FK_State_Country_CountryId]
GO
ALTER TABLE [dbo].[Token]  WITH CHECK ADD  CONSTRAINT [FK_Token_UserMaster_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserMaster] ([UserId])
GO
ALTER TABLE [dbo].[Token] CHECK CONSTRAINT [FK_Token_UserMaster_UserId]
GO
ALTER TABLE [dbo].[UserMaster]  WITH CHECK ADD FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[UserMaster]  WITH CHECK ADD FOREIGN KEY([CompanyId])
REFERENCES [dbo].[Company] ([CompanyId])
GO
ALTER TABLE [dbo].[UserMaster]  WITH CHECK ADD  CONSTRAINT [FK_User_Role_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[RoleMaster] ([RoleId])
GO
ALTER TABLE [dbo].[UserMaster] CHECK CONSTRAINT [FK_User_Role_RoleId]
GO
ALTER TABLE [dbo].[UserMenuMapping]  WITH CHECK ADD  CONSTRAINT [FK_UserMenuMapping_Menu_MenuId] FOREIGN KEY([MenuId])
REFERENCES [dbo].[Menu] ([MenuId])
GO
ALTER TABLE [dbo].[UserMenuMapping] CHECK CONSTRAINT [FK_UserMenuMapping_Menu_MenuId]
GO
ALTER TABLE [dbo].[UserMenuMapping]  WITH CHECK ADD  CONSTRAINT [FK_UserMenuMapping_UserMaster_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserMaster] ([UserId])
GO
ALTER TABLE [dbo].[UserMenuMapping] CHECK CONSTRAINT [FK_UserMenuMapping_UserMaster_UserId]
GO
/****** Object:  StoredProcedure [dbo].[CUS_spInsertCustomerMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[CUS_spInsertCustomerMaster](
@CustomerName varchar(30),
@CustomerGSTNo varchar(15),
@ContactNo varchar(15),
@State varchar(30),
@StateCode varchar(30))
as
begin
insert into CUS_tCustomerMaster(CustomerName,CustomerGSTNo,ContactNo,State,StateCode) values (@CustomerName,@CustomerGSTNo,@ContactNo,@State,@StateCode)
end
GO
/****** Object:  StoredProcedure [dbo].[CUS_spSelectCusrtomerMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[CUS_spSelectCusrtomerMaster]
as
begin
select * from CUS_tCustomerMaster
end
GO
/****** Object:  StoredProcedure [dbo].[CUS_spSelectCustomerMasterId]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[CUS_spSelectCustomerMasterId](@CustomerId int)
as
begin
select * from Cus_tCustomerMaster where CustomerId=@CustomerId
end
GO
/****** Object:  StoredProcedure [dbo].[DEB_spdebtorsView]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[DEB_spdebtorsView]
as begin
select B.BillNo,B.BillingDate,C.CustomerName,B.GrandTotal,B.PaidAmount,B.BalanceAmount from 
SAL_tSalesMaster as B  join
CUS_tCustomerMaster as C on C.CustomerId=B.CustomerId where B.BalanceAmount <> 0
end
GO
/****** Object:  StoredProcedure [dbo].[INV_spInventerView]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[INV_spInventerView]
as begin 
select PRO_tProductNameMaster.ProductName,PRO_tProductSizeMaster.ProductSize,INV_tInventoryMaster.Quantity from INV_tInventoryMaster ,PRO_tProductSizeMaster,PRO_tProductNameMaster
where PRO_tProductNameMaster.ProductNameId=INV_tInventoryMaster.ProductNameId and PRO_tProductSizeMaster.ProductSizeId=INV_tInventoryMaster.ProductSizeId
end
GO
/****** Object:  StoredProcedure [dbo].[INV_spInventerViewId]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[INV_spInventerViewId] 
as 
begin
select * from INV_tInventoryMaster
end
GO
/****** Object:  StoredProcedure [dbo].[INV_spSavePurchase]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[INV_spSavePurchase](@PurchaseInventry varchar(max))
as
begin try
Declare @tempTable table(Id int identity(1,1), ProductNameId int  ,
    ProductSizeId int ,
    Quantity int )

insert into @tempTable 
SELECT * 
FROM OPENJSON(@PurchaseInventry)
with
(
    ProductNameId int  ,
    ProductSizeId int ,
    Quantity int 
) 
declare @init int = 1
declare @maxcount int =(select Count(Id) from @tempTable)

WHILE (@init <= @maxcount)
begin
	Declare @m_Count int=0

set @m_Count  = (select count(a.Quantity) from INV_tInventoryMaster a,@tempTable b where B.ID = @init and a.ProductNameId = b.ProductNameId  and
a.ProductSizeId = b.ProductSizeId)



if(@m_Count>0 )
begin
DECLARE @Quantity int ,@m_ProductSizeId int ,@m_ProductNameId int 

	select @Quantity=Quantity, @m_ProductSizeId= ProductSizeId ,@m_ProductNameId=ProductNameId from @tempTable where id = @init
	update INV_tInventoryMaster set Quantity= Quantity + @Quantity where ProductNameId=@m_ProductNameId and ProductSizeId=@m_ProductSizeId
	end

else
	begin
	  
		insert into INV_tInventoryMaster 
		 select  ProductNameId,ProductSizeId,Quantity from @tempTable where id = @init
	end
	 SET @init = @init + 1
	 end
	 delete  @tempTable
end try
begin catch
end catch
GO
/****** Object:  StoredProcedure [dbo].[INV_spSaveSales]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[INV_spSaveSales](@SalesInventry varchar(max))
as
begin try
Declare @tempTable table(Id int identity(1,1), ProductNameId int  ,
    ProductSizeId int ,
    Quantity int )

insert into @tempTable 
SELECT * 
FROM OPENJSON(@SalesInventry)
with
(
    ProductNameId int  ,
    ProductSizeId int ,
    Quantity int 
) 
declare @init int = 1
declare @maxcount int =(select Count(Id) from @tempTable)

WHILE (@init <= @maxcount)
begin
	Declare @m_Count int=0,@m_Quantity int=0

set @m_Count  = (select count(a.Quantity) from INV_tInventoryMaster a,@tempTable b where B.ID = @init and a.ProductNameId = b.ProductNameId  and
a.ProductSizeId = b.ProductSizeId)



if(@m_Count>0 )
begin
DECLARE @Quantity int ,@m_ProductSizeId int ,@m_ProductNameId int 

	select @Quantity=Quantity, @m_ProductSizeId= ProductSizeId ,@m_ProductNameId=ProductNameId from @tempTable where id = @init
	set @m_Quantity = (select Quantity from INV_tInventoryMaster where ProductNameId=@m_ProductNameId and ProductSizeId=@m_ProductSizeId)
	if(@m_Quantity >= @Quantity)
	update INV_tInventoryMaster set Quantity= Quantity - @Quantity where ProductNameId=@m_ProductNameId and ProductSizeId=@m_ProductSizeId
	
else
print 'Available Quantity is less' 
	
	end
	 SET @init = @init + 1
	 end
	 delete  @tempTable
end try
begin catch
end catch

GO
/****** Object:  StoredProcedure [dbo].[MonthlyPurchaseReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[MonthlyPurchaseReport]  
AS BEGIN  
select pm.BillNo,pm.BillDate,pm.GrandTotal,v.VendorName,v.GSTNO,v.Address,v.ContactNo,n.ProductName,n.HSN_Code,s.ProductSize,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from VEN_tVendorMaster as v join   
PUR_tPurchaseMaster as pm on v.VendorId=pm.VendorId join  
PUR_tPurchaseDetails as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId where pm.BillDate between  DATEADD(Month, -1, Getdate()) and GetDate() 
end 
GO
/****** Object:  StoredProcedure [dbo].[MonthlySalesReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[MonthlySalesReport] 
AS BEGIN  
select pm.BillNo,pm.BillingDate,pm.GrandTotal,  
v.CustomerName,v.CustomerGSTNo,v.ContactNo,v.State,v.StateCode,  
n.ProductName,n.HSN_code,  
s.ProductSize,  
pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from CUS_tCustomerMaster as v join   
SAL_tSalesMaster as pm on v.CustomerId=pm.CustomerId join  
SAL_tSalesDetailsPaid as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId   
where pm.BillingDate   between  DATEADD(Month, -1, Getdate()) and GetDate()
end  
GO
/****** Object:  StoredProcedure [dbo].[PeriodicPurchaseReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PeriodicPurchaseReport](@FromDate Date,@ToDate Date)  
AS BEGIN  
select pm.BillNo,pm.BillDate,pm.GrandTotal,v.VendorName,v.GSTNO,v.Address,v.ContactNo,n.ProductName,n.HSN_Code,s.ProductSize,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from VEN_tVendorMaster as v join   
PUR_tPurchaseMaster as pm on v.VendorId=pm.VendorId join  
PUR_tPurchaseDetails as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId where pm.BillDate between @fromdate and @todate
end 
GO
/****** Object:  StoredProcedure [dbo].[PeriodicSalesReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[PeriodicSalesReport] (@FromDate Date,@ToDate Date) 
AS BEGIN  
select pm.BillNo,pm.BillingDate,pm.GrandTotal,  
v.CustomerName,v.CustomerGSTNo,v.ContactNo,v.State,v.StateCode,  
n.ProductName,n.HSN_code,  
s.ProductSize,  
pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from CUS_tCustomerMaster as v join   
SAL_tSalesMaster as pm on v.CustomerId=pm.CustomerId join  
SAL_tSalesDetailsPaid as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId   
where pm.BillingDate between @fromdate and @todate
end  
GO
/****** Object:  StoredProcedure [dbo].[PRO_spInsertProductNameMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[PRO_spInsertProductNameMaster] (@ProductName varchar(30),@HSN_Code varchar(15))
as
begin
insert into PRO_tProductNameMaster(ProductName,HSN_Code) values (@ProductName,@HSN_Code)
end
GO
/****** Object:  StoredProcedure [dbo].[PRO_spInsertProductSizeMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[PRO_spInsertProductSizeMaster](@ProductSize varchar(30))
as
begin
insert into PRO_tProductSizeMaster(ProductSize) values (@ProductSize)
end
GO
/****** Object:  StoredProcedure [dbo].[PRO_spSelectHSN_Code]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PRO_spSelectHSN_Code](@ProductNameId int)  
as  
begin  
select HSN_Code from PRO_tProductNameMaster where ProductNameId=@ProductNameId  
end
GO
/****** Object:  StoredProcedure [dbo].[PRO_spSelectProductName]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[PRO_spSelectProductName] 
as
begin
select *  from PRO_tProductNameMaster 
end
GO
/****** Object:  StoredProcedure [dbo].[PRO_spSelectProductSize]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PRO_spSelectProductSize]
as
begin
select * from PRO_tProductSizeMaster 
end
GO
/****** Object:  StoredProcedure [dbo].[PUR_spAllPurchaseDetails]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[PUR_spAllPurchaseDetails](@BillNo int)
AS BEGIN
select pm.BillNo,pm.BillDate,pm.GrandTotal,v.VendorName,v.GSTNO,v.Address,v.ContactNo,n.ProductName,n.HSN_Code,s.ProductSize,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount
from VEN_tVendorMaster as v join 
PUR_tPurchaseMaster as pm on v.VendorId=pm.VendorId join
PUR_tPurchaseDetails as pd on pm.BillNo=pd.BillNo join
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId where pm.BillNo=@BillNo
end
GO
/****** Object:  StoredProcedure [dbo].[PUR_spAllSalesDetailsBalance]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[PUR_spAllSalesDetailsBalance] (@BillNo int)
AS BEGIN
select pm.BillNo,pm.BillingDate,pm.GrandTotal,v.CustomerName,v.CustomerGSTNo,v.ContactNo,v.StateCode,v.State,n.ProductName,n.HSN_Code,s.ProductSize,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount,pm.PaidAmount,pm.BalanceAmount,d.PayableAmount
from CUS_tCustomerMaster as v join 
SAL_tSalesMaster as pm on v.CustomerId=pm.CustomerId join
SAL_tSalesDetails as pd on pm.BillNo=pd.BillNo join
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join
Debtors_table as d on d.BillNo=pd.BillNo Join
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId where pm.BillNo=@BillNo
--select pm.BillNo,pm.BillDate,pm.GrandTotal,v.VendorName,v.GSTNO,v.Address,v.ContactNo from VEN_tVendorMaster as v join 
--PUR_tPurchaseMaster as pm on v.VendorId=pm.VendorId where pm.BillNo=@BillNo 
--select n.ProductName,s.ProductSize,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount from PUR_tPurchaseDetails as pd  join
--PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join
--PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId where pd.BillNo=@BillNo
END
GO
/****** Object:  StoredProcedure [dbo].[PUR_spAllSalesDetailsPaid]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PUR_spAllSalesDetailsPaid] (@BillNo int)
AS BEGIN
select pm.BillNo,pm.BillingDate,pm.GrandTotal,
v.CustomerName,v.CustomerGSTNo,v.ContactNo,v.State,v.StateCode,
n.ProductName,n.HSN_code,
s.ProductSize,
pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount
from CUS_tCustomerMaster as v join 
SAL_tSalesMaster as pm on v.CustomerId=pm.CustomerId join
SAL_tSalesDetailsPaid as pd on pm.BillNo=pd.BillNo join
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId 
where pm.BillNo=@BillNo end
GO
/****** Object:  StoredProcedure [dbo].[PUR_spDeleteBillReturn]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[PUR_spDeleteBillReturn](
@BillNo int)
as
begin
delete from PUR_tPurchaseDetails where BillNo=@BillNo
delete from PUR_tPurchaseMaster where BillNo=@BillNo
end
GO
/****** Object:  StoredProcedure [dbo].[PUR_spInsertPurchaseMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PUR_spInsertPurchaseMaster]
(
@p_BillNo int,
@p_BillDate datetime,
@p_VendorID int,
@p_GrandTotal decimal(15,5),
@p_OrderDetails varchar(max)
)
as
begin
insert into PUR_tPurchaseMaster values(@p_BillNo,@p_BillDate,@p_VendorID,@p_GrandTotal)
insert into PUR_tPurchaseDetails select * from openjson(@p_OrderDetails)
 
with(BillNo int,
ProductNameId int ,
HSN_Code varchar(100),
ProductSizeId int,
Quantity int,
Rate decimal(15,5),
Amount decimal(15,5),
Tax varchar(10) ,
TotalAmount decimal(15,5))

end
GO
/****** Object:  StoredProcedure [dbo].[PUR_spPurchaseReturnBillLoad]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PUR_spPurchaseReturnBillLoad]   
(@BillNo int)    
as    
begin    
select v.VendorId,v.VendorName,v.GSTNO,v.Address,v.ContactNo, pm.BillNo,pm.BillDate,pm.GrandTotal from VEN_tVendorMaster as v    
 Join PUR_tPurchaseMaster as pm on pm.VendorId=v.VendorId where BillNo=@BillNo    
 select pd.BillNo,pn.ProductName,pn.ProductNameId,pd.HSN_code,ps.ProductSize,ps.ProductSizeId,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount     
 from PUR_tPurchaseDetails as pd join PRO_tProductNameMaster as pn on pd.productnameid=pn.productnameid  join pro_tproductSizeMaster as ps on     
 pd.productsizeid=ps.productsizeid where BillNo=@BillNo    
end 
GO
/****** Object:  StoredProcedure [dbo].[PUR_spViewPurchaseMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[PUR_spViewPurchaseMaster]
as
begin
select m.BillNo,m.BillDate,m.GrandTotal,v.VendorName,v.ContactNo from PUR_tPurchaseMaster as m join
VEN_tVendorMaster as v on m.VendorId=v.VendorId 
end
GO
/****** Object:  StoredProcedure [dbo].[SAL_spDeleteBillReturn]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SAL_spDeleteBillReturn](
@BillNo int)
as
begin
delete from SAL_tSalesDetailsPaid where BillNo=@BillNo
delete from TransporationDetails where BillNo=@BillNo
delete from SAL_tSalesMaster where BillNo=@BillNo
end
GO
/****** Object:  StoredProcedure [dbo].[SAL_spInsertSalesMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[SAL_spInsertSalesMaster] 
(
@p_BillNo int,
@P_BillingDate datetime,
@p_GSTNo varchar(15),
@p_CustomerId int,
@p_GrandTotal decimal(15,5),
@p_PaidAmount decimal(15,5),
@p_BalanceAmount decimal(15,5),
@p_TransporationMode varchar(max),
@p_VehicleNumber varchar(50),
@p_DateOfSupply datetime,
@p_PlaceOfSupply varchar(50),
@p_OrderDetails varchar(max)
)
as
begin
insert into SAL_tSalesMaster values(@P_BillingDate,@p_GSTNo,@p_CustomerId,@p_GrandTotal,@p_PaidAmount,@p_BalanceAmount)
insert into TransporationDetails (BillNo,TransporationMode,VehicleNumber,DateOfSupply,PlaceOfSupply)values (@p_BillNo,@p_TransporationMode,@p_VehicleNumber,@p_DateOfSupply,@p_PlaceOfSupply)
insert into SAL_tSalesDetailsPaid select * from OPENJSON(@p_OrderDetails) 
with ( BillNo int,
ProductNameId int,
HSN_Code varchar(10),
ProductSizeId int,
Quantity int,
Rate decimal(15,5),
Amount decimal(15,5),       
Tax varchar(10),
TotalAmount decimal(15,5)
)
end 
GO
/****** Object:  StoredProcedure [dbo].[SAL_spSalesReturnBillLoad]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SAL_spSalesReturnBillLoad]    
(@BillNo int)    
as    
begin    
select c.CustomerName,c.ContactNo,c.CustomerGSTNo,c.State,sm.BillNo,sm.BillingDate,sm.GrandTotal,T.TransporationMode,T.VehicleNumber,c.CustomerId,    
T.DateOfSupply,T.PlaceOfSupply from CUS_tCustomerMaster as c join SAL_tSalesMaster as sm    
on sm.CustomerId=c.CustomerId join TransporationDetails as T on sm.BillNo=T.BillNo where T.BillNo=@BillNo    
select n.ProductName,n.ProductNameId,s.BillNo,s.HSN_Code,m.ProductSize,m.ProductSizeId,s.Quantity,s.Rate,s.Amount,s.Tax,s.TotalAmount from SAL_tSalesDetailsPaid as s Join     
PRO_tProductNameMaster as n on s.ProductNameId=n.ProductNameId join PRO_tProductSizeMaster as m ON s.ProductSizeId=m.ProductSizeId where BillNo=@BillNo    
   
end 
GO
/****** Object:  StoredProcedure [dbo].[SAL_spViewSalesMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SAL_spViewSalesMaster]
as
begin
select m.BillNo,m.BillingDate,m.GrandTotal,m.PaidAmount,m.BalanceAmount,v.CustomerName,v.ContactNo from SAL_tSalesMaster as m join 
CUS_tCustomerMaster as v on m.CustomerId=v.CustomerId
end
GO
/****** Object:  StoredProcedure [dbo].[selectdata]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[selectdata](@StudentId int)
 as begin 
 select * from data where StudentId=@StudentId
 end
GO
/****** Object:  StoredProcedure [dbo].[selectState]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[selectState](@sateId int)
 as begin 
 select * from State  where sateId=@sateId
 end
GO
/****** Object:  StoredProcedure [dbo].[sp_deleteToken]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_deleteToken]
(
@userId BigInt
)
as
begin
DECLARE @TokenId varchar(max);
select  @TokenId = COALESCE(@TokenId+',','') + (CAST( TokenId AS VARCHAR(10)))  from Token where UserId = @userId and CAST(ExpiresOn as datetime) <> CAST(GETDATE() as datetime)

Delete from token where TokenId in (SELECT distinct  item FROM [dbo].[Split](@TokenId, ','))
end
GO
/****** Object:  StoredProcedure [dbo].[sp_GEN_SaveDeleteCountryMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_GEN_SaveDeleteCountryMaster]
	@A_CountryId int,
	@A_CountryName nvarchar(500),
	@A_CountryCode nvarchar(10),
	@A_CurrencyName nvarchar(500),
	@A_CurrencyCode nvarchar(50),
	@A_CurrencySymbol nvarchar(20),
	@A_CreatedBy int,
	@A_Process nvarchar(10),
	@A_RetVal int Output
AS
BEGIN
	
	SET NOCOUNT ON;

  --  Declare 
		--@A_CountryId int,
		--@A_CountryName int,
		--@A_CountryCode nvarchar(10),
		--@A_CurrencyName nvarchar(500),
		--@A_CurrencyCode nvarchar(50),
		--@A_CurrencySymbol nvarchar(20),
		--@A_CreatedBy int,
		--@A_Process nvarchar(10),
		--@A_RetVal int --Output


	Set @A_RetVal = 0

	If(@A_Process = 'Save')
	Begin
		If(@A_CountryId = 0)
		Begin
			If Not Exists(Select 1 from Country Where CountryName = @A_CountryName and CountryCode = @A_CountryCode)
			Begin
				Insert into Country(CountryName,CountryCode,IsActive,CurrencyName,CurrencyCode,CurrencySymbol,CreatedBy,CreatedOn)
				Values(@A_CountryName,@A_CountryCode,1,@A_CurrencyName,@A_CurrencyCode,@A_CurrencySymbol,@A_CreatedBy,GETDATE())

				Set @A_RetVal = 1
				-- Saved successfully
			End
			Else
			Begin			
				Set @A_RetVal = 2
				-- Country Code/Name Already Exists
			End	
		End
		Else
		Begin
			If Not Exists(Select 1 from Country Where CountryName = @A_CountryName and CountryCode = @A_CountryCode and CountryId <> @A_CountryId)
			Begin
				Update Country
				Set
					CountryName = @A_CountryName,
					CurrencyName = @A_CurrencyName,
					CurrencyCode = @A_CurrencyCode,
					CurrencySymbol = @A_CurrencySymbol,				
					ModifiedBy = @A_CreatedBy,
					ModifiedOn = GETDATE()
				Where	
					CountryId = @A_CountryId

				Set @A_RetVal = 3
				-- Updated successfully
			End
			Else
			Begin
				Set @A_RetVal = 2
				-- Country Code/Name Already Exists
			End
		End	
	End
	Else If(@A_Process = 'Delete')
	Begin
		Delete from Country Where CountryId = @A_CountryId
		Set @A_RetVal = 4
		-- Deleted successfully
	End

END
GO
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetCompanyListByEmp]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Gen_sGetCompanyListByEmp]        
AS      
BEGIN      
       
 -- exec [SP_Gen_sGetCompanyListByEmp]   
 Begin      
 select distinct cmp.CompanyId,cmp.CompanyName from Company cmp,Employee emp where emp.kpostUcode is null and emp.CompanyId = cmp.CompanyId  
 End      
END  
GO
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetDeportmentListByProject]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext [SP_Gen_sGetDesignationListByDepartment]


CREATE PROCEDURE [dbo].[SP_Gen_sGetDeportmentListByProject]          
@P_CompanyId int    
AS        
BEGIN        
         
 -- exec [SP_Gen_sGetDeportmentListByProject]  @p_ProjectId = 29    
 Begin        
 select distinct dep.DepartmentId,dep.DepartmentName from Company cmp,Employee emp,Department Dep,ProjectMaster PM     
 where emp.kpostUcode is null and emp.CompanyId = cmp.CompanyId     
 and dep.CompanyId = cmp.CompanyId and emp.DepartmentId = Dep.DepartmentId and cmp.CompanyId = @P_CompanyId    
 End        
END 
GO
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetDesignationListByDepartment]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext [SP_Gen_sGetDesignationListByDepartment]


 Create PROCEDURE [dbo].[SP_Gen_sGetDesignationListByDepartment]        
@P_CompanyId int,  
@P_DepartmentId int  
AS      
BEGIN      
       
 -- exec [SP_Gen_sGetDesignationListByDepartment]  @p_ProjectId = 8  
 Begin      
 select distinct Desg.DesignationId,Desg.DesignationName from Company cmp,Employee emp,Department Dep,Designation Desg   
 where emp.kpostUcode is null and emp.CompanyId = cmp.CompanyId   
 and dep.CompanyId = cmp.CompanyId and emp.DepartmentId = Dep.DepartmentId and emp.DesignationId = Desg.DesignationId and emp.DepartmentId = @P_DepartmentId and emp.CompanyId = @P_CompanyId  
 End      
END  
GO
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetEmployeeListByDesignation]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext [SP_Gen_sGetEmployeeListByDesignation]



CREATE PROCEDURE [dbo].[SP_Gen_sGetEmployeeListByDesignation]        
@P_CompanyId int,  
@P_DepartmentId int,  
@P_DesignationId int  
AS      
BEGIN      
       
 -- exec [SP_Gen_sGetDesignationListByDepartment]  @P_CompanyId = 8 and @P_DepartmentId =   
 Begin      
 select distinct emp.EmployeeId,emp.FirstName as EmployeeName,KpostUCode from Company cmp,Employee emp,Department Dep,Designation Desg   
 where emp.kpostUcode is null and emp.CompanyId = cmp.CompanyId   
 and dep.CompanyId = cmp.CompanyId and emp.DepartmentId = Dep.DepartmentId and emp.DesignationId = Desg.DesignationId   
 and emp.CompanyId = @P_CompanyId and emp.DepartmentId = @P_DepartmentId and emp.DesignationId = @P_DesignationId  
 End      
END  


 
GO
/****** Object:  StoredProcedure [dbo].[Sp_SalesforReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[Sp_SalesforReport] (@BillNo int)
AS BEGIN
select sm.BillNo,sm.BillingDate,c.CustomerName,t.TransporationMode,t.VehicleNumber,t.DateOfSupply,t.PlaceOfSupply,c.ContactNo,c.CustomerGSTNo,c.State,c.StateCode,p.ProductName,p.HSN_Code,
sd.Quantity,sd.Rate,sd.Amount,sd.Tax,sd.TotalAmount,sm.GrandTotal from SAL_tSalesDetailsPaid as sd JOIN
SAL_tSalesMaster as sm on sd.BillNo=sm.BillNo JOIN
TransporationDetails as t on sm.BillNo=t.BillNo JOIN
CUS_tCustomerMaster as c on sm.CustomerId=c.CustomerId JOIN
PRO_tProductNameMaster as p on sd.ProductNameId=p.ProductNameId 
where sd.BillNo=@BillNo
end
GO
/****** Object:  StoredProcedure [dbo].[sp_UpadtePage]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_UpadtePage](@BillNo int,@PayableAmount decimal(15,5))
as
begin
update SAL_tSalesMaster set BalanceAmount = BalanceAmount - @PayableAmount where BillNo=@BillNo
update SAL_tSalesMaster set PaidAmount = PaidAmount + @PayableAmount where BillNo=@BillNo
end
GO
/****** Object:  StoredProcedure [dbo].[spErrorLog]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spErrorLog]  
(  
@p_ErrorCode int= null , @p_Description varchar(max)= null , @p_Message varchar(max) , @p_ErrorLine varchar(70) =null, @p_ScreenName varchar(70),  
 @p_ActionName varchar(70), @p_ActionBy int)  
 as   
   begin  
  
   insert into [ErrorLog] (  
      [ErrorCode]  
      ,[Description]  
      ,[Message]  
      ,[ErrorLine]  
      ,[ScreenName]  
      ,[ActionName]  
      ,[Date]  
      ,[ActionBy])  
  
   values(  @p_ErrorCode , @p_Description  , @p_Message , @p_ErrorLine , @p_ScreenName , @p_ActionName,GETDATE(), @p_ActionBy)  
  
   
end  
GO
/****** Object:  StoredProcedure [dbo].[UpdatePurchase]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[UpdatePurchase] (@BillNo int,@PurchaseUpdate varchar(max))  
as  
begin try  
Declare @tempTable table(Id int identity(1,1), ProductNameId int  ,  
    ProductSizeId int ,  
    Quantity int )  
  
insert into @tempTable   
SELECT *   
FROM OPENJSON(@PurchaseUpdate)  
with  
(  
    ProductNameId int  ,  
    ProductSizeId int ,  
    Quantity int   
)   
declare @init int = 1  
declare @maxcount int =(select Count(Id) from @tempTable)  
  
WHILE (@init <= @maxcount)  
begin  
 Declare @m_Count int=0,@m_Quantity int=0  
  
set @m_Count  = (select count(a.Quantity) from PUR_tPurchaseDetails a,@tempTable b where B.ID = @init and a.ProductNameId = b.ProductNameId  and  
a.ProductSizeId = b.ProductSizeId and a.BillNo=@BillNo )  
  
  
  
if(@m_Count>0 )  
begin  
DECLARE @Quantity int ,@m_ProductSizeId int ,@m_ProductNameId int  
  
 select @Quantity=Quantity, @m_ProductSizeId= ProductSizeId ,@m_ProductNameId=ProductNameId from @tempTable where id = @init  
 set @m_Quantity = (select Quantity from PUR_tPurchaseDetails where ProductNameId=@m_ProductNameId and ProductSizeId=@m_ProductSizeId and BillNo=@BillNo )  
 if(@m_Quantity >= @Quantity)  
 update PUR_tPurchaseDetails set Quantity= Quantity - @Quantity,
 Amount=(Quantity - @Quantity)*Rate,
 TotalAmount=(Quantity - @Quantity)*Rate*Tax*0.01+(Quantity - @Quantity)*Rate
  where ProductNameId=@m_ProductNameId and ProductSizeId=@m_ProductSizeId  and BillNo=@BillNo
   
   else  
print 'Available Quantity is less'   

   
 end  
  SET @init = @init + 1  
  end  
  delete  @tempTable  
end try  
begin catch  
end catch  
GO
/****** Object:  StoredProcedure [dbo].[UpdateSales]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[UpdateSales](@BillNo int,@SalesUpdate varchar(max))  
as  
begin try  
Declare @tempTable table(Id int identity(1,1), ProductNameId int  ,  
    ProductSizeId int ,  
    Quantity int )  
  
insert into @tempTable   
SELECT *   
FROM OPENJSON(@SalesUpdate)  
with  
(  
    ProductNameId int  ,  
    ProductSizeId int ,  
    Quantity int   
)   
declare @init int = 1  
declare @maxcount int =(select Count(Id) from @tempTable)  
  
WHILE (@init <= @maxcount)  
begin  
 Declare @m_Count int=0,@m_Quantity int=0  
  
set @m_Count  = (select count(a.Quantity) from SAL_tSalesDetailsPaid a,@tempTable b where B.ID = @init and a.ProductNameId = b.ProductNameId  and  
a.ProductSizeId = b.ProductSizeId and a.BillNo=@BillNo)  
  
  
  
if(@m_Count>0 )  
begin  
DECLARE @Quantity int ,@m_ProductSizeId int ,@m_ProductNameId int   
  
 select @Quantity=Quantity, @m_ProductSizeId= ProductSizeId ,@m_ProductNameId=ProductNameId from @tempTable where id = @init  
 set @m_Quantity = (select Quantity from SAL_tSalesDetailsPaid where ProductNameId=@m_ProductNameId and ProductSizeId=@m_ProductSizeId and BillNo=@BillNo)  
 if(@m_Quantity >= @Quantity)  
 update SAL_tSalesDetailsPaid set Quantity= Quantity - @Quantity,
 Amount=(Quantity - @Quantity)*Rate,
 TotalAmount=(Quantity - @Quantity)*Rate*Tax*0.01+(Quantity - @Quantity)*Rate
  where ProductNameId=@m_ProductNameId and ProductSizeId=@m_ProductSizeId and BillNo=@BillNo 
   
   
   
 end  
  SET @init = @init + 1  
  end  
  delete  @tempTable  
end try  
begin catch  
end catch  
 

GO
/****** Object:  StoredProcedure [dbo].[VEN_spInsertVendorMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[VEN_spInsertVendorMaster](
@GSTNo varchar(15),
@VendorName varchar(30),
@Address varchar(200),
@ContactNo varchar(15))
as
begin
insert into VEN_tVendorMaster(GSTNo,VendorName,Address,ContactNo) values (@GSTNo,@VendorName,@Address,@ContactNo)
end
GO
/****** Object:  StoredProcedure [dbo].[VEN_spSelectVendorMaster]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[VEN_spSelectVendorMaster]
as
begin
select * from VEN_tVendorMaster
end
GO
/****** Object:  StoredProcedure [dbo].[VEN_spSelectVendorMasterId]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[VEN_spSelectVendorMasterId](@VendorId int)
as
begin
select * from VEN_tVendorMaster where VendorId=@VendorId
end
GO
/****** Object:  StoredProcedure [dbo].[WeeklyPurchaseReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[WeeklyPurchaseReport]  
AS BEGIN  
select pm.BillNo,pm.BillDate,pm.GrandTotal,v.VendorName,v.GSTNO,v.Address,v.ContactNo,n.ProductName,n.HSN_Code,s.ProductSize,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from VEN_tVendorMaster as v join   
PUR_tPurchaseMaster as pm on v.VendorId=pm.VendorId join  
PUR_tPurchaseDetails as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId where pm.BillDate between  DATEADD(DAY, -7, Getdate()) and GetDate() 
end  
GO
/****** Object:  StoredProcedure [dbo].[WeeklySalesReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[WeeklySalesReport] 
AS BEGIN  
select pm.BillNo,pm.BillingDate,pm.GrandTotal,  
v.CustomerName,v.CustomerGSTNo,v.ContactNo,v.State,v.StateCode,  
n.ProductName,n.HSN_code,  
s.ProductSize,  
pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from CUS_tCustomerMaster as v join   
SAL_tSalesMaster as pm on v.CustomerId=pm.CustomerId join  
SAL_tSalesDetailsPaid as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId   
where pm.BillingDate   between  DATEADD(DAY, -7, Getdate()) and GetDate() 
end  
GO
/****** Object:  StoredProcedure [dbo].[YearlyPurchaseReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[YearlyPurchaseReport]  
AS BEGIN  
select pm.BillNo,pm.BillDate,pm.GrandTotal,v.VendorName,v.GSTNO,v.Address,v.ContactNo,n.ProductName,n.HSN_Code,s.ProductSize,pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from VEN_tVendorMaster as v join   
PUR_tPurchaseMaster as pm on v.VendorId=pm.VendorId join  
PUR_tPurchaseDetails as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId where pm.BillDate between  DATEADD(YEAR, -1, Getdate()) and GetDate() 
end 
GO
/****** Object:  StoredProcedure [dbo].[YearlySalesReport]    Script Date: 11/27/2018 7:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[YearlySalesReport] 
AS BEGIN  
select pm.BillNo,pm.BillingDate,pm.GrandTotal,  
v.CustomerName,v.CustomerGSTNo,v.ContactNo,v.State,v.StateCode,  
n.ProductName,n.HSN_code,  
s.ProductSize,  
pd.Quantity,pd.Rate,pd.Amount,pd.Tax,pd.TotalAmount  
from CUS_tCustomerMaster as v join   
SAL_tSalesMaster as pm on v.CustomerId=pm.CustomerId join  
SAL_tSalesDetailsPaid as pd on pm.BillNo=pd.BillNo join  
PRO_tProductNameMaster as n on  pd.ProductNameId=n.ProductNameId join  
PRO_tProductSizeMaster as s on pd.ProductSizeId=s.ProductSizeId   
where pm.BillingDate   between   DATEADD(YEAR, -1, Getdate()) and GetDate() 
end  
GO
USE [master]
GO
ALTER DATABASE [Billing] SET  READ_WRITE 
GO

