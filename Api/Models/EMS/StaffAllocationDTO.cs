using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class StaffAllocationDTO
    {
        public int StaffAllocationId { get; set; }
        public string Class { get; set; }
        public string DepartmentName { get; set; }
        public string EmployeeName { get; set; }
    }
    public class saveStaffAllocationDTO
    {
        public int ClassId { get; set; }
        public int DepartmentId { get; set; }
        public int EmployeeId { get; set; }
        public string CreatedBy { get; set; }

    }
    public class ModifyStaffAllocationDTO
    {
        public int StaffAllocationId { get; set; }
        public int ClassId { get; set; }
        public int DepartmentId { get; set; }
        public int EmployeeId { get; set; }
        public string ModifiedBy { get; set; }

    }
    public class RemoveStaffAllocationDTO
    {
        public int StaffAllocationId { get; set; }
    }
}