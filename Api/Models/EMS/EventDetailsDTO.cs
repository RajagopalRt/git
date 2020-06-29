using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class EventDetailsDTO
    {
        public int EventId { get; set; }
        public int StudentId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string Department { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public string CollegeName { get; set; }
        public DateTime Date { get; set; }
        public DateTime FromTime { get; set; }
        public DateTime ToTime { get; set; }
        public string EventType { get; set; }
        public int Status { get; set; }
        public string Purpose { get; set; }
        //public string ApprovedStaffBy { get; set; }
        //public string ApprovedHodBy { get; set; }
        //public DateTime StaffApprovalDate { get; set; }
        //public DateTime HodApprovalDate { get; set; }
        //public string CreatedBy { get; set; }
        //public string ModifiedBy { get; set; }
        //public DateTime CreatedDate { get; set; }
        //public DateTime ModifiedDate { get; set; }
    }
    public class SaveEventDetailsDTO
    {
        public int StudentId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string Department { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public DateTime Date { get; set; }
        public string CollegeName { get; set; }
        public DateTime FromTime { get; set; }
        public DateTime ToTime { get; set; }
        public string EventType { get; set; }
        public int Status { get; set; }
        public string Purpose { get; set; }
        //public string ApprovedStaffBy { get; set; }
        //public string ApprovedHodBy { get; set; }
        //public DateTime StaffApprovalDate { get; set; }
        //public DateTime HodApprovalDate { get; set; }
        public string CreatedBy { get; set; }

    }
    public class RemoveEventDetailsDTO
    {
        public int EventId { get; set; }
    }
}