USE [master]
GO
/****** Object:  Database [Billing]    Script Date: 11/13/2018 7:48:49 PM ******/
CREATE DATABASE [Billing]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Billing', FILENAME = N'D:\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Billing.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Billing_log', FILENAME = N'D:\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Billing_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Billing] SET COMPATIBILITY_LEVEL = 140
GO 
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Billing].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Billing] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Billing] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Billing] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Billing] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Billing] SET ARITHABORT OFF 
GO
ALTER DATABASE [Billing] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Billing] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Billing] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Billing] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Billing] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Billing] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Billing] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Billing] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Billing] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Billing] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Billing] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Billing] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Billing] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Billing] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Billing] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Billing] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Billing] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Billing] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Billing] SET  MULTI_USER 
GO
ALTER DATABASE [Billing] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Billing] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Billing] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Billing] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Billing] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Billing] SET QUERY_STORE = OFF
GO
USE [Billing]
GO
/****** Object:  User [kaizen]    Script Date: 11/13/2018 7:48:49 PM ******/
CREATE USER [DESKTOP-QOHIPDF\user] FOR LOGIN [DESKTOP-QOHIPDF\user] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  UserDefinedFunction [dbo].[adjustedDate]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[getFinYear]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[JsonToKeyPair]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  Table [dbo].[Action]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  Table [dbo].[Area]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  Table [dbo].[AuditLog]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  Table [dbo].[City]    Script Date: 11/13/2018 7:48:49 PM ******/
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
/****** Object:  Table [dbo].[Company]    Script Date: 11/13/2018 7:48:50 PM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[CUS_tCustomerMaster]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[data]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[Debtors_table]    Script Date: 11/13/2018 7:48:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Debtors_table](
	[BillNo] [int] NULL,
	[payableAmount] [decimal](15, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Department]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[Designation]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[Employee]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[EmployeeAcademy]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[EmployeeAddress]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[EmployeeComponent]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[EmployeeExperience]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[EmployeeSalary]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[INV_tInventoryMaster]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[Menu]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[NatureOfBusiness]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[OrganizationLevel]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[OwnershipTypes]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[PRO_tProductNameMaster]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[PRO_tProductSizeMaster]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[PUR_tPurchaseDetails]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[PUR_tPurchaseMaster]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[RoleMaster]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[RoleMenuMapping]    Script Date: 11/13/2018 7:48:50 PM ******/
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
/****** Object:  Table [dbo].[SAL_tSalesDetails]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  Table [dbo].[SAL_tSalesDetailsPaid]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  Table [dbo].[SAL_tSalesMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  Table [dbo].[State1]    Script Date: 11/13/2018 7:48:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[State1](
	[sateId] [int] NULL,
	[stateName] [varchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StateMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  Table [dbo].[Token]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  Table [dbo].[TransporationDetails]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  Table [dbo].[UserMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserMenuMapping]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  Table [dbo].[VEN_tVendorMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[CUS_spInsertCustomerMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[CUS_spSelectCusrtomerMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[CUS_spSelectCustomerMasterId]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[DEB_spdebtorsView]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[INV_spInventerView]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[INV_spInventerViewId]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[INV_spSavePurchase]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[INV_spSaveSales]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[MonthlyPurchaseReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[MonthlySalesReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PeriodicPurchaseReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PeriodicSalesReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PRO_spInsertProductNameMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PRO_spInsertProductSizeMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PRO_spSelectHSN_Code]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PRO_spSelectProductName]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PRO_spSelectProductSize]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PUR_spAllPurchaseDetails]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PUR_spAllSalesDetailsBalance]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PUR_spAllSalesDetailsPaid]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PUR_spDeleteBillReturn]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PUR_spInsertPurchaseMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PUR_spPurchaseReturnBillLoad]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[PUR_spViewPurchaseMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SAL_spDeleteBillReturn]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SAL_spInsertSalesMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SAL_spSalesReturnBillLoad]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SAL_spViewSalesMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[selectdata]    Script Date: 11/13/2018 7:48:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[selectdata](@StudentId int)
 as begin 
 select * from data where StudentId=@StudentId
 end
GO
/****** Object:  StoredProcedure [dbo].[selectState]    Script Date: 11/13/2018 7:48:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[selectState](@sateId int)
 as begin 
 select * from State  where sateId=@sateId
 end
GO
/****** Object:  StoredProcedure [dbo].[sp_deleteToken]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_GEN_SaveDeleteCountryMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetCompanyListByEmp]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetDeportmentListByProject]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetDesignationListByDepartment]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SP_Gen_sGetEmployeeListByDesignation]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Sp_SalesforReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_UpadtePage]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spErrorLog]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdatePurchase]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateSales]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[VEN_spInsertVendorMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[VEN_spSelectVendorMaster]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[VEN_spSelectVendorMasterId]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[WeeklyPurchaseReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[WeeklySalesReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[YearlyPurchaseReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
/****** Object:  StoredProcedure [dbo].[YearlySalesReport]    Script Date: 11/13/2018 7:48:51 PM ******/
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
