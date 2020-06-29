using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class StudentDTO
    {
        public int StudentId { get; set; }
        public string Name { get; set; }
        public DateTime Dob { get; set; }
        public string DepartmentName { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public string Email { get; set; }
        public string Mobile { get; set; }
        public string Address { get; set; }
    }
    public class SaveStudentDTO
    {
        public string Name { get; set; }
        public DateTime Dob { get; set; }
        public int DepartmentId { get; set; }
        public int ClassId { get; set; }
        public int SectionId { get; set; }
        public string Email { get; set; }
        public string Mobile { get; set; }
        public string Address { get; set; }
        public string CreatedBy { get; set; }
    }
    public class ModifyStudentDTO
    {
        public int StudentId { get; set; }
        public string Name { get; set; }
        public DateTime Dob { get; set; }
        public int DepartmentId { get; set; }
        public int ClassId { get; set; }
        public int SectionId { get; set; }
        public string Email { get; set; }
        public string Mobile { get; set; }
        public string Address { get; set; }
        public string ModifiedBy { get; set; }
    }
    public class SectionName
    {
        public int SectionId { get; set; }
        public string Section { get; set; }
    }
    public class RemoveStudentDTO
    {
        public int StudentId { get; set; }
    }
}