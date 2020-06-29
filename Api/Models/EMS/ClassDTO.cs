using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class ClassDTO
    {
        public int ClassId { get; set; }
        public string Name { get; set; }
        public string DepartmentName { get; set; }
        public string Code { get; set; }
    }
    public class SaveClassDTO
    {
        public string Name { get; set; }
        public int DepartmentId { get; set; }
        public string Code { get; set; }
        public string CreatedBy { get; set; }
    }
    public class ModifyClassDTO
    {
        public int ClassId { get; set; }
        public string Name { get; set; }
        public int DepartmentId { get; set; }
        public string Code { get; set; }
        public string ModifiedBy { get; set; }

    }
    public class RemoveClassDTO
    {
        public int ClassId { get; set; }
    }
    public class DepartmentName
    {
        public int DepartmentId { get; set; }
        public string Name { get; set; }
    }
}