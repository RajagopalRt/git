using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class DepartmentDTO
    {
        public int DepartmentId { get; set; }
        public string Name { get; set; }
        public string CollegeName { get; set; }
        public string Code { get; set; }
    }
    public class SaveDepartmentDTO
    {
        public string Name { get; set; }
        public int CollegeId { get; set; }
        public string Code { get; set; }
        public string CreatedBy { get; set; }
    }
    public class ModifyDepartmentDTO
    {
        public int DepartmentId { get; set; }
        public string Name { get; set; }
        public int CollegeId { get; set; }
        public string Code { get; set; }
        public string ModifiedBy { get; set; }
    }
    public class College1DTO
    {
        public int CollegeId { get; set; }
        public string Name { get; set; }
    }
    public class RemoveDepartmentDTO
    {
        public int DepartmentId { get; set; }
    }
}