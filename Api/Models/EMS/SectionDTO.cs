using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class SectionDTO
    {
        public int SectionId { get; set; }
        public string ClassName { get; set; }
        public string Section { get; set; }
        public string DepartmentName { get; set; }
        public string Code { get; set; }
    }
    public class SaveSectionDTO
    {
        public int ClassId { get; set; }
        public int DepartmentId { get; set; }
        public string Section { get; set; }
        public string Code { get; set; }
        public string CreatedBy { get; set; }
    }
    public class ModifySectionDTO
    {
        public int ClassId { get; set; }
        public int SectionId { get; set; }
        public int DepartmentId { get; set; }
        public string Section { get; set; }
        public string Code { get; set; }
        public string ModifiedBy { get; set; }
    }
    public class RemoveSectionDTO
    {
        public int SectionId { get; set; }
    }
    public class ClassName
    {
        public int ClassId { get; set; }
        public string Name { get; set; }
    }
}