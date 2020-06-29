using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class Hod_AllocationDTO
    {
        public int HodAllocationId { get; set; }
        public string DepartmentName { get; set; }
        public string EmployeeName { get; set; }
    }
    public class SaveHod_AllocationDTO
    {

        public int DepartmentId { get; set; }
        public int EmployeeId { get; set; }
        public string CreatedBy { get; set; }

    }
    public class ModifyHod_AllocationDTO
    {

        public int HodAllocationId { get; set; }
        public int DepartmentId { get; set; }
        public int EmployeeId { get; set; }
        public string ModifiedBy { get; set; }

    }
    public class RemoveHod_AllocationDTO
    {
        public int HodAllocationId { get; set; }
    }
    public class Employee
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
    }
}