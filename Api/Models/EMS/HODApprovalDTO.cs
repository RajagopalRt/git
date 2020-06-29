using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class HODApprovalDTO
    {
        public int EventId { get; set; }
        public int StudentId { get; set; }
        public string Name { get; set; }
        public string CollegeName { get; set; }
        public string Department { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public string EventType { get; set; }
        public string Purpose { get; set; }
        public String Date { get; set; }
        public string FromTime { get; set; }
        public string ToTime { get; set; }
        public string ApprovedStaff { get; set; }
        public string ApprovedHOD { get; set; }
    }
    public class SaveHODApprovalDTO
    {
        public int EventId { get; set; }
        public int StudentId { get; set; }
        public string Name { get; set; }
        public string CollegeName { get; set; }
        public string Department { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public string EventType { get; set; }
        public String Date { get; set; }
        public string FromTime { get; set; }
        public string ToTime { get; set; }
        public string ApprovedStaff { get; set; }
        public string ApprovedHOD { get; set; }
    }
    public class RemoveHODApprovalDTO
    {
        public int EventId { get; set; }
        public int StudentId { get; set; }
    }
    public class SelectHODApprovalDTO
    {
        public int EventId { get; set; }
        public int StudentId { get; set; }
        public string Name { get; set; }
        public string CollegeName { get; set; }
        public string Department { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public string EventType { get; set; }
        public String Date { get; set; }
        public string FromTime { get; set; }
        public string ToTime { get; set; }
        public string ApprovedStaff { get; set; }
        public string ApprovedHOD { get; set; }
    }
    public class SelectHODApprovalProcDTO
    {
        public int EventId { get; set; }
        public int StudentId { get; set; }
    }
}