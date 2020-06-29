using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class UploadFileDTO
    {
        public int UploadFileId { get; set; }
        public string RegNo { get; set; }
        public string Student { get; set; }
        public string CollegeName { get; set; }
        public string Department { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public string Event { get; set; }
        public string Title { get; set; }
        public DateTime Date { get; set; }
        public string Place { get; set; }
        public string Upload { get; set; }
    }
    public class SaveUploadFileDTO
    {
        public string RegNo { get; set; }
        public string Student { get; set; }
        public string CollegeName { get; set; }
        public string Department { get; set; }
        public string Class { get; set; }
        public string Section { get; set; }
        public string Event { get; set; }
        public string Title { get; set; }
        public DateTime Date { get; set; }
        public string Place { get; set; }
        public string Upload { get; set; }
        public string CreatedBy { get; set; }
    }
}