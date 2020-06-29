using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class EmployeeDTO
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public DateTime DateOfJoining { get; set; }
        public string EmployeeType { get; set; }
        public string DepartmentName { get; set; }
        public string Role { get; set; }
        public string MobileNo { get; set; }
        public string Email { get; set; }
    }
    public class SaveEmployeeDTO
    {

        public string EmployeeName { get; set; }
        public DateTime DateOfJoining { get; set; }
        public string EmployeeType { get; set; }
        public int DepartmentId { get; set; }
        public int RoleId { get; set; }
        public string MobileNo { get; set; }
        public string Email { get; set; }
        public string CreatedBy { get; set; }
    }
    public class ModifyEmployeeDTO
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public DateTime DateOfJoining { get; set; }
        public string EmployeeType { get; set; }
        public int DepartmentId { get; set; }
        public int RoleId { get; set; }
        public string MobileNo { get; set; }
        public string Email { get; set; }
        public string ModifiedBy { get; set; }
    }
    public class RemoveEmployeeDTO
    {
        public int EmployeeId { get; set; }
    }
    public class RoleName
    {
        public int RoleId { get; set; }
        public string Name { get; set; }
    }
}