using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class CollegeDTO
    {
        public int CollegeId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string University { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Country { get; set; }
        public string Logo { get; set; }
        public string CompanyWebSite { get; set; }
        public string ContactNumber { get; set; }
        public string Email { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime ModifiedDate { get; set; }
        public DateTime CreatedDate { get; set; }
    }
    public class SaveCollegeDTO
    {
        public string Name { get; set; }
        public string Address { get; set; }
        public int University { get; set; }
        public int City { get; set; }
        public int State { get; set; }
        public int Country { get; set; }
        public string Logo { get; set; }
        public string CompanyWebSite { get; set; }
        public string ContactNumber { get; set; }
        public string Email { get; set; }
        public string CreatedBy { get; set; }
    }
    public class ModifyCollegeDTO
    {
        public int CollegeId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public int University { get; set; }
        public int City { get; set; }
        public int State { get; set; }
        public int Country { get; set; }
        public string Logo { get; set; }
        public string CompanyWebSite { get; set; }
        public string ContactNumber { get; set; }
        public string Email { get; set; }
        public string ModifiedBy { get; set; }
    }
    public class UniverSityMaster
    {
        public int UniversityId { get; set; }
        public int stateid { get; set; }
        public int cityid { get; set; }
        public int countryid { get; set; }
        public string Name { get; set; }
    }
    public class StateMaster
    {
        public int StateId { get; set; }
        public string Name { get; set; }
    }
    public class CityMaster
    {
        public int CityId { get; set; }
        public string Name { get; set; }
    }
    public class CountryMaster
    {
        public int CountryId { get; set; }
        public string Name { get; set; }
    }
    public class RemoveCollegeDTO
    {
        public int CollegeId { get; set; }
    }
}